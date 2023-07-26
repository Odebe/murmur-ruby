# frozen_string_literal: true

module Udp
  class Packet
    attr_accessor :target, :sender

    def initialize(sender:)
      @sender = sender
      @target = nil
    end

    def udp?
      true
    end

    def with_target(new_target)
      new_self = clone
      new_self.target = new_target
      new_self
    end

    def decode(_stream)
      raise 'abstract method'
    end

    def raw
      raise 'abstract method'
    end
  end
end
