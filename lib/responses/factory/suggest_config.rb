# frozen_string_literal: true

module Responses
  module Factory
    class SuggestConfig < Registry[:suggest_config]
      def call(_input)
        ::Proto::Mumble::SuggestConfig.new(
         version_v2: ::Version::SUPPORTED_PROTOCOL_VERSION_V2,
         version_v1: ::Version::SUPPORTED_PROTOCOL_VERSION_V1
        )
      end
    end
  end
end
