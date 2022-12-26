# Introduction

This repository contains discussion, analysis pipelines, files and scripts used in the preprint 
**["Cross-shore distribution of SAR11 suggests efficient removal by a hard-bottom subtidal community
"](https://www.biorxiv.org/content/10.1101/2022.12.24.521757v1.full.pdf+html
)**

> Throughout this documentation the names in the final publication are diffeent than those used in the analysis.  Rather than exchange all names we provide the correspondence between names that are:

> Since we do not keep the original paths in this distribution we add links to files necessary to reproduce our analysis whenever needed  
> We used different conda enviroments containing different packages so we will list the content of these environments. We also provide the system profile at some of the steps of the analysis  

## Contents

- [Pipeline Script](https://github.com/suzumar/transect_ms/blob/main/files/SSUpipeline.bash) Script used for the data analysis 
- [Taxonomy Identification Database](https://github.com/suzumar/transect_ms/blob/main/files/taxo.md) Construction of database used for ASV identification based on the silva_132_99.fna release from Silva
- [SRA submission](https://github.com/suzumar/transect_ms/blob/main/SRA_sub.md)

## Links

- Final classifier [Qiime artifact](https://figshare.com/articles/dataset/all-classifier_qza_tgz/12820445)
- [Mapping file](https://github.com/suzumar/transect_ms/blob/main/sample-metadata.tsv)
- ASV table [biom](https://github.com/suzumar/transect_ms/blob/main/721-752-proka-table-final-full.biom) and [txt](https://github.com/suzumar/transect_ms/blob/main/721-752-proka-table-final-full.txt) format
- Representative [sequences](https://github.com/suzumar/transect_ms/blob/main/721-752-proka-rep-seqs.qza)
