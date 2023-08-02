require_relative '../../spec_helper'

describe Rodbot::Dispatcher do
  subject do
    Rodbot::Dispatcher.new('rodbot-test', refork_delay: 0)
  end

  describe :register do
    it "adds a task name and proc to @tasks and returns self" do
      _(subject.register('serve')).must_be_instance_of Rodbot::Dispatcher
      _(subject.tasks).must_be_instance_of Hash
      _(subject.tasks.count).must_equal 1
      _(subject.tasks.keys.first).must_equal 'serve'
      _(subject.tasks.values.first).must_be_instance_of Proc
      _(subject.tasks.values.first.arity).must_equal 0
    end
  end

  describe :run do
    let :tmp do
      Rodbot.env.tmp
    end

    after do
      tmp.glob('rodbot-test.*.run').each(&:delete)
      tmp.glob('rodbot-test.*.pid').each do |pid_file|
        interrupt_task(pid_file.read, force: true)
        pid_file.delete
      end
      `ps axo command=,pid=`.split("\n").grep(/^rodbot-test\./).each do |ps|
        pid = ps.split(/\s+/).last.to_i
        interrupt_task(pid , force: true) unless pid == Process.pid
      end
    end

    it "runs, supervises and terminates tasks" do
      2.times do |index|
        subject.register(index.to_s) do
          tmp.join("rodbot-test.#{index}.run").write 'running'
          sleep
        end
      end
      _(subject.tasks.count).must_equal 2
      print ':'
      run_thread = Thread.new do
        subject.run
      end
      sleep 0.1
      _(tmp.glob('rodbot-test.*.run').map { _1.basename.to_s }).must_equal %w(rodbot-test.0.run rodbot-test.1.run)
      print ':'
      all_tasks_running_spec
      interrupt_task(tmp.join('rodbot-test.0.pid').read)
      sleep 0.1
      all_tasks_running_spec
      run_thread.kill
      sleep 0.1
      _(tmp.glob('rodbot-test.*.pid').count).must_be :zero?
      print ':'
    end
  end

  describe :pid_file do
    it "returns an absolute pathname" do
      _(subject.send(:pid_file, 'foo').to_s).must_match(%r(/tmp/rodbot-test.foo.pid$))
    end
  end

  def all_tasks_running_spec
    pid_files = tmp.glob('rodbot-test.*.pid')
    _(pid_files.map { _1.basename.to_s }).must_equal %w(rodbot-test.0.pid rodbot-test.1.pid)
    print ':'
    pid_files.each do |pid_file|
      _(task_running?(pid_file.read)).must_equal true
      print ':'
    end
  end

  def task_running?(pid)
    Process.kill(0, pid.to_i)
    true
  rescue Errno::ESRCH
    false
  end

  def interrupt_task(pid, force: false)
    Process.kill((force ? 'KILL' : 'INT'), pid.to_i)
  rescue Errno::ESRCH
  end
end
