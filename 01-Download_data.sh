#!/bin/bash
set -euo pipefail


##
wget -nc ftp://ftp.ebi.ac.uk/pub/databases/chembl/ChEMBLdb/latest/chembl_29_sqlite.tar.gz
wget -nc ftp://ftp.ebi.ac.uk/pub/databases/chembl/ChEMBLdb/latest/chembl_29.fa.gz

##
if [[ ! -d "chembl_29_sqlite" ]]; then
  tar -zxvf chembl_29_sqlite.tar.gz
fi

##
if [[ ! -d "tables" ]]; then
  mkdir -p tables
  for table in ACTIVITIES ASSAYS COMPONENT_CLASS COMPOUND_STRUCTURES PROTEIN_FAMILY_CLASSIFICATION TARGET_COMPONENTS TARGET_DICTIONARY; do
    sqlite3 -header -csv chembl_29_sqlite/chembl_29.db "SELECT * from ${table};" \
      > tables/${table}.csv
  done
fi

##
if [[ ! -f "chembl_29_fa.tsv" ]]; then
  seqkit fx2tab chembl_29.fa.gz > chembl_29_fa.tsv
fi

##
mkdir -p data
