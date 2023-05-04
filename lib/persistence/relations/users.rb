# frozen_string_literal: true

module Persistence
  module Relations
    class Users < ROM::Relation[:memory]
      schema(:users) do
        attribute :id, Types::Integer
        primary_key :id

        attribute :version, Types::Hash.optional do
          attribute :version_v1, Types::Integer
          attribute :version_v2, Types::Integer

          attribute :release,    Types::String
          attribute :os,         Types::String
          attribute :os_version, Types::String
        end

        attribute :auth, Types::Hash.optional do
          attribute :username,      Types::String
          attribute :password,      Types::String
          attribute :tokens,        Types::Array.of(Types::String)
          attribute :celt_versions, Types::Array.of(Types::String)
          attribute :opus,          Types::Bool
          attribute :client_type,   Types::Integer
        end
      end
    end
  end
end
