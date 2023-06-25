# frozen_string_literal: true

module Persistence
  module Commands
    module Clients
      class Delete < ROM::Memory::Commands::Delete
        relation :clients
        register_as :delete
      end
    end
  end
end
