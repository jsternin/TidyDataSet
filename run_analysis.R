#
# Course : Data cleaning
#
# get path (Windows)
#
wd <- normalizePath(getwd(),winslash='\\',mustWork = NA)
localFile <- paste0(wd,"\\getdata-projectfiles-UCI HAR Dataset.zip")
# 1. merge test and training data sets 
# 1.1download file
#
print("1.1 downloading file.....")
fileUrl1 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip?accessType = DOWNLOAD"
download.file(fileUrl1,destfile = localFile,mode = "wb") 
#
# 1.2 unzip file
#
print("1.2 unzipping file.....")
unzip(localFile, exdir = wd, overwrite = TRUE )
#
# 1.3 getpath to test & train data
# 
type = c("train","test")
dirdata = paste0(wd,"\\UCI HAR Dataset")
ptype = c(paste0(dirdata,"\\",type[1]),paste0(dirdata,"\\",type[2]))
#print(ptype)
#
# 1.4 get file names (measurement, dictionaries: activity, features )
#
print("1.4 getting file names......")
nsubject = c(paste0(ptype[1],"\\subject_",type[1],".txt"),paste0(ptype[2],"\\subject_",type[2],".txt"))
nmeasure = c(paste0(ptype[1],"\\X_",type[1],".txt"),paste0(ptype[2],"\\X_",type[2],".txt"))
nactivity = c(paste0(ptype[1],"\\y_",type[1],".txt"),paste0(ptype[2],"\\y_",type[2],".txt"))
#
# 1.5 merge test and train files
#
print("1.5 merging train & test data....")
subject = rbind(read.table(nsubject[1]),read.table(nsubject[2]))
measure = rbind(read.table(nmeasure[1]),read.table(nmeasure[2]))
activity = rbind(read.table(nactivity[1]),read.table(nactivity[2]))
nsubject = max(subject)
nactivity = max(activity)
#print(nrow(subject))
#print(nrow(measure))
#print(nrow(activity))
#
#make sure same number of rows
ndata = nrow(measure)
#
# 2. extract features with man & std
# 2.1create data frame with numbers of measurments mean & std 
#     to do so  - read features.txt and grep all items with -mean() and -std()
#
print("2. extracting mean & std() features......")
pfeatures = paste0(dirdata,"\\features.txt")
features = read.table(pfeatures,stringsAsFactors = FALSE)
# this grep will give 46 features (only with -mean()- and -std()- )
# mean_std_index = sort(c(grep("\\-mean\\(\\)\\-",features[,2]),grep("\\-std\\(\\)\\-",features[,2])))
# this pair of grep(s) give 79 features including meanFreq etc... 
mean_std_index = sort(c(grep("mean",features[,2]),grep("std",features[,2])))
nvars = length(mean_std_index)
features_mean_std = gsub("-","_",sub("\\(\\)","",tolower(features$V2[mean_std_index])))
#
# 3, use activity names 
# 3.1 get activities
#
print("3-4 - creating combined data set.....")
pactivity_labels = paste0(dirdata,"\\activity_labels.txt")
activity_labels = read.table(pactivity_labels,stringsAsFactors = FALSE)
nactivity = nrow(activity_labels)
# 4. appropriately label colums in data set
# 4.1 merge columns of activity, subject and selected columns of measures 
#
dataset = cbind(activity, subject, measure[,mean_std_index])
dataset[,1] = activity_labels$V2[dataset[,1]]
colnames(dataset) = c("activity","subject",features_mean_std)
#
#  4.2 save it as a file
#
write.table(dataset,file = paste0(wd,"\\cleandata4.txt"),row.names = FALSE,quote = FALSE)
#
#  5. create new tidy data set with averages for each feature for each activity & subject
#  must do library(dplyr)
#
dataset = arrange(dataset,activity,subject)

#
# 5.1 create dataframe
#
print("5.1 creating tidy dataset...(tidyset.txt)...........")
tidyset = data.frame(character(0),numeric(0),character(0),numeric(0),stringsAsFactors = FALSE)
colnames(tidyset) = c("activity","subject","feature","avg_measure")
#initial verision with 3 loops - slow
#for(iact in 1:nactivity) 
#    for(isubj in 1:nsubject) 
#        for(ifeat in 1:nvars) {
#            avg = mean(dataset[((dataset$activity == activity_labels$V2[iact]) &
#                                (dataset$subject == isubj)),2+ifeat],na.rm = TRUE)
#            if (!is.na(avg))
#                tidyset[nrow(tidyset)+1,] = c(activity_labels[iact,2],as.numeric(isubj),
#                                              features_mean_std[ifeat],as.numeric(avg))
#        }
# faster version - create narrow / long data set
# has 4 columns - activity, subject, feature (text), mean(measure)
for(ifeat in 1:nvars) {
    nfcol = ifeat + 2 #feature column
    fname = colnames(dataset[nfcol])
    pattern = "mean"
    if (0 == length(grep("mean",fname)))
        pattern = "std"
    
    mk <- dataset %>% 
          select(activity,subject,ifeat+2) %>% 
          mutate(feature = fname) %>% 
          select(activity,subject,feature,measure = contains(pattern)) %>% 
          group_by(activity,subject,feature) %>% 
          summarize(mean(measure))
    for(irow in 1:nrow(mk))
        tidyset[nrow(tidyset)+1,] = mk[irow,]
        
}
tidyset = arrange(tidyset,activity,subject,feature)

write.table(tidyset,file = paste0(wd,"\\tidyset.txt"),row.names = FALSE,sep = ' ',quote = FALSE)
print("5.1 creating tidy dataset codebook (codebook.txt).........")
#
# create code book
#
codebook = c("Tidy set contains averages (mean or std measurment ) ",
             " for each activity (6) , each subject(30) for each mean.std measure:79 : total 81",
             "=================================================================================",
             "1.activity lables(6)",
             "2. subjects(30)",
             "79 variables : features - for each we get average listed below:");
write.table(codebook,paste0(wd,"\\tidyset_codebook.txt"),col.names = FALSE,row.names = FALSE,quote = FALSE)
write.table(features_mean_std,paste0(wd,"\\tidyset_codebook.txt"),
            append= TRUE,col.names = FALSE,row.names = TRUE,quote = FALSE)


