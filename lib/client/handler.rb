# frozen_string_literal: true

module Client
  class Handler
    include ::MessageHandlers::Mixin
    include Repos

    def initialize(stream, rom)
      @stream  = stream
      @rom     = rom
      @user_id = nil
    end

    def start!
      save_user
      handle_loop
    end

    private

    def save_user
      @user_id = users.create[:id]
    end

    def handle_loop
      within_connection do
        loop do
          message = @stream.read_message
          break if message.nil?

          with_halt { handle message }
        end
      end
    end

    def with_halt(&block)
      catch(:halt, &block)
    end

    def current_async(&block)
      Async::Task.current.async do
        block.call
      end
    end

    def within_connection
      yield
    rescue EOFError
      # It's okay, client has disconnected.
    end

    def handle_not_defined(message, handler)
      puts "Undefined message: #{message.inspect} by handler #{handler}"
    end
  end
end
