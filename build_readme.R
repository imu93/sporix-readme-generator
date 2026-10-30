#!/usr/bin/env Rscript
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman", repos = "https://cloud.r-project.org")
}

pacman::p_load(optparse)
##############################################################################
# General options
general_options = list(
  make_option("--type", type = "character", default = NULL,
              help = "README type."),
  make_option("--name", type = "character", default = NULL,
              help = "Resource name."),
  make_option("--author", type = "character", default = NULL,
              help = "README author."),
  make_option("--date", type = "character", default = as.character(Sys.Date()),
              help = "README creation date."),
  make_option("--output", type = "character", default = "README.md",
              help = "Output README file."),
  make_option("--files", type = "character", default = NULL,
              help = "Path to the metadata table or file manifest."),
  make_option("--code", type = "character", default = NULL,
              help = "Comma-separated paths to processing scripts."),
  make_option("--notes", type = "character", default = NULL,
              help = "Notes about the resource."),
  make_option("--help-type", action = "store_true", default = FALSE,
              help = "Show help for the selected README type.")
)

##############################################################################
# Type-specific options
type_options = list(
  reference_genome = list(
    make_option("--accession", type = "character", default = NULL,
                help = "Assembly accession."),
    make_option("--organism", type = "character", default = NULL,
                help = "Organism name."),
    make_option("--strain", type = "character", default = NULL,
                help = "Strain or isolate."),
    make_option("--assembly-level", type = "character", default = NULL,
                help = "Assembly level."),
    make_option("--source-url", type = "character", default = NULL,
                help = "Reference source URL.")
  ),
  raw_data = list(
    make_option("--source", type = "character", default = NULL,
                help = "Data source."),
    make_option("--accession", type = "character", default = NULL,
                help = "Dataset accession."),
    make_option("--organism", type = "character", default = NULL,
                help = "Organism name."),
    make_option("--strain", type = "character", default = NULL,
                help = "Strain or isolate."),
    make_option("--sequencing-technology", type = "character", default = NULL,
                help = "Sequencing technology."),
    make_option("--seq-type", type = "character", default = NULL,
                help = "SINGLE-END or PAIRED-END."),
    make_option("--source-url", type = "character", default = NULL,
                help = "Data source URL.")
  ),
  rnaseq = list(
    make_option("--source", type = "character", default = NULL,
                help = "Data source: SRA, ENA or CUSTOM."),
    make_option("--accession", type = "character", default = NULL,
                help = "Dataset or run accession."),
    make_option("--bioproject", type = "character", default = NULL,
                help = "BioProject accession."),
    make_option("--biosample", type = "character", default = NULL,
                help = "BioSample accession."),
    make_option("--organism", type = "character", default = NULL,
                help = "Organism name."),
    make_option("--strain", type = "character", default = NULL,
                help = "Strain or isolate."),
    make_option("--condition", type = "character", default = NULL,
                help = "Experimental condition."),
    make_option("--seq-type", type = "character", default = NULL,
                help = "SINGLE-END or PAIRED-END."),
    make_option("--platform", type = "character", default = NULL,
                help = "Sequencing platform."),
    make_option("--source-url", type = "character", default = NULL,
                help = "Data source URL.")
  ),
  annotation = list(
    make_option("--accession", type = "character", default = NULL,
                help = "Annotation accession."),
    make_option("--organism", type = "character", default = NULL,
                help = "Organism name."),
    make_option("--strain", type = "character", default = NULL,
                help = "Strain or isolate."),
    make_option("--genome-assembly", type = "character", default = NULL,
                help = "Reference genome assembly."),
    make_option("--annotation-source", type = "character", default = NULL,
                help = "Annotation source."),
    make_option("--annotation-version", type = "character", default = NULL,
                help = "Annotation version."),
    make_option("--annotation-format", type = "character", default = NULL,
                help = "GTF or GFF3."),
    make_option("--source-url", type = "character", default = NULL,
                help = "Annotation source URL.")
  ),
  workflow = list(
    make_option("--workflow-name", type = "character", default = NULL,
                help = "Workflow name."),
    make_option("--description", type = "character", default = NULL,
                help = "Workflow description."),
    make_option("--version", type = "character", default = NULL,
                help = "Workflow version."),
    make_option("--repository", type = "character", default = NULL,
                help = "Git repository URL."),
    make_option("--nextflow-version", type = "character", default = NULL,
                help = "Nextflow version."),
    make_option("--execution-profile", type = "character", default = NULL,
                help = "Execution profile."),
    make_option("--container-engine", type = "character", default = NULL,
                help = "Container engine.")
  ),
  results = list(
    make_option("--result-name", type = "character", default = NULL,
                help = "Result name."),
    make_option("--result-type", type = "character", default = NULL,
                help = "Result type, e.g. assembly, VCF, phylogeny or BLAST."),
    make_option("--description", type = "character", default = NULL,
                help = "Analysis description."),
    make_option("--organism", type = "character", default = NULL,
                help = "Organism name."),
    make_option("--samples", type = "character", default = NULL,
                help = "Samples or dataset analyzed."),
    make_option("--reference", type = "character", default = NULL,
                help = "Reference genome or dataset."),
    make_option("--method", type = "character", default = NULL,
                help = "Analysis method."),
    make_option("--software", type = "character", default = NULL,
                help = "Software and versions."),
    make_option("--source-url", type = "character", default = NULL,
                help = "Source URL or repository.")
  ),
  project = list(
    make_option("--description", type = "character", default = NULL,
                help = "Project description."),
    make_option("--objectives", type = "character", default = NULL,
                help = "Scientific objectives."),
    make_option("--organisms", type = "character", default = NULL,
                help = "Organisms included in the project."),
    make_option("--samples", type = "character", default = NULL,
                help = "Samples or datasets included."),
    make_option("--start-date", type = "character", default = NULL,
                help = "Project start date."),
    make_option("--end-date", type = "character", default = NULL,
                help = "Project end date."),
    make_option("--status", type = "character", default = NULL,
                help = "Project status."),
    make_option("--principal-investigator", type = "character", default = NULL,
                help = "Principal investigator."),
    make_option("--collaborators", type = "character", default = NULL,
                help = "Project collaborators."),
    make_option("--repository", type = "character", default = NULL,
                help = "Project repository or Git URL."),
    make_option("--references", type = "character", default = NULL,
                help = "Project references.")
  )
)

##############################################################################
# Type-specific help
type_help = list(
  reference_genome = paste(
    "Reference genome README",
    "",
    "Example:",
    "Rscript build_readme.R --type reference_genome --name S288C",
    "  --organism 'Saccharomyces cerevisiae'",
    "  --accession GCA_000146045.2 --output README.md"
  ),
  raw_data = paste(
    "Raw sequencing data README",
    "",
    "The --files argument points to a metadata file.",
    "Expected columns can include ID, RAW_FASTQ and ED_FASTQ.",
    "",
    "Example:",
    "Rscript build_readme.R --type raw_data --name ONT_reads",
    "  --source CUSTOM --organism 'Saccharomyces cerevisiae'",
    "  --sequencing-technology ONT --seq-type SINGLE-END",
    "  --files metadata.md"
  ),
  rnaseq = paste(
    "RNA-seq README",
    "",
    "Example:",
    "Rscript build_readme.R --type rnaseq --name RNAseq_dataset",
    "  --source SRA --accession SRR12345678",
    "  --organism 'Saccharomyces cerevisiae'",
    "  --seq-type PAIRED-END --files metadata.md"
  ),
  annotation = paste(
    "Genome annotation README",
    "",
    "Example:",
    "Rscript build_readme.R --type annotation --name S288C_annotation",
    "  --organism 'Saccharomyces cerevisiae'",
    "  --genome-assembly S288C --annotation-format GFF3"
  ),
  workflow = paste(
    "Workflow README",
    "",
    "Example:",
    "Rscript build_readme.R --type workflow --name sRNAseq-nf",
    "  --version 1.0.0 --nextflow-version 26.04.6",
    "  --execution-profile SLURM --container-engine Apptainer"
  ),
  project = paste(
    "Generate a README for a general scientific project.",
    "",
    "Usage:",
    "  Rscript build_readme.R --type project --name <project_name>",
    "",
    "Options:",
    "  --description              Project description.",
    "  --objectives               Scientific objectives (comma-separated).",
    "  --organisms                Organisms included in the project (comma-separated).",
    "  --samples                  Samples or datasets included (comma-separated).",
    "  --start-date               Project start date.",
    "  --end-date                 Project end date.",
    "  --status                   Project status (e.g. ongoing, completed, archived).",
    "  --principal-investigator   Principal investigator.",
    "  --collaborators            Project collaborators (comma-separated).",
    "  --repository               Project repository or Git URL.",
    "  --references               Project references (comma-separated).",
    "  --notes                    Additional notes (semicolon-separated).",
    "",
    "Example:",
    "  Rscript build_readme.R --type project \\",
    "    --name 'Saccharomyces Comparative Genomics' \\",
    "    --description 'Comparative genomics of Saccharomyces isolates from Mexican agave fermentations.' \\",
    "    --objectives 'Genome assembly,Structural variation,Pangenome analysis' \\",
    "    --organisms 'Saccharomyces cerevisiae,Saccharomyces paradoxus' \\",
    "    --status ongoing \\",
    "    --principal-investigator 'Dr. Name' \\",
    "    --output README.md",
    sep = "\n"
  ),
  results = paste(
    "Analysis results README",
    "",
    "Example:",
    "Rscript build_readme.R --type results --name blast_results",
    "  --result-type BLAST --method BLASTP",
    "  --software 'BLAST+' --files results_metadata.md"
  )
)

##############################################################################
# README header
header = function(opt) {
  c(
    paste0("################ LEV_LAB ################"),
    paste0("# Created on: ", opt$date),
    paste0("# Author: ", opt$author),
    paste0("# README for: ", opt$type, " ", opt$name),
    paste0("############################################")
  )
}

##############################################################################
# Identify the selected type before parsing type-specific options
get_type = function(args) {
  i = which(args == "--type")
  if (length(i) > 0 && i[1] < length(args)) {
    return(args[i[1] + 1])
  }
  type_arg = grep("^--type=", args, value = TRUE)
  if (length(type_arg) > 0) {
    return(sub("^--type=", "", type_arg[1]))
  }
  return(NULL)
}

##############################################################################
# Parse arguments
args = commandArgs(trailingOnly = TRUE)
selected_type = get_type(args)
available_types = names(type_options)

if ("--help-type" %in% args && is.null(selected_type)) {
  cat("Available README types:\n")
  cat(paste0("  - ", available_types, collapse = "\n"), "\n")
  quit(status = 0)
}

if (!is.null(selected_type) && !selected_type %in% available_types) {
  stop(
    "Unknown README type: ", selected_type,
    "\nAvailable types: ", paste(available_types, collapse = ", "),
    call. = FALSE
  )
}

if (is.null(selected_type)) {
  selected_options = list()
  description = "Generate README files for LEV_LAB."
} else {
  selected_options = type_options[[selected_type]]
  description = paste("Generate README for type:", selected_type)
}

parser = OptionParser(
  option_list = c(general_options, selected_options),
  description = description
)

if ("--help-type" %in% args) {
  cat(type_help[[selected_type]], "\n\n")
  print_help(parser)
  quit(status = 0)
}

opt = parse_args(parser, args = args)

if (is.null(opt$type)) {
  print_help(parser)
  stop("Please specify --type.", call. = FALSE)
}



template_reference_genome = function(
    accession = NULL,
    organism = NULL,
    strain = NULL,
    assembly_level = NULL,
    source_url = NULL,
    download_date = Sys.Date(),
    code = NULL,
    notes = NULL,
    files = NULL) {
  
  # Helper for missing 
  
  field = function(x, label) {
    if (is.null(x) || length(x) == 0 ||
        is.na(x[1]) || !nzchar(trimws(as.character(x[1])))) {
      paste0("<!-- TODO: ", label, " -->")
    } else {
      as.character(x[1])
    }
  }
  
  ##############################################################################
  # Parse related code for any modification
  read_code = function(path) {
    if (!file.exists(path)) {
      stop("Code file not found: ", path, call. = FALSE)
    }
    if (dir.exists(path)) {
      stop("Expected a file, not a directory: ", path,
           call. = FALSE)
    }
    readLines(path, warn = FALSE)
  }
  
  code_section = c("## Processing code","")
  if (is.null(code) || length(code) == 0) {
    code_section = c(code_section, "<!-- TODO: Add code used for modifications. -->")
  } else {
    for (path in code) {
      code_section = c(code_section, paste0("### ", basename(path)), "", "```bash", read_code(path), "```", "")
    }
  }
  
  ##############################################################################
  # Read and reference any reatad file
  files_section = c("## Files","", "| File | Description |", "|---|---|")
  if (is.null(files) || length(files) == 0) {
    files_section = c(files_section,"| <!-- TODO: filename --> | <!-- TODO: description --> |")
  } else if (length(files) == 1 && is.null(names(files)) && file.exists(files[1])) {
    files_section = c(files_section, readLines(files[1], warn = FALSE))
  } else {
    if (is.null(names(files)) ||
        any(names(files) == "")) {
      stop(
        "'files' must be a metadata file path or a named character vector: ",
        call. = FALSE
      )
    }
    files_section = c(files_section,paste0("| ", names(files), " | ", unname(files), " |"))
  }
  
  ##############################################################################
  # Add notes
  notes_section = c("## Notes","")
  if (is.null(notes) || length(notes) == 0) {
    notes_section = c(notes_section, "<!-- TODO: Add notes about modifications or limitations. -->")
  } else {
    notes_section = c(notes_section, paste0("- ", notes))
  }
  ##############################################################################
  # README section
  readme = c(
    "## Reference genome information",
    "",
    "| Field | Value |",
    "|---|---|",
    paste0("| Organism | ", field(organism, "Organism"), " |"),
    paste0("| Strain | ", field(strain, "Strain"), " |"),
    paste0("| Accession | ", field(accession, "Assembly accession"), " |"),
    paste0("| Assembly level | ", field(assembly_level, "Assembly level"), " |"),
    paste0("| Source URL | ", field(source_url, "Source URL"), " |"),
    paste0("| Download date | ", download_date, " |"),
    "",
    files_section,
    "",
    code_section,
    "",
    notes_section,
    ""
  )
  
  return(readme)
}



template_annotation = function(
    accession = NULL,
    organism = NULL,
    strain = NULL,
    genome_assembly = NULL,
    annotation_source = NULL,
    annotation_version = NULL,
    annotation_format = NULL,
    source_url = NULL,
    download_date = Sys.Date(),
    code = NULL,
    notes = NULL,
    files = NULL) {
  
  # Helper for missing metadata
  field = function(x, label) {
    if (is.null(x) || length(x) == 0 ||
        is.na(x[1]) || !nzchar(trimws(as.character(x[1])))) {
      paste0("<!-- TODO: ", label, " -->")
    } else {
      as.character(x[1])
    }
  }
  
  ##############################################################################
  # Parse related code for any modification
  read_code = function(path) {
    if (!file.exists(path)) {
      stop("Code file not found: ", path, call. = FALSE)
    }
    if (dir.exists(path)) {
      stop("Expected a file, not a directory: ", path,
           call. = FALSE)
    }
    readLines(path, warn = FALSE)
  }
  
  code_section = c("## Processing code","")
  if (is.null(code) || length(code) == 0) {
    code_section = c(code_section, "<!-- TODO: Add code used for annotation processing. -->")
  } else {
    for (path in code) {
      code_section = c(code_section, paste0("### ", basename(path)), "", "```bash", read_code(path), "```", "")
    }
  }
  
  ##############################################################################
  # Read and reference any related file
  files_section = c("## Files","", "| File | Description |", "|---|---|")
  if (is.null(files) || length(files) == 0) {
    files_section = c(files_section,"| <!-- TODO: filename --> | <!-- TODO: description --> |")
  } else if (length(files) == 1 && is.null(names(files)) && file.exists(files[1])) {
    files_section = c(files_section, readLines(files[1], warn = FALSE))
  } else {
    if (is.null(names(files)) ||
        any(names(files) == "")) {
      stop(
        "'files' must be a metadata file path or a named character vector: ",
        call. = FALSE
      )
    }
    files_section = c(files_section,paste0("| ", names(files), " | ", unname(files), " |"))
  }
  
  ##############################################################################
  # Add notes
  notes_section = c("## Notes","")
  if (is.null(notes) || length(notes) == 0) {
    notes_section = c(notes_section, "<!-- TODO: Add notes about annotation methods, limitations or modifications. -->")
  } else {
    notes_section = c(notes_section, paste0("- ", notes))
  }
  ##############################################################################
  # README section
  readme = c(
    "## Genome annotation information",
    "",
    "| Field | Value |",
    "|---|---|",
    paste0("| Organism | ", field(organism, "Organism"), " |"),
    paste0("| Strain | ", field(strain, "Strain or isolate"), " |"),
    paste0("| Annotation accession | ", field(accession, "Annotation accession"), " |"),
    paste0("| Genome assembly | ", field(genome_assembly, "Reference genome assembly"), " |"),
    paste0("| Annotation source | ", field(annotation_source, "Annotation source"), " |"),
    paste0("| Annotation version | ", field(annotation_version, "Annotation version"), " |"),
    paste0("| Annotation format | ", field(annotation_format, "GTF or GFF3"), " |"),
    paste0("| Source URL | ", field(source_url, "Source URL"), " |"),
    paste0("| Download date | ", download_date, " |"),
    "",
    files_section,
    "",
    code_section,
    "",
    notes_section,
    ""
  )
  
  return(readme)
}


template_rnaseq = function(
    source = NULL,
    accession = NULL,
    bioproject = NULL,
    biosample = NULL,
    organism = NULL,
    strain = NULL,
    condition = NULL,
    seq_type = NULL,
    platform = NULL,
    source_url = NULL,
    download_date = Sys.Date(),
    code = NULL,
    notes = NULL,
    files = NULL) {
  
  # Helper for missing metadata
  field = function(x, label) {
    if (is.null(x) || length(x) == 0 ||
        is.na(x[1]) || !nzchar(trimws(as.character(x[1])))) {
      paste0("<!-- TODO: ", label, " -->")
    } else {
      as.character(x[1])
    }
  }
  
  ##############################################################################
  # Parse related code for any modification
  read_code = function(path) {
    if (!file.exists(path)) {
      stop("Code file not found: ", path, call. = FALSE)
    }
    if (dir.exists(path)) {
      stop("Expected a file, not a directory: ", path,
           call. = FALSE)
    }
    readLines(path, warn = FALSE)
  }
  
  code_section = c("## Processing code","")
  if (is.null(code) || length(code) == 0) {
    code_section = c(code_section, "<!-- TODO: Add code used for processing. -->")
  } else {
    for (path in code) {
      code_section = c(code_section, paste0("### ", basename(path)), "", "```bash", read_code(path), "```", "")
    }
  }
  
  ##############################################################################
  # Read and reference any related file
  files_section = c("## Files","")
  if (is.null(files) || length(files) == 0) {
    files_section = c(files_section, "<!-- TODO: Add metadata table. -->")
  } else {
    if (!file.exists(files)) {
      stop("Metadata file not found: ", files, call. = FALSE)
    }
    files_section = c(files_section, readLines(files, warn = FALSE))
  }
  
  ##############################################################################
  # Add notes
  notes_section = c("## Notes","")
  if (is.null(notes) || length(notes) == 0) {
    notes_section = c(notes_section, "<!-- TODO: Add notes about the dataset or processing. -->")
  } else {
    notes_section = c(notes_section, paste0("- ", notes))
  }
  
  ##############################################################################
  # README section
  readme = c(
    "## RNA-seq data information",
    "",
    "| Field | Value |",
    "|---|---|",
    paste0("| Source | ", field(source, "Data source: SRA, ENA or CUSTOM"), " |"),
    paste0("| Accession | ", field(accession, "Dataset or run accession"), " |"),
    paste0("| BioProject | ", field(bioproject, "BioProject accession"), " |"),
    paste0("| BioSample | ", field(biosample, "BioSample accession"), " |"),
    paste0("| Organism | ", field(organism, "Organism"), " |"),
    paste0("| Strain | ", field(strain, "Strain or isolate"), " |"),
    paste0("| Condition | ", field(condition, "Experimental condition"), " |"),
    paste0("| Sequencing type | ", field(seq_type, "SINGLE-END or PAIRED-END"), " |"),
    paste0("| Sequencing platform | ", field(platform, "Sequencing platform"), " |"),
    paste0("| Source URL | ", field(source_url, "Source URL"), " |"),
    paste0("| Download date | ", download_date, " |"),
    "",
    files_section,
    "",
    code_section,
    "",
    notes_section,
    ""
  )
  
  return(readme)
}


template_raw_data = function(
    source = NULL,
    accession = NULL,
    organism = NULL,
    strain = NULL,
    sequencing_technology = NULL,
    seq_type = NULL,
    source_url = NULL,
    download_date = Sys.Date(),
    code = NULL,
    notes = NULL,
    files = NULL) {
  
  # Helper for missing metadata
  field = function(x, label) {
    if (is.null(x) || length(x) == 0 ||
        is.na(x[1]) || !nzchar(trimws(as.character(x[1])))) {
      paste0("<!-- TODO: ", label, " -->")
    } else {
      as.character(x[1])
    }
  }
  
  ##############################################################################
  # Parse related code for any modification
  read_code = function(path) {
    if (!file.exists(path)) {
      stop("Code file not found: ", path, call. = FALSE)
    }
    if (dir.exists(path)) {
      stop("Expected a file, not a directory: ", path,
           call. = FALSE)
    }
    readLines(path, warn = FALSE)
  }
  
  code_section = c("## Processing code","")
  if (is.null(code) || length(code) == 0) {
    code_section = c(code_section, "<!-- TODO: Add code used for processing. -->")
  } else {
    for (path in code) {
      code_section = c(code_section, paste0("### ", basename(path)), "", "```bash", read_code(path), "```", "")
    }
  }
  
  ##############################################################################
  # Read and reference any related file
  files_section = c("## Files","")
  if (is.null(files) || length(files) == 0) {
    files_section = c(files_section, "<!-- TODO: Add metadata table with ID, RAW_FASTQ and ED_FASTQ. -->")
  } else {
    if (!file.exists(files)) {
      stop("Metadata file not found: ", files, call. = FALSE)
    }
    files_section = c(files_section, readLines(files, warn = FALSE))
  }
  
  ##############################################################################
  # Add notes
  notes_section = c("## Notes","")
  if (is.null(notes) || length(notes) == 0) {
    notes_section = c(notes_section, "<!-- TODO: Add notes about the dataset or processing. -->")
  } else {
    notes_section = c(notes_section, paste0("- ", notes))
  }
  
  ##############################################################################
  # README section
  readme = c(
    "## Raw sequencing data information",
    "",
    "| Field | Value |",
    "|---|---|",
    paste0("| Source | ", field(source, "Data source"), " |"),
    paste0("| Accession | ", field(accession, "Dataset accession"), " |"),
    paste0("| Organism | ", field(organism, "Organism"), " |"),
    paste0("| Strain | ", field(strain, "Strain or isolate"), " |"),
    paste0("| Sequencing technology | ", field(sequencing_technology, "Sequencing technology"), " |"),
    paste0("| Sequencing type | ", field(seq_type, "SINGLE-END or PAIRED-END"), " |"),
    paste0("| Source URL | ", field(source_url, "Source URL"), " |"),
    paste0("| Download date | ", download_date, " |"),
    "",
    files_section,
    "",
    code_section,
    "",
    notes_section,
    ""
  )
  
  return(readme)
}


template_workflow = function(
    workflow_name = NULL,
    description = NULL,
    version = NULL,
    repository = NULL,
    workflow_language = "Nextflow DSL2",
    nextflow_version = NULL,
    execution_profile = NULL,
    container_engine = NULL,
    source_url = NULL,
    update_date = Sys.Date(),
    code = NULL,
    notes = NULL,
    files = NULL) {
  
  # Helper for missing metadata
  field = function(x, label) {
    if (is.null(x) || length(x) == 0 ||
        is.na(x[1]) || !nzchar(trimws(as.character(x[1])))) {
      paste0("<!-- TODO: ", label, " -->")
    } else {
      as.character(x[1])
    }
  }
  
  ##############################################################################
  # Parse related code for any modification
  read_code = function(path) {
    if (!file.exists(path)) {
      stop("Code file not found: ", path, call. = FALSE)
    }
    if (dir.exists(path)) {
      stop("Expected a file, not a directory: ", path,
           call. = FALSE)
    }
    readLines(path, warn = FALSE)
  }
  
  code_section = c("## Workflow code","")
  if (is.null(code) || length(code) == 0) {
    code_section = c(code_section, "<!-- TODO: Add workflow code files. -->")
  } else {
    for (path in code) {
      code_section = c(code_section, paste0("### ", basename(path)), "", "```nextflow", read_code(path), "```", "")
    }
  }
  
  ##############################################################################
  # Read and reference any related file
  files_section = c("## Files","")
  if (is.null(files) || length(files) == 0) {
    files_section = c(files_section, "<!-- TODO: Add workflow file manifest. -->")
  } else {
    if (!file.exists(files)) {
      stop("Workflow file manifest not found: ", files, call. = FALSE)
    }
    files_section = c(files_section, readLines(files, warn = FALSE))
  }
  
  ##############################################################################
  # Add notes
  notes_section = c("## Notes","")
  if (is.null(notes) || length(notes) == 0) {
    notes_section = c(notes_section, "<!-- TODO: Add notes about execution, assumptions or limitations. -->")
  } else {
    notes_section = c(notes_section, paste0("- ", notes))
  }
  
  ##############################################################################
  # README section
  readme = c(
    "## Workflow information",
    "",
    "| Field | Value |",
    "|---|---|",
    paste0("| Workflow name | ", field(workflow_name, "Workflow name"), " |"),
    paste0("| Description | ", field(description, "Workflow description"), " |"),
    paste0("| Version | ", field(version, "Workflow version"), " |"),
    paste0("| Repository | ", field(repository, "Git repository"), " |"),
    paste0("| Workflow language | ", field(workflow_language, "Workflow language"), " |"),
    paste0("| Nextflow version | ", field(nextflow_version, "Nextflow version"), " |"),
    paste0("| Execution profile | ", field(execution_profile, "Execution profile, e.g. SLURM, local"), " |"),
    paste0("| Container engine | ", field(container_engine, "Container engine, e.g. Apptainer, Docker"), " |"),
    paste0("| Source URL | ", field(source_url, "Source URL"), " |"),
    paste0("| Last update | ", update_date, " |"),
    "",
    files_section,
    "",
    code_section,
    "",
    notes_section,
    ""
  )
  
  return(readme)
}

template_project = function(
    name,
    author = NULL,
    date = NULL,
    description = NULL,
    objectives = NULL,
    organisms = NULL,
    samples = NULL,
    start_date = NULL,
    end_date = NULL,
    status = NULL,
    principal_investigator = NULL,
    collaborators = NULL,
    repository = NULL,
    references = NULL,
    notes = NULL
) {
  
  # Helper function to format fields
  field = function(value, default = "Not specified") {
    if (is.null(value) || length(value) == 0 || is.na(value) || value == "") {
      return(default)
    }
    value
  }
  
  # Helper function to format lists
  format_list = function(x, default = "Not specified") {
    if (is.null(x) || length(x) == 0 || all(is.na(x)) || all(x == "")) {
      return(paste0("- ", default))
    }
    paste0("- ", x)
  }
  
  # Project information
  project_name = field(name)
  project_description = field(description)
  project_status = field(status)
  project_pi = field(principal_investigator)
  project_author = field(author)
  project_start = field(start_date)
  project_end = field(end_date)
  project_date = field(date)
  
  # Build README
  readme = c(
    paste0("# ", project_name),
    "",
    "## Project Overview",
    "",
    project_description,
    "",
    "## Scientific Objectives",
    "",
    format_list(objectives),
    "",
    "## Project Information",
    "",
    paste0("- **Principal Investigator:** ", project_pi),
    paste0("- **Author:** ", project_author),
    paste0("- **Status:** ", project_status),
    paste0("- **Start date:** ", project_start),
    paste0("- **End date:** ", project_end),
    paste0("- **Last update:** ", project_date),
    "",
    "## Organisms",
    "",
    format_list(organisms),
    "",
    "## Samples and Datasets",
    "",
    format_list(samples),
    "",
    "## Collaborators",
    "",
    format_list(collaborators),
    "",
    "## Project Repository",
    "",
    field(repository),
    "",
    "## References",
    "",
    format_list(references),
    "",
    "## Notes",
    "",
    format_list(notes),
    "",
    "---",
    "",
    paste0("*README generated by SPORIX_LAB on ", Sys.Date(), ".*")
  )
  
  return(readme)
}

template_results = function(
    result_name = NULL,
    result_type = NULL,
    description = NULL,
    organism = NULL,
    samples = NULL,
    reference = NULL,
    method = NULL,
    software = NULL,
    source_url = NULL,
    analysis_date = Sys.Date(),
    code = NULL,
    notes = NULL,
    files = NULL) {
  
  # Helper for missing metadata
  field = function(x, label) {
    if (is.null(x) || length(x) == 0 ||
        is.na(x[1]) || !nzchar(trimws(as.character(x[1])))) {
      paste0("<!-- TODO: ", label, " -->")
    } else {
      as.character(x[1])
    }
  }
  
  ##############################################################################
  # Parse related code for any modification
  read_code = function(path) {
    if (!file.exists(path)) {
      stop("Code file not found: ", path, call. = FALSE)
    }
    if (dir.exists(path)) {
      stop("Expected a file, not a directory: ", path,
           call. = FALSE)
    }
    readLines(path, warn = FALSE)
  }
  
  code_section = c("## Processing code","")
  if (is.null(code) || length(code) == 0) {
    code_section = c(code_section, "<!-- TODO: Add code used to generate the results. -->")
  } else {
    for (path in code) {
      code_section = c(code_section, paste0("### ", basename(path)), "", "```bash", read_code(path), "```", "")
    }
  }
  
  ##############################################################################
  # Read and reference any related file
  files_section = c("## Files","")
  if (is.null(files) || length(files) == 0) {
    files_section = c(files_section, "<!-- TODO: Add results metadata table. -->")
  } else {
    if (!file.exists(files)) {
      stop("Results metadata file not found: ", files, call. = FALSE)
    }
    files_section = c(files_section, readLines(files, warn = FALSE))
  }
  
  ##############################################################################
  # Add notes
  notes_section = c("## Notes","")
  if (is.null(notes) || length(notes) == 0) {
    notes_section = c(notes_section, "<!-- TODO: Add notes about interpretation, limitations or relevant details. -->")
  } else {
    notes_section = c(notes_section, paste0("- ", notes))
  }
  
  ##############################################################################
  # README section
  readme = c(
    "## Results information",
    "",
    "| Field | Value |",
    "|---|---|",
    paste0("| Result name | ", field(result_name, "Result name"), " |"),
    paste0("| Result type | ", field(result_type, "Result type, e.g. assembly, VCF, phylogeny, BLAST"), " |"),
    paste0("| Description | ", field(description, "Analysis description"), " |"),
    paste0("| Organism | ", field(organism, "Organism"), " |"),
    paste0("| Samples | ", field(samples, "Samples or dataset analyzed"), " |"),
    paste0("| Reference | ", field(reference, "Reference genome or dataset"), " |"),
    paste0("| Method | ", field(method, "Analysis method"), " |"),
    paste0("| Software | ", field(software, "Software and versions"), " |"),
    paste0("| Source URL | ", field(source_url, "Source URL or repository"), " |"),
    paste0("| Analysis date | ", analysis_date, " |"),
    "",
    files_section,
    "",
    code_section,
    "",
    notes_section,
    ""
  )
  
  return(readme)
}

##############################################################################
# Generate README
template_functions = list(
  project = template_project,
  reference_genome = template_reference_genome,
  raw_data = template_raw_data,
  rnaseq = template_rnaseq,
  annotation = template_annotation,
  workflow = template_workflow,
  results = template_results
)

if (is.null(opt$name) || !nzchar(trimws(opt$name))) {
  stop("Please specify --name.", call. = FALSE)
}

template_args = as.list(opt)
template_args$type = NULL
template_args$name = NULL
template_args$author = NULL
template_args$date = NULL
template_args$output = NULL
template_args$help_type = NULL

if (!is.null(opt$code) && nzchar(opt$code)) {
  template_args$code = trimws(strsplit(opt$code, ",", fixed = TRUE)[[1]])
}

if (!is.null(opt$notes) && nzchar(opt$notes)) {
  template_args$notes = trimws(strsplit(opt$notes, ";", fixed = TRUE)[[1]])
}

if (opt$type == "project") {
  template_args$name = opt$name
  template_args$author = NULL
  template_args$date = NULL
  
  list_options = c(
    "objectives",
    "organisms",
    "samples",
    "collaborators",
    "references"
  )
  
  for (option in list_options) {
    if (!is.null(template_args[[option]]) && nzchar(template_args[[option]])) {
      template_args[[option]] = trimws(
        strsplit(template_args[[option]], ",", fixed = TRUE)[[1]]
      )
    }
  }
}

if (opt$type == "workflow" && is.null(template_args$workflow_name)) {
  template_args$workflow_name = opt$name
}

if (opt$type == "results" && is.null(template_args$result_name)) {
  template_args$result_name = opt$name
}

if (!is.null(opt$date)) {
  if (opt$type %in% c("reference_genome", "raw_data", "rnaseq", "annotation")) {
    template_args$download_date = opt$date
  } else if (opt$type == "workflow") {
    template_args$update_date = opt$date
  } else if (opt$type == "results") {
    template_args$analysis_date = opt$date
  }
}

template_function = template_functions[[opt$type]]
template_formals = names(formals(template_function))
template_args = template_args[names(template_args) %in% template_formals]

readme = do.call(template_function, template_args)
readme = c(header(opt), "", readme)

writeLines(readme, con = opt$output)
message("README created: ", opt$output)
