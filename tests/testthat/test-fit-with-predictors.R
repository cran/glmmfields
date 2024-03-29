if (interactive()) options(mc.cores = parallel::detectCores())

ITER <- 600
CHAINS <- 2
SEED <- 9999
TOL <- 0.2 # %
TOL_df <- .25 # %

# ------------------------------------------------------
# a Gaussian observation model with factor-level predictors for years

test_that("mvt-norm estimates betas", {
  skip_on_cran()
  skip_on_travis()
  skip_on_appveyor()

  gp_sigma <- 0.2
  sigma <- 0.1
  df <- 10
  gp_theta <- 1.2
  n_draws <- 15
  nknots <- 9
  set.seed(SEED)
  B <- rnorm(n_draws, 0, 1)

  s <- sim_glmmfields(
    df = df, n_draws = n_draws, gp_theta = gp_theta,
    gp_sigma = gp_sigma, sd_obs = sigma, n_knots = nknots, B = B,
    X = model.matrix(~a - 1, data.frame(a = gl(n_draws, 100)))
  )
  # print(s$plot)
  # library(ggplot2); ggplot(s$dat, aes(time, y)) + geom_point()

  suppressWarnings({
  m <- glmmfields(y ~ as.factor(time) - 1,
    data = s$dat, time = "time",
    lat = "lat", lon = "lon", nknots = nknots,
    iter = ITER, chains = CHAINS, seed = SEED,
    estimate_df = FALSE, fixed_df_value = df,
    prior_beta = student_t(50, 0, 2)
  )
  })

  b <- tidy(m, estimate.method = "median")
  expect_equal(as.numeric(b[b$term == "sigma[1]", "estimate", drop = TRUE]), sigma, tol = sigma * TOL)
  expect_equal(as.numeric(b[b$term == "gp_sigma", "estimate", drop = TRUE]), gp_sigma, tol = gp_sigma * TOL)
  expect_equal(as.numeric(b[b$term == "gp_theta", "estimate", drop = TRUE]), gp_theta, tol = gp_theta * TOL)
  expect_equal(as.numeric(b[grep("B\\[*", b$term), "estimate", drop = TRUE]), B, tol = 0.05)
})
