# Pull all dependencies for mtbf runner


mtbf-env = mtbf-env
virtual-env-exists = $(shell if [ -d "mtbf-env" ]; then echo "exists"; fi)

setup-combo: combo-runner virtual-env activate

delete-mtbf-env:
	@rm -rf mtbf-env

utils: get-branch combo-runner virtual-env activate lib-install github-remove b2g-flash-tool b2g-tool

v2.1: mtbf-v2.1 utils custom-gaia

v2.2: mtbf-v2.2 utils custom-gaia

v2.5: mtbf-v2.5 utils custom-gaia

v2.2-nexus-sleep: mtbf-v2.2-nexus-sleep utils custom-gaia

vmaster: mtbf-vmaster utils custom-gaia

downloader: b2g-flash-tool

b2g-tool:
	@git clone https://github.com/mozilla-b2g/B2G
	@cp -r B2G/tools .
	@rm -rf B2G
	@touch tools/__init__.py


virtual-env:
ifneq ($(virtual-env-exists),exists)
	@virtualenv ${mtbf-env}
else
	@echo "virtual environment exists." 
endif

custom-gaia:
ifdef gaiatest
	cp -r ${gaiatest} .;\
	chmod -R +w gaia-ui-tests;\
	cp -r ${gaiatest}/../../atoms gaia-ui-tests/gaiatest/;\
	chmod -R +w gaia-ui-tests;\
	if [ -z "$$VIRTUAL_ENV" ];\
		then . ./mtbf-env/bin/activate;\
	fi;\
	cd gaia-ui-tests;\
	python setup.py clean;\
	python setup.py install;\
	cd ..;\
	rm -rf gaia-ui-tests
else
	@echo use default gaiatest
endif

lib-install: virtual-env
	$(shell if [ -z "$$VIRTUAL_ENV" ]; then\
			 . ./mtbf-env/bin/activate;\
		fi;\
		pip install lockfile >/dev/null 2>&1;)

activate: mtbf-driver virtual-env
	if [ -z "$$VIRTUAL_ENV" ]; then\
		 . ./mtbf-env/bin/activate;\
	fi;\
	cd MTBF-Driver;\
	python setup.py clean;\
	python setup.py install;\
	cd ../combo-runner;\
	python setup.py clean;\
	python setup.py install;

github-remove:
	@rm -rf MTBF-Driver combo-runner

get-branch:
	@cd MTBF-Driver && branch=$(git branch | grep "\*" | awk '{print $2}') && cd ..;

mtbf-vmaster: mtbf-driver
	@cd MTBF-Driver && git checkout master;

mtbf-v2.2-nexus-sleep: mtbf-driver
	@cd MTBF-Driver && git checkout -b v2.2-nexus-sleep origin/v2.2-nexus-sleep;

mtbf-v2.5: mtbf-driver
	@cd MTBF-Driver && git checkout -b v2.5 origin/v2.5;

mtbf-v2.2: mtbf-driver
	@cd MTBF-Driver && git checkout -b v2.2 origin/v2.2;

mtbf-v2.1: mtbf-driver
	@cd MTBF-Driver && git checkout -b v2.1 origin/v2.1;

combo-runner:
	@git clone https://github.com/Mozilla-TWQA/combo-runner.git;

mtbf-driver:
	@git clone https://github.com/Mozilla-TWQA/MTBF-Driver.git; \
		cp -rf MTBF-Driver/mtbf_driver/conf .; \
		cp -rf MTBF-Driver/mtbf_driver/tests .; \
		cp -rf MTBF-Driver/mtbf_driver/runlist .;

update: 
	@cd MTBF-Driver; \
     git pull -u; \
     cd ../combo-runner; \
     git pull -u;

b2g-flash-tool:
	git clone https://github.com/Mozilla-TWQA/B2G-flash-tool.git; \
		cp -r B2G-flash-tool flash_tool; \
		cp -f b2g_download.py flash_tool; \
		rm -rf B2G-flash-tool;

clean:
	@rm -rf build conf runlist dist MTBF-Driver combo-runner B2G-flash-tool tools flash_tool gaia-ui-tests ${mtbf-env}
