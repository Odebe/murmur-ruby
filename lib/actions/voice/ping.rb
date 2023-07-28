# frozen_string_literal: true

module Actions
  module Voice
    class Ping < Dispatch[UdpAction, ::Voice::Packet::Ping]
      def handle
        authorize!

        reply message
      end
    end
  end
end
