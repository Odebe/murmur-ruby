# frozen_string_literal: true

module Actions
  class Base
    extend Dry::Initializer
    extend Dry::Core::ClassAttributes

    include Persistence::Repos

    defines :dispatcher

    dispatcher Actions::Dispatch

    param :message
    param :rom
    param :stream
    param :settings
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
