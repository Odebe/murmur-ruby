# frozen_string_literal: true

module MessageHandlers
  module Version
    # @param [::Proto::Mumble::Version] message
    def handle_version(message)
      users.set_version(@uuid, message)
    end
  end
end
