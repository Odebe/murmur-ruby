# frozen_string_literal: true

module Handlers
  # Handler per client (TCP connection)
  class Client < Generic
    option :queue,    default: -> { Async::Queue.new }
    option :dispatcher, reader: :private, default: -> { Actions::Dispatch }
    option :decoder, reader: :private, default: -> { Decoders::Tcp.new(io) }
    option :client, reader: :private, default: -> { app.db.clients.create(queue, app, io.remote_address) }

    def setup!
      client[:timers].every(1) { client[:traffic_shaper].reset! }
    end

    def start!
      parent_task = Async::Task.current

      parent_task.async do |task|
        task.annotate 'client handler'

        task.async { loop { client[:timers].wait } }
        from = task.async { from_client_loop }
        _to  = task.async { to_client_loop }

        from.wait
      ensure
        task.stop

        build_tcp_action(::Actions::Tcp::Disconnect).call
      end
    end

    private

    def from_client_loop
      current_task.annotate 'from client loop'
      current_task.yield

      within_connection do
        loop do
          message = decoder.read_message
          action = dispatcher.call(message)
          action ? build_tcp_action(action, message: message).call : handle_not_defined(message)
        end
      end
    end

    def to_client_loop
      current_task.annotate 'to client loop'
      current_task.yield

      within_connection do
        loop do
          decoder.send_message(queue.dequeue)
        end
      end
    end
  end
end
