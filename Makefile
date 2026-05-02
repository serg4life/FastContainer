DESTDIR =

APP_NAME = run_container

CONTAINERS := generic-dev qemu-arm64-dev
CONTAINERS_DIR := /etc/containers

starter:
	@printf '#!/bin/bash\n$(APP_NAME) $$1\n' > starter
	@chmod +x starter

.PHONY: install starter clean

# Target principal: instala todo
install: starter $(CONTAINERS:%=install-%)

# Regla genérica por container (ESCALABLE)
.PHONY: install-%
install-%:
	@echo "Instalando $* en $(DESTDIR)${CONTAINERS_DIR}/$*"
	@mkdir -p $(DESTDIR)${CONTAINERS_DIR}/$*
	@cp -r containers/$*/* $(DESTDIR)${CONTAINERS_DIR}/$*/

clean:
	rm -f $(DESTDIR)/usr/bin/$(APP_NAME)
	rm -rf $(DESTDIR)${CONTAINERS_DIR}