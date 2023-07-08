# frozen_string_literal: true

module Client
  # https://github.com/mumble-voip/mumble/blob/master/src/PacketDataStream.h
  # https://github.com/umurmur/umurmur/blob/master/src/pds.c
  class VoiceStream < Async::IO::Protocol::Generic
    def write(value)
      return @stream.write(value) if value.is_a? String

      @stream.write [value].flatten.pack('C*')
    end

    def write_varint(value)
      i = value

      if (value & 0x8000000000000000) > 0 && ~value < 0x100000000
        # Signed number.
        i = ~i

        if i <= 0x3
          # Shortcase for -1 to -4
          write(0xFC | i)
          return
        else
          write(0xF8)
        end
      end

      if i < 0x80
        # Need top bit clear
        write(i)
      elsif i < 0x4000
        # Need top two bits clear
        write((i >> 8) | 0x80)
        write(i & 0xFF)
      elsif i < 0x200000
        write((i >> 16) | 0xC0)
        write((i >> 8) & 0xFF)
        write(i & 0xFF)
      elsif i < 0x100000000
        # It's a full 32-bit integer.
        write(0xF0)
        write((i >> 24) & 0xFF)
        write((i >> 16) & 0xFF)
        write((i >> 8) & 0xFF)
        write(i & 0xFF)
      else
        # It's a 64-bit value.
        write(0xF4)
        write((i >> 56) & 0xFF)
        write((i >> 48) & 0xFF)
        write((i >> 40) & 0xFF)
        write((i >> 32) & 0xFF)
        write((i >> 24) & 0xFF)
        write((i >> 16) & 0xFF)
        write((i >> 8) & 0xFF)
        write(i & 0xFF)
      end
    end

    def read(n)
      n.times.map { read_byte }
    end

    def read_byte
      @stream.getbyte
    end

    def read_varint
      i = 0
      v = read_byte

      if (v & 0x80) == 0x00
        i = v & 0x7F
      elsif (v & 0xC0) == 0x80
        i = ((v & 0x3F) << 8) | read_byte
      elsif (v & 0xF0) == 0xF0
        case v & 0xFC
        when 0xF0
          i = read_varint_bytes(4)
        when 0xF4
          i = read_varint_bytes(8)
        when 0xF8
          i = ~read_varint
        when 0xFC
          i = ~(v & 0x03)
        else
          i = 0
        end
      elsif (v & 0xF0) == 0xE0
        i = (v & 0x0F) << 24 | read_varint_bytes(3)
      elsif (v & 0xE0) == 0xC0
        i = (v & 0x1F << 16) | read_varint_bytes(2)
      end

      i
    end

    private

    # read_byte << 56 | read_byte << 48 | read_byte << 40 | ...
    def read_varint_bytes(count)
      result = 0
      (count - 1).downto(0).each do |i|
        result |= read_byte << (i * 8)
      end
      result
    end
  end
end
