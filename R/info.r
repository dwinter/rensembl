#'@export
lookup_id <- function(id, db_type="core", expand=NULL, format="full", 
                      object_type=NULL,species=NULL, return_format="json"){
    header <- ensembl_header(return_format, c("json"))
    q <- ensembl_body(match.call(), "id")
    if(length(id) == 1){
        res <- ensembl_GET(paste0("lookup/id/", id), header=header, query=q)
        ensembl_check(res)
    } else {
        res <- ensembl_POST("lookup/id/", query=q, header=header, body=list(ids=id))
        ensembl_check(res)
    }
    httr::content(res) #TODO custom parser for all returns ?httr::content
}

#'Retrieve information about a sequence via gene symbol and species
#'@export
#'@param symbol character, gene symbol(s) from which to retreive information.
#'@param species character, species from which to retreieve information. See
#'\code{info_species} for a list of avaliable species. Defaults to homo_sapiens
#'@param symbol logical, if \code{TRUE} return information about transcripts/proteins
#'associated with these record. Defaults to \code{FALSE}
#'@param format, character, type of record to return either 'full' or 'condensed'
#'@param return_format, character method by which record is returned. Defaults
#'to \code{json}
#'@references \url{lhttp://rest.ensembl.org/documentation/info/symbol_lookup}
#'@examples
#' human_brca <- lookup_symbol("BRCA2")
#' chimp_brca <- lookup_symbol("BRCA2", species="ptro")
#' chimp_brca_expanded <- lookup_symbol("BRCA2", species="ptro", expand=TRUE)

lookup_symbol <- function(symbol, expand = FALSE, species="homo_sapiens", 
                          format="full", return_format="json"){
    header <- ensembl_header(return_format, c("json", "xml"))
    q <- list(expand=arg_to_ensembl(expand), format=format)
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


