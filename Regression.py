
import  os
import numpy as np
from numpy import loadtxt, dtype,float32
import matplotlib.pyplot as plt
import pandas as pd


file_name= 'C:\\Users\\mo.villagran\\Desktop\\Python Demo\\AllData.csv'

file = open(file_name)
header = file.readline()
fields = header.split()
fields_and_types = [('AffiliateName',object),('CustomerDOB',object),('CustomerGender',object),('CustomeTobaccoUse',object),('CustomerZipcode',object),('Date',object),('Hour',int),('MilitaryHour',int),('Minute',int),('AM_PM',object),('Year',object),('LeadID',object),('LeadTier',object),('SalePrice',float32),('Vertical',object)]
data_dtype = dtype(fields_and_types)

table= np.array(loadtxt(file_name, dtype=data_dtype,delimiter=',', skiprows=1))

#print(table['SalePrice'])

#http://pythoncookbook.blogspot.com/2013/01/load-tab-delimited-text-file-as-numpy.html

#AffiliateName	CustomerDOB	CustomerGender	CustomeTobaccoUse	CustomerZipcode	Date	Hour	MilitaryHour	Minute	AM_PM	Year	LeadID	LeadTier	SalePrice	Vertical
#Affiliate_1	1/3/1900	Male	No	12345	12/3/2017	5	17	28	PM	2017	CAKEBF4B	2	2.1	Medicare



df = pd.DataFrame(table)
M_df = df.loc[df['Vertical'] == 'Medicare']
#print(M_df)


#print(df)
CountLead = M_df.groupby(['CustomerZipcode'])['LeadID'].count().astype(int)
SumSale = M_df.groupby(['CustomerZipcode'])['SalePrice'].sum().astype(float)
#print(SumSale)
#print(CountLead)

CountLead = CountLead.to_frame().reset_index()
SumSale = SumSale.to_frame().reset_index()

#https://stackoverflow.com/questions/37968785/merging-two-dataframes
#print(type(CountLead))
#print(type(SumSale))
clustertable = np.array(pd.merge(CountLead, SumSale, on ='CustomerZipcode'))

#print(clustertable)

"""
# Create K-mean clustering analysis

np.random.seed(200)
k = 2
# centroids[i] = [x, y]
centroids = {
    i+1: [np.random.randint(0, 200), np.random.randint(0, 200)]
    for i in range(k)
}
    
fig = plt.figure(figsize=(5, 5))
plt.scatter(clustertable[:,2], clustertable[:,1], color='k')
colmap = {1: 'r', 2: 'g', 3: 'b'}
for i in centroids.keys():
    plt.scatter(*centroids[i], color=colmap[i])
plt.xlim(0, 350)
plt.ylim(0, 350)

plt.title("First Scatter Plot")
plt.xlabel("Sale Sum")
plt.ylabel("Lead Count")

#plt.show()
"""

#run linear regression using library sklearn

#http://bigdata-madesimple.com/how-to-run-linear-regression-in-python-scikit-learn/

import seaborn as sns
from sklearn import datasets, linear_model
from sklearn.metrics import mean_squared_error, r2_score
Lead= clustertable[:,1] #Lead Count 
Sale= clustertable[:,2] #Sale Sum

Lead=Lead.reshape(len(Lead),1)
Sale=Sale.reshape(len(Sale),1)

# Create linear regression object
regr = linear_model.LinearRegression()
 
#predicting sale sum using lead count
regr.fit(Lead, Sale)
m = regr.coef_[0]
b = regr.intercept_

f ='Formula: Sale = {0} * Lead + {1}'.format(m, b)
r =regr.score(Lead,Sale)
r2 = "R-Squared: " + str(r)

plt.scatter(Lead,Sale)
# Plot outputs
plt.plot(Sale, regr.predict(Sale),color='red',linewidth=3)

plt.xlim(0, 80)
plt.ylim(0, 350)
plt.title("Linear Regression: Predicting Total Sale by Lead Counts in Medicare")
plt.text(25,150,f)
plt.text(25,125,r2)
plt.xlabel("Lead Count")
plt.ylabel("Sale Sum")


plt.show()


