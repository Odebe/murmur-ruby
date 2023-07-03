# frozen_string_literal: true

module Persistence
  class Repository < ROM::Repository::Root
    option :id_pool, default: -> { IdPool.new }
  end
end
