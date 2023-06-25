# frozen_string_literal: true

module Persistence
  module Relations
    class Rooms < ROM::Relation[:yaml]
      gateway :file

      schema(:rooms) do
        attribute :id, Types::Integer
        primary_key :id

        attribute :parent_id, Types::Integer.optional
        attribute :name, Types::String
      end
    end
  end
end
