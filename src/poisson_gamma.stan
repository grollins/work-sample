data {
    int<lower=1> N; // customers
    int<lower=1> K; // observations
    int<lower=0> Y[N,K];
}
parameters {
    real<lower=0,upper=10> alpha;
    real<lower=0,upper=1> beta;
    real<lower=0> lambda[N];
}
transformed parameters {
}
model {
    for(i in 1:N) {
        lambda[i] ~ gamma(alpha,beta);
        Y[i] ~ poisson(lambda[i]);
    }
}
