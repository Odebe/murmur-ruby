# frozen_string_literal: true

module Decoders
  class Generic
    include Mapping

    attr_reader :stream

    def initialize(io)
      @stream = self.class.const_get(:STREAM_CLASS).new(io)
    end
  end
end
