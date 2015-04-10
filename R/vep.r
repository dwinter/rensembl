#'@export
# vep_od('COSM467')
# vep_id(c("rs116035550", "COSM476"))
vep_id <- function(id, species="human", format="json"){
    if (length(id) == 1){
        return(vep_one(id, "id", species, format))
    }
    vep_many(id, "id", species, format)
}

#vep_region('AGT:c.803T>C', "hgvs")
#vep_regionc("21 26960070 rs116645811 G A", "21 26965148 - G A")
vep_region <- function(region, species="human", format="json"){
    if (length(region) == 1){
        return(vep_one(region, "hgvs", species, format))
    }
    vep_many(region, "region", species, format)
}



vep_one <- function(identifier, id_type, species="human", format="json"){
    end_point <- paste("vep", species, id_type,identifier, sep="/")
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

