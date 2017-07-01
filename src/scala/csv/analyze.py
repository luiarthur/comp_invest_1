import csv
import numpy as np
import matplotlib.pyplot as plt
import scipy.stats
from dlmPython import dlm_uni, lego, param, dlm_mod

np.random.seed(1)

### Read data ###
y = []
with open('MCD.csv') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',')
    for row in spamreader:
        try:
            y += [float(row[4])]
        except:
            pass

N = len(y)
n_train = N - 225
n_ahead = N - n_train + 1000
idx = np.linspace(1, N, N)

# plot data (just for fun)
plt.plot(idx, y, 'm*')
plt.show()


### Create DLM Object ###
dlm = dlm_mod.poly(1, V=10) #+ dlm_mod.arma(ar=[.95,.04], V=0)
p = #sum(dlm.__dimension__)

# Initialize DLM
init = param.uni_df(
        m=np.asmatrix(np.zeros((p,1))), 
        C=np.eye(p))

### Feed data to Kalman-filter ###
filt = dlm.filter(y[:n_train], init)

### One-step-ahead predictions at each time step ###
one_step_f = map(lambda x: x.f, filt)
one_step_Q = map(lambda x: x.Q, filt)
one_step_n = map(lambda x: x.n, filt)
# credible intervals for predictions
ci_one_step = dlm.get_ci(one_step_f, one_step_Q, one_step_n)

### Forecasts ###
fc = dlm.forecast(filt, n_ahead, linear_decay=False)
future_idx = np.linspace(n_train+1, n_train+n_ahead, n_ahead)
fc_f = fc['f']
fc_Q = fc['Q']
fc_n = [fc['n']] * n_ahead
ci = dlm.get_ci(fc_f, fc_Q, fc_n)

### Plot Results ###
# Notice that since the prior mean is far away from the first observation, the
# one-step ahead predictions are bad at the beginning.

def plot_result():
    plt.fill_between(idx[:n_train], ci_one_step['lower'], ci_one_step['upper'], color='lightblue')
    plt.fill_between(future_idx, ci['lower'], ci['upper'], color='pink')
    #
    plt.scatter(idx, y, color='grey', label='Data', s=1)
    plt.plot(future_idx, fc_f, 'r--', label='Forecast')
    plt.plot(idx[:n_train], one_step_f, 'b--', label='One-step-Ahead')
    #
    plt.xlabel('time')
    legend = plt.legend(loc='lower right')
    plt.ylim([30, 170])
    plt.show()
    #plt.savefig('img/quad.png')

plot_result()
