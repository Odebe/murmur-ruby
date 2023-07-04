# frozen_string_literal: true

module Client
  # TODO: refactor to generic UDP packets parser
  class VoicePacket
    attr_reader :target

    def initialize(data)
      @io_in      = AudioStream.new(data.bytes)
      @buffer_out = AudioStream.new

      read_header
      read_sequence_number
      read_payload
    end

    def to_outgoing(session_id:)
      write_header
      write_session_id(session_id)
      write_sequence_number
      write_payload

      @buffer_out.bytes.pack('C*')
    end

    private

    def write_header
      @buffer_out.write(@header)
    end

    def write_session_id(value)
      @buffer_out.write_varint(value)
    end

    def write_sequence_number
      @buffer_out.write_varint(@sequence_number)
    end

    def write_payload
      @buffer_out.write_varint(@payload_header)
      @buffer_out.append(@payload_data)
    end

    def read_payload
      # TODO: CELT payload reading
      raise NotImplementedError if @type != 4

      # OPUS payload reading
      @payload_header = @io_in.read_varint

      len           = @payload_header & 0x1FFF
      _last_frame   = @payload_header & 0x2000
      @payload_data = @io_in.read(len)
    end

    def read_sequence_number
      @sequence_number = @io_in.read_varint
    end

    def read_header
      @header = @io_in.read_byte
      @type   = (@header & 0xe0) >> 5
      @target = @header & 0x1f
    end
  end
end
