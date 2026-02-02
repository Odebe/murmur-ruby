# frozen_string_literal: true

module Streams
  class Udp < Generic
    wrap_nonblock(:recvmsg_nonblock, as: :read_nonblock)
    wrap_nonblock(:sendmsg_nonblock, as: :write_nonblock)
  end
end
