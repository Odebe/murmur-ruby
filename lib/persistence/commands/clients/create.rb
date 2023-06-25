# frozen_string_literal: true

module Persistence
  module Commands
    module Clients
      class Create < ROM::Memory::Commands::Create
        relation :clients
        register_as :create
      end
    end
  end
end
