
library(testthat)

context('test-engine')

parse_reactions <- mread.yaml:::parse_reactions
parse_species <- mread.yaml:::parse_species

test_that("parse species", {
  spec <- c("a --> b", "c + d <-> e")
  ans <- parse_species(spec)
  expect_equal(ncol(ans),4)
  expect_equal(nrow(ans),length(spec))
  expect_is(ans,"data.frame")
  expect_identical(names(ans),c("rxn", "lhs", "arrow", "rhs"))
  expect_identical(ans$lhs, c("a", "c+d"))
  expect_identical(ans$rhs, c("b", "e"))
  expect_identical(ans$arrow, c("-->", "<->"))
})

test_that("parse reactions", {
  l <- list(list(species = "a --> z"), list(species = "j <--> k"))
  ans <- parse_reactions(l)
  expect_length(ans,5)
  expect_identical(ans$label, c("<null>", "<null>"))
  expect_named(ans)
  expect_identical(names(ans), c("species", "lhs", "rhs", "j_names", "label"))
  lhs <- sapply(ans$lhs, "[[", 1L)
  expect_identical(lhs, c("a", "j"))
  rhs <- sapply(ans$rhs, "[[", 1L)
  expect_identical(rhs, c("z", "k"))
  expect_length(ans$lhs,2)
  expect_length(ans$rhs,2)
  expect_length(ans$j_names, length(ans$lhs))
})

test_that("parse reactions error", {
  l <- list(list(species = "a -->"))
  expect_error(parse_reactions(l),"invalid reaction specification")
  l <- list(list(species = " --> b"))
  expect_error(parse_reactions(l),"invalid reaction specification")
  l <- list(list(species = "a b"))
  expect_error(parse_reactions(l),"invalid reaction specification")
})
