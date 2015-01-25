## packages
library(data.table)
library(dplyr)



## -----------------------------------------------------------------------------------------------------
## Here are the data for the project:
## step 0: getting file from url to local drive
    
    ## set local file name
    dfile <- "gcd_dataset.zip"

    ## set file url
    url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    
    ## delete local file if already exists
    if (file.exists(dfile))
    {
        ##file.remove(dfile)
    }
    
    ## download data
    ##download.file(url,destfile = dfile)

    ## unzip data (list files)
    ##unzip(dfile, list = TRUE)
    
    ## load data tables
    feat    <- read.table(unzip(dfile, "UCI HAR Dataset/features.txt"))
    y_test  <- read.table(unzip(dfile, "UCI HAR Dataset/test/y_test.txt"))
    x_test  <- read.table(unzip(dfile, "UCI HAR Dataset/test/X_test.txt"))
    s_test  <- read.table(unzip(dfile, "UCI HAR Dataset/test/subject_test.txt"))
    y_train <- read.table(unzip(dfile, "UCI HAR Dataset/train/y_train.txt"))
    x_train <- read.table(unzip(dfile, "UCI HAR Dataset/train/X_train.txt"))
    s_train <- read.table(unzip(dfile, "UCI HAR Dataset/train/subject_train.txt"))

    ## X: process column names
    ## features 'feat' table lists columns in test (561)
    colnames(x_test)  <- t(feat[2])
    colnames(x_train) <- t(feat[2])


## -----------------------------------------------------------------------------------------------------
## You should create one R script called run_analysis.R that does the following. 
## 1. Merges the training and the test sets to create one data set.
  
    ## row bind test and train datasets (10299 records)
    x_merge <- rbind(x_test, x_train)
    
    ## remove dupe columns
    x_merge <- x_merge[, !duplicated(colnames(x_merge))]


## -----------------------------------------------------------------------------------------------------
## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

    ## mean:
    ## get columns
    x_mean <- grep("mean()", names(x_merge), value = FALSE, fixed = TRUE)
      x_mean <- append(x_mean, grep("gravityMean", names(x_merge), value = FALSE, fixed = TRUE))
      x_mean <- append(x_mean, grep("tBodyAccMean", names(x_merge), value = FALSE, fixed = TRUE))
      x_mean <- append(x_mean, grep("tBodyAccJerkMean", names(x_merge), value = FALSE, fixed = TRUE))
      x_mean <- append(x_mean, grep("tBodyGyroMean", names(x_merge), value = FALSE, fixed = TRUE))
      x_mean <- append(x_mean, grep("tBodyGyroJerkMean", names(x_merge), value = FALSE, fixed = TRUE))
    ## extract meas
    meas_xMean <- x_merge[x_mean]

    ## std:
    ## get columns
    x_std <- grep("std()", names(x_merge), value = FALSE, fixed = TRUE)
    ## extract meas
    meas_xSTD <- x_merge[x_std]


## -----------------------------------------------------------------------------------------------------
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names. 
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.