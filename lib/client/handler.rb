# frozen_string_literal: true

module Client
  class Handler
    extend Dry::Initializer

    include Persistence::Repos

    param :stream
    param :state

    option :waiter,     default: -> { Async::Waiter.new }
    option :queue_in,   default: -> { Async::Queue.new }
    option :dispatcher, default: -> { Actions::Dispatch }
    option :user_id,    default: -> { nil }

    def start!
      save_user
      main_loop
    end

    private

    def main_loop
      waiter.async { from_client_loop }
      waiter.async { to_client_loop }
      waiter.wait
    end

    def from_client_loop
      within_connection do
        loop do
          message = stream.read_message
          break if message.nil?

          action = dispatcher.call(message)
          unless action
            handle_not_defined(message)
            next
          end

          action.new(message, stream, state, user_id).call
        end
      end
    end

    def to_client_loop
      within_connection do
        queue_in.each { |message| stream.send_message(message) }
      end
    end

    def save_user
      @user_id = users.create(queue_in: queue_in)[:id]
    end

    def within_connection
      yield
    rescue EOFError
      # It's okay, client has disconnected.
    ensure
      users.delete(user_id)
    end

    def handle_not_defined(message)
      puts "Undefined message: #{message.inspect}"
    end
  end
end
