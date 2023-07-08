# frozen_string_literal: true

require 'zeitwerk'
require 'optparse'

require_relative 'app'
require_relative 'config'
require_relative 'persistence/db'

class Configurator
  extend Dry::Initializer

  option :loader,    default: -> { Zeitwerk::Loader.new }
  option :options,   default: -> { Hash.new }
  option :root_path, default: -> { Pathname(__dir__).join('..') }

  def self.call
    new.tap(&:parse_options!).call
  end

  def parse_options!
    OptionParser.new do |opts|
      opts.banner = "Usage: main.rb [options]"

      opts.on("--config=PATH", "Config path") do |v|
        options[:config_path] = Pathname(v)
      end

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end.parse!
  end

  def call
    loader.push_dir(lib_path)
    loader.setup

    config = Config.read_from_file(config_path)

    db  = Persistence::Db.new(db_path)
    app = App.new(config: config, db: db)
    app.setup!

    loader.eager_load
    app
  end

  def config_path
    @config_path ||= options[:config_path] || root_path.join('run/config.yml')
  end

  def lib_path
    root_path.join('lib')
  end

  def db_path
    config_path
  end
end
