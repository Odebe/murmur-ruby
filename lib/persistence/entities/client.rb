# frozen_string_literal: true

module Persistence
  module Entities
    class Client < ROM::Struct
      def update(diff)
        attributes.update(diff)
      end
    end
  end
end
