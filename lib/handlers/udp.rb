# frozen_string_literal: true

module Handlers
  # Handler per server (UDP socket)
  class Udp < Generic
    option :queue,    default: -> { Async::Queue.new }
    option :finished, default: -> { Async::Condition.new }

    option :barrier,    reader: :private, default: -> { Async::Barrier.new }
    option :dispatcher, reader: :private, default: -> { Actions::Dispatch }

    option :decoder, reader: :private, default: -> { Voice::Decoder.new(io) }

    def setup!
      app.udp_handler = self
    end

    def start!
      start_async_tasks!

      finished.wait
    ensure
      shutdown
    end

    private

    def start_async_tasks!
      barrier.async { from_client_loop }
      barrier.async { to_client_loop }
    end

    # TODO: graceful shutdown
    def shutdown
      barrier.stop
    end

    def from_client_loop
      current_task.annotate 'UDP receiving loop'
      current_task.yield

      within_connection do
        loop do
          message = decoder.read_encrypted
          action = dispatcher.call(message)
          action ? action.new(self, message, nil, app).call : handle_not_defined(message)

          current_task.yield
        end
      end
    end

    def to_client_loop
      current_task.annotate 'UDP sending loop'
      current_task.yield

      within_connection do
        loop do
          msg  = queue.dequeue
          body = ::Voice::Decoder.encode(msg)

          if msg.is_a? Voice::Packet
            client = app.db.clients.by_udp_address(msg.target).to_a.last
            next unless client && client[:crypt_state]

            body = client[:crypt_state].encrypt(body.bytes).pack('C*')
          end

          decoder.send_message(body, msg.target)
        end
      end
    end
  end
end
