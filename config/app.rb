require_relative './boot'
require_relative '../lib/app'

App.config_path = Pathname(__dir__).join('../run/config.yml')

OptionParser.new do |opts|
  opts.banner = 'Usage: main.rb [options]'

  opts.on('--config=PATH', 'Config path') do |v|
    App.config_path = Pathname(v)
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end
end.parse!

App.load!
