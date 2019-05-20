###################
# MASTER MAKEFILE
###################


LIST_TARGETS=$(addsuffix /code,install_packages initialdata nightlights summstats townships_loaddata counties_loaddata distance_gradients edushares zipf msa_comparisons populationelasticities pairwise_comparisons symlinks_graph printpaper publicdistro)

.PHONY: all $(LIST_TARGETS)

all: $(LIST_TARGETS)

$(LIST_TARGETS):
	$(MAKE) -C $@
