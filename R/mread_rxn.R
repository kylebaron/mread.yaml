#' Load a model file with ODEs specified as reactions
#'
#' @param file full path to file to read, parse, and compile
#' @param output_file full path to file to write output
#' @param ... passed to [mrgsolve::mread_cache]
#' @export
mread_rxn <- function(file,output_file=NULL,...) {
  if(!file.exists(file)) {
    stop("file '", file, "' doses not exist", call.=FALSE)
  }
  if(is.null(output_file)) {
    output_file <- file.path(tempdir(),basename(file))
  }
  mod <- modelparse(readLines(file))
  if(exists("ODE",mod)) {
    stop("model code cannot contain 'ODE' block", call.=FALSE)
  }
  new_model <- render_yaml_reactions(mod)
  new_model_code <- collapse_parsed_model(new_model)
  cat(new_model_code, file = output_file, sep = "\n")
  mread(output_file, ...)
}

#' @noRd
render_yaml_reactions <- function(mod) {
  if(is.null(mod$REACTIONS)) {
    stop("model code must contain a 'REACTIONS' block", call.=FALSE)
  }
  rxn <- mod$REACTIONS
  stopifnot(is.character(rxn))
  parsed <- try_yaml(paste0(rxn,collapse = "\n"))
  ans <- make_ode(list(reactions = parsed))
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

