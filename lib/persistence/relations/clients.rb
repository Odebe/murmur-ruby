# frozen_string_literal: true

module Persistence
  module Relations
    class Clients < ROM::Relation[:memory]
      gateway :memory

      Statuses = Types::Symbol.enum(:initialized, :authorized)

      schema(:clients) do
        attribute :session_id, Types::Integer
        primary_key :session_id

        attribute :status, Statuses

        attribute :self_mute, Types::Bool
        attribute :self_deaf, Types::Bool

        attribute :room_id, Types::Integer

        attribute :queue, Types.Instance(Async::Queue)
        attribute :stream, Types.Instance(::Client::ProtobufStream)
        attribute :crypt_key, Types.Instance(Cipher::Key).optional

        attribute :user_id,  Types::Integer.optional
        attribute :username, Types::String.optional
        attribute :password, Types::String.optional

        attribute :version, Types::Hash.optional do
          attribute :version_v1, Types::Integer
          attribute :version_v2, Types::Integer

          attribute :release,    Types::String
          attribute :os,         Types::String
          attribute :os_version, Types::String
        end

        attribute :tokens,        Types::Array.of(Types::String)
        attribute :celt_versions, Types::Array.of(Types::Integer)
        attribute :opus,          Types::Bool.optional
        attribute :client_type,   Types::Integer.optional
      end
    end
  end
end
