library(testthat)
 Sys.setenv('OMP_THREAD_LIMIT'=2)
 library(rlibkriging)

##library(rlibkriging, lib.loc="bindings/R/Rlibs")
##library(testthat)
#kernel="gauss"

for (kernel in c("exp","matern3_2","matern5_2","gauss")) {
  context(paste0("Check LogLikelihood for kernel ",kernel))
  
  f = function(x) 1-1/2*(sin(12*x)/(1+x)+2*cos(7*x)*x^5+0.7)
  plot(f)
  n <- 5
  set.seed(123)
  X <- as.matrix(runif(n))
  y = f(X)
  points(X,y)

  k = DiceKriging::km(design=X,response=y,covtype = kernel,control = list(trace=F),nugget=0, nugget.estim=TRUE)
  alpha0 = k@covariance@sd2/(k@covariance@sd2+k@covariance@nugget)
  ll_theta = function(theta) DiceKriging::logLikFun(c(theta,alpha0),k)
  plot(Vectorize(ll_theta),ylab="LL",xlab="theta",xlim=c(0.01,1))
  for (x in seq(0.01,1,,5)){
    envx = new.env()
    llx = DiceKriging::logLikFun(c(x,alpha0),k,envx)
    gllx = DiceKriging::logLikGrad(c(x,alpha0),k,envx)[1,]
    arrows(x,llx,x+.1,llx+.1*gllx)
  }
  
  ##library(rlibkriging)
  r <- NuggetKriging(y, X, kernel, parameters=list(nugget=0,is_nugget_estim=TRUE))
  ll2_theta = function(theta) logLikelihoodFun(r,c(theta,alpha0))$logLikelihood
  # second arg is alpha=1 for nugget=0
  # plot(Vectorize(ll2),col='red'), add=T) 
  for (x in seq(0.01,1,,5)){
    envx = new.env()
    ll2x = logLikelihoodFun(r,c(x,alpha0))$logLikelihood
    gll2x = logLikelihoodFun(r,c(x,alpha0),return_grad = T)$logLikelihoodGrad[,1]
    arrows(x,ll2x,x+.1,ll2x+.1*gll2x,col='red')
  }
  
  theta0 = k@covariance@range.val
  ll_alpha = function(alpha) DiceKriging::logLikFun(c(theta0,alpha),k)
  plot(Vectorize(ll_alpha),ylab="LL",xlab="alpha",xlim=c(0.01,1))
  for (x in seq(0.01,1,,5)){
    envx = new.env()
    llx = DiceKriging::logLikFun(c(theta0,x),k,envx)
    gllx = DiceKriging::logLikGrad(c(theta0,x),k,envx)[2,]
    arrows(x,llx,x+.1,llx+.1*gllx)
  }
  ll2_alpha = function(alpha) logLikelihoodFun(r,c(theta0,alpha))$logLikelihood
  #plot(Vectorize(ll2_alpha),col='red',add=T)
  for (x in seq(0.01,1,,5)){
    envx = new.env()
    ll2x = logLikelihoodFun(r,c(theta0,x))$logLikelihood
    gll2x = logLikelihoodFun(r,c(theta0,x),return_grad = T)$logLikelihoodGrad[,2]
    arrows(x,ll2x,x+.1,ll2x+.1*gll2x,col='red')
  }

  precision <- 1e-8  # the following tests should work with it, since the computations are analytical
  x=.25
  xenv=new.env()
  test_that(desc="logLik is the same that DiceKriging one /alpha", 
            expect_equal(
              logLikelihoodFun(r,c(theta0,x))$logLikelihood[1]
              ,
              DiceKriging::logLikFun(c(theta0,x),k,xenv)
              ,tolerance = precision))
  
  test_that(desc="logLik Grad is just good /alpha", 
            expect_equal(
              logLikelihoodFun(r,c(theta0,x),return_grad=T)$logLikelihoodGrad[,2]
              ,
              -(logLikelihoodFun(r,c(theta0,x-1e-5))$logLikelihood[1]-logLikelihoodFun(r,c(theta0,x))$logLikelihood[1])/1e-5,
              ,tolerance= 1e-5))
              
  test_that(desc="logLik Grad is the same that DiceKriging one /alpha", 
            expect_equal(
              logLikelihoodFun(r,c(theta0,x),return_grad=T)$logLikelihoodGrad[,2]
              ,
              DiceKriging::logLikGrad(c(theta0,x),k,xenv)[2,]
              ,tolerance= precision))
              
  xenv=new.env()
  test_that(desc="logLik is the same that DiceKriging one /theta", 
            expect_equal(
              logLikelihoodFun(r,c(x,alpha0))$logLikelihood[1]
              ,
              DiceKriging::logLikFun(c(x,alpha0),k,xenv)
              ,tolerance = precision))

  test_that(desc="logLik Grad is just good /theta", 
            expect_equal(
              logLikelihoodFun(r,c(x,alpha0),return_grad=T)$logLikelihoodGrad[,1]
              ,
              (logLikelihoodFun(r,c(x+1e-5,alpha0))$logLikelihood[1]-logLikelihoodFun(r,c(x,alpha0))$logLikelihood[1])/1e-5
              ,tolerance= 1e-3))

  test_that(desc="logLik Grad is the same that DiceKriging one /theta", 
            expect_equal(
              logLikelihoodFun(r,c(x,alpha0),return_grad=T)$logLikelihoodGrad[,1]
              ,
              DiceKriging::logLikGrad(c(x,alpha0),k,xenv)[1,]
              ,tolerance= precision))

}


########################## 2D



for (kernel in c("matern3_2","matern5_2","gauss","exp")) {
  context(paste0("Check LogLikelihood for kernel ",kernel))
  
  f <- function(X) apply(X, 1, function(x) prod(sin((x-.5)^2)))
  n <- 10
  set.seed(123)
  X <- cbind(runif(n),runif(n),runif(n))
  y <- f(X)

  k = DiceKriging::km(design=X,response=y,covtype = kernel,control = list(trace=F),nugget=0, nugget.estim=TRUE)
  
  ##library(rlibkriging)
  r <- NuggetKriging(y, X, kernel, parameters=list(nugget=0,is_nugget_estim=TRUE))
  
  precision <- 1e-8  # the following tests should work with it, since the computations are analytical
  #x = c(.2,.5,.7,0.01)
  #x=c(.5,.5,.5,.9999995)
  x = c(r$theta(),r$sigma2()/(r$sigma2()+r$nugget()))
  #x = c(k@covariance@range.val,k@covariance@sd2/(k@covariance@sd2+k@covariance@nugget))
  xenv=new.env()
  test_that(desc="logLik is the same that DiceKriging one", 
            expect_equal(
              logLikelihoodFun(r,x)$logLikelihood[1]
              ,
              DiceKriging::logLikFun(x,k,xenv)
              ,tolerance = precision))
  
  test_that(desc="logLik Grad is the same that DiceKriging one", 
            expect_equal(
              logLikelihoodFun(r,x,return_grad=T)$logLikelihoodGrad[1,]
              ,
              t(DiceKriging::logLikGrad(x,k,xenv))[1,]
              ,tolerance= precision))

  eps=0.000001
  test_that(desc="logLik Grad is just good", 
            expect_equal(
              -logLikelihoodFun(r,x,return_grad=T)$logLikelihoodGrad[1,]
              ,
              c( # finite-diff grad
                (logLikelihoodFun(r,x-c(eps,0,0,0))$logLikelihood[1]-logLikelihoodFun(r,x)$logLikelihood[1])/eps,
                (logLikelihoodFun(r,x-c(0,eps,0,0))$logLikelihood[1]-logLikelihoodFun(r,x)$logLikelihood[1])/eps,
                (logLikelihoodFun(r,x-c(0,0,eps,0))$logLikelihood[1]-logLikelihoodFun(r,x)$logLikelihood[1])/eps,
                (logLikelihoodFun(r,x-c(0,0,0,eps))$logLikelihood[1]-logLikelihoodFun(r,x)$logLikelihood[1])/eps
              )
              ,tolerance= 1e-2))
}
