# frozen_string_literal: true

module Persistence
  module Indexes
    class Uniq
      attr_reader :storage

      def initialize
        @storage = {}
      end

      def size
        @storage.size
      end
      alias :count :size

      def inspect
        @storage.inspect
      end

      def values
        @storage.values
      end

      def set(id, value)
        @storage[id] = value
      end

      def get(id)
        @storage[id]
      end

      def get_many(ids)
        ids.each_with_object([]) do |id, out|
          v = @storage[id]
          out << v if v
        end
      end

      def del(id)
        @storage.delete(id)
      end
      alias :remove :del

      def remove_by_value(id)
        key = @storage.key(id)
        @storage.delete(key)
      end

      def exists?(id)
        @storage.key?(id)
      end
    end
  end
end
