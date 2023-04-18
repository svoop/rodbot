class Application
  hash_branch('bot') do |r|

    return unless local?

    # GET /bot/help
    r.get 'help' do
      response['Content-Type'] = 'text/markdown; charset=utf-8'
      <<~END
        <SENDER> I'm [Analoges Halluzinelle](https://www.youtube.com/watch?v=A9D_PlfpBH4&t=165s), your friendly neighbourhood bot. What can I do for you today?

        * `!stock list` – list all registered stock alerts
        * `!stock add <SYMBOL> limit <LIMIT>` – alert when stock crosses the LIMIT
        * `!stock add <SYMBOL> delta <DELTA>` – alert when stock shifts by DELTA percent within 5 minutes
        * `!stock remove <ALERT>` – remove particular alert
        * `!stock remove <SYMBOL>` – remove all alerts for stock
        * `!stock remove all` – remove all alerts
      END
    end

    # GET /bot/stock
    r.get 'stock' do
      response['Content-Type'] = 'text/markdown; charset=utf-8'
      arguments = r.params['argument'].split(/\s+/)
      case arguments.first
      when 'list'
        ''
      when 'add'
        ''
      when 'remove'
        ''
      end
    end

    # GET /bot/hal
    r.get 'hal' do
      response['Content-Type'] = 'text/markdown; charset=utf-8'
      <<~END
        [🔴](https://www.youtube.com/watch?v=ARJ8cAGm6JE) I'm sorry <SENDER>, I'm afraid I can't do that.
      END
    end

  end
end
