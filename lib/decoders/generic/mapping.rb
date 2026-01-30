# frozen_string_literal: true

module Decoders
  class Generic
    module Mapping
      module Errors
        class ProtocolError < StandardError; end

        # 4xx-like
        class InvalidType < ProtocolError; end

        # 5xx-like
        class InvalidClass < ProtocolError; end
      end

      def self.included(base)
        base.extend(ClassMethods)
        base.include(InstanceMethods)
      end

      module ClassMethods
        def define_mapper(dict)
          const_set(:TYPE_TO_CLASS, dict)
          const_set(:CLASS_TO_TYPE, dict.invert)
        end
      end

      module InstanceMethods
        def find_class(type)
          self.class.const_get(:TYPE_TO_CLASS).fetch(type) { raise Errors::InvalidType, "type: #{type}" }
        end

        def find_type(klass)
          self.class.const_get(:CLASS_TO_TYPE).fetch(klass) { raise Errors::InvalidClass, "klass: #{klass}" }
        end

        def type_eql(type, klass)
          find_class(type) == klass
        end
      end
    end
  end
end
