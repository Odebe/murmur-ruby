# frozen_string_literal: true

module Persistence
  module Repositories
    class Users < Repository[:users]
      auto_struct false

      def all
        users.to_a
      end

      def by_name(name)
        users.restrict(username: name).to_a.last
      end
    end
  end
end
