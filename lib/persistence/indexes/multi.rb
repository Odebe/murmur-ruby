# frozen_string_literal: true

module Persistence
  module Indexes
    class Multi
      attr_reader :storage

      def initialize
        @storage = Hash.new { |hh, k| hh[k] = Set.new }
      end

      def add(key, id)
        @storage[key].add(id)
      end

      def get(key)
        @storage[key]
      end

      def get_many(keys)
        keys.each_with_object([]) do |key, out|
          v = @storage[key]
          out.concat(v.to_a) if v && !v.empty?
        end
      end

      def del(key, id)
        set = @storage[key]
        set.delete(id)
        @storage.delete(key) if set.empty?
      end
      alias :remove :del

      def remove_by_value(id)
        @storage.keys.each { |key| remove(key, id) }
      end

      def exists?(id)
        @storage.key?(id)
      end
    end
  end
end
