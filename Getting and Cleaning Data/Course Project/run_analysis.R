# Download and unzip the data with:
#download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "Dataset.zip")

# just to make sure that we have the original data, remove the "UCI HAR Dataset" 
# folder and unzip the "Dataset.zip" file. 
dataPath <- file.path("UCI HAR Dataset")
unlink(dataPath, recursive = TRUE)
unzip("Dataset.zip")

### 1 ###
# Merges the training and the test sets to create one data set.
mergedPath <- file.path(dataPath, "merged")
testPath <- file.path(dataPath, "test")
trainPath <- file.path(dataPath, "train")

dir.create(mergedPath)
dir.create(file.path(mergedPath, file.path("Inertial Signals")))

# copy test files into merged folder
fileListTest <- list.files(testPath, recursive = TRUE)
filesFromTest <- file.path(testPath, fileListTest)
filesToMerged <- file.path(mergedPath, gsub("(_test|_train)", "", fileListTest))
file.copy(filesFromTest, filesToMerged)

# append train files to the files in merged folder
fileListTrain <- list.files(trainPath, recursive = TRUE)
filesFromTrain <- file.path(trainPath, fileListTrain)
file.append( filesToMerged, filesFromTrain )


### 2 ###
# Extracts only the measurements on the mean and standard deviation for each 
# measurement. 

# read original labels
features <- read.table(file.path(dataPath, "features.txt"))
names(features)[1] <- "ID"
names(features)[2] <- "originalLabel" 

# read original
dt <- read.table(file.path(mergedPath, "X.txt"))
names(dt) <-  features[,2]

# remove columns which labels don't contain mean or std
idxFeaturesWithMeanOrStd <- grep("mean|std", features[,2], ignore.case = TRUE)
dt <- dt[,idxFeaturesWithMeanOrStd]

# add y.txt file as y activity column
activities<-read.table(file.path(mergedPath,"y.txt"))
dt$activity <- activities

# add subject.txt file as subjectNumber column
subjectsId<-read.table(file.path(mergedPath,"subject.txt"))
dt$subjectId <- subjectsId


### 3 ### 
# Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table(file.path(dataPath,"activity_labels.txt"), col.names = c('ID', 'activityLabel'))$activityLabel
activityLabels <- tolower(sub("_", " ", activityLabels))
dt$activity <- activityLabels[dt$activity[,1]]

### 4 ###
# Appropriately labels the data set with descriptive variable names.
# remove "-"
cleanedNames <- gsub("\\-", "", names(dt))

# remove "body" duplication
cleanedNames <- gsub("bodybody", "Body", cleanedNames, ignore.case = TRUE)

# upper case gravity first character of
cleanedNames <- gsub("gravity", "Gravity", cleanedNames, ignore.case = TRUE)

# some simple replacements
cleanedNames <- gsub("t(Body|Gravity)", "TimeDomainSignal\\1", cleanedNames)
cleanedNames <- gsub("f(Body|Gravity)", "FrequencyDomainSignal\\1", cleanedNames)
cleanedNames <- gsub("mad", "MedianAbsoluteDeviation", cleanedNames, ignore.case = TRUE)
cleanedNames <- gsub("mag", "Magnitude", cleanedNames, ignore.case = TRUE)
cleanedNames <- gsub("Acc", "Acceleration", cleanedNames)
cleanedNames <- gsub("Gyro", "Gyroscope", cleanedNames)
cleanedNames <- gsub("Freq\\(\\)", "Frequency", cleanedNames)
cleanedNames <- gsub("(mean\\(\\)|mean|meanfrequency)", "Mean", cleanedNames, ignore.case = TRUE)
cleanedNames <- gsub("std\\(\\)", "StandardDeviation", cleanedNames, ignore.case = TRUE)

# move "mean" and "StandardDeviation" to the front
cleanedNames <- gsub("(\\w*)(mean|StandardDeviation)(\\w*)", "\\2OfThe\\1\\3", cleanedNames, ignore.case = TRUE)

# X|Y|Z -> InTheAxX|Y|Z
cleanedNames <- gsub("(X|Y|Z)", "InThe\\1Ax", cleanedNames)

# remove syntax error in the angle where it closes a parenthesis leaving a variable outside
cleanedNames <- gsub("angle\\((\\w+)\\)", "angle(\\1", cleanedNames, ignore.case = TRUE)

# angle(a,b) -> angleBetweenAAndB
cleanedNames <- gsub("angle\\((\\w+),(\\w+)\\)", "angleBetweenThe\\1AndThe\\2", cleanedNames, ignore.case = TRUE)

# lowercase first character
cleanedNames <- paste(tolower(substring(cleanedNames, 1,1)), substring(cleanedNames, 2), sep="")

# and finaly, save it back
names(dt) <- cleanedNames


### CODE BOOK ###
# TODO
#descrip <- c("greendog", "bluecat")
#explanation <- decrip
#explanation <- gsub("green", "It is a green ", explanation)
#explanation <- gsub("blue", "It is a blue ", explanation)
#codebook <- paste("* ",descrip,"\n",explanation,"\n")
#write.table(codebook, "codebook.md", quote = FALSE, row.names = FALSE, col.names = FALSE)

### write.table(dt[1:100,],file.path(mergedPath,"ciccio.txt"))
