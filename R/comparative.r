#TODO: remove this and replace with base.r /header 
gene_tree_header <- function(tree_format){
    h <- switch(tree_format, "nh"      =  "text/x-nh", 
                             "newick"  =  "text/x-nh", 
                             "pyloxml" =  "text/x-phyloxml+xml",
                             "json"    =  "application/json", 


                 stop(paste("Unkown format for gene tree:", tree_format)))
    httr::accept(h)    
}

#'@export 
homology_symbol <- function(species, symbol, format, aligned=TRUE, sequence, 
                            target_species, target_taxon, type){
    end <- paste("homology/symbol", species, symbol, sep="/")
    header = ensembl_header(format, c("json", "orthoxml", "xml"))
    q <- ensembl_body(match.call(), c("species", "symbol", "format"))
    req <- ensembl_GET(end, header, query=q)
    httr::content(req)
}
                          

#' Retreieve a genomic alignment from a given region
#'@export
alignment_region <- function(region, species="homo_sapians", aligned=FALSE,
                             compact = TRUE, compara = "multi", 
                             display_species_set = NULL, mask="soft",  
                             method="EPO", species_set = NULL, 
                             species_set_group = "mammals", req_format="json"){
    end <- paste("alignment/region", species, region, sep="/")
    header = ensembl_header(req_format, c("json", "phyloxml", "xml"))
    q <- ensembl_body(match.call(), c("species", "region"))
    req <- ensembl_GET(end, header, query=q)
    httr::content(req)
}


#' Retreive a gene tree from species and gene symbol
#' @export
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




