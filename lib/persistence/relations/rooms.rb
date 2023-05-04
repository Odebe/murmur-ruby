# frozen_string_literal: true

module Persistence
  module Relations
    class Rooms < ROM::Relation[:memory]
      schema(:rooms) do
        attribute :id, Types::Integer
        primary_key :id

        attribute :name, Types::String
      end
    end
  end
end
