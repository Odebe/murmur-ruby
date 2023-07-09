# frozen_string_literal: true

module Actions
  class Base
    extend Dry::Initializer

    param :handler
    param :message
    param :client
    param :app

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

    def build(name, input = {})
      Messages::Registry
        .call(name)
        .new(client, app)
        .call(input)
    end

    def authorize!
      halt! unless db.clients.authorized?(client[:session_id])
    end

    def disconnect!(reason)
      handler.finished.signal(reason)
      halt!
    end

    def halt!
      throw(:halt)
    end

    def reply(message)
      client[:queue] << message
    end

    def post(message, to:)
      to[:queue] << message
    end

    def with_halt(&block)
      catch(:halt, &block)
    end

    def current_async(&block)
      Async::Task.current.async(&block)
    end
  end
end
