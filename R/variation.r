variation_id <- function(ids, species= "hsap", genotypes=FALSE, phenotypes=FALSE,
                         pops=FALSE, population_genotypes=FALSE, req_format="json"){
    header <- ensembl_header(req_format, c("json", "xml"))
    query <- ensembl
    if(length(ids) > 1){
        vars_post(end)
    }


vars_post <- function(ids, species= "hsap", header, query)
    end <- paste("variation", species, sep="/")
    ensembl_POST(end, body=ids, query=query, header)
}

vars_get <- function(ids, species= "hsap", header, query){
    end <- paste("variation", species, ids sep="/")
    ensembl_GET(end, query=query, header)
}
