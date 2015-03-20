# rensembl
[![Travis-CI Build
Status](https://travis-ci.org/dwinter/rensembl.png?branch=master)](https://travis-ci.org/dwinter/rensembl)


The very early stage of an R package wrapping [the Esembl REST
api](http://rest.ensembl.org/). 

This package is very much a workin progress, and the behaviour may well change
in the future. Evenso, there is some stuff to play with already. You can install
via `devtools`

```r
devtools::install_github("dwinter/rensembl")
```

##examples

There is still a lot to do, but there are some complete functions.

### convert within-transcript coordinates to genomic coordinates:

```r
coords <- map_genomic_coordinates("enst00000296026", "cdna", "100..110")
map_data <- coords$mappings[[1]]
cat(map_data$assembly_name, "\n", map_data$seq_region_name, ":", map_data$start, 
     "-", map_data$end, "\n", sep="")
```

```
GRCh38
4:74038580-74038590
```


