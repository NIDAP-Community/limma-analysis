#!/usr/bin/env Rscript

# Adapter-only entrypoint. The canonical OMIX CLI and R implementation remain
# byte-preserved under scripts/ and R/. This wrapper validates the deployment
# boundary, invokes that CLI unchanged, and creates a stable result bundle.
args <- commandArgs(trailingOnly = TRUE)
canonical_script <- file.path("scripts", "run_limma_analysis.R")

if (!file.exists(canonical_script)) {
  stop("Canonical Limma CLI is missing: ", canonical_script)
}

option_value <- function(name, values) {
  exact <- which(values == name)
  if (length(exact) == 1L && exact < length(values)) return(values[[exact + 1L]])
  prefix <- paste0(name, "=")
  inline <- values[startsWith(values, prefix)]
  if (length(inline) == 1L) return(substring(inline, nchar(prefix) + 1L))
  NULL
}

required_option <- function(name, values) {
  value <- option_value(name, values)
  if (is.null(value) || !nzchar(trimws(value))) stop(name, " is required for this adapter.")
  value
}

read_declared_table <- function(path, label) {
  extension <- tolower(tools::file_ext(path))
  if (extension == "rds") {
    object <- readRDS(path)
    if (is.matrix(object)) return(as.data.frame(object, check.names = FALSE))
    if (is.data.frame(object)) return(object)
    stop(label, " RDS must contain a matrix or data frame.")
  }
  if (extension == "csv") return(utils::read.csv(path, check.names = FALSE, stringsAsFactors = FALSE))
  if (extension %in% c("tsv", "txt")) return(utils::read.delim(path, check.names = FALSE, stringsAsFactors = FALSE))
  stop(label, " must be CSV, TSV, TXT, or RDS.")
}

allowed_input_data_types <- c(
  "microarray_log2_expression", "normalized_bulk_expression",
  "log2_cpm_without_voom_weights", "sctransform_mean_expression",
  "harmony_corrected_mean_expression", "gsva_enrichment_scores",
  "cibersort_relative_fractions", "cibersort_absolute_scores",
  "methylation_m_values", "normalized_proteomics", "normalized_metabolomics",
  "qpcr_delta_ct", "copy_number_log2_ratios",
  "normalized_chromatin_accessibility", "normalized_crispr_scores",
  "other_continuous"
)

describe_identifiers <- function(values) {
  if (length(values) == 0L) return("<none>")
  paste(utils::head(values, 5L), collapse = ", ")
}

`%||%` <- function(left, right) if (is.null(left)) right else left

validate_adapter_request <- function(arguments) {
  matrix_path <- required_option("--matrix", arguments)
  metadata_path <- required_option("--metadata", arguments)
  output_dir <- required_option("--output_dir", arguments)
  input_data_type <- required_option("--input_data_type", arguments)
  gene_column <- option_value("--gene_names_column", arguments) %||% "GeneName"
  sample_column <- option_value("--sample_names_column", arguments) %||% "Sample"

  if (!file.exists(matrix_path) || file.access(matrix_path, 4L) != 0L) {
    stop("--matrix must name a readable declared continuous-matrix artifact.")
  }
  if (!file.exists(metadata_path) || file.access(metadata_path, 4L) != 0L) {
    stop("--metadata must name a readable sample-metadata artifact.")
  }
  if (!input_data_type %in% allowed_input_data_types) {
    stop("--input_data_type must be an explicit supported continuous type; 'auto' and raw counts are not accepted by this adapter.")
  }

  manifest_path <- option_value("--pseudobulk_manifest", arguments)
  if (!is.null(manifest_path) && nzchar(trimws(manifest_path))) {
    if (!file.exists(manifest_path) || file.access(manifest_path, 4L) != 0L) {
      stop("--pseudobulk_manifest must name a readable approved manifest.")
    }
    manifest <- base::read.dcf(manifest_path)
    if (nrow(manifest) != 1L) stop("--pseudobulk_manifest must contain exactly one record.")
    if ("matrix_type" %in% colnames(manifest) && identical(trimws(unname(manifest[1L, "matrix_type"])), "raw_integer_counts")) {
      stop("The supplied manifest declares raw_integer_counts. Use a count-aware workflow, not this continuous-matrix adapter.")
    }
  }

  matrix <- read_declared_table(matrix_path, "--matrix")
  metadata <- read_declared_table(metadata_path, "--metadata")
  if (!gene_column %in% names(matrix)) stop("Feature identifier column '", gene_column, "' was not found in --matrix.")
  if (!sample_column %in% names(metadata)) stop("Sample identifier column '", sample_column, "' was not found in --metadata.")
  if (anyDuplicated(names(matrix))) stop("--matrix contains duplicate column names.")
  if (anyDuplicated(as.character(metadata[[sample_column]]))) stop("--metadata contains duplicate sample identifiers.")

  matrix_samples <- setdiff(names(matrix), gene_column)
  metadata_samples <- as.character(metadata[[sample_column]])
  if (length(matrix_samples) == 0L) stop("--matrix has no sample columns after the feature identifier column.")
  if (anyNA(metadata_samples) || any(!nzchar(trimws(metadata_samples)))) {
    stop("--metadata contains missing or empty sample identifiers.")
  }
  non_numeric <- matrix_samples[!vapply(matrix[matrix_samples], is.numeric, logical(1L))]
  if (length(non_numeric) > 0L) {
    stop("--matrix sample columns must be numeric continuous values; nonnumeric columns: ", describe_identifiers(non_numeric))
  }
  if (any(!is.finite(as.matrix(matrix[matrix_samples])))) {
    stop("--matrix contains missing, infinite, or non-finite sample values.")
  }
  missing_from_matrix <- setdiff(metadata_samples, matrix_samples)
  missing_from_metadata <- setdiff(matrix_samples, metadata_samples)
  if (length(missing_from_matrix) > 0L || length(missing_from_metadata) > 0L) {
    stop(
      "--matrix and --metadata sample identifiers must align exactly. Missing from matrix: ",
      describe_identifiers(missing_from_matrix), "; missing from metadata: ",
      describe_identifiers(missing_from_metadata)
    )
  }

  if (dir.exists(output_dir) && length(list.files(output_dir, all.files = TRUE, no.. = TRUE)) > 0L) {
    stop("--output_dir must be a new or empty directory so a prior manifest cannot be mistaken for this run.")
  }
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  output_dir <- normalizePath(output_dir, mustWork = TRUE)
  list(
    matrix_path = normalizePath(matrix_path, mustWork = TRUE),
    metadata_path = normalizePath(metadata_path, mustWork = TRUE),
    output_dir = output_dir,
    input_data_type = input_data_type
  )
}

copy_artifact <- function(source, destination, role) {
  if (!file.exists(source) || !file.copy(source, destination, overwrite = FALSE)) {
    stop("Could not preserve completed canonical artifact: ", role)
  }
}

write_bundle <- function(request, arguments) {
  artifacts <- data.frame(
    role = c(
      "Limma inferential result table", "Modeled sample metadata",
      "Variance diagnostic table", "Variance diagnostic figure", "Canonical run summary"
    ),
    source = c(
      "Limma_Analysis.csv", "Sample_Metadata.csv", "Variance_Diagnostic.csv",
      "variance_diagnostic.png", "run_summary.txt"
    ),
    destination = c(
      "tables/Limma_Analysis.csv", "tables/Sample_Metadata.csv", "tables/Variance_Diagnostic.csv",
      "figures/variance_diagnostic.png", "logs/run_summary.txt"
    ),
    stringsAsFactors = FALSE
  )
  batch_source <- file.path(request$output_dir, "Batch_Corrected_Expression.csv")
  if (file.exists(batch_source)) {
    artifacts <- rbind(artifacts, data.frame(
      role = "Batch-corrected continuous matrix for downstream use (not inferential Limma results)",
      source = "Batch_Corrected_Expression.csv",
      destination = "tables/Batch_Corrected_Expression.csv",
      stringsAsFactors = FALSE
    ))
  }
  if (!all(file.exists(file.path(request$output_dir, artifacts$source)))) {
    stop("Canonical Limma run did not create all required artifacts.")
  }
  for (directory in unique(dirname(artifacts$destination))) {
    dir.create(file.path(request$output_dir, directory), recursive = TRUE, showWarnings = FALSE)
  }
  for (index in seq_len(nrow(artifacts))) {
    copy_artifact(
      file.path(request$output_dir, artifacts$source[[index]]),
      file.path(request$output_dir, artifacts$destination[[index]]),
      artifacts$role[[index]]
    )
  }
  dir.create(file.path(request$output_dir, "logs"), recursive = TRUE, showWarnings = FALSE)
  capture.output(sessionInfo(), file = file.path(request$output_dir, "logs", "sessionInfo.txt"))

  input_artifacts <- data.frame(
    role = c("continuous_matrix", "sample_metadata"),
    path = c(request$matrix_path, request$metadata_path),
    md5 = unname(tools::md5sum(c(request$matrix_path, request$metadata_path))),
    stringsAsFactors = FALSE
  )
  timestamp <- format(Sys.time(), tz = "UTC", usetz = TRUE)
  application_revision <- Sys.getenv("LIMMA_ANALYSIS_IMAGE_REVISION", "unknown")
  canonical_commit <- Sys.getenv("LIMMA_ANALYSIS_OMIX_SOURCE_COMMIT", "unknown")
  base_image <- Sys.getenv("LIMMA_ANALYSIS_BASE_IMAGE", "unknown")
  metadata_lines <- c(
    "# Limma Run Metadata", "", "## Status", "", "Completed successfully (canonical CLI exit status 0).", "",
    "## Provenance", "", paste("- Application revision:", application_revision),
    paste("- Canonical OMIX source commit:", canonical_commit),
    "- Canonical module: OMIX-Limma-Analysis (primary continuous-matrix interface only)",
    paste("- Pinned base image:", base_image), paste("- Declared input data type:", request$input_data_type),
    "- Batch-corrected values, when present, are a separate downstream matrix and not inferential results.",
    paste("- Completed UTC:", timestamp), "", "## Declared input artifacts", "",
    "| Role | Path | MD5 |", "| --- | --- | --- |",
    paste0("| ", input_artifacts$role, " | `", input_artifacts$path, "` | `", input_artifacts$md5, "` |"),
    "", "## Parameters", "", paste0("`", paste(arguments, collapse = " ` `"), "`"), "",
    "## Interpretation", "", "This is an exploratory research analysis, not clinical decision support."
  )
  writeLines(metadata_lines, file.path(request$output_dir, "RUN_METADATA.md"))
  manifest <- list(
    status = "completed", exit_status = 0L, completed_utc = timestamp,
    application_revision = application_revision,
    canonical_omix_source_commit = canonical_commit, base_image = base_image,
    input_data_type = request$input_data_type,
    input_alignment = "exact matrix-column to metadata-row identifier match",
    artifacts = lapply(seq_len(nrow(artifacts)), function(index) {
      list(role = artifacts$role[[index]], path = artifacts$destination[[index]])
    }),
    input_artifacts = lapply(seq_len(nrow(input_artifacts)), function(index) {
      list(role = input_artifacts$role[[index]], path = input_artifacts$path[[index]], md5 = input_artifacts$md5[[index]])
    }),
    arguments = arguments
  )
  jsonlite::write_json(manifest, file.path(request$output_dir, "run_manifest.json"), auto_unbox = TRUE, pretty = TRUE)
}

if (any(args %in% c("--help", "-h"))) {
  status <- system2(file.path(R.home("bin"), "Rscript"), c("--vanilla", shQuote(canonical_script), shQuote(args)))
  quit(save = "no", status = as.integer(status))
}

request <- validate_adapter_request(args)
status <- system2(file.path(R.home("bin"), "Rscript"), c("--vanilla", shQuote(canonical_script), shQuote(args)))
if (identical(as.integer(status), 0L)) write_bundle(request, args)
quit(save = "no", status = as.integer(status))
