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
          out.concat(v) if v && !v.empty?
        end
      end

      def del(key, id)
        set = @storage[key]
        set.delete(id)
        @storage.delete(key) if set.empty?
      end
      alias :remove :del

      def exists?(id)
        @storage.key?(id)
      end

      def del_id(id)
        @storage.each_key { |k| @storage[k].delete(id) }
      end
    end
  end
end
