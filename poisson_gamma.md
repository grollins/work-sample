Gamma-Poisson Model of User Heterogeneity
================

Data
----

In this example, suppose we have data on the number of times per month that users of amazingcatnews.com visit the site. We have a 1000 x 100 data frame. The rows are users and the columns are months: row 1 represents the number of site visits per month between Oct 2008 and Jan 2017 for user 1, row 2 corresponds to visits per month for user 2, etc.

    ##    2008-10-01 2008-11-01 2008-12-01 2009-01-01 2009-02-01 2009-03-01
    ## 1           0          1          1          0          0          0
    ## 2           0          0          0          1          1          0
    ## 3           1          0          0          1          0          0
    ## 4           3          0          0          1          0          1
    ## 5           2          1          1          0          0          1
    ## 6           0          0          2          3          2          4
    ## 7           1          1          0          1          1          3
    ## 8           3          4          3          2          0          5
    ## 9           3          1          4          1          4          3
    ## 10          1          3          9          5          2          2

Plotting the data below, most users are relatively inactive, but there's a long tail of very active users. Most of the user time traces are plotted in gray, but a few examples are highlighted in teal.

![](poisson_gamma_files/unnamed-chunk-3-1.png)

Fitting model to data using RStan
---------------------------------

We can use Stan to fit a model to the data.

### Model

User *i* visited amazingcatnews.com *Y*<sub>*i*, *j*</sub> times in month *j*. The number of monthly visits is Poisson-distributed with rate parameter *λ*<sub>*i*</sub>. The rate parameters are sampled from a gamma distribution with scale parameter *α* and rate parameter *β*. Flat priors are assigned to *α* and *β*.

*Y*<sub>*i*, *j*</sub> ∼ Poisson(*λ*<sub>*i*</sub>)
*λ*<sub>*i*</sub> ∼ Gamma(*α*, *β*)
*α* ∼ Uniform(0, 10)
*β* ∼ Uniform(0, 1)

### Define Stan model

``` stan
data {
    int<lower=1> N; // num users
    int<lower=1> K; // num observations per user
    int<lower=0> Y[N,K];
}
parameters {
    real<lower=0> alpha; // gamma scale
    real<lower=0> beta;  // gamma shape
    real<lower=0> lambda[N]; // poisson rate by user
}
model {
    for(i in 1:N) {
        lambda[i] ~ gamma(alpha,beta);
        Y[i] ~ poisson(lambda[i]);
    }
}
```

### Stan fit

``` r
data = list(N = num_customers, K = num_observations_per_user,
            Y = Y)

fit <- stan(file = 'poisson_gamma.stan', data = data,
            iter = 1500, warmup = 500, chains = 1)
```

    ## Inference for Stan model: poisson_gamma.
    ## 1 chains, each with iter=1000; warmup=500; thin=1;
    ## post-warmup draws per chain=500, total post-warmup draws=500.
    ##
    ##            mean se_mean    sd  2.5%   25%   50%   75% 97.5% n_eff  Rhat
    ## alpha     1.522   0.003 0.061 1.410 1.483 1.518 1.557 1.658   500 1.000
    ## beta      0.020   0.000 0.001 0.019 0.020 0.020 0.021 0.022   500 1.004
    ## lambda[1] 0.436   0.003 0.068 0.314 0.391 0.436 0.476 0.568   500 0.998
    ## lambda[2] 0.681   0.004 0.081 0.532 0.619 0.678 0.741 0.834   500 0.998
    ## lambda[3] 0.787   0.004 0.079 0.639 0.733 0.787 0.846 0.933   500 1.001
    ## lambda[4] 1.183   0.005 0.109 0.971 1.115 1.178 1.251 1.407   500 0.998
    ##
    ## Samples were drawn using NUTS(diag_e) at Sat Jan 21 14:57:39 2017.
    ## For each parameter, n_eff is a crude measure of effective sample size,
    ## and Rhat is the potential scale reduction factor on split chains (at
    ## convergence, Rhat=1).

The true values used to generate the data were *α* = 1.5 and *β* = 0.02.
