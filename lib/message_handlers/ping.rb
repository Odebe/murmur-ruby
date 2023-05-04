# frozen_string_literal: true

module MessageHandlers
  module Ping
    # @param [::Proto::Mumble::Ping] message
    def handle_ping(message)
      @stream.send_message(Proto::Mumble::Ping.new(timestamp: message.timestamp))
    end
  end
end
