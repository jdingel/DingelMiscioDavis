all: ../output ../output/graphviz.txt ../output/task_flow.png

../output:
	mkdir $@

../output/graphviz.txt ../output/task_flow.png: graphmaker.sh | ../output
	bash graphmaker.sh
