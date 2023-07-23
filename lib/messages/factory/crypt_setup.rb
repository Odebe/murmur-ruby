# frozen_string_literal: true

module Messages
  module Factory
    class CryptSetup < Registry[:crypt_setup]
      def call(_input)
        state = client[:crypt_state]

        Proto::Mumble::CryptSetup.new(
          key:          state.key.pack('C*'),
          client_nonce: state.decrypt_nonce.pack('C*'),
          server_nonce: state.encrypt_nonce.pack('C*')
        )
      end
    end
  end
end
