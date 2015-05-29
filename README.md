<!-- README.md is generated from README.Rmd. Please edit that file -->
rensembl
========

[![Travis-CI Build Status](https://travis-ci.org/dwinter/rensembl.png?branch=master)](https://travis-ci.org/dwinter/rensembl)

The very early stage of an R package wrapping [the Ensembl REST api](http://rest.ensembl.org/).

This package is very much a work in progress, and the behaviour may well change in the future. Even so, there is some stuff to play with already. You can install the package via `devtools`

``` r
devtools::install_github("dwinter/rensembl")
```

Examples
--------

Our development plan is to work on low-level functions that return simple R objects (lists or character vectors), then build some higher-level functions hat impliment common tasks or return richer R objects

Though we have only low level functions at present, some of them are quite helpful:

### Get information about a gene by its symbol

``` r
brca2_info <- lookup_symbol("BRCA2")
brca2_info
#> $source
#> [1] "ensembl_havana"
#> 
#> $object_type
#> [1] "Gene"
#> 
#> $logic_name
#> [1] "ensembl_havana_gene"
#> 
#> $species
#> [1] "homo_sapiens"
#> 
#> $description
#> [1] "breast cancer 2, early onset [Source:HGNC Symbol;Acc:HGNC:1101]"
#> 
#> $display_name
#> [1] "BRCA2"
#> 
#> $assembly_name
#> [1] "GRCh38"
#> 
#> $biotype
#> [1] "protein_coding"
#> 
#> $end
#> [1] 32400266
#> 
#> $seq_region_name
#> [1] "13"
#> 
#> $db_type
#> [1] "core"
#> 
#> $strand
#> [1] 1
#> 
#> $id
#> [1] "ENSG00000139618"
#> 
#> $start
#> [1] 32315474
```

### Find variants within a gene

``` r
snps <- overlap(gene_id=brca2_info$id, feature="variation")
snps[[1]]
#> $feature_type
#> [1] "variation"
#> 
#> $alt_alleles
#> $alt_alleles[[1]]
#> [1] "T"
#> 
#> $alt_alleles[[2]]
#> [1] "G"
#> 
#> 
#> $assembly_name
#> [1] "GRCh38"
#> 
#> $end
#> [1] 32315494
#> 
#> $seq_region_name
#> [1] "13"
#> 
#> $consequence_type
#> [1] "5_prime_UTR_variant"
#> 
#> $strand
#> [1] 1
#> 
#> $id
#> [1] "rs546292946"
#> 
#> $start
#> [1] 32315494
```

We can extract some information for each case too:

``` r
table(sapply(snps, "[[", "consequence_type"))
#> 
#>                3_prime_UTR_variant                5_prime_UTR_variant 
#>                                 66                                 20 
#>            coding_sequence_variant                 frameshift_variant 
#>                                932                               1041 
#>                   inframe_deletion                  inframe_insertion 
#>                                 38                                  3 
#>                     intron_variant                   missense_variant 
#>                               2721                               1369 
#> non_coding_transcript_exon_variant           protein_altering_variant 
#>                                 65                                  1 
#>            splice_acceptor_variant               splice_donor_variant 
#>                                 60                                 66 
#>              splice_region_variant                         start_lost 
#>                                118                                  3 
#>                        stop_gained                 synonymous_variant 
#>                                346                                189
```
