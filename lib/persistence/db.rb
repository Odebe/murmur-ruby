# frozen_string_literal: true

require_relative './id_pool'

module Persistence
  class Db
    extend Dry::Initializer

    param :db_path

    def setup!
      read_config

      init_pools
      init_data
    end

    def clients
      @clients ||= Repositories::Clients.new(self, id_pool: @pools[:clients])
    end

    def users
      @users ||= Repositories::Users.new(self, id_pool: @pools[:users])
    end

    def rooms
      @rooms ||= Repositories::Rooms.new(self, id_pool: @pools[:rooms])
    end

    def codec
      @codec ||= Repositories::Codec.new
    end

    private

    def read_config
      @config = YAML.load_file(db_path)
    end

    def init_pools
      @pools = {
        clients: IdPool.new,
        users:   IdPool.new,
        rooms:   IdPool.new
      }
    end

    def init_data
      load_key(@config['users'], users)
      load_key(@config['rooms'], rooms)

      # users.all.each { |user| @pools[:users].reserve(user[:id]) }
      # rooms.all.each { |room| @pools[:rooms].reserve(room[:id]) }

      # Official client expects session number greater than zero
      # If session_id is zero it thinks there is no session
      # See 'Global::get().uiSession == 0' in mumble sources
      @pools[:clients].reserve(0)
    end

    def load_key(array, repo)
      array.each { |e| repo.create(**e.transform_keys(&:to_sym)) }
    end
  end
end
