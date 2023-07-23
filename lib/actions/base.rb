# frozen_string_literal: true

module Actions
  class Base
    attr_reader :handler, :message, :client, :app

    # We initialize a lot of instances so avoiding dry-initializer
    def initialize(handler, message, client, app)
      @handler = handler
      @message = message
      @client  = client
      @app     = app
    end

    def call
      with_halt { handle }
    end

    def handle
      raise 'abstract method'
    end

    private

    def message_type
      raise 'abstract method'
    end

    def db
      app.db
    end

    def disconnect!(reason)
      handler.finished.signal(reason)
      halt!
    end

    def halt!
      throw(:halt)
    end

    def with_halt(&block)
      catch(:halt, &block)
    end

    def current_async(&block)
      Async::Task.current.async(&block)
    end
  end
end
