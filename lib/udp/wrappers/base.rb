# frozen_string_literal: true

module Udp
  module Wrappers
    class Base
      attr_reader :message, :sender_sockaddr, :client

      def initialize(message, sender_sockaddr: nil, client: nil, source: :udp)
        @message = message
        @sender_sockaddr = sender_sockaddr
        @client = client
        @source = source
      end

      def sender_addr
        client.nil? ? sender_sockaddr : client[:udp_address]
      end

      def udp?
        @source == :udp
      end

      def tcp?
        @source == :tcp
      end

      def legacy?
        false
      end
    end
  end
end
