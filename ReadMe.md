ReadMe
================

# ABOUT

The experiments have been carried out with a group of 30 volunteers
within an age bracket of 19-48 years. Each person performed six
activities (WALKING, WALKING\_UPSTAIRS, WALKING\_DOWNSTAIRS, SITTING,
STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the
waist. Using its embedded accelerometer and gyroscope, we captured
3-axial linear acceleration and 3-axial angular velocity at a constant
rate of 50Hz

[Download
data](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

[Full
description](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

### License:

Use of this dataset in publications must be acknowledged by referencing
the following publication \[1\]

\[1\] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and
Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a
Multiclass Hardware-Friendly Support Vector Machine. International
Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz,
Spain. Dec 2012 This dataset is distributed AS-IS and no responsibility
implied or explicit can be addressed to the authors or their
institutions for its use or misuse. Any commercial use is prohibited.

Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita.
November 2012.

### The dataset includes the following files:

UCI HAR Dataset

  - README.txt

  - features\_info.txt : Shows information about the variables used on
    the feature vector.

  - features.txt : List of all features. A 561-feature vector with time
    and frequency domain variables.

  - activity\_labels.txt : Links the class labels with their activity
    name.

  - train
    
      - Inertial Signals
        
          - body\_acc\_x\_train.txt
        
          - body\_acc\_z\_train.txt
        
          - body\_acc\_y\_train.txt
        
          - body\_gyro\_x\_train.txt
        
          - body\_gyro\_y\_train.txt
        
          - body\_gyro\_z\_train.txt
        
          - Total\_acc\_x\_train.txt
        
          - Total\_acc\_y\_train.txt
        
          - Total\_acc\_z\_train.txt
    
      - x\_train.txt : Training set.
    
      - y\_train.txt : Training labels.
    
      - subject\_train.txt : Training subject Number

  - test
    
      - Inertial Signals
        
          - body\_acc\_x\_test.txt
        
          - body\_acc\_z\_test.txt
        
          - body\_acc\_y\_test.txt
        
          - body\_gyro\_x\_test.txt
        
          - body\_gyro\_y\_test.txt
        
          - body\_gyro\_z\_test.txt
        
          - Total\_acc\_x\_test.txt
        
          - Total\_acc\_y\_test.txt
        
          - Total\_acc\_z\_test.txt
    
      - x\_test.txt : Test set.
    
      - y\_test.txt : Test labels.
    
      - subject\_test.txt : Test Subject Number

### Following are the objectives of the project:

Create one R script called run\_analysis.R that does the following:

1.  Merges the training and the test sets to create one data set.

2.  Extracts only the measurements on the mean and standard deviation
    for each measurement.

3.  Uses descriptive activity names to name the activities in the data
    set

4.  Appropriately labels the data set with descriptive variable names.

5.  From the data set in step 4, creates a second, independent tidy data
    set with the average of each variable for each activity and each
    subject.

## Starting the project

### 1\. Merges the training and the test sets to create one data set.

``` r
library(reshape2)
path <- getwd()
feature <- data.table::fread(file.path(path,"UCI HAR Dataset/features.txt"))
activity <- data.table::fread(file.path(path,"UCI HAR Dataset/activity_labels.txt"),col.names = c("labels", "activity"))


train_x <- data.table::fread(file.path(path,"UCI HAR Dataset/train/X_train.txt"),col.names = feature$V2)
train_y <- data.table::fread(file.path(path,"UCI HAR Dataset/train/y_train.txt"),col.names = "activity")
train_subject <- data.table::fread(file.path(path,"UCI HAR Dataset/train/subject_train.txt"),col.names = "subject")

test_x <- data.table::fread(file.path(path,"UCI HAR Dataset/test/X_test.txt"))
test_y <- data.table::fread(file.path(path,"UCI HAR Dataset/test/y_test.txt"),col.names = "activity")
test_subject <- data.table::fread(file.path(path,"UCI HAR Dataset/test/subject_test.txt"),col.names = "subject")
```

``` r
dim(activity)
```

    ## [1] 6 2

``` r
dim(feature)
```

    ## [1] 561   2

``` r
dim(train_x)
```

    ## [1] 7352  561

``` r
dim(train_y)
```

    ## [1] 7352    1

``` r
dim(train_subject)
```

    ## [1] 7352    1

``` r
dim(test_x)
```

    ## [1] 2947  561

``` r
dim(test_y)
```

    ## [1] 2947    1

``` r
dim(test_subject)
```

    ## [1] 2947    1

the dimenions are:

| file           | dimension  |
| -------------- | ---------- |
| activity       | {6,2}      |
| feature        | {561,2}    |
| train\_x       | {7352,561} |
| train\_y       | {7352,1}   |
| train\_subject | {7352,1}   |
| test\_x        | {2947,561} |
| test\_y        | {2947,1}   |
| test\_subject  | {2947,1}   |

so to combine the data set first we use `cbind` on data with equal rows

``` r
train <- cbind(train_subject,train_y,train_x)
test <- cbind(test_subject,test_y,test_x)
```

now data **train\_x** and **test\_y** have subject number and activity
columns and then combine train and test data using `rbind` and setting
`use.names = FALSE`

``` r
dt <- rbind(train, test, use.names = FALSE)
```

### 2\. Extracts only the measurements on the mean and standard deviation for each measurement.

First we will edit variable **feature** which will contain the mean and
std measurement extracted from the **feature** data using `grep` and
rename the main data

``` r
feature <- feature$V2[grep("(mean|std)\\(\\)",feature$V2)]
dt <- subset(dt,select = c("subject", "activity",as.character(feature)))
```

### 3\. Uses descriptive activity names to name the activities in the data set

`activity` column of **dt** contain number from 1 to 6 to be replaced
with descriptive name extracted from **activity** using `factor` and
setting `labels = activity$activity`

``` r
dt$activity <- factor(dt$activity,labels = activity$activity)
```

### 4\. Appropriately labels the data set with descriptive variable names.

``` r
names(dt)<-gsub("-X", " on X-axis", names(dt))
names(dt)<-gsub("-Y", " on Y-axis", names(dt))
names(dt)<-gsub("-Z", " on Z-axis", names(dt))
names(dt)<-gsub("^t", "time: ", names(dt))
names(dt)<-gsub("Acc", "Accelerometer ", names(dt))
names(dt)<-gsub("Gyro", "Gyroscope ", names(dt))
names(dt)<-gsub("Mag", "Magnitude ", names(dt))
names(dt)<-gsub("Jerk", "Jerk ", names(dt))
names(dt)<-gsub("-mean", "mean", names(dt))
names(dt)<-gsub("-std", "std", names(dt))
names(dt)<-gsub("^f", "frequency: ", names(dt))
names(dt)<-gsub("BodyBody", "Body", names(dt))
```

### 5\. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

using `reshape2::melt` to narrow **dt** and then using `reshape2::dcast`
and finding mean with each activity with respect each subject and
feature and assigning to new dataset **tidy**

``` r
dt <- melt(dt, id.vars = c("subject","activity"))
tidy <- dcast(dt,subject + activity ~ variable, fun.aggregate = mean)
dim(tidy)
```

    ## [1] 180  68

final output

``` r
write.table( tidy, "tidy.txt",row.names = FALSE)
```
