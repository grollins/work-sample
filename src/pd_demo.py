import numpy as np
import pandas as pd
import seaborn as sns

df = (pd.read_csv('cars.csv')
        .sort_values(by='hp', ascending = False)
        .assign(id=lambda x: range(len(x)),
                fct_cyl=lambda x: pd.Categorical(x['cyl'])))
print(df.head())

(df.groupby('cyl')
   .size)

(df.groupby('cyl')
   .hp.agg([np.mean, np.median]))

(df.groupby('cyl')
   .qsec.agg([np.mean, np.median]))

plot1 = sns.regplot(data=df, x='hp', y='qsec')
plot1.get_figure().savefig('pd_demo_fig1.png')

plot2 = sns.pairplot(df, hue='fct_cyl', vars=['hp', 'qsec'])
plot2.fig.savefig('pd_demo_fig2.png')
