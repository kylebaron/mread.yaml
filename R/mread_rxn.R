
#' @export
mread_rxn <- function(file,output_file=NULL,...) {
  if(is.null(output_file)) {
    output_file <- file.path(tempdir(),basename(file))
  }
  new_model <- render_yaml_reactions(file)
  new_model_code <- collapse_parsed_model(new_model)
  cat(new_model_code, file = output_file, sep = "\n")
  mread(output_file, ...)
}

#' @noRd
render_yaml_reactions <- function(file) {
  mod <- modelparse(readLines(file))
  parsed <- yaml::yaml.load(paste0(mod$REACTIONS,collapse = "\n"))
  ans <- mread.yaml:::make_ode(list(reactions = parsed))
  ans[1] <- ""
  mod$REACTIONS <- NULL
  mod$ODE <- c(mod$ODE_ASSIGNMENTS,ans)
  mod$ODE_ASSIGNMENTS <- NULL
  mod
}

#' @noRd
collapse_parsed_model <- function(x) {
  ans <- imap(x, function(code,name) {
    name <- paste0("[ ", name, " ]",collapse = "")
    c(name,code," ")
  })
  flatten_chr(ans)
}

