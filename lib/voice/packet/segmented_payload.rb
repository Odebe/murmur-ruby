# frozen_string_literal: true

module Voice
  class Packet
    module SegmentedPayload
      def size
        # first is header byte
        1 +
          varint_size(@sequence_number) +
          varint_size(@session_id) +
          @frames.sum { |(_, payload)| 1 + payload.size }
      end

      def decode(stream)
        @sequence_number = stream.read_varint
        @frames = []

        loop do
          frame_header = stream.read_byte
          len = frame_header & 0x7F

          @frames <<
            if stream.size < len
              [frame_header, []]
            else
              [frame_header, stream.read(len)]
            end

          break if (frame_header & 0x80) != 0x80
        end

        true
      end

      def encode(stream)
        stream.write(@header)
        stream.write_varint(@session_id)
        stream.write_varint(@sequence_number)

        @frames.each do |(frame_header, payload)|
          stream.write(frame_header)
          stream.write(payload) if payload
        end

        true
      end
    end
  end
end
