library(rpart)
dc_tree <- rpart(formula1, 
                 train, method = "class",control=rpart.control(cp=0))

#剪枝
dc_tree_pru<-prune(dc_tree,cp= dc_tree$cptable[which.min(dc_tree$cptable[,"xerror"]),"CP"])


model_pre <- predict(dc_tree_pru, valid )