% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/KrigingClass.R
\name{fit.Kriging}
\alias{fit.Kriging}
\title{Fit \code{Kriging} object on given data.}
\usage{
\method{fit}{Kriging}(
  object,
  y,
  X,
  regmodel = c("constant", "linear", "interactive", "none"),
  normalize = FALSE,
  optim = c("BFGS", "Newton", "none"),
  objective = c("LL", "LOO", "LMP"),
  parameters = NULL,
  ...
)
}
\arguments{
\item{object}{S3 Kriging object.}

\item{y}{Numeric vector of response values.}

\item{X}{Numeric matrix of input design.}

\item{regmodel}{Universal Kriging linear trend: \code{"constant"}, 
\code{"linear"}, \code{"interactive"}, \code{"quadratic"}.}

\item{normalize}{Logical. If \code{TRUE} both the input matrix
\code{X} and the response \code{y} in normalized to take
values in the interval \eqn{[0, 1]}.}

\item{optim}{Character giving the Optimization method used to fit
hyper-parameters. Possible values are: \code{"BFGS"},
\code{"Newton"} and \code{"none"}, the later simply keeping
the values given in \code{parameters}. The method
\code{"BFGS"} uses the gradient of the objective (note that \code{"BGFS10"} means 10 multi-start of BFGS). The method
\code{"Newton"} uses both the gradient and the Hessian of the
objective.}

\item{objective}{Character giving the objective function to
optimize. Possible values are: \code{"LL"} for the
Log-Likelihood, \code{"LOO"} for the Leave-One-Out sum of
squares and \code{"LMP"} for the Log-Marginal Posterior.}

\item{parameters}{Initial values for the hyper-parameters. When
provided this must be named list with elements \code{"sigma2"}
and \code{"theta"} containing the initial value(s) for the
variance and for the range parameters. If \code{theta} is a
matrix with more than one row, each row is used as a starting
point for optimization.}

\item{...}{Ignored.}
}
\value{
No return value. Kriging object argument is modified.
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
y <- f(X)
points(X, y, col = "blue", pch = 16)

k <- Kriging("matern3_2")
print(k)

fit(k,y,X)
print(k)
}
\author{
Yann Richet \email{yann.richet@asnr.fr}
}
