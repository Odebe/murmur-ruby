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

    def udp?
      raise "abstract method"
    end

    def tcp?
      raise "abstract method"
    end

    def reply(_message)
      raise 'abstract method'
    end

    def send_tcp(message, to:)
      to[:tcp_queue] << message
    end

    def send_udp(message, to:)
      app.udp_handler.queue << [to[:udp_address], message]
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
  end
end
