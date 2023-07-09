# frozen_string_literal: true

module Persistence
  module Repositories
    class Codec
      def initialize
        @codec_alpha  = 0
        @codec_beta   = 0
        @prefer_alpha = false
      end

      def current_version
        @prefer_alpha ? @codec_alpha : @codec_beta
      end

      def to_hash
        {
          alpha:        @codec_alpha,
          beta:         @codec_beta,
          prefer_alpha: @prefer_alpha,
          opus:         true
        }
      end

      def recheck(version)
        return false if current_version == version

        # // If we don't already use the compat bitstream version set
        # // it as alpha and announce it. If another codec now got the
        # // majority set it as the opposite of the currently valid bPreferAlpha
        # // and announce it.
        @prefer_alpha =
          if version == 0x8000000b
            true
          else
            !@prefer_alpha
          end

        if @prefer_alpha
          @codec_alpha = version
        else
          @codec_beta = version
        end

        true
      end
    end
  end
end
