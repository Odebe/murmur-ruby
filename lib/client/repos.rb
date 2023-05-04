# frozen_string_literal: true

module Client
  module Repos
    def users
      @users ||= ::Persistence::Repositories::Users.new(@rom)
    end

    def rooms
      @rooms ||= ::Persistence::Repositories::Rooms.new(@rom)
    end
  end
end
