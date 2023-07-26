# frozen_string_literal: true

module Proto
  module Monkey
    class ::Protobuf::Message
      def udp?
        false
      end
    end
  end
end
