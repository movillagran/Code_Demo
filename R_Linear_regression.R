

#Author: Mo Villagran
#Date: 10/20/2017
#Purpose: To quantify factors that affect dental billing rates in the linear regression
#models so that payers can make better contractual decisions with providers

library(RODBC)
dbhandle <- odbcDriverConnect('driver={SQL Server};server=USHARTVM05;database=Proband_Mo;trusted_connection=true')
x <- sqlQuery(dbhandle, 'select * from [Proband_Mo].[dbo].[R_testing_CompanyYear_State_dentist_D1110_test]')
#x<-read.csv("U:/Health/ProBand/Marketing/Dental Research 2017/Data/NY_testing_R_Year.csv",header = TRUE);

#filtering criteria in the sql table for CDT D1110
#LOB_COM = 1
#NumOfDentists is not null
#[Paid_Allowed_Ratio] < 0.99
#[Allowed_Billed_Ratio] < 0.99 --anything that is = or > than 1 makes no sense and there are many 0.99 values



y<-data.frame(x);
y<-na.omit(y); #get rid of all NA 

#change FIPS from num to factor data type
y$FIPS<-factor(y$FIPS)
str(y);

summary(y);

#Visualize variables

library(purrr)
library(tidyr)
library(ggplot2)



pdf("C:/Users/mo.villigran/Documents/GitHub/Regressions/Results/State/variable_histograms_1.pdf")

#make Rstudio print the graphs on here because I have too many at the same time
par("mar")
par(mar=c(1,1,1,1))

par(mfrow=c(3,2), mar=c(4,4,4,3))


hist(y$Allowed_Billed_Ratio, main="Allowed_Billed_Ratio", xlab="Ratio")
hist(y$Paid_Allowed_Ratio, main="Paid_Allowed_Ratio", xlab="Ratio")
hist(y$Paid, main="Paid", xlab="Paid")
hist(log(y$Paid), main="Log-transformed Paid", xlab="Log-transformed Paid")
hist(y$OON_Stateag, main = 'OON', xlab = "Stateag")
hist(y$GroupSizeCategory_100Above_Stateag, main = "Group 100 +", xlab = "Stateag")

dev.off()

pdf("C:/Users/mo.villigran/Documents/GitHub/Regressions/Results/State/variable_histograms_2.pdf")
par(mfrow=c(3,2), mar=c(4,4,4,3))

hist(y$NumOfDentists, main="Num of Dentists", xlab="Num")
hist(log(y$NumOfDentists), main="Log-transformed Num of Dentists", xlab="Log-transformed Num")
hist(y$DentistRate, main="Dentist Rate", xlab = "Rate")
hist(log(y$DentistRate),main=" Log-transformed Dentist Rate", xlab = "Log-transformed Rate")
hist(y$DentistRatio, main = "Dentist Ratio", xlab = "Ratio")
hist(log(y$DentistRatio), main="Log-transformed Dentist Ratio", xlab="Log-transformed Ratio")

dev.off()



#regression model one

#lm to predict continuous dependent variable

#Using Stepwise regression to determine what variables to keep
linear<-step(lm(formula = y$Allowed_Billed_Ratio~ log(y$Paid) + y$Paid_Allowed_Ratio + y$OON_Stateag + y$Product_CMM + y$Product_EPO + y$Product_PPO + y$GroupSizeCategory_100Above_Stateag + log(y$NumOfDentists) + log(y$DentistRate) + log(y$DentistRatio), data=y));

#stepwise gave me this :
#
#
#Step:  AIC=-414363.9
#y$Allowed_Billed_Ratio ~ log(y$Paid) + y$Paid_Allowed_Ratio + 
#  y$OON_Stateag + y$Product_CMM + y$Product_PPO + y$GroupSizeCategory_100Above_Stateag + 
#  log(y$NumOfDentists) + log(y$DentistRate) + log(y$DentistRatio)

#Df Sum of Sq    RSS     AIC
#<none>                                           1455.5 -414364
#- y$Product_CMM                      1      0.97 1456.4 -414301
#- y$Product_PPO                      1      1.00 1456.5 -414298
#- y$GroupSizeCategory_100Above_Stateag  1      2.51 1458.0 -414196
#- log(y$DentistRatio)                1      5.40 1460.9 -414002
#- log(y$DentistRate)                 1      5.43 1460.9 -414000
#- log(y$NumOfDentists)               1      5.53 1461.0 -413993
#- y$OON_Stateag                         1     45.57 1501.0 -411334
#- y$Paid_Allowed_Ratio               1    723.32 2178.8 -374686
#- log(y$Paid)                        1    872.03 2327.5 -368193

#Compare models here:

fit1<-lm(formula = y$Allowed_Billed_Ratio ~ log(y$Paid) + y$OON_Stateag + y$Product_CMM +
         y$Product_PPO + y$GroupSizeCategory_100Above_Stateag + log(y$NumOfDentists) + log(y$DentistRate) + log(y$DentistRatio)+ y$Paid_Allowed_Ratio, data=y)

#CMM:  Comprehensive Major Medical / Traditional 


png(filename="C:/Users/mo.villigran/Documents/GitHub/Regressions/Results/State/fit1.png")

layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page 
plot(fit1)

dev.off()


fit1_result<-summary(fit1);
fit1_result;


fit2<-lm(formula = y$Allowed_Billed_Ratio ~ log(y$Paid) + y$OON_Stateag + y$Product_CMM +
           y$Product_PPO + y$GroupSizeCategory_100Above_Stateag + log(y$NumOfDentists) + log(y$DentistRate) + log(y$DentistRatio), data=y)


png(filename="C:/Users/mo.villigran/Documents/GitHub/Regressions/Results/State/fit2.png")

layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page 
plot(fit2)

dev.off()

fit2_result<-summary(fit2);
fit2_result;


fit3<-lm(formula = y$Allowed_Billed_Ratio ~ log(y$Paid) + y$OON_Stateag + y$Product_CMM +
           y$Product_PPO + y$GroupSizeCategory_100Above_Stateag + log(y$NumOfDentists) + log(y$DentistRate), data=y)


png(filename="C:/Users/mo.villigran/Documents/GitHub/Regressions/Results/State/fit3.png")

layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page 
plot(fit3)

dev.off()


fit3_result<-summary(fit3);
fit3_result;


fit4<-lm(formula = y$Allowed_Billed_Ratio ~ log(y$Paid) + y$OON_Stateag + y$Product_CMM +
           y$Product_PPO + y$GroupSizeCategory_100Above_Stateag + log(y$NumOfDentists), data=y)

png(filename="C:/Users/mo.villigran/Documents/GitHub/Regressions/Results/State/fit4.png")

layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page 
plot(fit4)

dev.off()

fit4_result<-summary(fit4);
fit4_result;



fit5<-lm(formula = y$Allowed_Billed_Ratio ~ log(y$Paid) + y$OON_Stateag + y$Product_CMM +
           y$Product_PPO + y$GroupSizeCategory_100Above_Stateag, data=y)

png(filename="C:/Users/mo.villigran/Documents/GitHub/Regressions/Results/State/fit5.png")

layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page 
plot(fit5)

dev.off()

fit5_result<-summary(fit5);
fit5_result;

#resulting final model here >> which fit? yet to be determined but I think it is fit5

png(filename="C:/Users/mo.villigran/Documents/GitHub/Regressions/Results/State/final.png")

layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page 
plot(final)

dev.off()

final_result<-summary(final);
final_result;


coef <- as.data.frame(coef(summary(fit1)))
coef

r2<-summary(final)$r.squared
r2

library('sjPlot')

#Produce linear regression summary table here to compare different models
sjt.lm(fit1,fit2,fit3,fit4, fit5
       ,labelPredictors=c("Paid", "OON", "Product-Traditional", "PPO", "GroupSize>100", "# ofDentist", "Dentist Rate", "Dentist Ratio", "Paid/Allowed Ratio"))


pdf("C:/Users/mo.villigran/Documents/GitHub/Regressions/Results/State/Predicted_Allowed_Billed_Ratio.pdf")

#make Rstudio print the graphs on here because I have too many at the same time
par("mar")
par(mar=c(1,1,1,1))

par(mfrow=c(3,2), mar=c(4,4,4,3))

#Visualize fitted distributions

hist(y$Allowed_Billed_Ratio, main="Allowed_Billed_Ratio", xlab="Ratio", xlim =c(0,1.0), ylim = c(0,40000))
hist(predict(fit1), main ="Model 1", xlab="Ratio", xlim =c(0,1.0), ylim = c(0,40000))
hist(predict(fit2), main ="Model 2", xlab="Ratio", xlim =c(0,1.0), ylim = c(0,40000))
hist(predict(fit3), main ="Model 3", xlab="Ratio", xlim =c(0,1.0), ylim = c(0,40000))
hist(predict(fit4), main ="Model 4", xlab="Ratio", xlim =c(0,1.0), ylim = c(0,40000))
hist(predict(fit5), main ="Model 5", xlab="Ratio", xlim =c(0,1.0), ylim = c(0,40000))

dev.off()


#############################   random testing   ##############################

y$Allowed_Billed_Ratio[1]

fitted(fit5)[1]

predict(fit5)[1]


diff<-(fitted(fi5)-y$Allowed_Billed_Ratio)

summary(diff)

hist(diff)

library(broom);
tidy(tb);

 plot_coeffs <- function(mlr_model) {
      coeffs <- coefficients(mlr_model)
      mp <- barplot(coeffs, col="#3F97D0", xaxt='n', main="Regression Coefficients Chart")
      lablist <- names(coeffs)
      text(mp, par("usr")[3], labels = lablist, srt = 45, adj = c(1.1,1.1), xpd = TRUE, cex=0.6)
    }


plot_coeffs(final);

confint(final);

confint.default(final);

exp(coef(final));

exp(cbind(OR= coef(final), confint(final)));
