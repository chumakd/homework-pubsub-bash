.PHONY: build run run-dev test clean help

PUBSUBD_PORT := 3000

build:
	docker build -t local/pubsubd .

run-dev: export DEVMODE := true
run-dev: export PUBSUBD_CMD := pubsubd --verbose
run-dev: run

run:
	docker run -it --rm -p $(PUBSUBD_PORT):3000 \
		       --tmpfs /memstor$${PUBSUBD_STOR_SIZE:+:size=$(PUBSUBD_STOR_SIZE)} \
		       --workdir /memstor \
		       --name pubsubd-devel \
		       $${DEVMODE:+--volume $${PWD}:/usr/local/sbin:ro} \
		   local/pubsubd $${PUBSUBD_CMD:+"$(PUBSUBD_CMD)"}

test:
	@./test --verbose

clean:
	@if docker container inspect -f '{{.Id}}' pubsubd-devel >/dev/null 2>&1 ; then \
	    docker rm --force pubsubd-devel || true ; \
	fi

help:
	@echo '  build    -- generate pubsubd docker image'
	@echo '  run      -- run pubsubd in a docker container, which listens on'
	@echo '              port $(PUBSUBD_PORT)'
	@echo '  run-dev  -- same as "run" but mounts $$PWD to /usr/local/sbin,'
	@echo '              which enables live code reload inside the running container'
	@echo '  test     -- run basic test script'
	@echo '  clean    -- remove pubsubd docker container'
