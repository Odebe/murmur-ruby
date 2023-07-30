# frozen_string_literal: true

module Voice
  class Packet
    class CeltBeta < Voice
      include SegmentedPayload
    end
  end
end
