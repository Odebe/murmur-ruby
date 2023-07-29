# frozen_string_literal: true

require 'dry-configurable'
require 'yaml'

require_relative './types'

# Modified version of https://github.com/hanami/hanami/blob/main/lib/hanami/settings.rb
class Config
  class InvalidSettingsError < StandardError
    def initialize(errors)
      super()
      @errors = errors
    end

    def to_s
      <<~STR.strip
        Could not initialize settings. The following settings were invalid:

        #{@errors.map { |setting, message| "#{setting}: #{message}" }.join("\n")}
      STR
    end
  end

  module Store
    class Yaml
      def initialize(path)
        @store = YAML.load_file(path)
      end

      def fetch(name, default_value)
        @store.key?(name.to_s) ? @store[name.to_s] : default_value
      end
    end
  end

  def self.read_from_file(path)
    new(Store::Yaml.new(path))
  end

  Undefined = Dry::Core::Constants::Undefined

  include Dry::Configurable

  def initialize(store)
    errors = config._settings.map(&:name).each_with_object({}) do |name, errs|
      value = store.fetch(name, Undefined)

      if value.eql?(Undefined)
        # When a key is missing entirely from the store, _read_ its value from the config instead,
        # which ensures its setting constructor runs (with a `nil` argument given) and raises any
        # necessary errors.
        public_send(name)
      else
        public_send("#{name}=", value)
      end
    rescue => e # rubocop:disable Style/RescueStandardError
      errs[name] = e
    end

    raise InvalidSettingsError, errors if errors.any?

    config.finalize!
  end

  setting :max_bandwidth,        constructor: Types::Integer
  setting :welcome_text,         constructor: Types::String
  setting :allow_html,           constructor: Types::Bool
  setting :message_length,       constructor: Types::Integer
  setting :image_message_length, constructor: Types::Integer
  setting :max_users,            constructor: Types::Integer
  setting :recording_allowed,    constructor: Types::Bool
  setting :max_username_length,  constructor: Types::Integer
  setting :default_room,         constructor: Types::Integer
  setting :host,                 constructor: Types::String
  setting :port,                 constructor: Types::Integer
  setting :ssl_cert,             constructor: Types::String
  setting :ssl_key,              constructor: Types::String
  setting :ssl_ca,               constructor: Types::String
  setting :debug,                constructor: Types::Bool
  setting :debug_web,            constructor: Types::Bool
  setting :ssl_allow_selfsigned, constructor: Types::Bool

  private

  def method_missing(name, *args, &block)
    if config.respond_to?(name)
      config.send(name, *args, &block)
    else
      super
    end
  end

  def respond_to_missing?(name, _include_all = false)
    config.respond_to?(name) || super
  end
end
