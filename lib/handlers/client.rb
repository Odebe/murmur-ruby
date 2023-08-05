# frozen_string_literal: true

module Handlers
  # Handler per client (TCP connection)
  class Client < Generic
    option :queue,    default: -> { Async::Queue.new }
    option :finished, default: -> { Async::Condition.new }

    option :stream,     reader: :private, default: -> { Async::IO::Stream.new(io) }
    option :barrier,    reader: :private, default: -> { Async::Barrier.new }
    option :dispatcher, reader: :private, default: -> { Actions::Dispatch }

    option :decoder, reader: :private, default: -> { Proto::Decoder.new(stream) }
    option :client, reader: :private, default: -> { app.db.clients.create(queue, app) }

    def setup!
      client[:timers].every(1) { client[:traffic_shaper].reset! }
    end

    def start!
      start_async_tasks!

      finished.wait
    ensure
      shutdown
    end

    private

    def start_async_tasks!
      barrier.async { loop { client[:timers].wait } }
      barrier.async { from_client_loop }
      barrier.async { to_client_loop }
    end

    # TODO: graceful shutdown
    def shutdown
      barrier.stop

      build_action(::Actions::Disconnect).call
    end

    def from_client_loop
      current_task.annotate 'from client loop'
      current_task.yield

      within_connection do
        loop do
          message = decoder.read_message
          action = dispatcher.call(message)
          action ? build_action(action, message).call : handle_not_defined(message)

          Async::Task.current.yield
        end
      end
    end

    def to_client_loop
      current_task.annotate 'to client loop'
      current_task.yield

      within_connection do
        loop { decoder.send_message(queue.dequeue) }
      end
    end

    def build_action(action, message = nil)
      action.new(self, message, client, app)
    end
  end
end
