# frozen_string_literal: true

module Actions
  module Voice
    class CeltBeta < Dispatch[Implementation, ::Voice::Packet::CeltBeta]
    end
  end
end
