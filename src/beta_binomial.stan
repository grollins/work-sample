data {
    int<lower=1> nA;
    int<lower=1> nB;
    int<lower=0> zA;
    int<lower=0> zB;
}
parameters {
    real<lower=0,upper=1> thetaA;
    real<lower=0,upper=1> thetaB;
}
transformed parameters {
    real<lower=-1,upper=1> delta_theta;
    delta_theta = thetaB - thetaA;
}
model {
    // Prior Distribution for Rate Theta
    thetaA ~ beta(4, 1);
    thetaB ~ beta(4, 1);
    // Observed Counts
    zA ~ binomial(nA, thetaA);
    zB ~ binomial(nB, thetaB);
}
