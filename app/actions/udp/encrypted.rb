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
        app.db.clients.all.each do |client|
          crypt_state = client[:crypt_state]
          next unless crypt_state

          result = crypt_state.decrypt(message.raw.bytes)

          if result.success?
            app.db.clients.update(client[:session_id], udp_address: message.sender)

            return [result.data.pack('C*'), client]
          elsif crypt_state.need_resync?
            crypt_state.reset_last_good!

            build_action(Actions::ResyncCrypto, target: client).call
          end
        end

        [nil, nil]
      end
    end
  end
end
