# frozen_string_literal: true

module Decoders
  class Tcp < Decoders::Generic
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

    def send_message(msg)
      body = msg.is_a?(Proto::Mumble::UDPTunnel) ? msg.packet : msg.class.encode(msg)

      raw_msg =
        [
          [find_type(msg.class)].pack('n'),
          [body.size].pack('N'),
          body
        ].join

      write raw_msg
      flush
    end

    def read_message
      type = read(2).unpack1('n')
      len  = read(4).unpack1('N')
      body = read(len)

      # avoiding UdpTunnel message parsing
      # cuz message body is literally voice packet and not protobuf message
      if type_eql(type, Proto::Mumble::UDPTunnel)
        Proto::Mumble::UDPTunnel.new(packet: body)
      else
        find_class(type).decode(body)
      end
    end

    private

    ############################################################

    wrap_nonblock(:read_nonblock, as: :read_nonblock)
    wrap_nonblock(:write_nonblock, as: :write_nonblock)

    def read(size)
      read_nonblock(size) or @stream.eof!
    end

    def write(body)
      write_nonblock(body)
    end

    def flush
      @stream.flush
    end
  end
end
