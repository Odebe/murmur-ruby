generate-test-cert:
# 	openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out run/server.cert -keyout run/server.key
	./ssl-certs.sh

PROTO_DIR = lib/proto/defs
RUBY_OUT = lib/proto

generate-proto:
	protoc --ruby_out=$(RUBY_OUT) --proto_path=$(PROTO_DIR) $(PROTO_DIR)/*.proto
	mv $(RUBY_OUT)/Mumble_pb.rb $(RUBY_OUT)/mumble.rb
	mv $(RUBY_OUT)/MumbleUDP_pb.rb $(RUBY_OUT)/mumble_udp.rb

run-profile:
	bundle exec ruby bin/profile.rb
