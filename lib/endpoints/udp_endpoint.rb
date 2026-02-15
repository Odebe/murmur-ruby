# frozen_string_literal: true

module Endpoints
  class UdpEndpoint
    attr_reader :endpoint, :app

    def initialize(app)
      @app      = app
      @endpoint = IO::Endpoint.udp(app.config.host, app.config.port)
    end

    def start!
      Async::Task.current.annotate "UDP endpoint"
      app.logger.info "Starting UDP endpoint at #{app.config.host}:#{app.config.port}"

      endpoint.bind do |socket|
        socket.binmode

        handler = Handlers::Udp.new(socket, app)
        handler.setup!
        handler.start!
        handler.wait!
      end
    end

    def stop!
      endpoint.close!
      app.logger.info "UDP endpoint stopped"
    end
  end
end
