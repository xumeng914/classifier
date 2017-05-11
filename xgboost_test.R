require(xgboost)
data(agaricus.train, package='xgboost')
data(agaricus.test, package='xgboost')
train <- agaricus.train
test <- agaricus.test

class(train$data)
bst <- xgboost(data = train$data, label = train$label, max.depth = 2, eta = 1,
               nround = 2, objective = "binary:logistic")

pred <- predict(bst, test$data)

cv.res <- xgb.cv(data = train$data, label = train$label, max.depth = 2, 
                 eta = 1, nround = 2, objective = "binary:logistic", 
                 nfold = 5)
cv.res
