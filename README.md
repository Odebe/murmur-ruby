# MurmurRuby
Mumble server implemented with Ruby and [async-io gem](https://github.com/socketry/async-io).

## Installation
### Docker compose
* Clone repo `git clone git@github.com:Odebe/murmur-ruby.git`
* Generate SSL cert `make generate-cert`
* Build docker image `docker-compose build`
* Run container `docker-compose up -d`

## Roadmap
- [ ] Messages
  - [ ] TCP
    - [x] Version
      - [x] Save client version
      - [ ] Send back the actual server version
    - [x] UDPTunnel (see also 'Voice parsing')
      - [x] Loopback
      - [x] Channel speech
      - [ ] Target speech
    - [x] Authenticate
      - [x] Credentials checking
      - [x] Updating the server's most popular CELT codec version
      - [x] Generating aes-128-ocb
      - [x] Announce users about new client
      - [x] Sync state
    - [x] Ping
      - [x] Send a ping back
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
- [ ] Traffic shaping
  - [x] Throttling
  - [ ] Leaky bucket

## Configuration
See example `run/config.yml`

### General configuration parameters
#### Connection block
```yaml
host: 0.0.0.0
port: 64_738
```

#### SSL block
```yaml
ssl_cert: 'run/server.cert'
ssl_key: 'run/server.key'
```

#### Server settings
```yaml
# Bits per second
max_bandwidth: 192_000

welcome_text: 'Hello world!'
allow_html: false
image_message_length: 0
max_users: 15
recording_allowed: true
max_username_length: 20
message_length: 500
```

### Channel configuration
Channels are defined by array in `rooms` key in config file.

Channel has to contain fields `id`, `name`, `parent_id` and `position`.

Root channel is mandatory and defined by `parent_id: null` nd `id: 0`.
```yaml
rooms:
  - id: 0
    name: Root
    parent_id: null
    position: 0
  - id: 1
    name: guest_room
    parent_id: 0
    position: 1
  - id: 2
    name: forum
    parent_id: 0
    position: 0
```

### Users configuration
Registered users are defined by array in `users` key in config file.

```yaml
users:
  - id: 0
    username: admin
    password: example
```
