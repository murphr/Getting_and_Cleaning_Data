# This is the run_analysis.R script for the Getting and Cleaning Data course Project.
# This script will:
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement.
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive activity names.
# 5. Create a second, independent tidy data set with the average of each variable for each activity and each subject.

# Check for and load any dependencies....
if (!require("data.table")) {install.packages("data.table")
                             require("data.table")}
if (!require("reshape2")) {install.packages("reshape2")
                           require("reshape2")}
# Download the train and test datasets....
dataZipFile <- "UCI_HAR_Data.zip"
dataDir <- "UCI HAR Dataset"
if (!file.exists(dataZipFile)){
        fileURL <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileURL, dataZipFile)
        # Read all required .txt files and label the datasets...
        if (!file.exists(dataDir)){ unzip(dataZipFile)}
}
# Load datasets into objects....
testSubject <- read.table("./UCI HAR Dataset/test/subject_test.txt")
testX <- read.table("./UCI HAR Dataset/test/X_test.txt")
testY <- read.table("./UCI HAR Dataset/test/Y_test.txt")
trainSubject <- read.table("./UCI HAR Dataset/train/subject_train.txt")
trainX <- read.table("./UCI HAR Dataset/train/X_train.txt")
trainY <- read.table("./UCI HAR Dataset/train/Y_train.txt")
features <- read.table("./UCI HAR Dataset/features.txt")
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")

# Merge test and train subject data.....
subject <- rbind(testSubject, trainSubject)
colnames(subject) <- "subject"

# Merge test and train labels with text labels....
label <- rbind(testY, trainY)
label <- merge(label, activityLabels, by=1)[,2]

# Merge the test and train data with the textual headings....
data <- rbind(testX, trainX)
colnames(data) <- features[, 2]

# Merge all previous datasets into one object....
data <- cbind(subject, label, data)
#write.table(data, file="data_set.txt")

# Create a subset dataset with just the mean and std variables....
search <- grep("-mean|-std", colnames(data))
dataMeanStd <- data[,c(1,2,search)]

# Compute the means, grouped by subject and by label....
meltedData = melt(dataMeanStd, id.var = c("subject", "label"))
means = dcast(meltedData , subject + label ~ variable, mean)

# Finally, save the output (means) data into a txt file...
write.table(means, file="tidy_data.txt")
