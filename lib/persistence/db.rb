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
  end
end
