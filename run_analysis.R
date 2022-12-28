filename<- "Project3.zip"
#Checking if archive already exists
if(!file.exists(filename)){
  fileurl<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileurl, filename, method="curl")
}
#Checking if folder exists
if(!file.exists("UCI HAR dataset")){
  unzip(filename)
}
features <- read.table("UCI HAR dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("UCI HAR dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR dataset/train/y_train.txt", col.names = "code")

#1. Merges the training and the test sets to create one data set.
X<- rbind(x_train, x_test)
Y<- rbind(y_train, y_test)
subject<- rbind(subject_train, subject_test)
merged_data<- cbind(subject, Y, X)

#2. Extracts only the measurements on the mean and standard devition for each measurement.
tidydata<- merged_data %>%
  select(subject, code, contains("mean"), contains("std"))

#3. Uses descriptive activity names to name the activies in the data set.
tidydata$code<- activities[tidydata$code, 2]

#4. Appropriately abels the data set with descriptive variable names.
names(tidydata)[2] = "activity"
names(tidydata)<-gsub("Acc", "Accelerometer", names(tidydata))
names(tidydata)<- gsub("Gyro", "Gyroscope", names(tidydata))
names(tidydata)<- gsub("BodyBody", "Body", names(tidydata))
names(tidydata)<- gsub("Mag", "Magnitude", names(tidydata))
names(tidydata)<- gsub("^t", "Time", names(tidydata))
names(tidydata)<- gsub("^f", "Frequency", names(tidydata))
names(tidydata)<- gsub("tBody", "TimeBody", names(tidydata))
names(tidydata)<- gsub("-mean()","Mean", names(tidydata), ignore.case=TRUE)
names(tidydata)<- gsub("-std()", "STD", names(tidydata), ignore.case=TRUE)
names(tidydata)<- gsub("-freq()", "Frequency", names(tidydata), ignore.case=TRUE)
names(tidydata)<- gsub("angle", "Angle", names(tidydata))
names(tidydata)<- gsub("gravity", "Gravity", names(tidydata))

#5. From the data set in #4 creates a second, independent tidy data set with the average of each variable for each activity and each subject.
finaldata<- tidydata %>%
  group_by(subject, activity) %>%
  summarize_all(funs(mean))
write.table(finaldata, "finaldata.txt", row.name= FALSE)
