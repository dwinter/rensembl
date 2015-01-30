#Extra functions
#
#Save the lat complete request in the the environment as a last, 
# use to check retry etc.


## Set up the timeout

ensembl_vars <- new.env()    
ensembl_vars$next_timeout <- 0



check_timeout <- function(){
    if(unclass(Sys.time()) < ensembl_vars$next_timeout){
            time_to_go <- unclass(Sys.time()) - next_timeout
        stop(paste("Ensembl has prevented you from sending requests for the next",
                   time_to_go, "seconds. Take a break."))
    }
}



base_url <- function() "http://rest.ensembl.org"

ensembl_GET  <- function(end_point, ... ){
    check_timeout()
    req  <- httr::GET(base_url(), path=end_point, ...)
    ensembl_check(req)
    req
}

ensembl_check <- function(req){
    if(! req$status_code < 400){
        if(req$status_code == 429){
            timeout <- req$headers['retry-after']
            ensembl$next_timeout <<- timeout + unclass(Sys.time())
            #Enforce this? The allowled rate is v. v. high
            msg <- paste("You have been rate-limited, take a break.", 
                         "You won't be able to send requests for", timeout, "seconds")
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
                             "newick"   =  "text/x-nh", 
                             "pyloxml" =  "text/x-phyloxml+xml",
                             "json"    =   "application/json", 
                 stop(paste("Unkown format for gene tree:", tree_format)))
    httr::accept(h)    
}


gene_tree <- function(spp, sym){
    end <- paste("genetree/member/symbol", spp, sym, sep="/")    
    sp_t <- ensembl_GET(end, 
                       httr::accept("text/x-nh"),
                       query=list(nh_format="species"))
    b_t <- ensembl_GET(end, 
                       httr::accept("text/x-nh"))
    tr <- read.tree(text=httr::content(b_t))
    tr$tip.label <- ape::read.tree(text=httr::content(sp_t))$tip.label
    tr
}



#species <- spp_sets("EPO")
#primates unlist(species[[4]]$species_set)
spp_sets  <- function(meth){
    end <- paste0("info/compara/species_sets/", meth)
    ensembl_GET(end)
}

b
