# frozen_string_literal: true

module Client
  class Handler
    extend Dry::Initializer

    param :client
    param :app

    option :barrier,      default: -> { Async::Barrier.new }
    option :finished,     default: -> { Async::Condition.new }
    option :dispatcher,   default: -> { Actions::Dispatch }

    def start!
      barrier.async { from_client_loop }
      barrier.async { to_client_loop }

      finished.wait
      shutdown
    end

    private

    # TODO: graceful shutdown
    def shutdown
      barrier.stop
      app.db.clients.delete(client[:session_id])
    end

    def from_client_loop
      current_task.annotate 'from client loop'
      current_task.yield

      within_connection do
        stream_loop do
          message = client[:stream].read_message
          action = dispatcher.call(message)

          unless action
            handle_not_defined(message)
            next
          end

          action.new(self, message, client, app).call
        end
      end
    end

    def to_client_loop
      current_task.annotate 'to client loop'
      current_task.yield

      within_connection do
        stream_loop do
          client[:stream].send_message(client[:queue].dequeue)
        end
      end
    end

    def stream_loop
      loop do
        yield
        Async::Task.current.yield
      end
    end

    def within_connection
      yield
    rescue OpenSSL::SSL::SSLError
      # It's okay, client has disconnected.
      finished.signal(:disconnect)
    rescue StandardError => error
      raise error
    else
      finished.signal(:disconnect)
    end

    def handle_not_defined(message)
      puts "Undefined message: #{message.inspect}"
    end

    def current_task
      Async::Task.current
    end
  end
end
