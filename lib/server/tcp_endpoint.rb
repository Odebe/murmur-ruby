# frozen_string_literal: true

require 'async/io'
require 'async/io/stream'

module Server
  class TcpEndpoint
    attr_reader :endpoint, :app

    def initialize(app)
      @app = app

      cert_file = File.open(app.settings[:ssl][:cert])
      key_file  = File.open(app.settings[:ssl][:key])

      ssl_context      = OpenSSL::SSL::SSLContext.new
      ssl_context.cert = OpenSSL::X509::Certificate.new(cert_file)
      ssl_context.key  = OpenSSL::PKey::RSA.new(key_file)

      @endpoint = Async::IO::Endpoint.ssl(
        app.settings[:host], app.settings[:port],
        ssl_context: ssl_context
      )
    end

    def start!
      endpoint.accept do |socket|
        socket = Async::IO::Stream.new(socket)
        stream = Proto::Stream.new(socket)
        queue  = Async::Queue.new
        client = app.db.clients.create(stream, queue)

        Client::Handler.new(client, app).start!
        socket.close
      end
    end
  end
end
