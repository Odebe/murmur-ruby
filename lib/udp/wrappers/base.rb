# frozen_string_literal: true

module Udp
  module Wrappers
    class Base
      attr_reader :message, :sender_sockaddr, :client, :bytesize

      def initialize(message, bytesize:, sender_sockaddr: nil, client: nil, source: :udp)
        @message = message
        @sender_sockaddr = sender_sockaddr
        @client = client
        @source = source
        @bytesize = bytesize
      end

      def sender_addr
        client.nil? ? sender_sockaddr : client.udp_address
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
