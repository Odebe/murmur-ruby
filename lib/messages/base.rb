# frozen_string_literal: true

module Messages
  class Base
    extend Dry::Initializer

    include Persistence::Repos

    param :rom
    param :stream
    param :settings
    param :user_id

    def call(_input)
      raise 'abstract method'
    end
  end
end
