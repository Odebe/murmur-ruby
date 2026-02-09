# frozen_string_literal: true

class Server
  extend Dry::Initializer

  option :config
  option :db

  option :logger,  default: -> { AsyncLogger.new }
  option :barrier, default: -> { Async::Barrier.new }
  option :trap,    default: -> { Async::IO::Trap.new('INT') }

  option :tcp, default: -> { Endpoints::TcpEndpoint.new(self) }
  option :udp, default: -> { Endpoints::UdpEndpoint.new(self) }

  option :udp_handler, default: -> {}

  attr_writer :udp_handler

  def setup!
    db.setup!
    # trap.install!
  end

  def start!
    Async do |task|
      task.async { logger.start! }
      task.async { tcp.start! }
      task.async { udp.start! }

      task.sleep
    end
  ensure
    # TODO: graceful shutdown
    stop!
  end

  def stop!
    tcp.stop!
    udp.stop!
  end
end
