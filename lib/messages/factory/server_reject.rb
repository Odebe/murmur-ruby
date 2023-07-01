
# frozen_string_literal: true

module Messages
  module Factory
    class ServerReject < Registry[:server_reject]
      def call(input)
        Proto::Mumble::Reject.new(
          type: Proto::Mumble::Reject::RejectType.const_get(input[:reason]),
          reason: input[:reason]
        )
      end
    end
  end
end
