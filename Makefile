VITAL_MODULES = Prelude \
								DateTime \
								System.Filepath \
								Data.String \
								Underscore

.PHONY: all
all:
	vim -c "Vitalize . --name=vimspy $(VITAL_MODULES)" -c q

.PHONY: doc
doc:
	vimdoc .

.PHONY: lint
lint:
	find . -name "*.vim" | grep -v vital | xargs beco vint

.PHONY: clean
clean:
	/bin/rm -rf autoload/vital*

