.PHONY: all compile run build

ELM=elm
ELECTRON=node_modules/.bin/electron
PACKAGER=node_modules/.bin/electron-packager
SOURCEDIR=src
APPDIR=app
BUILDDIR=builds

all: compile run

compile:
	$(ELM) make $(SOURCEDIR)/Mayoy.elm --output $(APPDIR)/mayoy.js

run:
	$(ELECTRON) $(APPDIR)/app.js $(APPDIR)

build:
	$(PACKAGER) ./ --out $(BUILDDIR) --overwrite --icon icon.icns
