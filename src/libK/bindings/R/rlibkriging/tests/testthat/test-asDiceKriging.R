#library(rlibkriging, lib.loc="bindings/R/Rlibs")
#library(testthat)

## Changes by Yves remove the references to the packages as in 'rlibkriging::simulate',
## because simulate is not exported as such from rlibkriging

f <- function(x) {
    1 - 1 / 2 * (sin(12 * x) / (1 + x) + 2 * cos(7 * x) * x^5 + 0.7)
}
## f <- function(X) apply(X, 1, function(x) prod(sin((x-.5)^2)))
n <- 5
set.seed(123)
X <- cbind(runif(n))
y <- f(X)
d <- ncol(X)

## kriging model 1 : matern5_2 covariance structure, no trend, no nugget effect
km1 <- DiceKriging::km(design = X, response = y, covtype = "gauss",
         formula = ~1, estim.method = "LOO",
         parinit = c(.15), control = list(trace = FALSE))
#library(rlibkriging)
KM1 <- rlibkriging::KM(design = X, response = y, covtype = "gauss",
          formula = ~1, estim.method = "LOO",
          parinit = c(.15))

test_that("m1.leaveOneOutFun == KM1.leaveOneOutFun",
          expect_true( DiceKriging::leaveOneOutFun(km1@covariance@range.val, km1) ==
                      DiceKriging::leaveOneOutFun(km1@covariance@range.val, KM1)))

test_that("m1.argmax(loo) == KM1.argmax(loo)", 
          expect_equal(km1@covariance@range.val,
                       KM1@covariance@range.val,
                       tol = 0.001))

plot(Vectorize(function(.t) DiceKriging::leaveOneOutFun(param = as.numeric(.t), model = km1)))
abline(v = km1@covariance@range.val)
plot(Vectorize(function(.t) rlibkriging::leaveOneOutFun(KM1@Kriging, as.numeric(.t))),
     add = TRUE, col = 'red')
abline(v = KM1@covariance@range.val, col = 'red')



##########################################################################

context("# A 2D example - Branin-Hoo function")

branin <- function (x) {
  x1 <- x[1] * 15 - 5
  x2 <- x[2] * 15
  (x2 - 5/(4 * pi^2) * (x1^2) + 5/pi * x1 - 6)^2 +
      10 * (1 - 1/(8 * pi)) * cos(x1) + 10
}

## a 16-points factorial design, and the corresponding response
d <- 2; n <- 16
design.fact <- expand.grid(x1 = seq(0, 1, length.out = 4),
                           x2 = seq(0, 1, length.out = 4))
y <- apply(design.fact, 1, DiceKriging::branin)

library(DiceKriging)
## kriging model 1 : matern5_2 covariance structure, no trend, no nugget effect
km1 <- DiceKriging::km(design = design.fact, response = y, covtype = "gauss",
          parinit = c(.5, 1), control = list(trace = FALSE))
rlibkriging:::optim_log(3)
KM1 <- rlibkriging::KM(design = design.fact, response = y, covtype = "gauss",
          parinit = c(.5, 1))
rlibkriging:::optim_log(0)

test_that("m1.logLikFun == as_m1.logLikFun",
          expect_true(DiceKriging::logLikFun(km1@covariance@range.val, km1) ==
                      DiceKriging::logLikFun(km1@covariance@range.val, KM1)))

test_that("m1.argmax(logLig) == as_m1.argmax(logLig)", 
          expect_equal(km1@covariance@range.val,
                       KM1@covariance@range.val,
                       tol = 0.01))

ll <- function(Theta){
    apply(Theta, 1,
          function(theta) DiceKriging::logLikFun(theta, km1))
}
as_ll <- function(Theta){
    apply(Theta, 1,
          function(theta) rlibkriging::logLikelihoodFun(KM1@Kriging, theta)$logLikelihood[1])
}
t <- seq(from = 0.01, to = 2,,51)
ttg <- expand.grid(t, t)
contour(t, t,
        matrix(ll(as.matrix(ttg)), nrow = length(t)), nlevels = 30)
contour(t, t,
        matrix(as_ll(as.matrix(ttg)), nrow = length(t)), nlevels = 30,
        add = TRUE, col = 'red')
points(km1@covariance@range.val[1],
       km1@covariance@range.val[2])
points(KM1@covariance@range.val[1],
       KM1@covariance@range.val[2],
       col = 'red')

pred <- DiceKriging::predict(km1,
                newdata = matrix(.5, ncol = 2), type = "UK",
                checkNames = FALSE, light.return = TRUE)
Pred <- DiceKriging::predict(KM1,
                newdata = matrix(.5, ncol = 2), type = "UK",
                checkNames = FALSE, light.return = TRUE)

test_that("p$mean, Pred$mean",
          expect_equal(pred$mean[1], Pred$mean[1], tol = 0.1))
test_that("pred$sd, Pred$sd",
          expect_equal(pred$sd[1], Pred$sd[1], tol = 0.1))

################################################################################

f <- function(x) {
    1 - 1 / 2 * (sin(12 * x) / (1 + x) + 2 * cos(7 * x) * x^5 + 0.7)
}
plot(f)
set.seed(123)
X <- as.matrix(runif(5))
y <- f(X)
points(X, y, col = 'blue')

#rlibkriging:::optim_log(2)
#rlibkriging:::optim_use_variogram_bounds_heuristic(TRUE)

r <- Kriging(y, X, kernel = "gauss")
x <- seq(0,1,,101)
s_x <- simulate(r, nsim = 3, x = x)
lines(x, s_x[ , 1], col = 'blue')
lines(x, s_x[ , 2], col = 'blue')
lines(x, s_x[ , 3], col = 'blue')

## sk_x = simulate(as.km(r), nsim=3, newdata=x)
##   lines(x,sk_x[,1],col='red')
##   lines(x,sk_x[,2],col='red')
##   lines(x,sk_x[,3],col='red')
  
################################################################################
f <-  function(x) 1 - 1 / 2 * (sin(12 * x) / (1 + x) + 2 * cos(7 * x) * x^5 + 0.7)
# f <- function(X) apply(X, 1, function(x) prod(sin((x-.5)^2)))
n <- 5
set.seed(123)
X <- cbind(runif(n))
y <- f(X)
d <- ncol(X)
plot(X,y)

formula <-~1
design <- X
response <-y
covtype <- "gauss"

## k <<- DiceKriging::km(formula = formula, design = design,
##                       response = response, covtype = covtype,
##                       coef.cov = 0.5, coef.var=0.5, coef.trend = 0.5, 
##                       control = list(trace=F))
## NOT working for logLikFun, because @method is not available (bug in
## DiceKriging ?)
## as_k <<- rlibkriging::KM(formula = formula,design = design,
##                          response = response, covtype = covtype,
##                          coef.cov = 0.5, coef.var = 0.5, coef.trend = 0.5)

km2 <<- DiceKriging::km(formula = formula,design = design,
                        response = response, covtype = covtype,
                        coef.cov = 0.5, coef.var=0.5, coef.trend = 0.5, 
                        control = list(trace=F))
km2@method <- "LL"
km2@case <- "LLconcentration_beta"

## XXXY Here a warning is thrown
suppressWarnings(KM2 <<- rlibkriging::KM(formula = formula,design = design,
                                         response = response, covtype = covtype,
                                         coef.cov = km2@covariance@range.val,
                                         coef.var= km2@covariance@sd2,
                                         coef.trend = km2@trend.coef))

test_that("DiceKriging::T == rlibkriging::T", expect_equal(km2@T, KM2@T))
test_that("DiceKriging::M == rlibkriging::M", expect_equal(km2@M, KM2@M))
test_that("DiceKriging::z == rlibkriging::z", expect_equal(km2@z, KM2@z))

# plot(Vectorize(function(.t) DiceKriging::logLikFun(c(.t,0.5),km2)[1]),
#      xlim = c(0.000001, 1),ylim=c(-5000,0))
# plot(Vectorize(function(.t)
#         rlibkriging::logLikelihoodFun(KM2@Kriging, .t)$logLikelihood[1]),
#      xlim = c(0.000001, 1),add=TRUE,col='red')
# abline(v=km2@covariance@range.val,col='blue')

x = km2@covariance@range.val
test_that("DiceKriging::logLik == rlibkriging::logLikelihood",
          expect_equal(DiceKriging::logLikFun(x, km2)[1],
                       rlibkriging::logLikelihoodFun(KM2@Kriging,x)$logLikelihood[1]))

x <- runif(ncol(X))
test_that("DiceKriging::logLik == rlibkriging::logLikelihood",
          expect_equal(DiceKriging::logLikFun(c(x,0.5), km2)[1], # logLikFun arg is c(theta,sigma2)
                       rlibkriging::logLikelihoodFun(KM2@Kriging,x)$logLikelihood[1]))
# not impl. in DiceKriging: LLconcentration_beta for LOO
#test_that("DiceKriging::leaveOneOut == rlibkriging::leaveOneOut",
#          expect_equal(DiceKriging::leaveOneOutFun(x, km2)[1],
#                       rlibkriging::leaveOneOutFun(KM2@Kriging,x)$leaveOneOut[1]))

.x=seq(from=0,to=1,length.out=11)
plot(f)
points(X,y)
lines(.x,DiceKriging::predict(km2,newdata=.x,type="UK",checkNames=FALSE)$mean,xlim=c(0,1))
lines(.x,DiceKriging::predict(KM2,newdata=.x,type="UK",checkNames=FALSE)$mean,col='red')
lines(.x,KM2@Kriging$predict(.x)$mean,col='red',lty=2)

x <- 0.5
test_that("Consitency of 'DiceKriging' and 'rlibkriging' 'predict' methods",
          expect_equal(DiceKriging::predict(km2,newdata = x, type = "UK",
                                            checkNames = FALSE)$mean[1],
                       DiceKriging::predict(KM2, newdata = x, type = "UK")$mean[1],
                       tol = 0.01))

x <- matrix(X[2, ], ncol = d) + 0.001
n <-  1000
set.seed(123)
sims_km2 <- DiceKriging::simulate(km2, nsim = n,newdata = x,
                     checkNames = FALSE, cond = TRUE,
                     nugget.sim=1e-10)
sims_KM2 <- DiceKriging::simulate(KM2, nsim = n, newdata = x,
                     checkNames = FALSE , cond = TRUE)
t <- t.test(sims_km2, sims_KM2, var.equal = FALSE)

if (t$p.value < 0.05) {
    plot(f)
    points(X, y)
    xx <-  seq(0,1,,101)
    for (i in 1:100) {
        lines(xx, DiceKriging::simulate(km2, nsim = 1, newdata = xx,
                           checkNames = FALSE, cond = TRUE,
                           nugget.sim = 1e-10),
              col = rgb(0, 0, 1, 0.02))
        lines(xx, DiceKriging::simulate(KM2, nsim = 1, newdata = xx,
                           checkNames = FALSE, cond=TRUE,
                           nugget.sim = 0),
              col = rgb(1, 0, 0, 0.02))
    }
}
print(t)
## issue #100
## test_that("DiceKriging::simulate ~= rlibkriging::simulate",
##           expect_true(t$p.value>0.05))
################################################################################


f <- function(X) apply(X, 1, function(x) prod(sin((x * pi - .5)^2)))
n <- 5#100
set.seed(123)
X <- cbind(runif(n))#,runif(n),runif(n))
y <- f(X)
d <-  ncol(X)
## plot(function(x)f(as.matrix(x)))
## points(X,y)

test_args <-  function(formula, design, response ,covtype, estim.method ) {
    context(paste0("asDiceKriging: ",
                   paste0(sep = ", ",
                          formula,
                          paste0("design ", nrow(design), "x", ncol(design)),
                          paste0("response ", nrow(response), "x", ncol(response)),
                          covtype)))
    
    set.seed(123)
    
  parinit <- runif(ncol(design))
    k <<- DiceKriging::km(formula = formula, design = design,
             response = response, covtype = covtype,
             estim.method = estim.method,
             parinit = parinit, control = list(trace = FALSE))
    as_k <<- rlibkriging::KM(formula = formula, design = design,
                response = response, covtype = covtype,
                estim.method = estim.method,
                parinit = parinit)
    
    ##print(k)
    ##print(as_k)
    ##if (e=="MLE") {
    ##  plot(Vectorize(function(t)DiceKriging::logLikFun(t,k)[1]),xlim=c(0.0001,2))
    ##} else {
    ##  plot(Vectorize(function(t)DiceKriging::leaveOneOutFun(t,k)[1]),xlim=c(0.0001,2))
    ##}
    ##abline(v=k@covariance@range.val)
    ##if (e=="MLE") {
    ##  plot(Vectorize(function(t)rlibkriging::logLikelihoodFun(as_k@Kriging,t)$logLikelihood[1]),
    ##       xlim = c(0.0001,2), add=T, col='red')
    ##} else {
    ##  plot(Vectorize(function(t)rlibkriging::leaveOneOutFun(as_k@Kriging,t)$leaveOneOut[1]),
    ##       xlim=c(0.0001,2),add=T,col='red')
    ##}
    ##abline(v=as_k@covariance@range.val,col='red')

  t <- runif(ncol(X))
    test_that("DiceKriging::logLikFun == rlibkriging::logLikelihood",
              expect_equal(DiceKriging::logLikFun(t, k)[1],
                           rlibkriging::logLikelihoodFun(as_k@Kriging,t)$logLikelihood[1]))
    test_that("DiceKriging::leaveOneOutFun == rlibkriging::leaveOneOut",
              expect_equal(DiceKriging::leaveOneOutFun(t, k)[1],
                           rlibkriging::leaveOneOutFun(as_k@Kriging, t)$leaveOneOut[1]))
    
    x <- matrix(runif(d),ncol=d)
    test_that("DiceKriging::predict == rlibkriging::predict",
              expect_equal(DiceKriging::predict(k, newdata = x, type = "UK",
                                                checkNames = FALSE)$mean[1],
                           DiceKriging::predict(as_k, newdata = x, type = "UK")$mean[1],
                           tol = 0.01))
    
    n <- 1000
    set.seed(123)
    sims_km2 <<- DiceKriging::simulate(k, nsim = n, newdata = x,
                          checkNames = FALSE, cond = TRUE,
                          nugget.sim = 1e-10)
    sims_KM2 <<- DiceKriging::simulate(as_k, nsim = n,newdata = x,
                          checkNames = FALSE, cond = TRUE)
    t = t.test(t(sims_km2), sims_KM2, var.equal = FALSE , paired = FALSE)
    print(t)
    ## issue #100 
     test_that("DiceKriging::simulate ~= rlibkriging::simulate",
               expect_true(t$p.value>0.05))
}

## Test the whole matrix of km features already available
for (f in c( ~1 , ~. , ~.^2 ))
    for (co in c("gauss","exp","matern3_2","matern5_2"))
        for (e in c("MLE","LOO")) {
            print(paste0("kernel:", co, " objective:", e,
                         " trend:", paste0(f, collapse = "")))
            test_args(formula = f, design = X,
                      response = y, covtype = co, estim.method = e)
    }
