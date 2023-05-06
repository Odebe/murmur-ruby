# frozen_string_literal: true

module Client
  class Handler
    include ::MessageHandlers::Mixin
    include Repos

    attr_reader :settings, :waiter

    def initialize(stream, rom, settings)
      @waiter   = Async::Waiter.new

      @settings = settings
      @rom      = rom

      @user_id  = nil
      @stream   = stream
      @queue_in = Async::Queue.new
    end

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
          message = @stream.read_message
          break if message.nil?

          with_halt { handle message }
        end
      end
    end

    def to_client_loop
      within_connection do
        @queue_in.each { |message| @stream.send_message(message) }
      end
    end

    def save_user
      @user_id = users.create(queue_in: @queue_in)[:id]
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
      users.delete(@user_id)
    end

    def handle_not_defined(message, handler)
      puts "Undefined message: #{message.inspect} by handler #{handler}"
    end
  end
end
