# frozen_string_literal: true

module Decoders
  # TODO: refactor this mess
  class Udp < Decoders::Generic
    define_mapper(
      0 => ::Proto::MumbleUdp::Audio,
      1 => ::Proto::MumbleUdp::Ping
    )

    UDP_PACKET_SIZE = 1024

    VOICE_DICT = {
      0 => Voice::Packet::CeltAlpha,
      1 => Voice::Packet::Ping,
      2 => Voice::Packet::Speex,
      3 => Voice::Packet::CeltBeta,
      4 => Voice::Packet::Opus
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

    wrap_nonblock(:recvmsg_nonblock, as: :read_nonblock)
    wrap_nonblock(:sendmsg_nonblock, as: :write_nonblock)

    def read_encrypted
      data, sender_sockaddr, _rflags, *_controls = read_nonblock(UDP_PACKET_SIZE)

      encrypted = StringIO.new(data).binmode
      crypt_header = encrypted.read(4).bytes

      if data.size == 12 && crypt_header == [0, 0, 0, 0]
        # legacy ping packet
        packet = ::Udp::Ping.new(sender: sender_sockaddr)
        packet.decode(encrypted)
        packet
      else
        ::Udp::RawPacket.new(data, sender_sockaddr)
      end
    end

    def decode(raw)
      type = raw[0].unpack1('C')
      find_class(type).decode(raw[1..-1])
    end

    def send_message(body, target)
      write_nonblock(body, 0, target)
    end
  end
end
