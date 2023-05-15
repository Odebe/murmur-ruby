# frozen_string_literal: true

module Proto
  module Dicts
    TYPE_TO_CLASS = {
      0 => ::Proto::Mumble::Version,
      1 => ::Proto::Mumble::UDPTunnel,
      2 => ::Proto::Mumble::Authenticate,
      3 => ::Proto::Mumble::Ping,
      4 => ::Proto::Mumble::Reject,
      5 => ::Proto::Mumble::ServerSync,
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
    }.freeze

    CLASS_TO_TYPE = TYPE_TO_CLASS.invert.freeze
  end
end
