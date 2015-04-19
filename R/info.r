#'@export
lookup_id <- function(id, expand=NULL){
    q <- arg_to_ensembl(list(expand=expand))
    res <- ensembl_GET(paste0("lookup/id/", id), query=q)
    ensembl_check(res)
    res
}
#'@export
lookup_symbol <- function(symbol, expand = FALSE, species="homo_sapiens", 
                          format="full", return_format="json"){
    header = ensembl_header(return_format, c("json", "xml"))
    q = arg_to_ensembl(list(expand=expand, format=format))
    if(length(symbol) == 1){
        end <- paste("lookup/symbol", species, symbol, sep="/")
        req <- ensembl_GET(end, header=header, query=q)
    } else {
        end <- paste("lookup/symbol", species, sep="/")
        req <- ensembl_POST(end, header=header, query=q, body = list(symbols = symbol))
    }
    httr::content(req)
}

#'@export
#species <- spp_sets("EPO")
#primates unlist(species[[4]]$species_set)
spp_sets  <- function(meth){
    end <- paste0("info/compara/species_sets/", meth)
    ensembl_GET(end)
}


