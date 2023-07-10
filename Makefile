generate-cert:
	openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out run/server.cert -keyout run/server.key

run-profile:
	(bundle exec ruby-prof main.rb ) &> ruby-prof.report
