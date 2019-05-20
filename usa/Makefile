# MASTER MAKEFILE

LIST_TARGETS=$(addsuffix /code,install_packages initialdata nightlights counties_loaddata CBSA commuting county_to_MSA CBSA_comparison symlinks_graph printpaper)

.PHONY: all $(LIST_TARGETS)

all: $(LIST_TARGETS)

$(LIST_TARGETS):
	$(MAKE) -C $@
