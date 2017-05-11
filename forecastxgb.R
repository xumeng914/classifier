devtools::install_github("ellisp/forecastxgb-r-package/pkg")  
#install.packages("forecastxgb")

library(forecastxgb)  
model <- xgbar(gas) 
summary(model)  

fc <- forecast(model, h = 12)  
plot(fc)  

#如果有额外的自变量需要加入：
library(fpp)  
consumption <- usconsumption[ ,1]  
income <- matrix(usconsumption[ ,2], dimnames = list(NULL, "Income"))  
consumption_model <- xgbar(y = consumption, xreg = income)  
#Stopping.Best iteration:20  

#预测以及画图：
income_future <- matrix(forecast(xgbar(usconsumption[,2]), h = 10)$mean,   
                        dimnames = list(NULL, "Income"))  
#Stopping. Best iteration: 1  
plot(forecast(consumption_model, xreg = income_future))  


