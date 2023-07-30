# frozen_string_literal: true

module Voice
  class Packet
    class Voice < Packet
      def size
        # first is header byte
        1 +
          varint_size(@sequence_number) +
          varint_size(@session_id) +
          varint_size(@payload_header) +
          @payload_len
      end
    end
  end
end
