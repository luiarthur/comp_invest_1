library(dlm)
library(rcommon)

daily_return <- function(x) {
  diff(x) / x[-length(x)] - 1
}

### Read Data and preprocess
files <- Filter(function(x) grepl("csv", x), list.files())
tickers_tmp <- lapply(files, read.csv)
names(tickers_tmp) <- gsub(".csv", "", files)
dates <- Reduce(function(a,b) intersect(a,b), lapply(tickers_tmp, function(x) x$Date))
# NEXT: Just keep the data that take place on those dates

tickers <- lapply(tickers_tmp, function(ticker) {
  idx <- sapply(dates, function(d) which(ticker$Date == d))
  ticker[idx, ]
})

### Assert that all dates match
stopifnot(all(apply(sapply(tickers, function(t) t$Date), 1, function(row) length(unique(row)) == 1 )))


### Create matrix of closing values
stocks <- sapply(tickers, function(t) t$Close)
N <- nrow(stocks)

### Visualize
plot.ts(stocks)
my.pairs(stocks, customDiag=function(i,X) {
  plot(X[,i],type='l', bty='l', fg='grey', main=colnames(X)[i])
  idx <- 1:nrow(X)
  mod <- lm(X[,i] ~ idx)
  abline(mod$coef[1], mod$coef[2])
})

### Stats
var(stocks)
mean(stocks)

### Daily Returns
d_ret <- apply(stocks, 2, daily_return)
my.pairs(d_ret)

K <- ncol(d_ret) # num stocks
par(mfrow=c(K/2,2), oma=oma.ts(), mar=mar.ts())
for(j in 1:K) {
  plot(d_ret[,"SPY"], d_ret[,j], ylab=colnames(d_ret)[j],
       xaxt=ifelse(j<K-1,'n','s'), pch=19, col=rgb(0,0,1,.5))
  abline(mod <- lm(d_ret[,j] ~ d_ret[,'SPY']) )
  legend('topleft', legend=c(paste('alpha =', round(mod$coef[1],2)), 
                             paste('beta =',  round(mod$coef[2],2))), bg='white')
}
par(mfrow=c(1,1), oma=oma.default(), mar=mar.default())

### DLM Analysis ###

#### Spectral Density Estimation (periodogram)
#spec.pgram(stocks)
#
#n_train <- N - 225
##n_train <- N - 300
#add <- 1000
#mod <- dlmModPoly(2, dV=1, dW=c(1,1)*1E-6, m0=c(0,0), C0=diag(2)*100) +
#       dlmModARMA(ar=c(.95,.04), C0=diag(2)*100)
#       #dlmModARMA(ar=c(.9468, .0514))
#
#j <- 4
##y <- log(1:N)^2
##filt  <- dlmFilter(y[1:n_train], mod)
#filt  <- dlmFilter(stocks[1:n_train, j], mod)
#fc <- dlmForecast(filt, nAhead=N-n_train + add)
#sm <- dlmSmooth(filt)
#
#filt$f
#filtQ <- sapply(1:n_train, function(i) (filt$U.R[[i]] %*% diag(filt$D.R[i,]^2) %*% t(filt$U.R[[i]]))[1])
#
#year_begin <- 1
#for (i in 2:N) {
#  if (substr(as.character(tickers$CL$Date[i]),3,5) == 'Jan' && substr(as.character(tickers$CL$Date[i-1]),3,5) != 'Jan') {
#    year_begin <- append(year_begin, i)
#  }
#}
#
#### Plot
#plot(stocks[,j], pch=20, col='grey', cex=.5, xlim=c(0,N+add), ylim=range(stocks[,j] + 30, stocks[,j] - 30),
#     ylab=colnames(stocks)[j], xaxt='n', fg='grey')
##plot(y, pch=20, col='grey', cex=.5, xlim=c(0,N+add), ylim=range(stocks[,j] + 30, stocks[,j] - 30))
#lab <- 2010:2016
#axis(1, at=year_begin, lab=lab, las=2)
#abline(v=year_begin, lty=2, col='grey85')
#lines(filt$f, col='red', lwd=2)
#color.btwn(1:n_train, filt$f - 2*sqrt(filtQ),  filt$f + 2*sqrt(filtQ), from=1, to=n_train, col.area=rgb(1,0,0,.3))
##lines((n_train+1):N, fc$f, col='red', lwd=1, lty=2)
#lines((n_train+1):(N+add), fc$f, col='red', lwd=1, lty=2)
#Q <- unlist(fc$Q)
##color.btwn((n_train+1):N, fc$f-sqrt(Q)*qt(.975, n_train-1), fc$f+sqrt(Q)*qt(.975, n_train-1), from=n_train+1, N,
##           col.area=rgb(1,0,0,.3))
#color.btwn((n_train+1):(N+add), fc$f-sqrt(Q)*qnorm(.975), fc$f+sqrt(Q)*qnorm(.975), from=n_train+1, N+add,
#           col.area=rgb(1,0,0,.3))
#
