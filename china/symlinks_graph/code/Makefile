#Definitions
folders=../output
output= ../output/graphviz.txt ../output/task_flow.png

#Recipes
all: $(folders) $(output)

$(folders):
	mkdir $@

$(output): graphmaker.sh | $(folders)
	bash graphmaker.sh
