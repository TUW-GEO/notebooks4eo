.ONESHELL:
SHELL = /bin/bash
.PHONY: help clean environment kernel post-render data
YML = $(wildcard chapters/*.yml)
REQ = $(basename $(notdir $(YML)))
CONDA_ENV_DIR := $(foreach i,$(REQ),$(shell conda info --base)/envs/$(i))
KERNEL_DIR := $(foreach i,$(REQ),$(shell jupyter --data-dir)/kernels/$(i))
CONDA_ACTIVATE_BASE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate 
CONDA_ACTIVATE = $(CONDA_ACTIVATE_BASE) ; conda activate

help:
	@echo "make clean"
	@echo " clean all jupyter checkpoints"
	@echo "make environment"
	@echo " create a conda environment"
	@echo "make kernel"
	@echo " make ipykernel based on conda lock file"

clean:
	rm --force --recursive .ipynb_checkpoints/
	conda deactivate
	for i in $(REQ); do conda remove -n $$i --all -y ; jupyter kernelspec uninstall -y $$i ; done

$(CONDA_ENV_DIR):
	for i in $(YML); do conda env create -f $$i && pip install update pip setuptools wheel ; done

environment: $(CONDA_ENV_DIR)
	@echo -e "conda environments are ready."

$(KERNEL_DIR):
	$(CONDA_ACTIVATE_BASE)
	conda install jupyter -y
	for i in $(REQ); do $(CONDA_ACTIVATE) $$i ; python -m ipykernel install --user --name $$i --display-name $$i ; conda deactivate; done

kernel: $(KERNEL_DIR) $(CONDA_ENV_DIR)
	@echo -e "conda jupyter kernel is ready."

post-render:
	mv chapters/*.ipynb pangeo-workflow-examples/

data:
	wget -q -P ./data https://cloud.geo.tuwien.ac.at/s/AezWMFwmFQJsKyr/download/floodmap.zip
	cd data && unzip -n floodmap.zip && rm floodmap.zip