# Pancreatic Injury Analysis Pipeline

This repository contains all scripts and resources used to generate the data and figures for the publication:

**Pancreatic injury induces β-cell regeneration in axolotl** ([DOI:10.1002/dvdy.70060](https://doi.org/10.1002/dvdy.70060))

---

## Full Reproduction Instructions

To reproduce the analysis end-to-end, run the scripts in `./scripts/` in the following order:

   ** note : prepare scanpy_env using `./bin/scanpy_env.yml` prior to running scripts 1 - 2

| Step | Script                                   | Purpose                                                                 |
|------|------------------------------------------|-------------------------------------------------------------------------|
| 0    | `0_dataverse_download.sh`                | Downloads raw FASTQ files (`./data/`), reference files (`./ref/`), and Seurat objects (`./output/seurat/`) from Dataverse |
| 1    | `1_transcriptome_download.sh`                          | Downloads transcriptome                          |
| 2  | `2_alignment_quant.sh`                     | Aligns and quantifies the sequencing data                           |
| 3    | `3_DE_analysis.Rmd` | Runs DESeq2 and generates plots       |
---

## Computational Environment

All analyses were conducted using the [Harvard FASRC Cluster](https://www.rc.fas.harvard.edu/) in 2025.

Software versions:

- Python v3.12.11 - see `./bin/nanopore_env.yml` for environment info

- R v4.3.3

---

## Data Availability

All raw data can be found at https://doi.org/10.7910/DVN/POAP0C

---

## Contact & Authorship

This repository is maintained by members of the **Whited Lab** at the **Harvard University Department of Stem Cell and Regenerative Biology**.


**Author Contact**  
- **Name:** Connor Powell
- **Email:** [connor_powell@fas.harvard.edu](mailto:connor_powell@fas.harvard.edu)  
- **Role:** Project Lead Scientist

**Repository Contact**  
- **Name:** Hani Singer  
- **Email:** [hani_singer@fas.harvard.edu](mailto:hani_singer@fas.harvard.edu)  
- **Role:** Research Laboratory Manager

**Principal Investigator**  
- **Name:** Dr. Jessica L. Whited  
- **Lab Website:** [www.whitedlab.com](http://www.whitedlab.com)  
- **Lab Email:** [whitedlab@gmail.com](mailto:whitedlab@gmail.com)


---

## Issues & Contributions

For questions, bug reports, or to contribute:
- Open an Issue at [https://github.com/Whited-Lab/project-axolotl-pancreatic-injury/issues](https://github.com/Whited-Lab/project-axolotl-pancreatic-injury/issues)
- Or contact us directly by email
