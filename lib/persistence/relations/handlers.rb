# frozen_string_literal: true
require 'byebug'

module Persistence
  module Relations
    class Handlers < ROM::Relation[:memory]
      gateway :memory

      ConnectionTypes = Types::Symbol.enum(:tcp, :udp)

      schema(:handlers) do
        attribute :session_id, Types::Integer
        attribute :connection_type, ConnectionTypes

        # primary_key [:session_id, :type]

        attribute :queue,  Types.Instance(Async::Queue)
        attribute :stream, Types.Instance(Proto::Decoder)
        attribute :finish, Types.Instance(Async::Condition)

        associations do
          belongs_to :client, combine_key: :session_id
        end
      end
    end
  end
end
