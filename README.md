# MurmurRuby
Mumble server implemented with Ruby and [async-io gem](https://github.com/socketry/async-io).

## Installation
### Docker compose
* Clone repo `git clone git@github.com:Odebe/murmur-ruby.git`
* Generate SSL cert `make generate-cert`
* Build docker image `docker-compose build`
* Run container `docker-compose up -d`

## Configuration
See example `run/config.yml`

TODO

## Roadmap
- [ ] Messages
  - [ ] TCP
    - [x] Version
      - [x] Save client version
      - [ ] Send back actual server version
    - [x] UDPTunnel (see also 'Voice parsing')
      - [x] Loopback
      - [x] Channel speech
      - [ ] Target speech
    - [x] Authenticate
      - [x] Credentials checking
      - [x] Updating server's most popular CELT codec version
      - [x] Generating aes-128-ocb
      - [x] Announce users about new client
      - [x] Sync state
    - [x] Ping
      - [x] Send ping back
      - [ ] Update client timers
    - [x] Reject
    - [x] ServerSync
    - [ ] ChannelRemove
    - [x] ChannelState
      - [x] Send all states on connection
      - [ ] Links
      - [ ] Description
      - [ ] Permissions
      - [ ] Update by Admin
    - [x] UserRemove
      - [x] Announce users about client disconnection
    - [x] UserState
      - [x] Change channel
      - [x] Mute\Deafen self
    - [ ] BanList
    - [x] TextMessage
      - [ ] To Tree
      - [x] To client
      - [x] To channel
    - [x] PermissionDenied
    - [ ] ACL
    - [ ] QueryUsers
    - [x] CryptSetup
    - [ ] ContextActionModify
    - [ ] ContextAction
    - [ ] UserList
    - [ ] VoiceTarget
    - [x] PermissionQuery
    - [x] CodecVersion
    - [ ] UserStats
    - [ ] RequestBlob
    - [x] ServerConfig
    - [ ] SuggestConfig
  - [ ] UDP
    - [ ] Ping
    - [ ] Voice (see also 'Voice parsing')
- [ ] Voice parsing
  - [x] OPUS
  - [ ] CELT
  - [ ] Speex
- [ ] Basic role model
