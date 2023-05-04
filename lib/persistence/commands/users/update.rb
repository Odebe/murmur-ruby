# frozen_string_literal: true

module Persistence
  module Commands
    module Users
      class Update < ROM::Memory::Commands::Update
        relation :users
        register_as :update
      end
    end
  end
end
