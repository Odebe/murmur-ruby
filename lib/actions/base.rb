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

    def reply(message)
      if message.udp?
        target = client.blank? ? message.sender : client[:udp_address]

        app.udp_handler.queue << message.with_target(target)
      else
        client[:tcp_queue] << message
      end
    end

    def post(message, to:)
      if message.udp? && to[:udp_address]
        app.udp_handler.queue << message.with_target(to[:udp_address])
      else
        to[:tcp_queue] << message
      end
    end

    def authorize!
      halt! unless db.clients.authorized?(client[:session_id])
    end

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
