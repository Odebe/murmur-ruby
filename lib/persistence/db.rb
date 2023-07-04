# frozen_string_literal: true
require_relative './id_pool'

module Persistence
  class Db
    def initialize(app)
      @app = app
    end

    def setup!
      init_rom
      init_pools
      init_data
    end

    def clients
      @clients ||= Repositories::Clients.new(@rom, id_pool: @pools[:clients])
    end

    def users
      @users ||= Repositories::Users.new(@rom, id_pool: @pools[:users])
    end

    def rooms
      @rooms ||= Repositories::Rooms.new(@rom, id_pool: @pools[:rooms])
    end

    def codec
      @codec ||= Repositories::Codec.new
    end

    private

    def init_rom
      @rom = ROM.container(
        memory: [:memory, 'memory://ruby_murmur'],
        file:   [:yaml,    @app.settings[:db][:path]]
      ) do |config|
        config.auto_registration(@app.persistence_path)
      end
    end

    def init_pools
      @pools = {
        clients: IdPool.new,
        users: IdPool.new,
        rooms: IdPool.new,
      }
    end

    def init_data
      users.all.each { |user| @pools[:users].reserve(user[:id]) }
      rooms.all.each { |room| @pools[:rooms].reserve(room[:id]) }

      # Official client expects session number greater than zero
      # If session_id is zero it thinks there is no session
      # See 'Global::get().uiSession == 0' in mumble sources
      @pools[:clients].reserve(0)
    end
  end
end
