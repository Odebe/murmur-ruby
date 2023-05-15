# frozen_string_literal: true

require 'async/io'
require 'async/io/stream'

class Server
  attr_reader :tcp_endpoint, :rom, :settings

  def initialize(settings)
    @settings = settings
  end

  def setup_persistence!
    rom_conf = ROM::Configuration.new(:memory, 'memory://test')
    rom_conf.auto_registration(App.persistence_path)

    @rom = ROM.container(rom_conf)

    Persistence::Repositories::Rooms
      .new(@rom)
      .create_root
  end

  def setup_endpoint!
    ssl_context      = OpenSSL::SSL::SSLContext.new
    ssl_context.cert = OpenSSL::X509::Certificate.new(File.open(settings[:ssl][:cert]))
    ssl_context.key  = OpenSSL::PKey::RSA.new(File.open(settings[:ssl][:key]))

    @tcp_endpoint = Async::IO::Endpoint.ssl(
      settings[:host], settings[:port],
      ssl_context: ssl_context
    )
  end

  def start_tcp!
    tcp_endpoint.accept do |socket|
      socket = Async::IO::Stream.new(socket)
      stream = Proto::Stream.new(socket)

      Client::Handler.new(stream, rom, settings).start!
    end
  end
end
