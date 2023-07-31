# frozen_string_literal: true

module Voice
  class Packet
    class Ping < Packet
      def decode(stream)
        @timestamp = stream.read(8)
        @decoded = true
      end

      def encode(stream)
        stream.write(@header)
        stream.write(@timestamp)

        true
      end
    end
  end
end
