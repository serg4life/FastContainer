DESTDIR =

APP_NAME = run_container

CONTAINERS := generic-dev qemu-arm64-dev
CONTAINERS_DIR := /etc/containers

starter:
	@printf '#!/bin/bash\n$(APP_NAME) $$1\n' > starter

.PHONY: install starter clean

# Target principal: instala todo
install: $(APP_NAME) $(CONTAINERS:%=install-%)

$(APP_NAME): starter
	install -m 755 run_docker.sh $(DESTDIR)/usr/bin/$(APP_NAME)
	install -m 755 starter $(DESTDIR)${CONTAINERS_DIR}
	install -m 755 scripts/project-configurator-reduced.sh $(DESTDIR)/usr/bin/project-configurator
	rm -f starter

# Regla genérica por container (ESCALABLE)
.PHONY: install-%
install-%:
	mkdir -p $(DESTDIR)${CONTAINERS_DIR}/$*
	cp -r containers/$*/* $(DESTDIR)${CONTAINERS_DIR}/$*/

clean:
	rm -f $(DESTDIR)/usr/bin/$(APP_NAME)
	rm -rf $(DESTDIR)${CONTAINERS_DIR}