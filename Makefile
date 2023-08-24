DOCKER := docker
EXT := dockerfile
SRC_DIR=docker
SOURCE := $(wildcard $(SRC_DIR)/*.$(EXT))  $(wildcard *.$(EXT))
DOCKERTYPES := $(sort $(SOURCE:.$(EXT)=))
DOCKERIMAGES := $(subst docker/,,$(subst -,_builder:,$(DOCKERTYPES)))

.PHONY: help
help:
	@echo "The following are valid targets:"
	@echo "  docker       - build all docker images"
	@echo "  <IMAGE>      - available images ($(DOCKERTYPES))"
	@echo "  install      - modify PATH in the ~/.profiles"
	@echo "  clean        - remove ALL changes in examples"
	@echo "  dist_clean   - remove sq-*-build scripts from PATH"
	@echo "  docker_clean - remove ALL created docker images"
	@echo "  clean_all    - performs all clean actions"
	@echo "  help         - get this help"

.PHONY: docker
docker: $(DOCKERTYPES)

.PHONY: $(DOCKERTYPES)
$(DOCKERTYPES):
	@$(DOCKER) build $(P) -f $@.$(EXT) -t $(subst $(SRC_DIR)/,,$(word 1, $(subst -, ,$@)))_builder$(word 2, $(subst -, :,$@)) .

.PHONY: install
install:
	@grep -q "source ${PWD}/scripts/profile.bash" ~/.bashrc \
	    || echo source ${PWD}/scripts/profile.bash >> ~/.bashrc

.PHONY: clean
clean:
	@git checkout HEAD -- examples \
	    || git clean -fd -- examples

.PHONY: dist_clean
dist_clean:
	@grep -q "source ${PWD}/scripts/profile.bash" ~/.bashrc \
	    && sed -i '\|source ${PWD}/scripts/profile.bash|d' ~/.bashrc \
	    || true

.PHONY: docker_clean
docker_clean:
	@docker rmi $(DOCKERIMAGES)

.PHONY: clean_all
clean_all: clean dist_clean docker_clean
