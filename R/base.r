#Extra functions
#
#Save the lat complete request in the the environment as a last, 
# use to check retry etc.
# Timout function so not GET/POST


base_url <- function() "http://rest.ensembl.org"

ensembl_GET  <- function(end_point, base=base_url(), headers=c(), ...){
    req  <- httr::GET(base_url(), path=end_point, add_headers=headers, ...)
    ensembl_check(req)
    req
}

ensembl_check <- function(req){
    if(! req$status_code < 400){
        if(req$status_code == 429){
            timeout <- req$headers['retry-after']
            #Enforce this? The allowled rate is v. v. high
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

gene_tree_header <- function(tree_format){
    h <- switch(tree_format, "nh"      =  "text/x-nh", 
                            "nexus"   =  "text/x-nh", 
                            "pyloxml" =  "text/x-phyloxml+xml",
                            "json"    =   "application/json", 
                 stop(paste("Unkown format for gene tree:", tree_format)))
    httr::accept(h)    
}


gene_tree <- function(spp, sym){
    end <- paste("genetree/member/symbol", spp, sym, sep="/")  
    sp_t <- ensembl_GET(end, 
                       httr::accept("accept"="text/x-nh"),
                       query=list(nh_format="species"))
    b_t <- ensembl_GET(end, 
                       httr::add_headers("accept"="text/x-nh"))
    tr <- read.tree(b_t)
    tr$tip.label <- ape::read.tree(sp_t)$tip.label
    tr
}
