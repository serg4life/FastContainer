DESTDIR =
VERSION = "1.0-1"

APP_NAME = run_container

CONTAINER_NAME = generic-dev
CONTAINERS_DIR = /etc/containers
CONTAINER_PATH=$(CONTAINERS_DIR)/$(CONTAINER_NAME)

default: install all

starter:
	printf '#!/bin/bash\n$(APP_NAME) $$1\n' > starter
	chmod +x starter

.PHONY: install
install: starter
	install -m 755 run_docker.sh $(DESTDIR)/usr/bin/$(APP_NAME)
	install -d ${DESTDIR}$(CONTAINER_PATH)
	cp -r ${CONTAINER_NAME}/* $(DESTDIR)${CONTAINER_PATH}/
	install -m 755 starter $(DESTDIR)${CONTAINERS_DIR}/
	rm -f starter

.PHONY: clean
clean:
	rm -f $(DESTDIR)/usr/bin/$(APP_NAME)
	rm -rf $(DESTDIR)${CONTAINERS_DIR}