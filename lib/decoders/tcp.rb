# frozen_string_literal: true

module Decoders
  class Tcp < Decoders::Generic
    STREAM_CLASS = Streams::Tcp

    define_mapper(
      0 => ::Proto::Mumble::Version,
      1 => ::Proto::Mumble::UDPTunnel,
      2 => ::Proto::Mumble::Authenticate,
      3 => ::Proto::Mumble::Ping,
      4 => ::Proto::Mumble::Reject,
      5 => ::Proto::Mumble::ServerSync,
      6 => ::Proto::Mumble::ChannelRemove,
      7 => ::Proto::Mumble::ChannelState,
      8 => ::Proto::Mumble::UserRemove,
      9 => ::Proto::Mumble::UserState,
      10 => ::Proto::Mumble::BanList,
      11 => ::Proto::Mumble::TextMessage,
      12 => ::Proto::Mumble::PermissionDenied,
      13 => ::Proto::Mumble::ACL,
      14 => ::Proto::Mumble::QueryUsers,
      15 => ::Proto::Mumble::CryptSetup,
      16 => ::Proto::Mumble::ContextActionModify,
      17 => ::Proto::Mumble::ContextAction,
      18 => ::Proto::Mumble::UserList,
      19 => ::Proto::Mumble::VoiceTarget,
      20 => ::Proto::Mumble::PermissionQuery,
      21 => ::Proto::Mumble::CodecVersion,
      22 => ::Proto::Mumble::UserStats,
      23 => ::Proto::Mumble::RequestBlob,
      24 => ::Proto::Mumble::ServerConfig,
      25 => ::Proto::Mumble::SuggestConfig
    )

    PROTO_TYPE_SIZE = 2
    PROTO_LEN_SIZE = 4
    PROTO_HEADER_SIZE = PROTO_TYPE_SIZE + PROTO_LEN_SIZE

    UDP_TUNNEL_TYPE = 1
    AUDIO_UDP_TYPE = 0

    def send_message(msg)
      raw_msg =
        # MumbleUdp::Audio as Mumble::UDPTunnel
        if msg.is_a?(Proto::MumbleUdp::Audio)
          body = Proto::MumbleUdp::Audio.encode(msg)
          packet_len = body.bytesize + 1
          raw = String.new(capacity: packet_len + PROTO_HEADER_SIZE, encoding: Encoding::BINARY)

          raw << [UDP_TUNNEL_TYPE, packet_len, AUDIO_UDP_TYPE].pack('nNC')
          raw << body
        else
          body = msg.class.encode(msg)
          packet_len = body.bytesize
          raw = String.new(capacity: packet_len + PROTO_HEADER_SIZE, encoding: Encoding::BINARY)

          type = find_type(msg.class)

          raw << [type, packet_len].pack('nN')
          raw << body
        end

      stream.send raw_msg
    end

    def read_message
      type = stream.receive(PROTO_TYPE_SIZE).unpack1('n')
      len  = stream.receive(PROTO_LEN_SIZE).unpack1('N')
      body = stream.receive(len)

      # avoiding UdpTunnel message parsing
      if type_eql(type, Proto::Mumble::UDPTunnel)
        ::Proto::MumbleUdp::Audio.decode(body.byteslice(1, body.bytesize - 1))
      else
        find_class(type).decode(body)
      end
    end
  end
end
