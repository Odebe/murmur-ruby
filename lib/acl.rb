# frozen_string_literal: true

# BIG TODO
# Mumble sources: src/ACL.cpp
class Acl
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

    ALL =
      Write | Traverse | Enter | Speak | MuteDeafen | Move |
      MakeChannel | LinkChannel | Whisper | TextMessage |
      MakeTempChannel | Listen | Kick | Ban | Register |
      SelfRegister | ResetUserContent |Cached

    DEFAULT =
      Traverse | Enter | Speak | Whisper | TextMessage | Listen

    NOT_IMPLEMENTED =
      Move | MakeChannel | LinkChannel | Whisper |
      MakeTempChannel | Kick | Ban | Register |
      SelfRegister | ResetUserContent | Cached

    module Implemented
      ALL     = Permissions::ALL     & ~Permissions::NOT_IMPLEMENTED
      DEFAULT = Permissions::DEFAULT & ~Permissions::NOT_IMPLEMENTED
    end
  end

  def self.granted_permissions(client, _channel)
    client[:user_id].nil? ? Permissions::Implemented::DEFAULT : Permissions::Implemented::ALL
  end
end
