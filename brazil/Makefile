###################
# MASTER MAKEFILE
###################

LIST_TARGETS=$(addsuffix /code,install_packages initialdata municipios_loaddata census_microdata nightlights summstats municipio_to_MSA MSA_traits MSA_comparisons shares popelast_plot distance_gradients compute_municipio_wages regress_MSA_wagesbysize populationelasticities pairwise_comparisons symlinks_graph printpaper publicdistro)

.PHONY: all $(LIST_TARGETS)

all: $(LIST_TARGETS)

$(LIST_TARGETS):
	$(MAKE) -C $@
