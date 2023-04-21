# frozen-string-literal: true

module Rodbot

  # Dispatcher infrastructure to run and monitor tasks
  class Dispatcher

    # Which signals detached processes trap in order to exit
    TRAPS = %w(INT TERM).freeze

    # @return [String] name of the group of tasks
    attr_reader :group

    # @return [String] registered tasks
    attr_reader :tasks

    # @param group [String] name of the group of tasks
    # @param refork_delay [Integer] seconds to wait before re-forking dead tasks
    def initialize(group, refork_delay: 5)
      @group, @refork_delay = group, refork_delay
      @tasks = {}
    end

    # Register a task
    #
    # @param task [String] task name
    # @yield block for the task to run
    # @return self
    def register(task)
      tasks[task] = Proc.new do
        detach task
        unless Rodbot::Log.std?
          logger = Rodbot::Log.logger("dispatcher #{group}.#{task}]")
          $stdout = Rodbot::Log::LoggerIO.new(logger, Logger::INFO)
          $stderr = Rodbot::Log::LoggerIO.new(logger, Logger::WARN)
          $stdin.reopen(File::NULL)
        end
        yield
      end
      self
    end

    # Run and monitor the registered tasks
    #
    # @param daemonize [Boolean] whether to run the tasks in the background
    def run(daemonize: false)
      cleanup
      if daemonize
        Process.daemon(false, true)
        detach 'monitor'
      else
        Process.setproctitle("#{group}.monitor")
      end
      dispatch
      monitor
    ensure
      cleanup
    end

    # Interrupt the registered tasks
    def interrupt
      Process.kill('INT', pid_file('monitor').read.to_i)
    rescue Errno::ESRCH
    end

    private

    # Dispatch all registered tasks
    def dispatch
      tasks.each_value { fork &_1 }
    end

    # Monitor all dispatched tasks
    def monitor
      loop do
        pid = Process.wait
        sleep @refork_delay
        fork &tasks[task(pid)]
      end
    end

    # Remove all artefacts
    def cleanup
      Rodbot.env.tmp.glob("#{group}.*.pid").each do |pid_file|
        pid = pid_file.read.to_i
        Process.kill('INT', pid) unless pid == Process.pid
      rescue Errno::ESRCH
      ensure
        pid_file.delete
      end
    end

    # Perform operations to properly detach the task
    #
    # @param task [String] task name
    def detach(task)
      pid_file(task).write Process.pid
      Process.setproctitle("#{group}.#{task}")
      TRAPS.each { trap(_1) { exit } }
    end

    # PID file of the given task should be
    #
    # @param task [String] task name
    # @return [Pathname] PID file
    def pid_file(task)
      Rodbot.env.tmp.join("#{group}.#{task}.pid")
    end

    # Fetch a task name for a process ID from the PID files
    #
    # @param pid [Integer] process ID
    # @return [String] task name
    def task(pid)
      Rodbot.env.tmp.glob("#{group}.*.pid").find do |pid_file|
        pid_file.read.to_i == pid
      end.then do |pid_file|
        pid_file.basename.to_s.split('.')[1] if pid_file
      end
    end

  end
end
