.PHONY: install

define ANNOUNCE_INSTALL

	 = 🔥

  Install to /usr/bin/layout.nvim ?

endef
export ANNOUNCE_INSTALL

install:
	export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
	git clone ./.git ${XDG_CONFIG_HOME}/nvim-apps/layout.nvim
	# rm -r ${XDG_CONFIG_HOME}/nvim-apps/layout.nvim/lua/layout
	cd ${XDG_CONFIG_HOME}/nvim-apps/layout.nvim
	chmod +x layout.nvim
	@echo "$$ANNOUNCE_INSTALL"
	sudo cp layout.nvim /usr/bin/layout.nvim

define ANNOUNCE_DEV

   = 🔥

	Set Debug/Release in lua/bootstrap/plugins.lua

endef
export ANNOUNCE_DEV


dev:
	export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
	rm -rf ${XDG_CONFIG_HOME}/nvim-apps/layout.nvim
	cp -r ./ ${XDG_CONFIG_HOME}/nvim-apps/layout.nvim/
	rm -r ${XDG_CONFIG_HOME}/nvim-apps/layout.nvim/lua/layout
	# sudo cp layout.nvim /usr/bin/layout.nvim
	@echo "$$ANNOUNCE_DEV"

define ANNOUNCE_DELETE

	  Delete?

	🔴 ${XDG_CONFIG_HOME}/nvim-apps/layout.nvim
	🔴 ${XDG_DATA_HOME}/nvim-apps/layout.nvim

endef
export ANNOUNCE_DELETE

clean:
	export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
	@echo "$$ANNOUNCE_DELETE"
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	rm -rf ${XDG_CONFIG_HOME}/nvim-apps/layout.nvim
	rm -rf ${XDG_DATA_HOME}/nvim-apps/layout.nvim
