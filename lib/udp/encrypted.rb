# frozen_string_literal: true

module Udp
  class Encrypted < Packet
    def decode(stream)
      @data = stream.string
    end

    def raw
      @data
    end

    def encode(_stream)
      raise 'Can\'t encode encrypted packet'
    end
  end
end
