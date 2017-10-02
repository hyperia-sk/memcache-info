prefix=/usr/local
TASK_DONE = echo "\n✓ $@ done\n"
# files that need mode 755
EXEC_FILES=memcache-info

.PHONY: test

all:
	@echo "usage: make install"
	@echo "       make uninstall"
	@echo "       make reinstall"
	@echo "       make test"

help:
	$(MAKE) all
	@$(TASK_DONE)

install:
	install -m 0755 $(EXEC_FILES) $(prefix)/bin
	@$(TASK_DONE)

uninstall:
	test -d $(prefix)/bin && \
	cd $(prefix)/bin && \
	rm -f $(EXEC_FILES)
	@$(TASK_DONE)

reinstall:
	git pull origin master
	$(MAKE) uninstall && \
	$(MAKE) install
	@$(TASK_DONE)

test:
	tests/commands_test.sh
	@$(TASK_DONE)