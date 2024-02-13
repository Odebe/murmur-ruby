# frozen_string_literal: true

# it has to be done
# full monkey
module Async
  class Clock
    def reset!
      @total = 0
      @started = Async::Clock.now
    end
  end
end

module Client
  class CryptoState
    # Async::Clock uses ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
    # that return seconds, Mumble sources uses microseconds so converting 5000000 to 5
    FIVE_SECONDS = 5

    def initialize
      @state = ::RbMumbleProtocol::CryptState.new

      @last_good = Async::Clock.start
      @last_request = Async::Clock.start
    end

    def need_resync?
      @last_good.total > FIVE_SECONDS && @last_request.total > FIVE_SECONDS
    end

    def reset_last_good!
      restart(@last_good)
    end

    def key
      @state.key
    end

    def stats
      @state.stats
    end

    def decrypt_nonce
      @state.decrypt_nonce
    end

    def encrypt_nonce
      @state.encrypt_nonce
    end

    def encrypt(bytes)
      @state.encrypt(bytes).tap { |_encrypted| restart(@last_request) }
    end

    def decrypt(bytes)
      @state.decrypt(bytes).tap do |result|
        restart(@last_good) if result.success?
      end
    end

    private

    def restart(clock)
      elapsed = clock.stop!
      clock.reset!
      elapsed
    end
  end
end
