# frozen_string_literal: true

module Responses
  module Factory
    class PermissionDenied < Registry[:permission_denied]
      def call(input)
        Proto::Mumble::PermissionDenied.new(
          type:   Proto::Mumble::PermissionDenied::DenyType::Text,
          reason: input[:reason]
        )
      end
    end
  end
end
