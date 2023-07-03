# frozen_string_literal: true

require 'openssl'

module Cipher
  MUMBLE_CRYPT_ALGORITHM = 'aes-128-ocb'

  class Key
    def initialize
      cipher = new_cipher

      @raw_key = cipher.random_key

      # for some reason #random_iv returns 96 bit vector, so using #random_key
      @encrypt_iv = cipher.random_key
      @decrypt_iv = cipher.random_key
    end

    def to_hash
      {
        key: @raw_key,
        client_nonce: @encrypt_iv,
        server_nonce: @decrypt_iv
      }
    end

    # TODO: encrypt, decrypt

    private

    def new_cipher
      OpenSSL::Cipher::AES.new(128, :OCB)
    end
  end
end
