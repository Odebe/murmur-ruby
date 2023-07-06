# frozen_string_literal: true

require 'async/io/protocol/generic'

module Client
  class ProtobufStream < Async::IO::Protocol::Generic
    # TODO: write in one call
    def send_message(msg)
      body =
        if msg.is_a? ::Proto::Mumble::UDPTunnel
          msg.packet
        else
          msg.encode
        end

      raw_msg =
        [
          [class_to_type(msg.class)].pack('n'),
          [body.size].pack('N'),
          body
        ].join('')

      write raw_msg
    end

    def read_message
      type = read_type
      len  = read_length
      body = read_body(len)

      # avoiding UdpTunnel message parsing
      # cuz message body is literally voice packet and not protobuf message
      if type == 1
       ::Proto::Mumble::UDPTunnel.new(packet: body)
      else
        ::Proto::Dicts::TYPE_TO_CLASS[type].decode(body)
      end
    end

    private

    def read_type
      read(2).unpack1('n')
    end

    def read_length
      read(4).unpack1('N')
    end

    def read_body(len)
      read(len)
    end

    def write_type(klass)
      write [class_to_type(klass)].pack('n')
    end

    def write_length(body)
      write [body.size].pack('N')
    end

    def write(body)
      @stream.write(body)
    end

    def read(size)
      @stream.read(size) or @stream.eof!
    end

    def class_to_type(klass)
      ::Proto::Dicts::CLASS_TO_TYPE[klass]
    end
  end
end
