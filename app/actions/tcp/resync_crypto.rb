# frozen_string_literal: true

module Actions
  module Tcp
    class ResyncCrypto < TcpAction
      def handle
        message = ::Proto::Mumble::CryptSetup.new
        state   = client[:crypt_state]

        message.key          = state.key
        message.client_nonce = state.decrypt_nonce
        message.server_nonce = state.encrypt_nonce

        reply message
      end
    end
  end
end
