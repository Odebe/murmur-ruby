# frozen_string_literal: true

module Client
  # Simple throttler
  # TODO: rewrite to leaky bucket
  class VoiceTrafficShaper
    def initialize(bandwidth)
      @bytes_per_second = bandwidth / 8
      @sent_bytes       = 0
    end

    def check!(len)
      total_sent = @sent_bytes + len
      return false if total_sent > @bytes_per_second

      @sent_bytes = total_sent
      true
    end

    def reset!
      @sent_bytes = 0
    end
  end
end
