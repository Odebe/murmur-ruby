# frozen_string_literal: true

module Version
  PROTOBUF_INTRODUCTION_VERSION = Gem::Version.new("1.5.0")
  UNKNOWN_VERSION = 0

  #################################################################################################
  # The mumble version format (v2) is a uint64:
  # major   minor   patch   reserved/unused
  # 0xFFFF  0xFFFF  0xFFFF  0xFFFF
  # (big-endian)
  OFFSET_MAJOR  = 48
  OFFSET_MINOR  = 32
  OFFSET_PATCH  = 16
  OFFSET_UNUSED = 0
  FIELD_MASK    = 0xFFFF
  FIELD_MAJOR   = FIELD_MASK << OFFSET_MAJOR
  FIELD_MINOR   = FIELD_MASK << OFFSET_MINOR
  FIELD_PATCH   = FIELD_MASK << OFFSET_PATCH
  FIELD_UNUSED  = FIELD_MASK << OFFSET_UNUSED

  def self.from_v2(uint64)
    major = uint64 & FIELD_MAJOR
    minor = uint64 & FIELD_MINOR
    patch = uint64 & FIELD_PATCH

    Gem::Version.new("#{major}.#{minor}.#{patch}")
  end

  def self.to_v2(version)
    major, minor, patch = version.segments
    (major << OFFSET_MAJOR) | (minor << OFFSET_MINOR) | (patch << OFFSET_PATCH)
  end

  #################################################################################################
  # Mumble legacy version format (v1) is a uint32:
  # major   minor  patch
  # 0xFFFF  0xFF   0xFF
  # (big-endian)
  def self.from_v1(uint32)
    major = (uint32 & 0xFFFF0000) >> 16
    minor = (uint32 & 0x0000FF00) >> 8
    patch = (uint32 & 0x000000FF)

    Gem::Version.new("#{major}.#{minor}.#{patch}")
  end

  def self.to_v1(version)
    major, minor, patch = version.segments
    ((major & 0xFFFF) << 16) | ((minor & 0xFF) << 8) | (patch & 0xFF)
  end

  #################################################################################################

  SUPPORTED_PROTOCOL_VERSION = PROTOBUF_INTRODUCTION_VERSION
  SUPPORTED_PROTOCOL_VERSION_V2 = to_v2(SUPPORTED_PROTOCOL_VERSION)
  SUPPORTED_PROTOCOL_VERSION_V1 = to_v1(SUPPORTED_PROTOCOL_VERSION)

  #################################################################################################
end
