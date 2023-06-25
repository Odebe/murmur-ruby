# frozen_string_literal: true

module Client
  class Handler
    extend Dry::Initializer

    param :client
    param :app

    option :barrier ,   default: -> { Async::Barrier.new }
    option :finished,   default: -> { Async::Condition.new }
    option :dispatcher, default: -> { Actions::Dispatch }

    def start!
      Async::Task.current.annotate "serving session: #{client[:session_id]}"

      barrier.async { from_client_loop }
      barrier.async { to_client_loop }

      finished.wait
      barrier.stop
    end

    private

    def from_client_loop
      Async::Task.current.annotate 'from client loop'

      within_connection do
        loop do
          message = client[:stream].read_message
          break if message.nil?

          action = dispatcher.call(message)
          unless action
            handle_not_defined(message)
            next
          end

          action.new(message, client, app).call

          Async::Task.current.yield
        end
      end
    end

    def to_client_loop
      Async::Task.current.annotate 'to client loop'

      within_connection do
        client[:queue].each { |message| client[:stream].send_message(message) }
      end
    end

    def within_connection
      yield
    rescue EOFError
      # It's okay, client has disconnected.
    ensure
      app.db.clients.delete(client[:session_id])
      finished.signal(:disconnect)
    end

    def handle_not_defined(message)
      puts "Undefined message: #{message.inspect}"
    end
  end
end
