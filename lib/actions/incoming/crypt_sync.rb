# frozen_string_literal: true

module Actions
  module Incoming
    class CryptSync < Dispatch[TcpAction, ::Proto::Mumble::CryptSetup]
      def handle
        state = client[:crypt_state]

        if message.field?(:client_nonce)
          state.set_decrypt_nonce(message.client_nonce.bytes)
          # TODO: increment cryptState.uiResync
        else
          message.key          = state.key.pack('C*')
          message.client_nonce = state.decrypt_nonce.pack('C*')
          message.server_nonce = state.encrypt_nonce.pack('C*')

          reply message
        end
      end
    end
  end
end
