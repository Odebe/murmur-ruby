# frozen_string_literal: true

module Decoders
  class Generic
    include Mapping

    def initialize(stream)
      @stream = stream
    end

    def closed?
      @stream.closed?
    end

    def close
      @stream.close
    end

    private

    # wrap_nonblock(:recvmsg_nonblock, as: :read_nonblock)
    def self.wrap_nonblock(method_name, as:)
      define_method(as) do |*args|
        result = nil

        loop do
          result = @stream.__send__(method_name, *args, exception: false)

          case result
          when :wait_readable
            @stream.wait_readable(@stream.timeout)
          when :wait_writable
            @stream.wait_writable(@stream.timeout)
          else
            break
          end
        end

        result
      end
    end
  end
end
