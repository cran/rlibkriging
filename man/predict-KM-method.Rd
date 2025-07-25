% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/KMClass.R
\name{predict,KM-method}
\alias{predict,KM-method}
\title{Prediction Method for a \code{KM} Object}
\usage{
\S4method{predict}{KM}(
  object,
  newdata,
  type = "UK",
  se.compute = TRUE,
  cov.compute = FALSE,
  light.return = TRUE,
  bias.correct = FALSE,
  checkNames = FALSE,
  ...
)
}
\arguments{
\item{object}{\code{KM} object.}

\item{newdata}{Matrix of "new" input points where to perform
prediction.}

\item{type}{character giving the kriging type. For now only
\code{"UK"} is possible.}

\item{se.compute}{Logical. Should the standard error be computed?}

\item{cov.compute}{Logical. Should the covariance matrix between
newdata points be computed?}

\item{light.return}{Logical. If \code{TRUE}, no auxiliary results
will be returned (such as the Cholesky root of the correlation
matrix).}

\item{bias.correct}{Logical. If \code{TRUE} the UK variance and
covariance are .}

\item{checkNames}{Logical to check the consistency of the column
names between the design stored in \code{object@X} and the new
one given \code{newdata}.}

\item{...}{Ignored.}
}
\value{
A named list. The elements are the conditional mean and
    standard deviation (\code{mean} and \code{sd}), the predicted
    trend (\code{trend}) and the confidence limits (\code{lower95}
    and \code{upper95}). Optionnally, the conditional covariance matrix
    is returned in \code{cov}.
}
\description{
Compute predictions for the response at new given input
points. These conditional mean, the conditional standard deviation
and confidence limits at the 95\% level. Optionnally the
conditional covariance can be returned as well.
}
\details{
Without a dedicated \code{predict} method for the class
\code{"KM"}, this method would have been inherited from the
\code{"km"} class. The dedicated method is expected to run faster.
A comparison can be made by coercing a \code{KM} object to a
\code{km} object with \code{\link{as.km}} before calling
\code{predict}.
}
\examples{
## a 16-points factorial design, and the corresponding response
d <- 2; n <- 16
design.fact <- expand.grid(x1 = seq(0, 1, length = 4), x2 = seq(0, 1, length = 4))
y <- apply(design.fact, 1, DiceKriging::branin) 

## library(DiceKriging)
## kriging model 1 : matern5_2 covariance structure, no trend, no nugget
## m1 <- km(design = design.fact, response = y, covtype = "gauss",
##          parinit = c(.5, 1), control = list(trace = FALSE))
KM1 <- KM(design = design.fact, response = y, covtype = "gauss",
               parinit = c(.5, 1))
Pred <- predict(KM1, newdata = matrix(.5,ncol = 2), type = "UK",
                checkNames = FALSE, light.return = TRUE)

}
\author{
Yann Richet \email{yann.richet@asnr.fr}
}
