# frozen_string_literal: true

module Persistence
  module Repos
    def users
      @users ||= ::Persistence::Repositories::Users.new(rom)
    end

    def rooms
      @rooms ||= ::Persistence::Repositories::Rooms.new(rom)
    end

    def rom
      state.rom
    end
  end
end
