#'@export
# vep_id('COSM467')
# vep_id(c("rs116035550", "COSM476"))
vep_id <- function(id, species="human", format="json"){
    if (length(id) == 1){
        return(vep_one(paste(id, species, sep="/"), format))
    }
    vep_many(id, "id", species, format)
}

#'@export
#vep_allele(species="hsap", region=9:22125503-22125502:1, allele="C")
#
vep_allele <- function(species="hsap", region, allele, format="json"){
    vep_one(paste(species, "region", region,allele, sep="/"), format)
}

#vep_region('AGT:c.803T>C')
#vep_regioni(c("21 26960070 rs116645811 G A", "21 26965148 - G A"))
vep_region <- function(region, species="human", format="json"){
    if (length(region) == 1){
        return(vep_one(paste(region, "hgvs", species, sep="/"), format))
    }
    vep_many(region, "region", species, format)
}



vep_one <- function(path, format="json"){
    end_point <- paste("vep", path, sep="/")
    cat(end_point)
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

