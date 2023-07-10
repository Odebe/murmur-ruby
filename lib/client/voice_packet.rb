# frozen_string_literal: true

module Client
  class VoicePacket
    include Mixins::VarintSize

    attr_reader :target

    def initialize(session_id)
      @session_id = session_id
      @decoded    = false
    end

    # TODO: return varint size from stream when reading
    def size
      return 0 unless @decoded

      # first is header byte
      1 +
        varint_size(@sequence_number) +
        varint_size(@session_id) +
        varint_size(@payload_header) +
        @payload_len
    end

    def decode_from(stream)
      @header = stream.read_byte
      @type   = (@header & 0xe0) >> 5
      @target = @header & 0x1f

      @sequence_number = stream.read_varint

      # TODO: CELT payload reading
      # TODO: udp ping reading
      raise NotImplementedError if @type != 4

      # OPUS payload reading
      @payload_header = stream.read_varint

      @payload_len  = @payload_header & 0x1FFF
      @last_frame   = @payload_header & 0x2000
      @payload_data = stream.read(@payload_len)

      @decoded = true
      true
    end

    def encode_to(stream)
      stream.write(@header)
      stream.write_varint(@session_id)
      stream.write_varint(@sequence_number)
      stream.write_varint(@payload_header)
      stream.write(@payload_data)

      true
    end
  end
end
