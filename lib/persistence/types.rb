# frozen_string_literal: true

require 'dry-types'

module Persistence
  module Types
    include Dry.Types

    UUID = String.default { SecureRandom.uuid }
    ID   = Integer.default { SecureRandom.uuid.hash }
  end
end
