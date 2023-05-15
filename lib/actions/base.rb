# frozen_string_literal: true

module Actions
  class Base
    extend Dry::Initializer

    include Persistence::Repos

    param :message
    param :stream
    param :state
    param :user_id

    def call
      with_halt { handle(message) }
    end

    def handle(_message)
      raise 'abstract method'
    end

    private

    def message_type
      raise 'abstract method'
    end

    def build(name, input = {})
      Messages::Registry
        .call(name)
        .new(state, stream, user_id)
        .call(input)
    end

    def reply(message)
      stream.send_message message
    end

    def post(message, to:)
      to[:queue_in] << message
    end

    def auth!
      throw :halt unless users.auth?(user_id)
    end

    def with_halt(&block)
      catch(:halt, &block)
    end

    def current_async(&block)
      Async::Task.current.async do
        block.call
      end
    end
  end
end
