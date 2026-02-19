# frozen_string_literal: true

module Decoders
  class Udp < Decoders::Generic
    STREAM_CLASS = Streams::Udp
    UDP_PACKET_SIZE = 1024
    LEGACY_PING_HEADER = "\x00\x00\x00\x00".freeze

    define_mapper(
      0 => ::Proto::MumbleUdp::Audio,
      1 => ::Proto::MumbleUdp::Ping
    )

    def self.encode(msg)
      msg.class.encode(msg)
    end

    def read_encrypted
      data, sender_sockaddr, _rflags, *_controls = stream.receive(UDP_PACKET_SIZE)

      if data.bytesize == 12 && data.byteslice(0, 4) == LEGACY_PING_HEADER
        # legacy ping packet
        packet = ::Udp::Ping.new
        packet.sender_sockaddr = sender_sockaddr
        packet.ident = data.byteslice(4, 8)
        packet
      else
        packet = ::Udp::EncryptedPacket.new
        packet.sender_sockaddr = sender_sockaddr
        packet.data = data
        packet
      end
    end

    def decode(raw)
      type = raw.getbyte(0)
      body = raw.byteslice(1, raw.bytesize - 1)

      klass = find_class(type)
      klass.decode(body)
    end

    def send_message(body, target)
      stream.send(body, 0, target)
    end
  end
end
