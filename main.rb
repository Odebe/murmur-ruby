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

if ENV['DEBUG']
  require 'async/debug'
  require 'byebug'
end

require_relative 'lib/app'

app = App.new
app.setup!

server = Server::TcpEndpoint.new(app)

Async do
  Async::Debug.serve if ENV['DEBUG']
  server.start!
end
