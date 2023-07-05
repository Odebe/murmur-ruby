# frozen_string_literal: true

require 'concurrent-ruby'

require 'dry/core/class_attributes'
require 'dry-types'
require 'dry-initializer'

require 'rom'
require 'rom-yaml'

require 'async/io'
require 'async/queue'
require 'async/barrier'
require 'async/condition'

require_relative 'lib/configurator'

app          = Configurator.call
tcp_endpoint = Server::TcpEndpoint.new(app)

require 'async/debug' if app.config.debug_web

Sync do
  Async::Debug.serve if app.config.debug_web

  app.start!
  tcp_endpoint.start!
end
