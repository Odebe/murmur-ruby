# frozen_string_literal: true

module Voice
  class Packet
    class Opus < Voice
      def decode(stream)
        @sequence_number = stream.read_varint
        @payload_header  = stream.read_varint

        @payload_len  = @payload_header & 0x1FFF
        @last_frame   = @payload_header & 0x2000
        @payload_data = stream.read(@payload_len)

        @decoded = true
        true
      end

      def encode(stream)
        stream.write(@header)
        stream.write_varint(@session_id)
        stream.write_varint(@sequence_number)
        stream.write_varint(@payload_header)
        stream.write(@payload_data)

        true
      end
    end
  end
end
