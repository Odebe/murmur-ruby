# frozen_string_literal: true

require 'async/io'
require 'async/io/stream'

module Server
  class UdpEndpoint
    attr_reader :endpoint, :app

    UDP_PACKET_SIZE = 1024

    def initialize(app)
      @app      = app
      @endpoint = Async::IO::Endpoint.udp(app.config.host, app.config.port)
    end

    def start!
      app.logger.info "Starting UDP endpoint at #{app.config.host}:#{app.config.port}"

      endpoint.bind do |socket|
        handler = Handlers::Udp.new(socket, app)
        handler.setup!
        handler.start!
      end
    end
  end
end
