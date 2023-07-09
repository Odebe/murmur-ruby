proto-gen:
	protoc proto/*.proto --plugin=protoc-gen-ruby-protobuf=/home/odebe/.rbenv/versions/3.2.0/lib/ruby/gems/3.2.0/gems/protobuf-3.10.7/bin/protoc-gen-ruby --ruby-protobuf_out=lib

generate-cert:
	openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out run/server.cert -keyout run/server.key

run-profile:
	(bundle exec ruby-prof main.rb ) &> prof2