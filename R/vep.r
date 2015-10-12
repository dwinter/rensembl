#' Get all variants and effects
#'@export
#'@param id gene ID
#'@param species ensembl name for the species from which the gene ID comes
#'  (default = hsap = humans)
#'@param format format for fetched recrod (default = json)
#'@examples
#' vep_id('COSM467')
#' vep_id(c("rs116035550", "COSM476"))
vep_id <- function(id, species="hsap", format="json"){
    if (length(id) == 1){
        return(vep_one(paste(species, "id", id, sep="/"), format))
    }
    vep_many(id, "id", species, format)
}

#' Fetch variant consequences fro a given allele at a given site 
#'@export
#'@examples
#'vep_allele(species="hsap", region="9:22125503-22125502:1", allele="C")
vep_allele <- function(species="hsap", region, allele, format="json"){
    vep_one(paste(species, "region", region,allele, sep="/"), format)
}

#' Fetch variant consequences from regions 
#'@export
#'@examples
#'vep_region('AGT:c.803T>C')
#'vep_region(c("21 26960070 rs116645811 G A", "21 26965148 - G A"))
vep_region <- function(region, species="human", format="json"){
    if (length(region) == 1){
        return(vep_one(paste(region, "hgvs", species, sep="/"), format))
    }
    vep_many(region, "region", species, format)
}

vep_one <- function(path, format="json"){
    end_point <- paste("vep", path, sep="/")
    header <- ensembl_header(format, c("json", "xml"))
    req <- ensembl_GET(end_point, header)
    httr::content(req)
}

#vep_many(c("rs116035550", "COSM476"))
vep_many <- function(identifier, id_type , species="human", format="json"){
    body <- if(id_type=="id") list(ids=identifier) else list(variants = identifier)
    end <- paste("vep", species, id_type, sep="/")
    header <- ensembl_header(format, c("json", "xml"))
    req <- ensembl_POST(end, body, header)
    httr::content(req)
}

