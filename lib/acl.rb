# frozen_string_literal: true

# BIG TODO
# Mumble sources: src/ACL.cpp
class Acl
  # extend Dry::Core::ClassAttributes
  # extend Dry::Initializer

  # module Mixin
  #   def permission?(...)
  #     ACL.has_permission(...)
  #   end
  # end

  module Permissions
    None            = 0x0
    Write           = 0x1
    Traverse        = 0x2
    Enter           = 0x4
    Speak           = 0x8
    MuteDeafen      = 0x10
    Move            = 0x20
    MakeChannel     = 0x40
    LinkChannel     = 0x80
    Whisper         = 0x100
    TextMessage     = 0x200
    MakeTempChannel = 0x400
    Listen          = 0x800

    # Root channel only
    Kick             = 0x10000
    Ban              = 0x20000
    Register         = 0x40000
    SelfRegister     = 0x80000
    ResetUserContent = 0x100000

    Cached = 0x8000000

    All = Write + Traverse + Enter + Speak + MuteDeafen + Move + MakeChannel + LinkChannel + Whisper +
      TextMessage + MakeTempChannel + Listen + Kick + Ban + Register + SelfRegister + ResetUserContent

    Default = Traverse | Enter | Speak | Whisper | TextMessage | Listen
  end

  # TODO: cache
  # defines :all_cache
  # all_cache ::Concurrent::Hash.new

  # TODO
  # param :channel
  # param :perm, default: -> { Permissions::Default }

  # TODO
  # def self.has_permission(user, chan, perm)
  #   Permissions::None != (granted_permissions(user, chan) & perm)
  # end

  # TODO: cache and calculation
  def self.granted_permissions(user, _channel)
    client[:user_id].nil? ? Permissions::Default : Permissions::All
  end
end
