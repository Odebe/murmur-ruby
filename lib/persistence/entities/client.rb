# frozen_string_literal: true

module Persistence
  module Entities
    class Client
      attr_accessor :session_id # Types::Integer
      attr_accessor :status # Statuses
      attr_accessor :self_mute # Types::Bool
      attr_accessor :self_deaf # Types::Bool
      attr_accessor :room_id # Types::Integer
      attr_accessor :tcp_queue # Types.Instance(Async::Queue)
      attr_accessor :tcp_address # Types.Instance(Addrinfo)
      attr_accessor :udp_used # Types::Bool
      attr_accessor :udp_address # Types.Instance(Addrinfo).optional
      attr_accessor :remote_address # Types.Instance(Addrinfo)
      attr_accessor :timers # Types.Instance(Timers::Group)
      attr_accessor :crypt_state # Types.Instance(::Client::CryptoState).optional
      attr_accessor :traffic_shaper # Types.Instance(::Client::TrafficShaper)
      attr_accessor :user_id # Types::Integer.optional
      attr_accessor :username # Types::String.optional
      attr_accessor :password # Types::String.optional
      attr_accessor :version # Types::Hash.optional do
      # attr_accessor :version_v1 # Types::Integer
      # attr_accessor :version_v2 # Types::Integer
      # attr_accessor :release # Types::String
      # attr_accessor :os # Types::String
      # attr_accessor :os_version # Types::String
      attr_accessor :tokens # Types::Array.of(Types::String)
      attr_accessor :celt_versions # Types::Array.of(Types::Integer)
      attr_accessor :opus # Types::Bool.optional
      attr_accessor :client_type # Types::Integer.optional
    end
  end
end
