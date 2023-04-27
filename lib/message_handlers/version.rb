# frozen_string_literal: true

module MessageHandlers
  # ::Proto::Mumble::Version
  module Version
    def handle_version(message)
      puts message.inspect
    end
  end
end
