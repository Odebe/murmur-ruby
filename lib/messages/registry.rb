# frozen_string_literal: true

module Messages
  class Registry
    extend Dry::Core::ClassAttributes

    defines :types

    types ::Concurrent::Hash.new

    class << self
      def [](message_name)
        Class.new(Base) do
          define_singleton_method :inherited do |klass|
            super(klass)
            Messages::Registry.types[message_name] = klass
          end
        end
      end

      def call(message_name)
        types[message_name]
      end
    end
  end
end
