% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NuggetKrigingClass.R
\name{fit.NuggetKriging}
\alias{fit.NuggetKriging}
\title{Fit \code{NuggetKriging} object on given data.}
\usage{
\method{fit}{NuggetKriging}(
  object,
  y,
  X,
  regmodel = c("constant", "linear", "interactive", "none"),
  normalize = FALSE,
  optim = c("BFGS", "none"),
  objective = c("LL", "LMP"),
  parameters = NULL,
  ...
)
}
\arguments{
\item{object}{S3 NuggetKriging object.}

\item{y}{Numeric vector of response values.}

\item{X}{Numeric matrix of input design.}

\item{regmodel}{Universal NuggetKriging 
\code{"linear"}, \code{"interactive"}, \code{"quadratic"}.}

\item{normalize}{Logical. If \code{TRUE} both the input matrix
\code{X} and the response \code{y} in normalized to take
values in the interval \eqn{[0, 1]}.}

\item{optim}{Character giving the Optimization method used to fit
hyper-parameters. Possible values are: \code{"BFGS"} and \code{"none"},
the later simply keeping
the values given in \code{parameters}. The method
\code{"BFGS"} uses the gradient of the objective 
(note that \code{"BGFS10"} means 10 multi-start of BFGS).}

\item{objective}{Character giving the objective function to
optimize. Possible values are: \code{"LL"} for the
Log-Likelihood and \code{"LMP"} for the Log-Marginal Posterior.}

\item{parameters}{Initial values for the hyper-parameters. When provided this
must be named list with some elements \code{"sigma2"}, \code{"theta"}, \code{"nugget"}
containing the initial value(s) for the variance, range and nugget
parameters. If \code{theta} is a matrix with more than one row,
each row is used as a starting point for optimization.}

\item{...}{Ignored.}
}
\value{
No return value. NuggetKriging object argument is modified.
}
\description{
The hyper-parameters (variance and vector of correlation ranges)
are estimated thanks to the optimization of a criterion given by
\code{objective}, using the method given in \code{optim}.
}
\examples{
f <- function(x) 1 - 1 / 2 * (sin(12 * x) / (1 + x) + 2 * cos(7 * x) * x^5 + 0.7)
plot(f)
set.seed(123)
X <- as.matrix(runif(10))
y <- f(X) + 0.1 * rnorm(nrow(X))
points(X, y, col = "blue", pch = 16)

k <- NuggetKriging("matern3_2")
print(k)

fit(k,y,X)
print(k)
}
\author{
Yann Richet \email{yann.richet@asnr.fr}
}
