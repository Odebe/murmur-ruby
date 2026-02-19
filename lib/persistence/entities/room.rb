# frozen_string_literal: true

module Persistence
  module Entities
    class Room
      attr_accessor :id # Types::Integer
      attr_accessor :parent_id # Types::Integer.optional
      attr_accessor :name # Types::String
      attr_accessor :position # Types::Integer
      attr_accessor :clients # Types::Array.of(Entities::Client)
    end
  end
end
