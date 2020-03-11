species_re <- "(.*?)(<*-+>)(.*)"

#' Parse species
#'
#' @keywords  internal
parse_species <- function(species,re = species_re) {
  species <- gsub(" ", "", species, fixed = TRUE)
  species <- stringr::str_match(species,species_re)
  stopifnot(ncol(species) ==4)
  if(anyNA(species)) species[is.na(species)] <- ""
  colnames(species) <- c("rxn", "lhs", "arrow", "rhs")
  as.data.frame(species,stringsAsFactors = FALSE)
}

parse_reactions <- function(eq,width = NULL,width_plus = 1,j_prefix = "J",re=NULL) {
  if(is.null(re)) re <- "(.*?)(<*-+>)(.*)"
  species0 <- map_chr(eq, "species")
  species <- parse_species(species0,re)
  if(any(species$lhs=="" | species$rhs=="")) {
    bad_species_i <- which(species$lhs=="" | species$rhs=="")
    bad_species <- paste0(" - reaction: ",species0[bad_species_i])
    message("context: parsing reactions")
    message(bad_species)
    stop("invalid reaction specification.",call.=FALSE)
  }
  formula <- map_chr(eq, "form", .default = "<null>")
  label <- map_chr(eq, "label", .default = "<null>")
  lhs <- strsplit(species[,2], split = "\\+")
  rhs <- strsplit(species[,4], split = "\\+")
  if(is.null(width)) width <- ceiling(log10(nrow(species))) + width_plus
  j_names <- paste0(j_prefix,formatC(seq_along(lhs),width = width, flag="0"))
  species$formula <- formula
  species$J <- j_names
  return(list(species = species,lhs = lhs, rhs = rhs,j_names = j_names,label=label))
}
