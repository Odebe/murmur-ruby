# frozen_string_literal: true

module Client
  class Handler
    extend Dry::Initializer

    param :client
    param :app

    option :barrier,    default: -> { Async::Barrier.new }
    option :finished,   default: -> { Async::Condition.new }
    option :dispatcher, default: -> { Actions::Dispatch }
    option :timers,     default: -> { Timers::Group.new }

    # rubocop:disable Metrics/AbcSize
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
    # rubocop:enable Metrics/AbcSize

    def start!
      schedule_timers!
      start_async_tasks!

      finished.wait
    ensure
      shutdown
    end

    private

    def schedule_timers!
      timers.every(1) { client[:traffic_shaper].reset! }
    end

    def start_async_tasks!
      barrier.async { loop { timers.wait } }
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
          message = read_client_message
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
        loop { client[:stream].send_message(read_server_message) }
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
