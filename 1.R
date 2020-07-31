### downloading and unziping data

library(reshape2)

path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,file.path(path,"data.zip"),method = "curl")
unzip("data.zip")


### loading files 
### loading feature and activity 

feature <- data.table::fread(file.path(path,"UCI HAR Dataset/features.txt"))
activity <- data.table::fread(file.path(path,"UCI HAR Dataset/activity_labels.txt"),col.names = c("labels", "activity"))

### loading training dataset

train_x <- data.table::fread(file.path(path,"UCI HAR Dataset/train/X_train.txt"),col.names = feature$V2)
train_y <- data.table::fread(file.path(path,"UCI HAR Dataset/train/y_train.txt"),col.names = "activity")
train_subject <- data.table::fread(file.path(path,"UCI HAR Dataset/train/subject_train.txt"),col.names = "subject")

### loading testing dataset

test_x <- data.table::fread(file.path(path,"UCI HAR Dataset/test/X_test.txt"))
test_y <- data.table::fread(file.path(path,"UCI HAR Dataset/test/y_test.txt"),col.names = "activity")
test_subject <- data.table::fread(file.path(path,"UCI HAR Dataset/test/subject_test.txt"),col.names = "subject")

### column wise combining dataset

train <- cbind(train_subject,train_y,train_x)
test <- cbind(test_subject,test_y,test_x)

### row-wise merging the train and test datasets 

dt <- rbind(train, test, use.names =FALSE)

### extracting mean and std from feature.txt

feature <- feature$V2[grep("(mean|std)\\(\\)",feature$V2)]
dt <- subset(dt,select = c("subject","activity",as.character(feature)))

### factoring activity column in dt with labels from activity data

dt$activity <- factor(dt$activity,labels = activity$activity)

### Appropriately labels the data set with descriptive variable names

names(dt)<-gsub("-X", "on X-axis", names(dt))
names(dt)<-gsub("-Y", "on Y-axis", names(dt))
names(dt)<-gsub("-Z", "on Z-axis", names(dt))
names(dt)<-gsub("^t", "time: ", names(dt))
names(dt)<-gsub("Acc", "Accelerometer ", names(dt))
names(dt)<-gsub("Gyro", "Gyroscope ", names(dt))
names(dt)<-gsub("Mag", "Magnitude ", names(dt))
names(dt)<-gsub("Jerk", "Jerk ", names(dt))
names(dt)<-gsub("-mean", "mean", names(dt))
names(dt)<-gsub("-std", "std", names(dt))
names(dt)<-gsub("^f", "frequency: ", names(dt))
names(dt)<-gsub("BodyBody", "Body", names(dt))

### find mean of each activity with respect to each subject
### first using melt from reshape2 library and narrowing dt with subject and activity as id
### then using dcast from reshape2 library and widening dt 

dt <- melt(dt, id.vars = c("subject","activity"))
tidy <- dcast(dt,subject + activity ~ variable, fun.aggregate = mean)
dim(tidy)

### generating a tidy.txt file

write.table( tidy, "tidy.txt",row.names = FALSE)
