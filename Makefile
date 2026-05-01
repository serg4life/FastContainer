DESTDIR =""
VERSION = "1.0-1"

default: install all

.PHONY: install
install:
	@echo "Installing generic-dev container configuration to $(DESTDIR)/etc/containers/generic-dev/"
	install -m 755 run_docker.sh $(DESTDIR)/usr/local/bin/run_container
	install -d generic-dev $(DESTDIR)/etc/containers/generic-dev
	cp -r generic-dev/* $(DESTDIR)/etc/containers/generic-dev/

.PHONY: clean
clean:
	@echo "Cleaning build artifacts (if any)"
	rm -rf /etc/containers/*
	rm -f /usr/local/bin/run_container