# frozen_string_literal: true

module Persistence
  module Commands
    module Users
      class Delete < ROM::Memory::Commands::Delete
        relation :users
        register_as :delete
      end
    end
  end
end
