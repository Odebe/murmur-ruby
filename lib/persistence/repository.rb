# frozen_string_literal: true

module Persistence
  class Repository
    attr_reader :id, :id_pool

    class << self
      def index(name, type: Indexes::Uniq)
        @indexes ||= {}
        @indexes[name] = type
      end
    end

    def initialize(db, id_pool: nil)
      @db = db
      @id_pool = id_pool
      @indexes = {}

      set_indexes
    end

    def inspect_indexes
      @indexes.each do |name, index|
        puts "#{name}:"
        pp index.storage
        puts
      end
    end

    private

    def set_indexes
      indexes = self.class.instance_variable_get(:@indexes)
      return if indexes.nil? || indexes.empty?

      indexes.each do |name, klass|
        @indexes[name] ||= klass.new

        define_singleton_method("index_#{name}") { @indexes[name] }
      end
    end

    def clean_indexes(value)
      @indexes.each_value { |index| index.remove_by_value(value) }
    end
  end
end
