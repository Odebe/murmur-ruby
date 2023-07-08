# frozen_string_literal: true

module Client
  class Handler
    extend Dry::Initializer

    param :client
    param :app

    option :barrier,    default: -> { Async::Barrier.new }
    option :finished,   default: -> { Async::Condition.new }
    option :dispatcher, default: -> { Actions::Dispatch }

    def setup!
      # avoiding app.config.debug check in runtime
      return unless app.config.debug

      define_singleton_method(:read_client_message) do
        client[:stream].read_message.tap do |message|
          app.logger.debug("<< #{message.inspect}")
        end
      end

      define_singleton_method(:read_server_message) do
        client[:queue].dequeue.tap do |message|
          app.logger.debug(">> #{message.inspect}")
        end
      end
    end

    def start!
      barrier.async { from_client_loop }
      barrier.async { to_client_loop }

      finished.wait
    ensure
      shutdown
    end

    private

    # TODO: graceful shutdown
    def shutdown
      barrier.stop

      build_action(::Actions::Disconnect).call
    end

    def from_client_loop
      current_task.annotate 'from client loop'
      current_task.yield

      within_connection do
        stream_loop do
          message = read_client_message
          action = dispatcher.call(message)
          action ? build_action(action, message).call : handle_not_defined(message)
        end
      end
    end

    def to_client_loop
      current_task.annotate 'to client loop'
      current_task.yield

      within_connection do
        stream_loop do
          client[:stream].send_message(read_server_message)
        end
      end
    end

    def build_action(action, message = nil)
      action.new(self, message, client, app)
    end

    def read_client_message
      client[:stream].read_message
    end

    def read_server_message
      client[:queue].dequeue
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
    rescue StandardError => e
      app.logger.error(e)
    ensure
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
