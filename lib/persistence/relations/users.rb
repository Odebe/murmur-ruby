# frozen_string_literal: true

module Persistence
  module Relations
    # Registered clients
    class Users < ROM::Relation[:yaml]
      gateway :file

      schema(:users) do
        attribute :id, Types::Integer
        primary_key :id

        attribute :username, Types::String
        attribute :password, Types::String
      end
    end
  end
end
