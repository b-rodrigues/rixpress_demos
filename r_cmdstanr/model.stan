data {
  int<lower=1> N;
  vector[N] x;
  vector[N] y;
}
parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}
model {
  // Priors
  alpha ~ normal(0, 5);
  beta  ~ normal(0, 5);
  sigma ~ inv_gamma(1, 1);

  // Likelihood
  y ~ normal(alpha + beta * x, sigma);
}