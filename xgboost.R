#devtools::install_github('dmlc/xgboost',subdir='R-package')  
#install.packages("xgboost")

#案例的主要内容是：服用安慰剂对病情康复的情况，其他指标还有年龄、性别。

#（1）数据导入与包的加载
#操作时对包的要求，在加载的时候也会一些报错。后面换了版本就OK了。

library("xgboost")
library("Matrix")
library("data.table")
library("grid")
library("vcd")
require(xgboost)  
require(Matrix)  
require(data.table)  
if (!require('vcd')) install.packages('vcd')   

data(Arthritis)  
df <- data.table(Arthritis, keep.rownames = F)  

#接下来对数据进行一些处理。
head(df[,AgeDiscret := as.factor(round(Age/10,0))])               #:= 新增加一列  
head(df[,AgeCat:= as.factor(ifelse(Age > 30, "Old", "Young"))])   #ifelse  
df[,ID:=NULL]    

#（2）生成特定的数据格式
sparse_matrix <- sparse.model.matrix(Improved~.-1, data = df)  #变成稀疏数据，然后0变成.，便于占用内存最小  
#生成了one-hot encode数据，独热编码。Improved是Y变量，-1是将treament变量（名义变量）拆分。

#（3）设置因变量（多分类）
output_vector = df[,Improved] == "Marked"   

#（4）xgboost建模
bst <- xgboost(data = sparse_matrix, label = output_vector, max.depth = 4,  
               eta = 1, nthread = 2, nround = 10,objective = "binary:logistic")
#其中nround是迭代次数，可以用此来调节过拟合问题；
#nthread代表运行线程，如果不指定，则表示线程全开；
#objective代表所使用的方法：binary:logistic是以非线性的方式，分支。
#reg:linear（默认）、reg:logistic、count:poisson（泊松分布）、multi:softmax

#（5）特征重要性排名
importance <- xgb.importance(sparse_matrix@Dimnames[[2]], model = bst)  
head(importance)  
#会出来比较多的指标，Gain是增益，树分支的主要参考因素；
#cover是特征观察的相对数值；
#Frequence是gain的一种简单版，他是在所有生成树中，特征的数量（慎用！）

#（6）特征筛选与检验
#知道特征的重要性是一回事儿，现在想知道年龄对最后的治疗的影响。所以需要可以用一些方式来反映出来。以下是官方自带的。
importanceRaw <- xgb.importance(sparse_matrix@Dimnames[[2]], model = bst, data = sparse_matrix, label = output_vector)  

# Cleaning for better display  
importanceClean <- importanceRaw[,`:=`(Cover=NULL, Frequence=NULL)]  #同时去掉cover frequence  
head(importanceClean) 
#比第一种方式多了split列,代表此时特征分割的界线，比如特征2: Age  61.5，代表分割在61.5岁以下治疗了就痊愈了。
#同时，多了RealCover 和RealCover %列，前者代表在这个特征的个数，后者代表个数的比例。

#绘制重要性图谱：
xgb.plot.importance(importance_matrix = importanceRaw)  
#需要加载install.packages("Ckmeans.1d.dp")，其中输出的是两个特征，这个特征数量是可以自定义的，可以定义为10族。

#变量之间影响力的检验，官方用的卡方检验：
c2 <- chisq.test(df$Age, output_vector)  
#检验年龄对最终结果的影响。

#（7）疑问？
#Random Forest™ - 1000 trees  
bst <- xgboost(data = train$data, label = train$label,
               max.depth = 4, num_parallel_tree = 1000,
               subsample = 0.5, colsample_bytree =0.5,
               nround = 1, objective = "binary:logistic")  
#num_parallel_tree这个是什么？  

#Boosting - 3 rounds  
bst <- xgboost(data = train$data, label = train$label,
               max.depth = 4, nround = 3, objective = "binary:logistic")  
#？？？代表boosting  

#话说最后有一个疑问，这几个代码是可以区分XGBoost、随机森林以及boosting吗？

#（8）一些进阶功能的尝试
#作为比赛型算法，真的超级好。下面列举一些我比较看中的功能：

#1、交叉验证每一折显示预测情况
#挑选比较优质的验证集。
# do cross validation with prediction values for each fold  
res <- xgb.cv(params = param, data = dtrain, nrounds = nround, nfold = 5, prediction = TRUE)  
res$evaluation_log  
length(res$pred)  
#交叉验证时可以返回模型在每一折作为预测集时的预测结果，方便构建ensemble模型。

#2、循环迭代
#允许用户先迭代1000次，查看此时模型的预测效果，然后继续迭代1000次，最后模型等价于一次性迭代2000次。
# do predict with output_margin=TRUE, will always give you margin values before logistic transformation  
ptrain <- predict(bst, dtrain, outputmargin=TRUE)  
ptest  <- predict(bst, dtest, outputmargin=TRUE)  

#3、每棵树将样本分类到哪片叶子上
# training the model for two rounds  
bst = xgb.train(params = param, data = dtrain, nrounds = nround, nthread = 2)  

#4、线性模型替代树模型
#可以选择使用线性模型替代树模型，从而得到带L1+L2惩罚的线性回归或者logistic回归。

# you can also set lambda_bias which is L2 regularizer on the bias term  
param <- list(objective = "binary:logistic", booster = "gblinear",  
              nthread = 2, alpha = 0.0001, lambda = 1)  




