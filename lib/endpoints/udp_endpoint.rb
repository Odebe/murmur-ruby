# frozen_string_literal: true

module Endpoints
  class UdpEndpoint
    attr_reader :endpoint, :app

    def initialize(app)
      @app      = app
      @endpoint = IO::Endpoint.udp(app.config.host, app.config.port)
    end

    def start!
      app.logger.info "Starting UDP endpoint at #{app.config.host}:#{app.config.port}"

      endpoint.bind do |socket|
        handler = Handlers::Udp.new(socket, app)
        handler.setup!
        handler.start!
      end
    end

    def stop!
      endpoint.close!
    end
  end
end
