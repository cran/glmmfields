#' Return a vector of parameters
#'
#' @param obs_error The observation error distribution
#' @param estimate_df Logical indicating whether the degrees of freedom
#'   parameter should be estimated
#' @param est_temporalRE Logical: estimate a random walk for the time variable?
#' @param estimate_ar Logical indicating whether the ar
#'   parameter should be estimated
#' @param fixed_intercept Should the intercept be fixed?
#' @param save_log_lik Logical: should the log likelihood for each data point be
#'   saved so that information criteria such as LOOIC or WAIC can be calculated?
#'   Defaults to \code{FALSE} so that the size of model objects is smaller.
stan_pars <- function(obs_error, estimate_df = TRUE, est_temporalRE = FALSE,
                      estimate_ar = FALSE, fixed_intercept = FALSE,
                      save_log_lik = FALSE) {
  p <- c(
    #"y_new",
    "gp_sigma",
    "gp_theta",
    "B",
    switch(obs_error[[1]], lognormal = "sigma", gaussian = "sigma",
      gamma = "CV", nbinom2 = "nb2_phi"
    ),
    "spatialEffectsKnots"
  )
  if (estimate_df) p <- c("df", p)
  if (estimate_ar) p <- c("phi", p)
  if (est_temporalRE) {
    p <- c("year_sigma", "yearEffects", p)
  }
  if (fixed_intercept) p <- p[p != "B"]
  if (save_log_lik) p <- c(p, "log_lik")
  p
}
