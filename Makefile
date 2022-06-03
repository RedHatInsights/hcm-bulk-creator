all:
	@echo "run 'make upload' to create sources, 'make destroy' to destroy them."

create:
	bash create.sh

destroy:
	bash destroy.sh
