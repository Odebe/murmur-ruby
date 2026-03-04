# frozen_string_literal: true

module Decoders
  class Generic
    include Mapping

    attr_reader :stream, :msg_buffer

    def initialize(io)
      @stream = self.class.const_get(:STREAM_CLASS).new(io)
      @msg_buffer = String.new(capacity: 1024, encoding: Encoding::BINARY)
    end
  end
end
