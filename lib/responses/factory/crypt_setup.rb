# frozen_string_literal: true

module Responses
  module Factory
    class CryptSetup < Registry[:crypt_setup]
      def call(_input)
        state = client.crypt_state

        Proto::Mumble::CryptSetup.new(
          key:          state.key,
          client_nonce: state.decrypt_nonce,
          server_nonce: state.encrypt_nonce
        )
      end
    end
  end
end
