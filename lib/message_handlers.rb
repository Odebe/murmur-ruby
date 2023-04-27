# frozen_string_literal: true

module MessageHandlers
  def self.included(mod)
    Dir[File.join(__dir__, 'message_handlers/*.rb')].map do |file|
      mod.include $loader.load_file(file)
    end

    # mod.define_method :handle do |message|
    #   handler = "handle_#{message.class.name.split('::').last.downcase}"
    #   respond_to?(handler) ? send(handler, message) : handle_not_defined(message)
    # end
  end

  def handle(message)
    handler = "handle_#{message.class.name.split('::').last.downcase}"
    respond_to?(handler) ? send(handler, message) : handle_not_defined(message)
  end
end
