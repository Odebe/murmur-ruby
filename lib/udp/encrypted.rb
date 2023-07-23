# frozen_string_literal: true

module Udp
  class Encrypted < Packet
    def decode(stream)
      @data = stream.string
    end

    def raw
      @data
    end

    # def encode(stream)
    #   stream.write(0)
    #   stream.write(1)
    #   stream.write(3)
    #   stream.write(4)
    # end
  end
end
