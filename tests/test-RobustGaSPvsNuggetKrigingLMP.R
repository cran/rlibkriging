if(requireNamespace('RobustGaSP', quietly = TRUE)) {
library(testthat)
 Sys.setenv('OMP_THREAD_LIMIT'=2)
 library(rlibkriging)

library(RobustGaSP)

kernel_type = function(kernel) {
  if (kernel=="matern3_2") return("matern_3_2")
  if (kernel=="matern5_2") return("matern_5_2")
  stop(paste0("Cannot use ",kernel))
}
kernel_type_num = function(kernel) {
  if (kernel=="matern3_2") return(2)
  if (kernel=="matern5_2") return(3)
  stop(paste0("Cannot use ",kernel))
}

for (kernel in c("matern5_2","matern3_2")) {
  context(paste0("Check Marginal Posterior for kernel ",kernel))
  
  f = function(x) 1-1/2*(sin(12*x)/(1+x)+2*cos(7*x)*x^5+0.7)
  plot(f)
  n <- 15
  set.seed(123)
  X <- as.matrix(runif(n))
  y = f(X) + rnorm(n,0,0.1)
  points(X,y)

  k = RobustGaSP::rgasp(design=X,response=y,kernel_type=kernel_type(kernel), nugget.est=TRUE)

  lmp = function(theta,nugget_est=FALSE) {
    #cat("theta: ",theta,"\n")
    param = c(log(1/theta),k@nugget)
    if (!nugget_est) param = param[-length(param)]
    #cat("log_marginal_lik\n")
    lml = RobustGaSP::log_marginal_lik(param=param,nugget=k@nugget,nugget_est=nugget_est,
      R0=k@R0,X=k@X,zero_mean=k@zero_mean,output=k@output,kernel_type=kernel_type_num(kernel),alpha=k@alpha)
    #cat("  lml: ",lml,"\n")
    #cat("log_approx_ref_prior\n")
    larp = RobustGaSP::log_approx_ref_prior(param=param,nugget=k@nugget,nugget_est=nugget_est,
      CL=k@CL,a=0.2,b=1/(length(y))^{1/dim(as.matrix(X))[2]}*(0.2+dim(as.matrix(X))[2]))
    #cat("  larp: ",larp,"\n")
    return(lml+larp)
  }

  plot(Vectorize(lmp),ylab="LMP",xlab="theta",xlim=c(0.01,2),ylim=c(-5,5))
  abline(v=1/k@beta_hat)

  lmp_deriv = function(theta, nugget_est=FALSE) {
    #cat("theta: ",theta,"\n")
    param = c(log(1/theta),k@nugget)
    if (!nugget_est) param = param[-length(param)]
    #cat("log_marginal_lik_deriv\n")
    lml_d = RobustGaSP::log_marginal_lik_deriv(param=param,nugget=k@nugget,nugget_est=nugget_est,
      R0=k@R0,X=k@X,zero_mean=k@zero_mean,output=k@output,kernel_type=kernel_type_num(kernel),alpha=k@alpha)
    #cat("  lml_d: ",lml_d,"\n")
    #cat("log_approx_ref_prior_deriv\n")
    larp_d = RobustGaSP::log_approx_ref_prior_deriv(param=param,nugget=k@nugget,nugget_est=nugget_est,
      CL=k@CL,a=0.2,b=1/(length(y))^{1/dim(as.matrix(X))[2]}*(0.2+dim(as.matrix(X))[2]))
    #cat("  larp_d: ",larp_d,"\n")
    return((lml_d + larp_d)* 1/theta * (-1/theta))
  }

  for (x in seq(0.01,2,,11)){
    arrows(x,lmp(x),x+.1,lmp(x)+.1*lmp_deriv(x))
  }

  #library(rlibkriging)
  r <- NuggetKriging(y, X, kernel, objective="LMP")#, 
                     #optim="none", parameters=list(theta = matrix(1/k@beta_hat), nugget=k@nugget*k@sigma2_hat,sigma2=k@sigma2_hat))
  ## Should be equal:
  #lmp(1.0); lmp_deriv(1.0);
  #logMargPostFun(r,1.0,return_grad = T)
  #lmp(0.1); lmp_deriv(0.1);
  #logMargPostFun(r,0.1,return_grad = T)
  #ll2 = function(theta) logMargPostFun(r,theta)$logMargPost
  # plot(Vectorize(ll2),col='red',add=T,xlim=c(0.01,2)) # FIXME fails with "error: chol(): decomposition failed"
  alpha = r$sigma2()/(r$sigma2()+r$nugget()) #1/(1+k@nugget) #r$sigma2()/(r$nugget()+r$sigma2())
  for (x in seq(0.01,2,,11)){
    ll2x = logMargPostFun(r,c(x,alpha))$logMargPost
    gll2x = logMargPostFun(r,c(x,alpha),return_grad = T)$logMargPostGrad[1]
    arrows(x,ll2x,x+.1,ll2x+.1*gll2x,col='red')
  }
  
#lmp_deriv(c(k@beta_hat,k@nugget), TRUE)
#logMargPostFun(r,c(1/k@beta_hat,1/(1+k@nugget)),return_grad = T)
#logMargPostFun(r,c(r$theta(),r$sigma2()/(r$sigma2()+r$nugget())),return_grad = T)

  precision <- 1e-4  # the following tests should work with it, since the computations are analytical
  x=.5
  test_that(desc="logMargPost is the same that RobustGaSP one", 
            expect_equal(logMargPostFun(r,c(x,1/(1+k@nugget)))$logMargPost[1],lmp(x),tolerance = precision))
  
  test_that(desc="logMargPost Grad is the same that RobustGaSP one", 
            expect_equal(logMargPostFun(r,c(x,1/(1+k@nugget)),return_grad = T)$logMargPostGrad[1],lmp_deriv(x),tolerance= precision))
}
}
