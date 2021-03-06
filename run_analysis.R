## packages
library(data.table)
library(dplyr)
library(reshape)
library(stringr)

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
    rm(url)

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
    rm(dfile)

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
  
    ## pre-filter columns for speed (will be used in cbind x test and train)
    f1col <- filter(feat, grepl("mean()|std()", feat[,2]))
    f1col <- f1col[,1]
    rm(feat)

## -----------------------------------------------------------------------------------------------------
## You should create one R script called run_analysis.R that does the following. 
## 1. Merges the training and the test sets to create one data set.
    
    ## row bind labels
    y_merge <- rbind(y_test, y_train)
    rm(y_test)
    rm(y_train)
    
    ## row bind test and train datasets
    x_merge <- rbind(x_test[,f1col], x_train[,f1col])
    rm(x_test)
    rm(x_train)
    rm(f1col)

    ## row bind test and subject datasets
    s_merge <- rbind(s_test, s_train)
    rm(s_test)
    rm(s_train)
    
    ## col bind labels and dataset
    dta     <- cbind(s_merge, y_merge, x_merge)
    rm(s_merge)
    rm(x_merge)
    rm(y_merge)
    
    ## variable names (for step 4)
    names(dta) <- gsub("Acc-"     , "Accelerator:N:" , names(dta))
    names(dta) <- gsub("Gyro-"    , "Gyroscope:N:"   , names(dta))
    names(dta) <- gsub("AccJerk-" , "Accelerator:Y:" , names(dta))
    names(dta) <- gsub("GyroJerk-", "Gyroscope:Y:"   , names(dta))
    names(dta) <- gsub("^t"       , "Time:"          , names(dta))
    names(dta) <- gsub("^f"       , "Frequency:"     , names(dta))
    names(dta) <- gsub("Body"     , "Body:"          , names(dta))
    names(dta) <- gsub("Gravity"  , "Gravity:"       , names(dta))

    ## reshape data / tall&skinny
    dta <- melt(dta, id=c("subjectId","activityId"))
    
    ## data frame
    dta.df <- as.data.frame.matrix(dta)
    rm(dta)

## -----------------------------------------------------------------------------------------------------
## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

  ## mean/standard deviation:
  dta.df1 <- filter(dta.df, grepl("mean()", dta.df$variable))
  dta.df2 <- filter(dta.df, grepl("std()" , dta.df$variable))
  dta.df3 <- rbind(data.table(dta.df1), data.table(dta.df2))
  rm(dta.df1)
  rm(dta.df2)
  dta.df <- as.data.frame.matrix(dta.df3)
  rm(dta.df3)
  
##-----------------------------------------------------------------------------------------------------
## 3. Uses descriptive activity names to name the activities in the data set
  
  ## merge data table with activity labels
  ## join done on activityId field, set in the prep section
  dta.df <- inner_join(dta.df, a_label)
  rm(a_label)
  

##-----------------------------------------------------------------------------------------------------
## 4. Appropriately labels the data set with descriptive variable names. 
  
    ## split variable string
    dta.dft <- as.data.frame(str_match(dta.df$variable, "^(.*):(.*):(.*):(.*):(.*)-(.*)$")[,-1])
    ##Time:Body:Accelerator:FALSE:mean()-X
    
    ## update column names for variables
    colnames(dta.dft)  <- c("domain", "signal", "instrument", "jerk_ind", "estimate_func", "axis")
    
    ## col bind dataset with variables
    dta.final <- cbind(
        dta.df[,1:2], activity = dta.df[,c("activity")], dta.dft, value = dta.df[,c("value")]
        )
    rm(dta.df)
    rm(dta.dft)
  
## -----------------------------------------------------------------------------------------------------
## 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
    
    ## set group
    grouped <- group_by(dta.final
              ,subjectId,activity,domain, signal, instrument, jerk_ind, estimate_func, axis)
    tidy_dta <- summarise(grouped, mean=mean(value))
    rm(grouped)
    
    ## write data set for upload
    write.table(tidy_dta, file = "tidy.txt", row.names = FALSE)