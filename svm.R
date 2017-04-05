library(e1071)
tuned <- tune.svm(formula1, data = train, gamma = 10^(-6:-1), 
  cost = 10^(1:2))  # tune
summary(tuned)  # to select best gamma=0.1 and cost=10

g <- as.numeric(tuned$best.parameters[1])
c <- as.numeric(tuned$best.parameters[2])


svmfit <- svm(formula1, data = train, kernel = "radial", decision.values = TRUE, 
  probability = TRUE, cost = c, gamma = g, scale = FALSE)


print(svmfit)


a <- predict(svmfit, valid, decision.values = TRUE, probability = TRUE)


model_pre <- attr(a, "probabilities")[, 1]