# frozen_string_literal: true

class App
  extend Dry::Initializer

  option :config
  option :db

  option :logger,  default: -> { AsyncLogger.new }
  option :barrier, default: -> { Async::Barrier.new }

  option :tcp, default: -> { Server::TcpEndpoint.new(self) }
  option :udp, default: -> { Server::UdpEndpoint.new(self) }

  option :udp_handler, default: -> {}

  attr_writer :udp_handler

  def setup!
    db.setup!
  end

  def start!
    logger.start!

    barrier.async { tcp.start! }
    barrier.async { udp.start! }
    barrier.wait
  end
end
