# frozen_string_literal: true

module Messages
  class Base
    extend Dry::Initializer

    param :client
    param :app

    def call(_input)
      raise 'abstract method'
    end
  end
end
