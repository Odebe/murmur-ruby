# frozen_string_literal: true

module Persistence
  class Repository < ROM::Repository::Root
    option :id_pool, default: -> { IdPool.new }

    # attr_reader :id_pool
    #
    # def initialize(*args)
    #   @id_pool = args.shift
    #
    #   super(*args)
    # end
  end
end
