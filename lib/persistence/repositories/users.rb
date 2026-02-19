# frozen_string_literal: true

module Persistence
  module Repositories
    class Users < Repository
      index :by_id, type: Indexes::Uniq
      index :by_name, type: Indexes::Uniq

      def all
        index_by_id.values
      end

      def by_id(id)
        index_by_id.get(id)
      end

      def by_name(name)
        index_by_name.get(name)
      end

      def create(id:, username:, password:)
        user = Entities::User.new
        user.id = id.nil? ? id_pool.obtain : id_pool.reserve(id)
        user.username = username
        user.password = password

        index_by_id.set(id, user)
        index_by_name.set(username, user)

        user
      end
    end
  end
end
