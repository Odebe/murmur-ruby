# frozen_string_literal: true

require 'singleton'

module Persistence
  class IdRegistry
    include ::Singleton

    INIT_VALUE = 1

    def initialize
      @relations = Concurrent::Hash.new
    end

    def [](relation)
      @relations[relation] ||= INIT_VALUE
      value = @relations[relation]
      @relations[relation] = value.succ
      value
    end
  end
end
