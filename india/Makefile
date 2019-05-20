# MASTER MAKEFILE

LIST_TARGETS=$(addsuffix /code,install_packages initialdata nightlights summstats SDT_MSA_loaddata town_MSA_loaddata urban_agglomerations zipf edushares populationelasticities pairwise_comparisons symlinks_graph printpaper publicdistro)

.PHONY: all $(LIST_TARGETS)

all: $(LIST_TARGETS)

$(LIST_TARGETS):
	$(MAKE) -C $@
