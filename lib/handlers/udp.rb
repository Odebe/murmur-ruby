# frozen_string_literal: true

module Handlers
  # Handler per server (UDP socket)
  class Udp < Generic
    option :queue,    default: -> { Async::Queue.new }
    option :dispatcher, reader: :private, default: -> { Actions::Dispatch }
    option :decoder, reader: :private, default: -> { Decoders::Udp.new(io) }

    def setup!
      app.udp_handler = self
    end

    # TODO: move work with task in parent class (more sugar)
    def start!
      parent_task = Async::Task.current

      @task = parent_task.async do |task|
        from = task.async { from_client_loop }
        _to  = task.async { to_client_loop }

        from.wait
      ensure
        task.stop
      end
    end

    def wait!
      @task.wait
    end

    private

    def from_client_loop
      current_task.annotate 'UDP receiving loop'
      current_task.yield

      within_connection do
        loop do
          message = decoder.read_encrypted
          next if message.nil?

          if message.legacy?
            wrapped_message = ::Udp::Wrappers.wrap(
              message,
              bytesize: message.bytesize,
              sender_sockaddr: message.sender_sockaddr
            )

            handle_client_message(wrapped_message)
            next
          end

          result = find_user_by_address_and_decrypt(message)
          next unless result

          decrypted_data, client = result

          proto_message = decoder.decode(decrypted_data)

          wrapped_message = ::Udp::Wrappers.wrap(proto_message, bytesize: message.bytesize, client: client)
          handle_client_message(wrapped_message)
        end
      end
    end

    def to_client_loop
      current_task.annotate 'UDP sending loop'
      current_task.yield

      within_connection do
        loop do
          target, msg = queue.dequeue
          body = ::Decoders::Udp.encode(msg)

          unless msg.is_a?(::Udp::Ping)
            # TODO: pass from action
            client = app.db.clients.by_udp_address(target).to_a.last
            next unless client&.crypt_state

            type = decoder.find_type(msg.class)
            buffer = String.new(capacity: body.bytesize + 1, encoding: Encoding::BINARY)
            buffer << [type].pack('C')
            buffer << body

            body = client.crypt_state.encrypt(buffer)
          end

          decoder.send_message(body, target)
        end
      end
    end

    def handle_client_message(wrapped_message)
      action = dispatcher.call(wrapped_message)

      if action.nil?
        handle_not_defined(wrapped_message)
        return
      end

      action.new(self, app, wrapped_message).call
    end

    # TODO: refactor this mess (maybe create new type of decoder)
    def find_user_by_address_and_decrypt(message)
      found_by_udp = app.db.clients.by_udp_address(message.sender_sockaddr).to_a.last
      if found_by_udp
        result = try_decrypt(found_by_udp, message)
        return result if result
      end

      found_by_same_ip = app.db.clients.by_same_ip(message.sender_sockaddr).to_a
      found_by_same_ip.each do |same_ip_client|
        result = try_decrypt(same_ip_client, message)
        return result if result
      end

      app.db.clients.all.each do |client|
        next if client == found_by_udp || found_by_same_ip.include?(client)

        result = try_decrypt(client, message)
        return result if result
      end

      nil
    end

    def try_decrypt(client, message)
      crypt_state = client.crypt_state
      return unless crypt_state

      data, result = crypt_state.decrypt(message.data)
      if result == :ok
        app.db.clients.update(client, udp_address: message.sender_sockaddr)

        return [data, client]
      elsif crypt_state.need_resync?
        crypt_state.reset_last_good!

        build_tcp_action(Actions::Tcp::ResyncCrypto, target_client: client).call
      end

      nil
    end
  end
end
