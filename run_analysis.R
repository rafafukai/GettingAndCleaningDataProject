## packages
library(data.table)
library(dplyr)
library(reshape)


## -----------------------------------------------------------------------------------------------------
## Here are the data for the project:
## prep: getting file from url to local drive
    
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
    a_label <- read.table(unzip(dfile, "UCI HAR Dataset/activity_labels.txt"))
    y_test  <- read.table(unzip(dfile, "UCI HAR Dataset/test/y_test.txt"))
    x_test  <- read.table(unzip(dfile, "UCI HAR Dataset/test/X_test.txt"))
    s_test  <- read.table(unzip(dfile, "UCI HAR Dataset/test/subject_test.txt"))
    y_train <- read.table(unzip(dfile, "UCI HAR Dataset/train/y_train.txt"))
    x_train <- read.table(unzip(dfile, "UCI HAR Dataset/train/X_train.txt"))
    s_train <- read.table(unzip(dfile, "UCI HAR Dataset/train/subject_train.txt"))
    

    ## process column names
    ## features 'feat' table lists columns in test (561)
    colnames(x_test)  <- t(feat[2])
    colnames(x_train) <- t(feat[2])
    colnames(y_test)  <- c("activityId")
    colnames(y_train) <- c("activityId")
    ## activity labels
    colnames(a_label) <- c("activityId","activity")
    ## subject
    colnames(s_test)  <- c("subjectId")
    colnames(s_train) <- c("subjectId")

## -----------------------------------------------------------------------------------------------------
## You should create one R script called run_analysis.R that does the following. 
## 1. Merges the training and the test sets to create one data set.
    
    ## row bind labels
    y_merge <- rbind(y_test, y_train)
    
    ## row bind test and train datasets
    x_merge <- rbind(x_test, x_train)

    ## row bind test and subject datasets
    s_merge <- rbind(s_test, s_train)
    
    ## col bind labels and dataset
    dta     <- cbind(s_merge, y_merge, x_merge)
    
    ## remove dupe columns
    ##dta     <- dta[, !duplicated(colnames(dta))]
    
    ## factor subject id
    ##dta$subjectId <- as.factor(dta$subjectId)

    ## reshape data
    dta <- melt(dta, id=c("subjectId","activityId"))

