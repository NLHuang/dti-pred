rm(list = ls())
library(tidyverse)


##
tbl_TARGET_COMPONENTS <-
  readr::read_csv("tables/TARGET_COMPONENTS.csv")

##
tbl_COMPONENT_CLASS <-
  readr::read_csv("tables/COMPONENT_CLASS.csv")

##
tbl_PROTEIN_FAMILY_CLASSIFICATION <-
  readr::read_csv("tables/PROTEIN_FAMILY_CLASSIFICATION.csv")

##
tbl_ALL <-
  dplyr::left_join(tbl_TARGET_COMPONENTS, tbl_COMPONENT_CLASS, by = "component_id")
tbl_ALL <-
  dplyr::inner_join(tbl_ALL, tbl_PROTEIN_FAMILY_CLASSIFICATION, by = "protein_class_id")

##
readr::write_csv(
  tbl_ALL %>% dplyr::select(
    -component_id,
    -targcomp_id,
    -homologue,
    -protein_class_id,
    -comp_class_id
  ),
  "data/Protein_class.csv.gz"
)
