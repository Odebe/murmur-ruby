# frozen_string_literal: true

module Messages
  module Factory
    class CryptSetup < Registry[:crypt_setup]
      def call(_input)
        Proto::Mumble::CryptSetup.new(client[:crypt_key].to_hash)
      end
    end
  end
end
