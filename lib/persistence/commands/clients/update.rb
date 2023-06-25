# frozen_string_literal: true

module Persistence
  module Commands
    module Clients
      class Update < ROM::Memory::Commands::Update
        relation :clients
        register_as :update
      end
    end
  end
end
