# frozen_string_literal: true

class App
  extend Dry::Initializer

  option :config
  option :db

  option :logger,  default: -> { AsyncLogger.new }
  option :barrier, default: -> { Async::Barrier.new }
  option :trap,    default: -> { Async::IO::Trap.new(Signal.list['INT']) }

  option :tcp, default: -> { Server::TcpEndpoint.new(self) }
  option :udp, default: -> { Server::UdpEndpoint.new(self) }

  option :udp_handler, default: -> {}

  attr_writer :udp_handler

  def setup!
    db.setup!
    trap.install!
  end

  def start!
    logger.start!

    barrier.async { tcp.start! }
    barrier.async { udp.start! }

    barrier.async { trap.wait { stop! } }
    barrier.wait
  end

  def stop!
    tcp.stop!
    udp.stop!

    barrier.stop
  end
end
