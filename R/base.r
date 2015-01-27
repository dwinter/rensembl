
base_url <- function() "http://rest.ensembl.org"

ensembl_GET  <- function(end_point, base=base_url(), headers=c(), ...){
    req  <- httr::GET(base_url(), path=end_point, add_headers=headers, ...)
#    httr::content(req)
    req
}

ensembl_check <- function(req){
    if(! req$status_code < 400){
        if(req$status_code == 429){
            timeout <- req$headers['retry-after']
            msg <- paste("You have been rate-limited, take a break:", 
                         "no more requests for", timeout, "seconds")
            stop(msg)
        }
        stop(httr::content(req))
    }
}

lookup_id <- function(id){
    res <- ensembl_GET(paste0("lookup/id/", id))
    ensembl_check(res)
    res
}

gene_tree <- function(spp, sym){
    end <- paste("genetree/member/symbol", spp, sym, sep="/")
    res <- ensembl_GET(end, query=list("content-type"="text/x-phyloxml+xml"))
    ensembl_check(res)
    res
}
