#' Lognormal family
#'
#' @param link The link (must be log)
#' @export
#' @examples
#' lognormal()
lognormal <- function(link = "log") {
  assert_that(identical("log", as.character(substitute(link))))
  list(family = "lognormal", link = "log")
}

#' Negative binomial family
#'
#' This is the NB2 parameterization where the variance scales quadratically
#' with the mean.
#'
#' @param link The link (must be log)
#' @export
#' @examples
#' nbinom2()
nbinom2 <- function(link = "log") {
  assert_that(identical("log", as.character(substitute(link))))
  list(family = "nbinom2", link = "log")
}

# Check a family object
#
# @param family The family
check_family <- function(family) {
  assert_that(identical(class(family), "family") |
    identical(lognormal(link = "log"), family) |
    identical(nbinom2(link = "log"), family))

  assert_that(family$family %in%
    c("gaussian", "lognormal", "Gamma", "nbinom2", "poisson", "binomial"))

  if (family$family == "gaussian") assert_that(identical(family$link, "identity"))
  if (family$family %in% c("lognormal", "Gamma", "nbinom2", "poisson")) {
    assert_that(identical(family$link, "log"))
  }
  if (family$family == "binomial") assert_that(identical(family$link, "logit"))

  list(family = family$family, link = family$link)
}

logit <- function(x) stats::qlogis(x)
