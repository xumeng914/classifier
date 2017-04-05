formula1 <- leb ~ .


model_step_glm <- glm(formula1, data = train, family = "binomial")


summary(model_step_glm)


model_pre <- predict(model_step_glm, newdata = valid, type = "response")

