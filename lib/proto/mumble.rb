# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf'

module Proto
  module Mumble
    ::Protobuf::Optionable.inject(self) { ::Google::Protobuf::FileOptions }

    ##
    # Message Classes
    #
    class Version < ::Protobuf::Message; end
    class UDPTunnel < ::Protobuf::Message; end
    class Authenticate < ::Protobuf::Message; end
    class Ping < ::Protobuf::Message; end
    class Reject < ::Protobuf::Message
      class RejectType < ::Protobuf::Enum
        define :None, 0
        define :WrongVersion, 1
        define :InvalidUsername, 2
        define :WrongUserPW, 3
        define :WrongServerPW, 4
        define :UsernameInUse, 5
        define :ServerFull, 6
        define :NoCertificate, 7
        define :AuthenticatorFail, 8
      end

    end

    class ServerSync < ::Protobuf::Message; end
    class ChannelRemove < ::Protobuf::Message; end
    class ChannelState < ::Protobuf::Message; end
    class UserRemove < ::Protobuf::Message; end
    class UserState < ::Protobuf::Message
      class VolumeAdjustment < ::Protobuf::Message; end

    end

    class BanList < ::Protobuf::Message
      class BanEntry < ::Protobuf::Message; end

    end

    class TextMessage < ::Protobuf::Message; end
    class PermissionDenied < ::Protobuf::Message
      class DenyType < ::Protobuf::Enum
        define :Text, 0
        define :Permission, 1
        define :SuperUser, 2
        define :ChannelName, 3
        define :TextTooLong, 4
        define :H9K, 5
        define :TemporaryChannel, 6
        define :MissingCertificate, 7
        define :UserName, 8
        define :ChannelFull, 9
        define :NestingLimit, 10
        define :ChannelCountLimit, 11
        define :ChannelListenerLimit, 12
        define :UserListenerLimit, 13
      end

    end

    class ACL < ::Protobuf::Message
      class ChanGroup < ::Protobuf::Message; end
      class ChanACL < ::Protobuf::Message; end

    end

    class QueryUsers < ::Protobuf::Message; end
    class CryptSetup < ::Protobuf::Message; end
    class ContextActionModify < ::Protobuf::Message
      class Context < ::Protobuf::Enum
        define :Server, 1
        define :Channel, 2
        define :User, 4
      end

      class Operation < ::Protobuf::Enum
        define :Add, 0
        define :Remove, 1
      end

    end

    class ContextAction < ::Protobuf::Message; end
    class UserList < ::Protobuf::Message
      class User < ::Protobuf::Message; end

    end

    class VoiceTarget < ::Protobuf::Message
      class Target < ::Protobuf::Message; end

    end

    class PermissionQuery < ::Protobuf::Message; end
    class CodecVersion < ::Protobuf::Message; end
    class UserStats < ::Protobuf::Message
      class Stats < ::Protobuf::Message; end

    end

    class RequestBlob < ::Protobuf::Message; end
    class ServerConfig < ::Protobuf::Message; end
    class SuggestConfig < ::Protobuf::Message; end
    class PluginDataTransmission < ::Protobuf::Message; end


    ##
    # File Options
    #
    set_option :optimize_for, ::Google::Protobuf::FileOptions::OptimizeMode::SPEED


    ##
    # Message Fields
    #
    class Version
      optional :uint32, :version_v1, 1
      optional :uint64, :version_v2, 5
      optional :string, :release, 2
      optional :string, :os, 3
      optional :string, :os_version, 4
    end

    class UDPTunnel
      required :bytes, :packet, 1
    end

    class Authenticate
      optional :string, :username, 1
      optional :string, :password, 2
      repeated :string, :tokens, 3
      repeated :int32, :celt_versions, 4
      optional :bool, :opus, 5, :default => false
      optional :int32, :client_type, 6, :default => 0
    end

    class Ping
      optional :uint64, :timestamp, 1
      optional :uint32, :good, 2
      optional :uint32, :late, 3
      optional :uint32, :lost, 4
      optional :uint32, :resync, 5
      optional :uint32, :udp_packets, 6
      optional :uint32, :tcp_packets, 7
      optional :float, :udp_ping_avg, 8
      optional :float, :udp_ping_var, 9
      optional :float, :tcp_ping_avg, 10
      optional :float, :tcp_ping_var, 11
    end

    class Reject
      optional ::Proto::Mumble::Reject::RejectType, :type, 1
      optional :string, :reason, 2
    end

    class ServerSync
      optional :uint32, :session, 1
      optional :uint32, :max_bandwidth, 2
      optional :string, :welcome_text, 3
      optional :uint64, :permissions, 4
    end

    class ChannelRemove
      required :uint32, :channel_id, 1
    end

    class ChannelState
      optional :uint32, :channel_id, 1
      optional :uint32, :parent, 2
      optional :string, :name, 3
      repeated :uint32, :links, 4
      optional :string, :description, 5
      repeated :uint32, :links_add, 6
      repeated :uint32, :links_remove, 7
      optional :bool, :temporary, 8, :default => false
      optional :int32, :position, 9, :default => 0
      optional :bytes, :description_hash, 10
      optional :uint32, :max_users, 11
      optional :bool, :is_enter_restricted, 12
      optional :bool, :can_enter, 13
    end

    class UserRemove
      required :uint32, :session, 1
      optional :uint32, :actor, 2
      optional :string, :reason, 3
      optional :bool, :ban, 4
    end

    class UserState
      class VolumeAdjustment
        optional :uint32, :listening_channel, 1
        optional :float, :volume_adjustment, 2
      end

      optional :uint32, :session, 1
      optional :uint32, :actor, 2
      optional :string, :name, 3
      optional :uint32, :user_id, 4
      optional :uint32, :channel_id, 5
      optional :bool, :mute, 6
      optional :bool, :deaf, 7
      optional :bool, :suppress, 8
      optional :bool, :self_mute, 9
      optional :bool, :self_deaf, 10
      optional :bytes, :texture, 11
      optional :bytes, :plugin_context, 12
      optional :string, :plugin_identity, 13
      optional :string, :comment, 14
      optional :string, :hash, 15
      optional :bytes, :comment_hash, 16
      optional :bytes, :texture_hash, 17
      optional :bool, :priority_speaker, 18
      optional :bool, :recording, 19
      repeated :string, :temporary_access_tokens, 20
      repeated :uint32, :listening_channel_add, 21
      repeated :uint32, :listening_channel_remove, 22
      repeated ::Proto::Mumble::UserState::VolumeAdjustment, :listening_volume_adjustment, 23
    end

    class BanList
      class BanEntry
        required :bytes, :address, 1
        required :uint32, :mask, 2
        optional :string, :name, 3
        optional :string, :hash, 4
        optional :string, :reason, 5
        optional :string, :start, 6
        optional :uint32, :duration, 7
      end

      repeated ::Proto::Mumble::BanList::BanEntry, :bans, 1
      optional :bool, :query, 2, :default => false
    end

    class TextMessage
      optional :uint32, :actor, 1
      repeated :uint32, :session, 2
      repeated :uint32, :channel_id, 3
      repeated :uint32, :tree_id, 4
      required :string, :message, 5
    end

    class PermissionDenied
      optional :uint32, :permission, 1
      optional :uint32, :channel_id, 2
      optional :uint32, :session, 3
      optional :string, :reason, 4
      optional ::Proto::Mumble::PermissionDenied::DenyType, :type, 5
      optional :string, :name, 6
    end

    class ACL
      class ChanGroup
        required :string, :name, 1
        optional :bool, :inherited, 2, :default => true
        optional :bool, :inherit, 3, :default => true
        optional :bool, :inheritable, 4, :default => true
        repeated :uint32, :add, 5
        repeated :uint32, :remove, 6
        repeated :uint32, :inherited_members, 7
      end

      class ChanACL
        optional :bool, :apply_here, 1, :default => true
        optional :bool, :apply_subs, 2, :default => true
        optional :bool, :inherited, 3, :default => true
        optional :uint32, :user_id, 4
        optional :string, :group, 5
        optional :uint32, :grant, 6
        optional :uint32, :deny, 7
      end

      required :uint32, :channel_id, 1
      optional :bool, :inherit_acls, 2, :default => true
      repeated ::Proto::Mumble::ACL::ChanGroup, :groups, 3
      repeated ::Proto::Mumble::ACL::ChanACL, :acls, 4
      optional :bool, :query, 5, :default => false
    end

    class QueryUsers
      repeated :uint32, :ids, 1
      repeated :string, :names, 2
    end

    class CryptSetup
      optional :bytes, :key, 1
      optional :bytes, :client_nonce, 2
      optional :bytes, :server_nonce, 3
    end

    class ContextActionModify
      required :string, :action, 1
      optional :string, :text, 2
      optional :uint32, :context, 3
      optional ::Proto::Mumble::ContextActionModify::Operation, :operation, 4
    end

    class ContextAction
      optional :uint32, :session, 1
      optional :uint32, :channel_id, 2
      required :string, :action, 3
    end

    class UserList
      class User
        required :uint32, :user_id, 1
        optional :string, :name, 2
        optional :string, :last_seen, 3
        optional :uint32, :last_channel, 4
      end

      repeated ::Proto::Mumble::UserList::User, :users, 1
    end

    class VoiceTarget
      class Target
        repeated :uint32, :session, 1
        optional :uint32, :channel_id, 2
        optional :string, :group, 3
        optional :bool, :links, 4, :default => false
        optional :bool, :children, 5, :default => false
      end

      optional :uint32, :id, 1
      repeated ::Proto::Mumble::VoiceTarget::Target, :targets, 2
    end

    class PermissionQuery
      optional :uint32, :channel_id, 1
      optional :uint32, :permissions, 2
      optional :bool, :flush, 3, :default => false
    end

    class CodecVersion
      required :int32, :alpha, 1
      required :int32, :beta, 2
      required :bool, :prefer_alpha, 3, :default => true
      optional :bool, :opus, 4, :default => false
    end

    class UserStats
      class Stats
        optional :uint32, :good, 1
        optional :uint32, :late, 2
        optional :uint32, :lost, 3
        optional :uint32, :resync, 4
      end

      optional :uint32, :session, 1
      optional :bool, :stats_only, 2, :default => false
      repeated :bytes, :certificates, 3
      optional ::Proto::Mumble::UserStats::Stats, :from_client, 4
      optional ::Proto::Mumble::UserStats::Stats, :from_server, 5
      optional :uint32, :udp_packets, 6
      optional :uint32, :tcp_packets, 7
      optional :float, :udp_ping_avg, 8
      optional :float, :udp_ping_var, 9
      optional :float, :tcp_ping_avg, 10
      optional :float, :tcp_ping_var, 11
      optional ::Proto::Mumble::Version, :version, 12
      repeated :int32, :celt_versions, 13
      optional :bytes, :address, 14
      optional :uint32, :bandwidth, 15
      optional :uint32, :onlinesecs, 16
      optional :uint32, :idlesecs, 17
      optional :bool, :strong_certificate, 18, :default => false
      optional :bool, :opus, 19, :default => false
    end

    class RequestBlob
      repeated :uint32, :session_texture, 1
      repeated :uint32, :session_comment, 2
      repeated :uint32, :channel_description, 3
    end

    class ServerConfig
      optional :uint32, :max_bandwidth, 1
      optional :string, :welcome_text, 2
      optional :bool, :allow_html, 3
      optional :uint32, :message_length, 4
      optional :uint32, :image_message_length, 5
      optional :uint32, :max_users, 6
      optional :bool, :recording_allowed, 7
    end

    class SuggestConfig
      optional :uint32, :version_v1, 1
      optional :uint64, :version_v2, 4
      optional :bool, :positional, 2
      optional :bool, :push_to_talk, 3
    end

    class PluginDataTransmission
      optional :uint32, :senderSession, 1
      repeated :uint32, :receiverSessions, 2, :packed => true
      optional :bytes, :data, 3
      optional :string, :dataID, 4
    end

  end

end
