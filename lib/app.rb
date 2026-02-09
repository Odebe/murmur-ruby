# frozen_string_literal: true

class App
  class << self
    attr_accessor :config_path

    def load!
      load_code

      config
      db
      server
    end

    def start!
      server.setup!
      server.start!
    end

    def stop!
      server.stop!
    end

    private

    def load_code
      load_paths.each { |path| loader.push_dir(path) }

      loader.setup
      loader.eager_load
    end

    def server
      @server ||= Server.new(config:, db:)
    end

    def config
      @config ||= Config.read_from_file(config_path)
    end

    def db
      @db ||= Persistence::Db.new(config_path)
    end

    def root_path
      @root_path ||= Pathname(__dir__).join('..')
    end

    def loader
      @loader ||= Zeitwerk::Loader.new
    end

    def load_paths
      @load_paths ||=
        %w[
          lib
          app
        ].each do |path|
          root_path.join(path)
        end
    end
  end
end
