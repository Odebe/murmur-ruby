# frozen_string_literal: true

require 'async/io'
require 'async/io/stream'

module Server
  class TcpEndpoint
    attr_reader :endpoint, :app

    # rubocop:disable Metrics/AbcSize
    def initialize(app)
      @app = app

      cert_file = File.open(app.config.ssl_cert)
      key_file  = File.open(app.config.ssl_key)

      ssl_context = OpenSSL::SSL::SSLContext.new

      ssl_context.cert = OpenSSL::X509::Certificate.new(cert_file)
      ssl_context.key  = OpenSSL::PKey::RSA.new(key_file)
      ssl_context.ca_file = app.config.ssl_ca

      ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER unless app.config.ssl_allow_selfsigned

      ssl_context.ciphers = ['AES256-SHA']
      ssl_context.min_version = OpenSSL::SSL::TLS1_VERSION
      ssl_context.options |= OpenSSL::SSL::OP_NO_SSLv2
      ssl_context.options |= OpenSSL::SSL::OP_NO_SSLv3

      @endpoint = Async::IO::Endpoint.ssl(
        app.config.host, app.config.port,
        ssl_context: ssl_context
      )
    end
    # rubocop:enable Metrics/AbcSize

    def start!
      app.logger.info "Starting TCP endpoint at #{app.config.host}:#{app.config.port}"

      endpoint.accept do |socket|
        handler = Handlers::Client.new(socket, app)
        handler.setup!
        handler.start!
      end
    end

    def stop!
      endpoint.close!
    end
  end
end
