rm(list = ls())
library(tidyverse)


##
potency_type <- "Ki"

##
tbl_ACTIVITIES <-
  readr::read_csv("tables/ACTIVITIES.csv", show_col_types = FALSE) %>%
  dplyr::filter(
    standard_type == potency_type &
      standard_value > 0 &
      standard_units == "nM" &
      standard_relation == "="
  ) %>%
  dplyr::select(assay_id, molregno, standard_value)

## Keep "single protein format" only
tbl_ASSAYS <-
  readr::read_csv("tables/ASSAYS.csv", show_col_types = FALSE) %>%
  dplyr::filter(bao_format == "BAO_0000357") %>%
  dplyr::select(assay_id, tid)

##
tbl_TARGET_DICTIONARY <-
  readr::read_csv("tables/TARGET_DICTIONARY.csv", show_col_types = FALSE) %>%
  dplyr::select(-pref_name, -species_group_flag)

##
tbl_TARGET_SEQ <-
  readr::read_tsv(
    "chembl_29_fa.tsv",
    col_names = c("chembl_id", "tseq"),
    show_col_types = FALSE
  )
tbl_TARGET_SEQ$chembl_id <- gsub("^ ", "", tbl_TARGET_SEQ$chembl_id)
tbl_TARGET_SEQ$chembl_id <-
  gsub(" .*$", "", tbl_TARGET_SEQ$chembl_id)
tbl_TARGET_SEQ <- tidyr::separate_rows(tbl_TARGET_SEQ, chembl_id)

##
tbl_COMPOUND_STRUCTURES <-
  readr::read_csv("tables/COMPOUND_STRUCTURES.csv", show_col_types = FALSE) %>%
  dplyr::select(molregno, canonical_smiles)

##
tbl_PROTEIN_CLASS <-
  readr::read_csv("data/Protein_class.csv.gz", show_col_types = FALSE)
table(tbl_PROTEIN_CLASS$l1)

##
tbl_ALL <-
  dplyr::inner_join(tbl_ACTIVITIES, tbl_ASSAYS, by = "assay_id")
tbl_ALL <-
  dplyr::inner_join(tbl_ALL, tbl_TARGET_DICTIONARY, by = "tid")
tbl_ALL <-
  dplyr::inner_join(tbl_ALL, tbl_TARGET_SEQ, by = "chembl_id")
tbl_ALL <-
  dplyr::inner_join(tbl_ALL, tbl_COMPOUND_STRUCTURES, by = "molregno")
tbl_ALL <-
  dplyr::left_join(tbl_ALL, tbl_PROTEIN_CLASS, by = "tid")
tbl_ALL <- tbl_ALL %>%
  dplyr::filter(!is.na(standard_value)) %>%
  dplyr::mutate(pair = paste0(molregno, "_", tid))

## Filter multiple interactions
tbl_ALL %>%
  dplyr::group_by(pair) %>%
  dplyr::summarise(n = n()) %>%
  dplyr::filter(n > 1) %>%
  nrow()

## Get 1-1 interaction
one_to_one <- tbl_ALL %>%
  dplyr::group_by(pair) %>%
  dplyr::summarise(n = n()) %>%
  dplyr::filter(n == 1) %>%
  dplyr::pull(pair)
length(one_to_one)

## Keep median for each interaction pair, add class, and export
df_values_with_class <- tbl_ALL %>%
  dplyr::group_by(pair) %>%
  dplyr::mutate(standard_value_median = median(standard_value),
                n = n()) %>%
  dplyr::ungroup() %>%
  dplyr::select(l1, l2, canonical_smiles, tseq, standard_value_median, n) %>%
  unique()

df_values_with_class_subset <-
  df_values_with_class %>%
  dplyr::filter(l1 == "Enzyme" & l2 == "Kinase") %>%
  dplyr::select(-l1,-l2,-n)

readr::write_csv(
  df_values_with_class_subset,
  paste0("data/", potency_type, "_median_EK.tsv.gz"),
  col_names = FALSE
)
