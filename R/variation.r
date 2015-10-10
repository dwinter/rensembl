#'@export
variation_id <- function(ids, species= "hsap", genotypes=FALSE, phenotypes=FALSE,
                         pops=FALSE, population_genotypes=FALSE, req_format="json"){
    header <- ensembl_header(req_format, c("json", "xml"))
    query <- ensembl_body(match.call(), exclude=c("ids", "species"))
    protocol_fxn <- if(length(ids) > 1) vars_post else vars_get
    req <- protocol_fxn(ids, species, query=query, header=header)
    httr::content(req)
}

#'@export
vars_post <- function(ids, species= "hsap", query, header){
    end <- paste("variation", species, sep="/")
    ensembl_POST(end, body=list(ids=ids), query=query, header)
}

#'@export
vars_get <- function(ids, species= "hsap", header, query){
    end <- paste("variation", species, ids, sep="/")
    ensembl_GET(end, query=query, header)
}
