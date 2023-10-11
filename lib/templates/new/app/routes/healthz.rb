module Routes
  class Healthz < App

    route do |r|

      # GET /healthz
      r.root do
        response['Content-Type'] = 'text/plain; charset=utf-8'
        'alive and kicking'
      end

    end

  end
end
