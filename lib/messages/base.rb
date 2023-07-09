# frozen_string_literal: true

module Messages
  class Base
    attr_reader :client, :app

    # We initialize a lot of instances so avoiding dry-initializer
    def initialize(client, app)
      @client = client
      @app    = app
    end

    def call(_input)
      raise 'abstract method'
    end
  end
end
