# frozen_string_literal: true

require 'dry-types'

class Error < StandardError; end
class ConnectionClosingError < Error; end

module Types
  include Dry.Types
end
