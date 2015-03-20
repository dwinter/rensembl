#Extra functions
#
#Save the lat complete request in the the environment as a last, 
# use to check retry etc.


## Set up the timeout

ensembl_vars <- new.env()    
ensembl_vars$next_timeout <- 0

#' @export
last <- function(x) UseMethod("last")


#' @export 
last.default <- function(x) tail(x,1)

#'@export 
last.list <- function(x) x[[ length(x) ]]

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

ensembl_header <- function(format, available=c()){
    if( !(format %in% available)){
        stop(paste0("Format '", format, "'not available for this database"))
    }
    h <- switch(format,  "nh"       =  "text/x-nh", 
                         "newick"   =  "text/x-nh", 
                         "pyloxml"  =  "text/x-phyloxml+xml",
                         "orthoxml" =  "text/x-orthooxml+xml",
                         "xml"      =  "text/x-xml",
                         "seqxml"   =  "text/x-seqxml+xml",
                         "yaml"     =  "text/x-yaml",
                         "json"     =  "application/json",                       
                         "fasta"    =  "text/x-fasta",
                         "gff"      =  "text/x-gff3",
                         "gff3"     =  "text/x-gff3",
                         "bed"      =  "text/x-bed", 
        stop(paste0("Format '", format, "'not availble from Ensembl")))
    httr::accept(h) 
}


#Create a query list from long list of possible arguments. 
ensembl_body <- function(arg_list, exclude){
    arg_list[[1]] <- NULL
    arg_list[exclude] <- NULL
    lapply(arg_list, arg_to_ensembl)
}


arg_to_ensembl <- function(x){
    if( is.logical(x) ){
        return(as.numeric(x))
    }
    x
}


lookup_id <- function(id, expand=NULL){
    if(expand){
        expand <- as.integer(expand)
    }
#    q <- list(expand=expand)
    q<- list()
    res <- ensembl_GET(paste0("lookup/id/", id), query=q)
    ensembl_check(res)
    res
}






#species <- spp_sets("EPO")
#primates unlist(species[[4]]$species_set)
spp_sets  <- function(meth){
    end <- paste0("info/compara/species_sets/", meth)
    ensembl_GET(end)
}


