# frozen_string_literal: true

module Client
  module Mixins
    # Avoiding refinements due performance regression
    # TODO: check https://bugs.ruby-lang.org/issues/18572 later
    module VarintSize
      def varint_size(value)
        size = 0

        if (value & 0x8000000000000000).positive? && ~value < 0x100000000
          size += 1

          return size if value <= 0x3
        end

        if value < 0x80
          size + 1
        elsif value < 0x4000
          size + 2
        elsif value < 0x200000
          size + 3
        elsif value < 0x10000000
          size + 4
        elsif value < 0x100000000
          size + 5
        else
          size + 9
        end
      end
    end
  end
end
