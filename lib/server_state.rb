# frozen_string_literal: true

class ServerState
  extend Dry::Initializer

  option :rom
  option :settings
end
