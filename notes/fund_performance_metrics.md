# Fund Performance Metrics

- Annual Return
    - `(Value[end] / Value[start]) - 1`
- Standard Deviationa of Daily Return
    - `daily_return[i] = (value[i] / value[i-1]) - 1`
    - then, `std(daily_return)`
    - where `i` is the day
- Max Draw Down
    - see video
- Sharpe Ratio
    - Higher sharpe ratio is better
    - For two assets with the same return, the asset with the higher sharpe ratio
      gives more return for the same risk
    - $S = \frac{E[R - R_f]}{SD[R - R_f]}$ (Reward / Risk, Reward = Return) 
    - $R_f$ is some risk free return. So it has no variance. So, sometimes 
      $S = \frac{E[R]}{SD[R]}$ 
    - $\hat{S} = \frac{\bar{dailyReturn}}{std(dailyReturn)} * k$, $k=\sqrt{250}$
    - 250 = number of days in a trading year
