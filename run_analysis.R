## packages
library(data.table)
library(dplyr)



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
    dta     <- dta[, !duplicated(colnames(dta))]
    
    ## factor subject id
    dta$subjectId <- as.factor(dta$subjectId)

## -----------------------------------------------------------------------------------------------------
## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

    ## mean:
    ## get columns
    dtaMean <- grep("mean()", names(dta), value = FALSE, fixed = TRUE)
      dtaMean <- append(dtaMean, grep("gravityMean"      , names(dta), value = FALSE, fixed = TRUE))
      dtaMean <- append(dtaMean, grep("tBodyAccMean"     , names(dta), value = FALSE, fixed = TRUE))
      dtaMean <- append(dtaMean, grep("tBodyAccJerkMean" , names(dta), value = FALSE, fixed = TRUE))
      dtaMean <- append(dtaMean, grep("tBodyGyroMean"    , names(dta), value = FALSE, fixed = TRUE))
      dtaMean <- append(dtaMean, grep("tBodyGyroJerkMean", names(dta), value = FALSE, fixed = TRUE))
    ## extract meas
    meas_xMean <- dta[dtaMean]
    
    ## std:
    ## get columns
    dtaSTD <- grep("std()", names(dta), value = FALSE, fixed = TRUE)
    ## extract meas
    meas_xSTD <- dta[dtaSTD]


## -----------------------------------------------------------------------------------------------------
## 3. Uses descriptive activity names to name the activities in the data set

    ## merge data table with activity labels
    ## join done on activityId field, set in the prep section
    dta <- inner_join(dta, a_label)
    
    ## factor activity
    dta$activity <- as.factor(dta$activity)
    
    
## -----------------------------------------------------------------------------------------------------
## 4. Appropriately labels the data set with descriptive variable names. 

    names(dta) <- gsub("Acc" , "Accelerator", names(dta))
    names(dta) <- gsub("Mag" , "Magnitude", names(dta))
    names(dta) <- gsub("Gyro", "Gyroscope", names(dta))
    names(dta) <- gsub("^t"  , "time", names(dta))
    names(dta) <- gsub("^f"  , "frequency", names(dta))

## -----------------------------------------------------------------------------------------------------
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
    
    dta.dt <- data.table(dta)
    tidy_dta <- dta.dt[, lapply(.SD, mean), by = c("subjectId,activity")]
    write.table(tidy_dta, file = "Tidy.txt", row.names = FALSE)
