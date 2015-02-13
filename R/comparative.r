gene_tree_header <- function(tree_format){
    h <- switch(tree_format, "nh"      =  "text/x-nh", 
                             "newick"   =  "text/x-nh", 
                             "pyloxml" =  "text/x-phyloxml+xml",
                             "json"    =   "application/json", 
                 stop(paste("Unkown format for gene tree:", tree_format)))
    httr::accept(h)    
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


.parse_xml <- function(){
    xml_tree <- XML::xmlTreeParse(
       genetree_member_symbol("homo_sapiens", symbol, "phyloxml", sequence="none"), 
       useInternalNodes=TRUE
    )
    terminals <- Filter(function(x) xmlName(x) == "clade" & "sequence" %in% names(xmlChildren(x)), 
                        xml_tree["//*"])
    res <- lapply(terminals, function(x) list(orth = grepl(tolower(symbol),  tolower(xmlValue(x["sequence"][[1]][[2]]))),
                                             spp = sub("\\ ", "_", xmlValue(x["taxonomy"][[1]][[2]]))))
    names(res) <-  sapply(terminals, function(x) xmlValue(x[[1]]))
    node_summary <- xmlValue(x["sequence"][[1]][[2]])

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
