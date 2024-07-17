.ONESHELL:
SHELL = /bin/bash
.PHONY: help clean environment kernel post-render data
YML = $(wildcard chapters/*.yml)
REQ = $(basename $(notdir $(YML)))
CONDA_ENV_DIR = $(shell conda info --base)/envs/$(REQ)
KERNEL_DIR = $(shell jupyter --data-dir)/kernels/$(REQ)
CONDA_ACTIVATE = source $$(conda info --base)/etc/profile.d/conda.sh ; conda activate ; conda activate

help:
	@echo "make clean"
	@echo " clean all jupyter checkpoints"
	@echo "make environment"
	@echo " create a conda environment"
	@echo "make kernel"
	@echo " make ipykernel based on conda lock file"

clean:
	rm --force --recursive .ipynb_checkpoints/
	conda deactivate; for i in $(REQ); do conda remove -n $$i --all -y 2>&1 2>/dev/null; jupyter kernelspec uninstall -y $$i 2>&1 2>/dev/null; done

$(CONDA_ENV_DIR):
	for i in $(YML); do conda env create -f $$i && pip install update pip setuptools wheel 2>&1 2>/dev/null; done

environment: $(CONDA_ENV_DIR)
	@echo -e "conda environments are ready."

$(KERNEL_DIR):
	for i in $(REQ); do	$(CONDA_ACTIVATE) $$i ; python -m ipykernel install --user --name $$i --display-name $$i ; conda deactivate; done

kernel: $(CONDA_ENV_DIR) $(KERNEL_DIR)
	@echo -e "conda jupyter kernel is ready."

post-render:
	mv chapters/*.ipynb pangeo-workflow-examples/

data:
	wget -q -P ./data https://cloud.geo.tuwien.ac.at/s/AezWMFwmFQJsKyr/download/floodmap.zip
	cd data && unzip -n floodmap.zip && rm floodmap.zip
	