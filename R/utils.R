
try_yaml <- function(text,context="try_yaml") {
  out <- try(yaml.load(text,error.label = context),silent=TRUE)
  if(inherits(out,"try-error")) {
    stop(out)
  }
  out
}

try_yaml_file <- function(file,context="try_yaml_file") {
  out <- try(yaml.load_file(file,error.label = context),silent=TRUE)
  if(inherits(out,"try-error")) {
    stop(out)
  }
  out
}

file_writeable <- function(x) file.access(x,2)==0

is_named_chr_list <- function(x) {
  a <- is.list(x)
  nms <- names(x)
  b <- is.character(nms) && all(nzchar(nms))
  c <- all(sapply(x,inherits,"character"))
  all(a,b,c)
}

is_chr_list <- function(x) {
  a <- is.list(x)
  c <- all(vapply(x,inherits,TRUE,"character"))
  all(a,c)
}

