library(dlm)
library(rcommon)


wf <- read.csv("WFC.csv")
cl <- read.csv("CL.csv")
co <- read.csv("COST.csv")
or <- read.csv("ORCL.csv")
mc <- read.csv("MCD.csv")

dim(cl)
dim(co)
dim(wf)
dim(or)
dim(mc)

missing_date <- setdiff(as.character(cl$Date), as.character(co$Date))

plot(co$Close, type='l', main='Costco')
idx <- which(co$Date == "31-Mar-10")
abline(v=idx)
co_new <- data.frame(append(co$Date, missing_date, idx),
                     append(co$Open, co$Open[idx], idx),
                     append(co$High, co$High[idx], idx),
                     append(co$Low, co$Low[idx], idx),
                     append(co$Close, co$Close[idx], idx),
                     append(co$Volume, co$Volume[idx], idx))
colnames(co_new) <- colnames(co)

stocks <- cbind(cl$Close, wf$Close, or$Close, mc$Close, co_new$Close)
colnames(stocks) <- c("CL", "WFC", "ORCL", "MCD", "COST")
plot.ts(stocks)
var(stocks)
mean(stocks)
N <- nrow(stocks)


### Spectral Density Estimation (periodogram)
spec.pgram(stocks)

n_train <- N - 225
#n_train <- N - 300
add <- 1000
mod <- dlmModPoly(2, dV=10, dW=c(1,1)*1E-6, m0=c(40,0), C0=var(stocks[,1])*diag(2)) +
       dlmModARMA(ar=c(.95,.04))
       #dlmModARMA(ar=c(.9468, .0514))

j <- 4
#y <- log(1:N)^2
#filt  <- dlmFilter(y[1:n_train], mod)
filt  <- dlmFilter(stocks[1:n_train, j], mod)
fc <- dlmForecast(filt, nAhead=N-n_train + add)
sm <- dlmSmooth(filt)

filt$f
filtQ <- sapply(1:n_train, function(i) (filt$U.R[[i]] %*% diag(filt$D.R[i,]^2) %*% t(filt$U.R[[i]]))[1])

year_begin <- 1
for (i in 2:N) {
  if (substr(as.character(cl$Date[i]),3,5) == 'Jan' && substr(as.character(cl$Date[i-1]),3,5) != 'Jan') {
    year_begin <- append(year_begin, i)
  }
}

### Plot
plot(stocks[,j], pch=20, col='grey', cex=.5, xlim=c(0,N+add), ylim=range(stocks[,j] + 30, stocks[,j] - 30),
     ylab=colnames(stocks)[j], xaxt='n', fg='grey')
#plot(y, pch=20, col='grey', cex=.5, xlim=c(0,N+add), ylim=range(stocks[,j] + 30, stocks[,j] - 30))
lab <- 2010:2016
axis(1, at=year_begin, lab=lab, las=2)
abline(v=year_begin, lty=2, col='grey85')
lines(filt$f, col='red', lwd=2)
color.btwn(1:n_train, filt$f - 2*sqrt(filtQ),  filt$f + 2*sqrt(filtQ), from=1, to=n_train, col.area=rgb(1,0,0,.3))
#lines((n_train+1):N, fc$f, col='red', lwd=1, lty=2)
lines((n_train+1):(N+add), fc$f, col='red', lwd=1, lty=2)
Q <- unlist(fc$Q)
#color.btwn((n_train+1):N, fc$f-sqrt(Q)*qt(.975, n_train-1), fc$f+sqrt(Q)*qt(.975, n_train-1), from=n_train+1, N,
#           col.area=rgb(1,0,0,.3))
color.btwn((n_train+1):(N+add), fc$f-sqrt(Q)*qt(.975, n_train-1), fc$f+sqrt(Q)*qt(.975, n_train-1), from=n_train+1, N+add,
           col.area=rgb(1,0,0,.3))

