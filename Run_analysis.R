#Downloading the file into R
download.file(fileUrl, destfile = "/Dataset.zip", mode = "wb")

#Unzipping file
unzip(zipfile = "/data/Dataset.zip",exdir="/data")

#Looking at the files inside the zip folder
list.files("/data/UCI HAR Dataset")

#Looking at the files inside of train
list.files("/data/UCI HAR Dataset/train")

#Reading into R those files
X_train <- read.table("data/UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("data/UCI HAR Dataset/train/Y_train.txt")
subject_train <- read.table("data/UCI HAR Dataset/train/subject_train.txt")

#Reading files inside of test
X_test <- read.table("data/UCI HAR Dataset/test/X_test.txt")
Y_test <- read.table("data/UCI HAR Dataset/test/Y_test.txt")
subject_test <- read.table("data/UCI HAR Dataset/test/subject_test.txt")

#Reading features file
features <- read.table("/UCI HAR Dataset/features.txt")

#Reading activity labels
activity_labels <- read.table("/UCI HAR Dataset/activity_labels.txt")

#Giving the columns names
colnames(X_train) <- features[,2]
colnames(Y_train) <- "ActivityID"
colnames(subject_train) <- "SubjectID"

colnames(X_test) <- features[,2]
colnames(Y_test) <- "ActivityID"
colnames(subject_test) <- "SubjectID"

colnames(activity_labels) <- c("ActivityID", "SubjectID")

#Merging data sets
#It is bound in that order so it will have first the Activity ID, then the Subject ID and lastly the info
Train <- cbind(Y_train,subject_train,X_train)
Test <- cbind(Y_test, subject_test, X_test)
Dataset <- rbind(Train, Test)

#Defining colNames to be able to use the grepl function 
colNames <- colnames(Dataset)

#Creating a subset with the Activity ID, Subject ID and any column whose name includes either mean or std
Mean.and.SD <- (grepl("ActivityID" , colNames) | grepl("SubjectID" , colNames) | grepl("mean.." , colNames) | grepl("std.." , colNames))

#Defining the new dataset with the columns specified above
mean_and_sd <- Dataset[,Mean.and.SD == TRUE]
mean_and_sd$ActivityID <- as.character(mean_and_sd$ActivityID)
mean_and_sd$Subject <- as.factor(mean_and_sd$Subject)


#Changing the names
names(mean_and_sd)<-gsub("-mean()", "Mean", names(mean_and_sd), ignore.case = TRUE)
names(mean_and_sd)<-gsub("-std()", "STD", names(mean_and_sd), ignore.case = TRUE)

#Creating the final data set
mean_and_sd <- data.table(mean_and_sd)

#Creating the tidy dataset
Tidy <- aggregate(. ~SubjectID + ActivityID, mean_and_sd, mean)
Tidy <- Tidy[order(Tidy$SubjectID,Tidy$ActivityID),]
write.table(Tidy, file = "Tidy.txt", row.names = FALSE)
