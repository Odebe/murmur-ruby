# frozen_string_literal: true

module Handlers
  # Generic handler
  class Generic
    extend Dry::Initializer

    param :io
    param :app

    def setup!
      raise 'abstract method'
    end

    def start!
      raise 'abstract method'
    end

    private

    def within_connection
      retries = 0

      begin
        yield
      rescue OpenSSL::SSL::SSLError, EOFError, Errno::ECONNRESET
        # It's okay, client has disconnected.
      rescue StandardError => e
        app.logger.error(e)

        retries += 1
        retry if retries < 3
      ensure
        finished.signal(:disconnect)
      end
    end

    def handle_not_defined(message)
      puts "[#{self.class.name}] Undefined message: #{message.inspect}"
    end

    def current_task
      Async::Task.current
    end

    # TODO: make consistent tcp and udp actions
    def build_tcp_action(action, target_client: client, message: nil)
      action.new(self, message, target_client, app)
    end
  end
end
