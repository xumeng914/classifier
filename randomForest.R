library("randomForest")

Forest<- randomForest(leb~., data =train, ntree=100 ,importance=TRUE)
model_pre <- predict(Forest,newdata=new,type = "prob") 

cs<-model_pre[,2]