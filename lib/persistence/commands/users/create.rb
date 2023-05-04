# frozen_string_literal: true

module Persistence
  module Commands
    module Users
      class Create < ROM::Memory::Commands::Create
        relation :users
        register_as :create
      end
    end
  end
end
