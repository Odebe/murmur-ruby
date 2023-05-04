# frozen_string_literal: true

module MessageHandlers
  module Mixin
    def self.included(mod)
      Dir[File.join(__dir__, '*.rb')].map do |file|
        next if file.include? __FILE__

        mod.include $loader.load_file(file)
      end

      mod.include Utils
    end

    def handle(message)
      handler = "handle_#{message.class.name.split('::').last.downcase}"
      puts "#{handler}: #{message.inspect}"

      respond_to?(handler) ? send(handler, message) : handle_not_defined(message, handler)
    end

    module Utils
      def auth!
        throw :halt unless users.auth?(@uuid)
      end
    end
  end
end
