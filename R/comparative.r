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

primate_tree <- function(symbol){
    sp_tree <- ape::read.tree(
       text=genetree_member_symbol("homo_sapiens", symbol, "newick", nh_format="species")
    )
    blens_tree <- ape::read.tree(
       text=genetree_member_symbol("homo_sapiens", symbol, "newick")
    )
    blens_tree$tip.label <- sp_tree$tip.label
    primates <- c('papio_anubis', 'homo_sapiens', 'pongo_abelii' , 
                   'pan_troglodytes', 'chlorocebus_sabaeus', 'gorilla_gorilla',
                   'macaca_mulatta', 'callithrix_jacchus')
    to_drop <- blens_tree$tip.label[!(blens_tree$tip.label %in% primates)]
    ape::drop.tip(blens_tree, to_drop)

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


analyse_primate_tree <- function(tr, plot=FALSE){
    human_tips <- which(tr$tip.label == "homo_sapiens")
    if(plot){
        cols <- ifelse(tr$edge[,2]  %in% human_tips, "red", "grey60")
        ape::plot.phylo(tr, show.tip.label=F, edge.color=cols)
    }
    tr$edge.length[tr$edge[,2] %in% human_tips ]
}
