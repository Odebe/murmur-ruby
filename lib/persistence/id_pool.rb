# frozen_string_literal: true

module Persistence
  class IdPool
    def initialize
      @next  = 0
      @mutex = Mutex.new
      @free  = []
      @used  = []
    end

    def obtain
      @mutex.synchronize do
        if @free.any?
          @free
            .shift
            .tap { |free_id| @used << free_id }
        else
          find_next
            .tap { |id| @next = id.succ }
            .tap { |free_id| @used << free_id }
        end
      end
    end

    def reserve(id)
      @mutex.synchronize { @used << id }
    end

    def release(id)
      @mutex.synchronize { @free << @used.delete(id) }
    end

    private

    def find_next
      return @next unless @used.include?(@next)

      loop do
        @next += 1
        break unless @used.include?(@next)
      end

      @next
    end
  end
end
