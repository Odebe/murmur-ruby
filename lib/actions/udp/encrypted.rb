# frozen_string_literal: true

module Actions
  module Udp
    class Encrypted < Dispatch[UdpAction, ::Udp::Encrypted]
      def handle
        @decrypted, @client = find_client_and_decrypt
        halt! unless @client

        voice_packet = ::Voice::Decoder.read_decrypted(@decrypted)
        voice_packet.sender = message.sender

        action = Actions::Dispatch.call(voice_packet)
        halt! unless action

        action.new(handler, voice_packet, @client, app).call
      end

      def find_client_and_decrypt
        client = app.db.clients.by_udp_address(message.sender).to_a.last

        if client && client[:crypt_state]
          success, value = client[:crypt_state].decrypt(message.raw.bytes)

          return [value.pack('C*'), client] if success
        end

        app.db.clients.all.each do |client|
          crypt_state = client[:crypt_state]
          next unless crypt_state

          success, value = crypt_state.decrypt(message.raw.bytes)
          next unless success

          app.db.clients.update(client[:session_id], udp_address: message.sender)

          return [value.pack('C*'), client]
        end

        [nil, nil]
      end
    end
  end
end
