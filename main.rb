# frozen_string_literal: true

require 'async/io'
require 'zeitwerk'

$loader = Zeitwerk::Loader.new
$loader.push_dir("#{__dir__}/lib")
$loader.setup
$loader.eager_load

settings = {
  host: '127.0.0.1',
  port: 64_738,
  ssl: {
    cert: 'cert.pem',
    key: 'key.pem'
  }
}

ssl_context      = OpenSSL::SSL::SSLContext.new
ssl_context.cert = OpenSSL::X509::Certificate.new(File.open(settings[:ssl][:cert]))
ssl_context.key  = OpenSSL::PKey::RSA.new(File.open(settings[:ssl][:key]))

endpoint = Async::IO::SSLEndpoint.tcp(
  settings[:host],
  settings[:port],
  reuse_port: true
)

ssl_endpoint = Async::IO::SSLEndpoint.new(
  endpoint,
  ssl_context: ssl_context
)

Server.new(ssl_endpoint).start!
