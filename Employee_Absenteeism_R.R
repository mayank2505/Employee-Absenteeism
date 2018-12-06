#Clean the environment
rm(list = ls())

#Set working directory
setwd("C:/Users/Mayank/Desktop/Edwisor/Projects/Project 2")

#Load the librarires
libraries = c("dummies","caret","rpart.plot","plyr","dplyr", "ggplot2","rpart","dplyr","DMwR","randomForest","usdm","corrgram","DataCombine","xlsx")
lapply(X = libraries,require, character.only = TRUE)
rm(libraries)

#Read the csv file
emp_absent = read.xlsx(file = "Absenteeism_at_work.xls", header = T, sheetIndex = 1)

########################################EXPLORE THE DATA########################################
#Check number of rows and columns
dim(emp_absent)

#Observe top 5 rows
head(emp_absent)

#Structure of variables
str(emp_absent)

#Transform data types
emp_absent$ID = as.factor(as.character(emp_absent$ID))

emp_absent$Reason.for.absence[emp_absent$Reason.for.absence %in% 0] = 20
emp_absent$Reason.for.absence = as.factor(as.character(emp_absent$Reason.for.absence))

emp_absent$Month.of.absence[emp_absent$Month.of.absence %in% 0] = NA
emp_absent$Month.of.absence = as.factor(as.character(emp_absent$Month.of.absence))

emp_absent$Day.of.the.week = as.factor(as.character(emp_absent$Day.of.the.week))
emp_absent$Seasons = as.factor(as.character(emp_absent$Seasons))
emp_absent$Disciplinary.failure = as.factor(as.character(emp_absent$Disciplinary.failure))
emp_absent$Education = as.factor(as.character(emp_absent$Education))
emp_absent$Son = as.factor(as.character(emp_absent$Son))
emp_absent$Social.drinker = as.factor(as.character(emp_absent$Social.drinker))
emp_absent$Social.smoker = as.factor(as.character(emp_absent$Social.smoker))
emp_absent$Pet = as.factor(as.character(emp_absent$Pet))

#Structure of variables
str(emp_absent)

#Make a copy of data
df = emp_absent

########################################MISSING VALUE ANALYSIS########################################
#Get number of missing values
sapply(df,function(x){sum(is.na(x))})
missing_values = data.frame(sapply(df,function(x){sum(is.na(x))}))

#Get the rownames as new column
missing_values$Variables = row.names(missing_values)

#Reset the row names 
row.names(missing_values) = NULL

#Rename the column
names(missing_values)[1] = "Miss_perc"

#Calculate missing percentage
missing_values$Miss_perc = ((missing_values$Miss_perc/nrow(emp_absent)) *100)

#Reorder the columns
missing_values = missing_values[,c(2,1)]

#Sort the rows according to decreasing missing percentage
missing_values = missing_values[order(-missing_values$Miss_perc),]

#Create a bar plot to visualie top 5 missing values
ggplot(data = missing_values[1:5,], aes(x=reorder(Variables, -Miss_perc),y = Miss_perc))+
  geom_bar(stat = "identity",fill = "grey")+xlab("Parameter")+
  ggtitle("Missing data percentage") + theme_bw()

#Create missing value and impute using mean, median and knn
#Value = 31
#Mean = 26.67
#Median = 25
#KNN = 31
  #df[["Body.mass.index"]][3]
  #df[["Body.mass.index"]][3] = NA
  #df[["Body.mass.index"]][3] = mean(df$Body.mass.index, na.rm = T)
  #df[["Body.mass.index"]][3] = median(df$Body.mass.index, na.rm = T)
df = knnImputation(data = df, k = 5)

#Check if any missing values
sum(is.na(df))

# Saving output result into excel file
write.xlsx(missing_values, "Missing_perc_R.xlsx", row.names = F)

########################################EXPLORE DISTRIBUTION USING GRAPHS########################################
#Get numerical data
numeric_index = sapply(df, is.numeric)
numeric_data = df[,numeric_index]

#Distribution of factor data using bar plot
bar1 = ggplot(data = df, aes(x = ID)) + geom_bar() + ggtitle("Count of ID") + theme_bw()
bar2 = ggplot(data = df, aes(x = Reason.for.absence)) + geom_bar() + 
  ggtitle("Count of Reason for absence") + theme_bw()
bar3 = ggplot(data = df, aes(x = Month.of.absence)) + geom_bar() + ggtitle("Count of Month") + theme_bw()
bar4 = ggplot(data = df, aes(x = Disciplinary.failure)) + geom_bar() + 
  ggtitle("Count of Disciplinary failure") + theme_bw()
bar5 = ggplot(data = df, aes(x = Education)) + geom_bar() + ggtitle("Count of Education") + theme_bw()
bar6 = ggplot(data = df, aes(x = Son)) + geom_bar() + ggtitle("Count of Son") + theme_bw()
bar7 = ggplot(data = df, aes(x = Social.smoker)) + geom_bar() + 
  ggtitle("Count of Social smoker") + theme_bw()

gridExtra::grid.arrange(bar1,bar2,bar3,bar4,ncol=2)
gridExtra::grid.arrange(bar5,bar6,bar7,ncol=2)

#Check the distribution of numerical data using histogram
hist1 = ggplot(data = numeric_data, aes(x =Transportation.expense)) + 
  ggtitle("Transportation.expense") + geom_histogram(bins = 25)
hist2 = ggplot(data = numeric_data, aes(x =Height)) + 
  ggtitle("Distribution of Height") + geom_histogram(bins = 25)
hist3 = ggplot(data = numeric_data, aes(x =Body.mass.index)) + 
  ggtitle("Distribution of Body.mass.index") + geom_histogram(bins = 25)
hist4 = ggplot(data = numeric_data, aes(x =Absenteeism.time.in.hours)) + 
  ggtitle("Distribution of Absenteeism.time.in.hours") + geom_histogram(bins = 25)

gridExtra::grid.arrange(hist1,hist2,hist3,hist4,ncol=2)

########################################OUTLIER ANALYSIS########################################
#Get the data with only numeric columns
numeric_index = sapply(df, is.numeric)
numeric_data = df[,numeric_index]

#Get the data with only factor columns
factor_data = df[,!numeric_index]

#Check for outliers using boxplots
for(i in 1:ncol(numeric_data)) {
  assign(paste0("box",i), ggplot(data = df, aes_string(y = numeric_data[,i])) +
           stat_boxplot(geom = "errorbar", width = 0.5) +
           geom_boxplot(outlier.colour = "red", fill = "grey", outlier.size = 1) +
           labs(y = colnames(numeric_data[i])) +
           ggtitle(paste("Boxplot: ",colnames(numeric_data[i]))))
}

#Arrange the plots in grids
gridExtra::grid.arrange(box1,box2,box3,box4,ncol=2)
gridExtra::grid.arrange(box5,box6,box7,box8,ncol=2)
gridExtra::grid.arrange(box9,box10,ncol=2)

#Get the names of numeric columns
numeric_columns = colnames(numeric_data)

#Replace all outlier data with NA
for(i in numeric_columns){
  val = df[,i][df[,i] %in% boxplot.stats(df[,i])$out]
  print(paste(i,length(val)))
  df[,i][df[,i] %in% val] = NA
}

#Check number of missing values
sapply(df,function(x){sum(is.na(x))})

#Get number of missing values after replacing outliers as NA
missing_values_out = data.frame(sapply(df,function(x){sum(is.na(x))}))
missing_values_out$Columns = row.names(missing_values_out)
row.names(missing_values_out) = NULL
names(missing_values_out)[1] = "Miss_perc"
missing_values_out$Miss_perc = ((missing_values_out$Miss_perc/nrow(emp_absent)) *100)
missing_values_out = missing_values_out[,c(2,1)]
missing_values_out = missing_values_out[order(-missing_values_out$Miss_perc),]
missing_values_out

#Compute the NA values using KNN imputation
df = knnImputation(df, k = 5)

#Check if any missing values
sum(is.na(df))

########################################FEATURE SELECTION########################################
#Check for multicollinearity using VIF
vifcor(numeric_data)

#Check for multicollinearity using corelation graph
corrgram(numeric_data, order = F, upper.panel=panel.pie, 
         text.panel=panel.txt, main = "Correlation Plot")

#Variable Reduction
df = subset.data.frame(df, select = -c(Body.mass.index))

#Make a copy of Clean Data
clean_data = df
write.xlsx(clean_data, "clean_data.xlsx", row.names = F)

########################################FEATURE SCALING########################################
#Normality check
hist(df$Absenteeism.time.in.hours)

#Remove dependent variable
numeric_index = sapply(df,is.numeric)
numeric_data = df[,numeric_index]
numeric_columns = names(numeric_data)
numeric_columns = numeric_columns[-9]

#Normalization of continuous variables
for(i in numeric_columns){
  print(i)
  df[,i] = (df[,i] - min(df[,i]))/
    (max(df[,i]) - min(df[,i]))
}

#Get the names of factor variables
factor_columns = names(factor_data)

#Create dummy variables of factor variables
df = dummy.data.frame(df, factor_columns)

rmExcept(keepers = c("df","emp_absent"))

########################################DECISION TREE########################################
#RMSE: 2.276
#MAE: 1.694
#R squared: 0.44

#Splitting data into train and test data
set.seed(1)
train_index = sample(1:nrow(df), 0.8*nrow(df))        
train = df[train_index,]
test = df[-train_index,]

#Build decsion tree using rpart
dt_model = rpart(Absenteeism.time.in.hours ~ ., data = train, method = "anova")

#Plot the tree
rpart.plot(dt_model)

#Perdict for test cases
dt_predictions = predict(dt_model, test[,-115])

#Create data frame for actual and predicted values
df_pred = data.frame("actual"=test[,115], "dt_pred"=dt_predictions)
head(df_pred)

#Calcuate MAE, RMSE, R-sqaured for testing data 
print(postResample(pred = dt_predictions, obs = test[,115]))

#Plot a graph for actual vs predicted values
plot(test$Absenteeism.time.in.hours,type="l",lty=2,col="green")
lines(dt_predictions,col="blue")

########################################RANDOM FOREST########################################
#RMSE: 2.194
#MAE: 1.61
#R squared: 0.479

##Train the model using training data
rf_model = randomForest(Absenteeism.time.in.hours~., data = train, ntree = 500)

#Predict the test cases
rf_predictions = predict(rf_model, test[,-115])

#Create dataframe for actual and predicted values
df_pred = cbind(df_pred,rf_predictions)
head(df_pred)

#Calcuate MAE, RMSE, R-sqaured for testing data 
print(postResample(pred = rf_predictions, obs = test[,115]))

#Plot a graph for actual vs predicted values
plot(test$Absenteeism.time.in.hours,type="l",lty=2,col="green")
lines(rf_predictions,col="blue")

########################################LINEAR REGRESSION########################################
#RMSE: 2.559
#MAE: 1.86
#R squared: 0.358

##Train the model using training data
lr_model = lm(formula = Absenteeism.time.in.hours~., data = train)

#Get the summary of the model
summary(lr_model)

#Predict the test cases
lr_predictions = predict(lr_model, test[,-115])

#Create dataframe for actual and predicted values
df_pred = cbind(df_pred,lr_predictions)
head(df_pred)

#Calcuate MAE, RMSE, R-sqaured for testing data 
print(postResample(pred = lr_predictions, obs = test[,115]))

#Plot a graph for actual vs predicted values
plot(test$Absenteeism.time.in.hours,type="l",lty=2,col="green")
lines(lr_predictions,col="blue")

########################################DIMENSION REDUCTION USING PCA########################################
#Principal component analysis
prin_comp = prcomp(train)

#Compute standard deviation of each principal component
pr_stdev = prin_comp$sdev

#Compute variance
pr_var = pr_stdev^2

#Proportion of variance explained
prop_var = pr_var/sum(pr_var)

#Cumulative scree plot
plot(cumsum(prop_var), xlab = "Principal Component",
     ylab = "Cumulative Proportion of Variance Explained",
     type = "b")

#Add a training set with principal components
train.data = data.frame(Absenteeism.time.in.hours = train$Absenteeism.time.in.hours, prin_comp$x)

# From the above plot selecting 45 components since it explains almost 95+ % data variance
train.data =train.data[,1:45]

#Transform test data into PCA
test.data = predict(prin_comp, newdata = test)
test.data = as.data.frame(test.data)

#Select the first 45 components
test.data=test.data[,1:45]

########################################DECISION TREE########################################
#RMSE: 0.442
#MAE: 0.301
#R squared: 0.978

#Build decsion tree using rpart
dt_model = rpart(Absenteeism.time.in.hours ~., data = train.data, method = "anova")

#Predict the test cases
dt_predictions = predict(dt_model,test.data)

#Create data frame for actual and predicted values
df_pred = data.frame("actual"=test[,115], "dt_pred"=dt_predictions)
head(df_pred)

#Calcuate MAE, RMSE, R-sqaured for testing data 
print(postResample(pred = dt_predictions, obs = test$Absenteeism.time.in.hours))

#Plot a graph for actual vs predicted values
plot(test$Absenteeism.time.in.hours,type="l",lty=2,col="green")
lines(dt_predictions,col="blue")

########################################RANDOM FOREST########################################
#RMSE: 0.480
#MAE: 0.264
#R squared: 0.978

#Train the model using training data
rf_model = randomForest(Absenteeism.time.in.hours~., data = train.data, ntrees = 500)

#Predict the test cases
rf_predictions = predict(rf_model,test.data)

#Create dataframe for actual and predicted values
df_pred = cbind(df_pred,rf_predictions)
head(df_pred)

#Calcuate MAE, RMSE, R-sqaured for testing data 
print(postResample(pred = rf_predictions, obs = test$Absenteeism.time.in.hours))

#Plot a graph for actual vs predicted values
plot(test$Absenteeism.time.in.hours,type="l",lty=2,col="green")
lines(rf_predictions,col="blue")

########################################LINEAR REGRESSION########################################
#RMSE: 0.003
#MAE: 0.002
#R squared: 0.999

#Train the model using training data
lr_model = lm(Absenteeism.time.in.hours ~ ., data = train.data)

#Get the summary of the model
summary(lr_model)

#Predict the test cases
lr_predictions = predict(lr_model,test.data)

#Create dataframe for actual and predicted values
df_pred = cbind(df_pred,lr_predictions)
head(df_pred)

#Calcuate MAE, RMSE, R-sqaured for testing data 
print(postResample(pred = lr_predictions, obs =test$Absenteeism.time.in.hours))

#Plot a graph for actual vs predicted values
plot(test$Absenteeism.time.in.hours,type="l",lty=2,col="green")
lines(lr_predictions,col="blue")
