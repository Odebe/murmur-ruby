# frozen_string_literal: true

module Messages
  class Base
    extend Dry::Initializer

    include Persistence::Repos

    param :state
    param :stream
    param :user_id

    def call(_input)
      raise 'abstract method'
    end

    private

    def settings
      state.settings
    end
  end
end
