# frozen_string_literal: true

module Actions
  # actions registry
  class Dispatch
    extend Dry::Core::ClassAttributes

    defines :actions

    actions ::Concurrent::Hash.new

    class << self
      def [](base, message_klass)
        # Actions::Base class-level decorator
        Class.new(base) do
          define_singleton_method :inherited do |klass|
            super(klass)
            Dispatch.actions[message_klass] = klass
          end
        end
      end

      def call(message)
        actions[message.class]
      end
    end
  end
end
