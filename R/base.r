
## Set up the timeout
#
# Ensembl rate-limits requests. If a user oversteps they will get 429 return
# with retry-after in the headers. My approach to implementing this on the R
# side (so preventing extra calls which will be bounced) is to check and
# environmental variable (next timeout) before making the request. When a
# 429 is returned the timeout is updated.
#
# If there is a cleaner way to do this I'm keen to hear about it :)

ensembl_vars <- new.env()    
ensembl_vars$next_timeout <- 0

check_timeout <- function(){
    if(unclass(Sys.time()) < ensembl_vars$next_timeout){
        time_to_go <- unclass(Sys.time()) - ensembl_vars$next_timeout
        stop(paste("Ensembl has prevented you from sending requests for the next",
                   time_to_go, "seconds. Take a break."))
    }
}

## Query building
# $his basically follows the httr best practices:
# http://cran.r-project.org/web/packages/httr/vignettes/api-packages.html
#
# Not check has the timeout handling code too

base_url <- function() "http://rest.ensembl.org"

ensembl_GET  <- function(end_point, ... ){
    check_timeout()
    req  <- httr::GET(base_url(), path=end_point, ...)
    ensembl_check(req)
    req
}

ensembl_POST <- function(end_point, body, ...){
    stopifnot(is.list(body))
    check_timeout()
    body_json <- jsonlite::toJSON(body)
    req <- httr::POST(base_url(), path=end_point, body=body_json)
    ensembl_check(req)
    req
}

ensembl_check <- function(req){
    if(! req$status_code < 400){
        if(req$status_code == 429){
            timeout <- req$headers['retry-after']
            ensembl_vars$next_timeout <- timeout + unclass(Sys.time())
            #Enforce this? The allowled rate is v. v. high
            msg <- paste("You have been rate-limited, take a break.", 
                         "You won't be able to send requests for", timeout, "seconds")
            stop(msg)
        }
        stop(httr::content(req))
    }
}

##Set the content headers
#
# The most straightforward way to set the conent for a request is to give each
# req a header. The complete list of avaliable ones is here
# https://github.com/Ensembl/ensembl-rest/wiki/HTTP-Headers
#
# This function is intended to take a format specified from a end-point wrapping
# function and return a matching headeer via httr::accept. The "avaliable"
# argument can be used to limit the possible headers for a given endpoint (and
# give a helpful error msg if an unknown format is specified. 
#

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
#
# Lots of the endpoints have very long (potential) argument lists, almost all of
# which can be pased along to GET as a query. This fxn is used to strip out
# those arguments that aren't part of the query (usually headers, and variables
# used to specify the correct path for a request). 
#
# At the moment all arg_to_ensembl does is convert R-style logicals (TRUE/FALSE)
# to ensembl-style boolens (0/1). If other arguments need similar
# 'style-conversion' they can be added.

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



