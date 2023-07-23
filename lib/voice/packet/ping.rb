# frozen_string_literal: true

module Voice
  class Packet
    class Ping < Packet
      def decode(stream)
        @timestamp = stream.read_varint
        @decoded = true
      end

      def encode(stream)
        stream.write(@header)
        stream.write_varint(@timestamp)

        true
      end
    end
  end
end
