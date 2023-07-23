# frozen_string_literal: true

module Voice
  class Packet
    attr_accessor :target, :sender, :session_id

    def initialize(header)
      @header     = header
      @decoded    = false
      @sender     = nil
      @session_id = nil
    end

    def with_target(new_target)
      new_self = self.clone
      new_self.target = new_target
      new_self
    end

    def decode(_stream)
      raise 'abstract method'
    end

    def type
      (@header & 0xe0) >> 5
    end

    def header_target
      @header & 0x1f
    end

    private

    def varint_size(value)
      size = 0

      if (value & 0x8000000000000000).positive? && ~value < 0x100000000
        size += 1

        return size if value <= 0x3
      end

      if value < 0x80
        size + 1
      elsif value < 0x4000
        size + 2
      elsif value < 0x200000
        size + 3
      elsif value < 0x10000000
        size + 4
      elsif value < 0x100000000
        size + 5
      else
        size + 9
      end
    end
  end
end
