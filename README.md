# SPORIX README Generator

A lightweight R-based command-line tool to generate standardized README files for projects and resources within **SPORIX**.
The generator provides predefined templates to document:

- Research projects
- Reference genomes
- Raw sequencing data
- RNA-seq analyses
- Genome annotations
- Workflows and pipelines
- Analysis results

## Requirements

- R
- `optparse`
- `pacman`

Required R packages are loaded automatically using `pacman::p_load()`.

## Installation

Clone or download this repository:

```bash
git clone https://github.com/imu93/sporix-readme-generator.git
cd sporix-readme-generator

