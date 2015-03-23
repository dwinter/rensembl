gene_tree_header <- function(tree_format){
    h <- switch(tree_format, "nh"      =  "text/x-nh", 
                             "newick"  =  "text/x-nh", 
                             "pyloxml" =  "text/x-phyloxml+xml",
                             "json"    =  "application/json", 


                 stop(paste("Unkown format for gene tree:", tree_format)))
    httr::accept(h)    
}


homology_symbol <- function(species, symbol, format, aligned=TRUE, sequence, 
                            target_species, target_taxon, type){
    end <- paste("homology/symbol", species, symbol, sep="/")
    header = ensembl_header(format, c("json", "orthoxml", "xml"))
    q <- ensembl_body(match.call(), c("species", "symbol", "format"))
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




#' @export
primate_tree <- function(symbol){
    sp_tree <- ape::read.tree(
       text=genetree_member_symbol("homo_sapiens", symbol, "newick", nh_format="display_label_composite")
    )
    primates <- c('Panu', 'Hsap', 'Pabe' , 'Ptro', 'Csab', 'Ggor', 'Mmul', 'Cjac')
    toks <- strsplit(sp_tree$tip.label, "_")
    orth <- grepl(paste0("^",symbol), sapply(toks, "[[", 1))
    right_sp  <- sapply(toks, last) %in% primates
    to_drop <- sp_tree$tip.label[!(right_sp & orth)]
    ape::drop.tip(sp_tree, to_drop)
}



#' Get dN/dS data for a given gene symbol
#'@param symbol gene symbol
#'@return a dataframe contaning dnds, species and taxonomic level 
#'@export
dnds <- function(symbol){
    big_rec <- homology_symbol("hsap", symbol, format="json")
    homologies <- big_rec$data[[1]]$homologies
    primates <- Filter(function(x) is_primate(x), homologies)
    res <- lapply(primates, 
      function(x) c(dnds = .get_dnds(x), species=x$target$species, group=x$taxonomy_level))
    df0 <- do.call(rbind.data.frame, res)
    names(df0) <- c("dnds", "species", "group")
    df0
}

.get_dnds <- function(x){
    if(is.null(x$dn_ds )){
        return("NA")
    }
    x$dn_ds
}




is_primate <- function(x){
    if(x$type == "ortholog_one2one"){
        return (x$taxonomy_level %in% c("Homininae", "Hominidae", "Hominoidea", "Catarrhini", "Simiiformes"))
    }
    return(FALSE)
}



.parse_xml <- function(){
    xml_tree <- XML::xmlTreeParse(
       genetree_member_symbol("homo_sapiens", symbol, "phyloxml", sequence="none"), 
       useInternalNodes=TRUE
    )
    terminals <- Filter(function(x) xmlName(x) == "clade" & "sequence" %in% names(XML::xmlChildren(x)), 
                        xml_tree["//*"])
    res <- lapply(terminals, function(x) list(orth = grepl(tolower(symbol),  tolower(XML::xmlValue(x["sequence"][[1]][[2]]))),
                                             spp = sub("\\ ", "_", XML::xmlValue(x["taxonomy"][[1]][[2]]))))
    names(res) <-  sapply(terminals, function(x) XML::xmlValue(x[[1]]))
    node_summary <- XML::xmlValue(x["sequence"][[1]][[2]])

}

#' @export
analyse_primate_tree <- function(tr, plot=FALSE){
    spp <- sapply(strsplit(tr$tip.label, "_"), last)
    human_tips <- which(spp == "Hsap")
    if(plot){
        cols <- ifelse(tr$edge[,2]  %in% human_tips, "red", "grey60")
        ape::plot.phylo(tr, edge.color=cols)
    }
    tr$edge.length[tr$edge[,2] %in% human_tips ]
}
