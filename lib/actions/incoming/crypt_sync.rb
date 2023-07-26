# frozen_string_literal: true

module Actions
  module Incoming
    class CryptSync < Dispatch[TcpAction, ::Proto::Mumble::CryptSetup]
      def handle
        state = client[:crypt_state]

        message.key          = state.key.pack('C*')
        message.client_nonce = state.decrypt_nonce.pack('C*')
        message.server_nonce = state.encrypt_nonce.pack('C*')

        reply message
      end
    end
  end
end
