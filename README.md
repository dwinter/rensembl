# rensembl
[![Travis-CI Build
Status](https://travis-ci.org/dwinter/rensembl.png?branch=master)](https://travis-ci.org/dwinter/rensembl)


The very early stage of an R package wrapping [the Esembl REST
api](http://rest.ensembl.org/). 

This package is very much a work in progress, and the behaviour may well change
in the future. Eveni so, there is some stuff to play with already. You can install via `devtools`

```r
devtools::install_github("dwinter/rensembl")
```

##examples

There is still a lot to do. The plan is to work on low-level functions that
return simple R objects (xml or json as parsed by `XML` and `jsonlite` and
character vectors other return-types)  then build higher-level classes and
functions on top of that. Some of the low-level functions already implemented
might be helpful:

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


