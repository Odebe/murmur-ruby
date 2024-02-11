# frozen_string_literal: true

module Actions
  class ResyncCrypto < TcpAction
    def handle
      message = ::Proto::Mumble::CryptSetup.new
      state   = client[:crypt_state]

      message.key          = state.key.pack('C*')
      message.client_nonce = state.decrypt_nonce.pack('C*')
      message.server_nonce = state.encrypt_nonce.pack('C*')

      reply message
    end
  end
end
