# frozen_string_literal: true

require 'concurrent-ruby'

require 'dry-types'
require 'rom'
require 'rom-repository'

require 'async/queue'
require 'async/waiter'
require 'async/io'

require 'zeitwerk'

$loader = Zeitwerk::Loader.new
$loader.push_dir("#{__dir__}/lib")
$loader.setup

settings = {
  host: '127.0.0.1',
  port: 64_738,
  max_bandwidth: 72_000,
  welcome_text: 'Hello world!',
  ssl: {
    cert: 'server.cert',
    key: 'server.key'
  }
}

rom_conf = ROM::Configuration.new(:memory, 'memory://test')
rom_conf.auto_registration("#{__dir__}/lib/persistence/")
rom      = ROM.container(rom_conf)

rooms    = Persistence::Repositories::Rooms.new(rom)
rooms.create_root

$loader.eager_load

ssl_context      = OpenSSL::SSL::SSLContext.new
ssl_context.cert = OpenSSL::X509::Certificate.new(File.open(settings[:ssl][:cert]))
ssl_context.key  = OpenSSL::PKey::RSA.new(File.open(settings[:ssl][:key]))

ssl_endpoint = Async::IO::Endpoint.ssl(
  settings[:host], settings[:port],
  ssl_context: ssl_context
)

Async { Server.new(ssl_endpoint, rom, settings).start! }
