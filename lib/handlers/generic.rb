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
      yield
    rescue OpenSSL::SSL::SSLError, EOFError
      # It's okay, client has disconnected.
    rescue StandardError => e
      app.logger.error(e)
    ensure
      finished.signal(:disconnect)
    end

    def handle_not_defined(message)
      puts "[#{self.class.name}] Undefined message: #{message.inspect}"
    end

    def current_task
      Async::Task.current
    end
  end
end
