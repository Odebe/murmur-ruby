# frozen_string_literal: true

module Voice
  class Decoder < GenericDecoder
    UDP_PACKET_SIZE = 1024

    VOICE_DICT = {
      0 => Packet::CeltAlpha,
      1 => Packet::Ping,
      2 => Packet::Speex,
      3 => Packet::CeltBeta,
      4 => Packet::Opus
    }.freeze

    def self.read_decrypted(raw)
      buffer = StringIO.new(raw).binmode
      stream = VarintStream.new(buffer)

      header = stream.read_byte
      type   = (header & 0xe0) >> 5

      packet_klass = VOICE_DICT.fetch(type) { raise NotImplementedError, "type: #{type}" }

      packet = packet_klass.new(header)
      packet.decode(stream)
      packet
    end

    def self.encode(msg)
      buffer = StringIO.new.binmode
      stream = VarintStream.new(buffer)

      msg.encode(stream)

      buffer.string
    end

    def read_encrypted
      data, sender_sockaddr, _rflags, *_controls = @stream.recvmsg(UDP_PACKET_SIZE)

      encrypted = StringIO.new(data).binmode
      crypt_header = encrypted.read(4).bytes

      packet_klass =
        if data.size == 12 && crypt_header == [0, 0, 0, 0]
          Udp::Ping
        else
          Udp::Encrypted
        end

      packet = packet_klass.new(sender: sender_sockaddr)
      packet.decode(encrypted)
      packet
    end

    def send_message(body, target)
      @stream.send body, 0, target
    end
  end
end
