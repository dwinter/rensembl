gene_tree_header <- function(tree_format){
    h <- switch(tree_format, "nh"      =  "text/x-nh", 
                             "newick"   =  "text/x-nh", 
                             "pyloxml" =  "text/x-phyloxml+xml",
                             "json"    =   "application/json", 
                 stop(paste("Unkown format for gene tree:", tree_format)))
    httr::accept(h)    
}

##' Retreive a gene tree from species and gene symbol
##' @export
genetree_member_symbol <- function(species, symbol, tree_format,  aligned=NULL,
                                   external_db=NULL, nh_format=NULL, object_type=NULL,
                                   sequence = NULL)
{
    header  <- gene_tree_header(tree_format)
    q <- ensembl_body(match.call(), c("species", "symbol", "tree_format"))
    end <- paste("genetree/member/symbol", species, symbol, sep="/")    
    req <- ensembl_GET(end,  header,  query=q)
    httr::content(req)
}
