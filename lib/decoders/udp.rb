# frozen_string_literal: true

module Decoders
  class Udp < Decoders::Generic
    define_mapper(
      0 => ::Proto::MumbleUdp::Audio,
      1 => ::Proto::MumbleUdp::Ping
    )

    UDP_PACKET_SIZE = 1024

    wrap_nonblock(:recvmsg_nonblock, as: :read_nonblock)
    wrap_nonblock(:sendmsg_nonblock, as: :write_nonblock)

    def read_encrypted
      data, sender_sockaddr, _rflags, *_controls = read_nonblock(UDP_PACKET_SIZE)

      encrypted = StringIO.new(data).binmode
      crypt_header = encrypted.read(4).bytes

      if data.size == 12 && crypt_header == [0, 0, 0, 0]
        # legacy ping packet
        packet = ::Udp::Ping.new
        packet.sender_sockaddr = sender_sockaddr
        packet.ident = encrypted.read(8)
        packet
      else
        packet = ::Udp::RawPacket.new
        packet.sender_sockaddr = sender_sockaddr
        packet.data = data
        packet
      end
    end

    def decode(raw)
      type = raw[0].unpack1('C')
      klass = find_class(type)
      body = raw[1..-1]

      klass.decode(body)
    end

    def send_message(body, target)
      write_nonblock(body, 0, target)
    end

    def self.encode(msg)
      msg.class.encode(msg)
    end
  end
end
