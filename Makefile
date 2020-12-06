KICK_ASSEMBLER_URL := http://www.theweb.dk/KickAssembler/KickAssembler.zip

.PHONY: bootstrap
bootstrap: /usr/local/opt/openjdk/bin/java vendor/KickAssembler/KickAss.jar vendor/64spec
# https://phoenixnap.dl.sourceforge.net/project/c64-debugger/C64-65XE-Debugger-v0.64.58-MacOS.zip

.PHONY: clean
clean:
	# -find . -type f -name '.asminfo.txt' -exec rm {} +
	-find . -type f -name '.source.txt' -exec rm {} +
	-find . -type f -name '*.sym' -exec rm {} +
	-find . -type f -name '*.prg' -exec rm {} +
	-find . -type f -name '*.vs' -exec rm {} +

.PHONY: clean-deps
clean-deps:
	-rm -rf vendor/*
	touch vendor/.gitkeep

# vendor/64spec:
#
/usr/local/opt/openjdk/bin/java:
	brew install openjdk

vendor/KickAssembler:
	-mkdir $@

vendor/KickAssembler.zip: vendor
	curl -L $(KICK_ASSEMBLER_URL) -o $@

vendor/KickAssembler/KickAss.jar: vendor/KickAssembler vendor/KickAssembler.zip
	unzip -o vendor/KickAssembler.zip -d $<

vendor/64spec:
	git clone https://github.com/64bites/64spec.git $@

vendor/64spec/6502_tester: vendor/64spec
	pushd $<; make; popd
