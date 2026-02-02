# frozen_string_literal: true

module Streams
  class Generic
    def initialize(io)
      @io = io
    end

    def send(*args)
      write_nonblock(*args)
    end

    def receive(*args)
      read_nonblock(*args)
    end

    private

    # wrap_nonblock(:recvmsg_nonblock, as: :read_nonblock)
    def self.wrap_nonblock(method_name, as:)
      define_method(as) do |*args|
        result = nil

        loop do
          result = @io.__send__(method_name, *args, exception: false)

          case result
          when :wait_readable
            @io.wait_readable(@io.timeout)
          when :wait_writable
            @io.wait_writable(@io.timeout)
          else
            break
          end
        end

        result
      end
    end
  end
end
