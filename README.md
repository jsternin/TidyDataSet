Tidy Data Set
-----------------
Getting and Cleaning Data � Course Project 

This is the description of how run_analysis.R works

1. Part1 � get and merge test & train data.
---------------------------------------------------
1.1 Download file - as it was in lectures.
use mode = "wb"
Download in working directory (wd) 
Local file name: getdata-projectfiles-UCI HAR Dataset.zip

1.2 Unzip zipped file - unzipped direcotry name: UCI HAR Dataset
It resides under wd (working direcotry)

1.3 Get path to train and test data 
It has directory names: train and test

1.4. Get path to train/test files: 
activity  - nactivity[2]
subjects  - nsubject[2]
measurments  -  nmeasure[2]


1.5 merge test and train data:
use rbind and merge read.table from files in 1.4
for each of 3 groups: result are 3 data sets:
subject,activity,measures � all of them have 10299 rows (train + test)

2.Extract features (measurement names ) with �mean� and �std�
---------------------------------------------------------------
get path to feature dictionary - feature.txt
read.table - features.
Run grep - get indices of features data frame that match - 
"-mean()-" and "-std()-". This is average and stadard deviation of 
original measurments as it was requested. 
I did not include meanFreq - because it is not original mesurments -
this is some kind of spectral processing. - total it is 79 features.
mean_std_index - array of indices of mean() and std() in features;
features_mean_std - array of strings that contain mean() and std()
convert features_mean_std to lowercase and remove () 


3-4 replace activity codes with activity names; save wide file
------------------------------------------------------------------

3. Get activity_labels file ; read it into activity_labels data set

4.1 using cbind - merge activity, subject and subset of measures in one data set.
replace colum 1 - activity codes with activity labels
set column names for the data set "activity" "subject" subset of mean and std features
(features_mean_std)

4.2 save this as dataset in a file using write table

5.Create tidy data set (long/narrow) and code book from wide data set
---------------------------------------------------------------------

5.1 build tidy set and save it to disk
- create blank data frame -
strings - for activity, numbers for subject, strings for features, and number
for mean (average) of measurments with mean/std
name of data frame is - tidyset.
-for each: activity; subject; feature - calculate mean of slice of dataset
if this slice is not na - add row with :
activity_label, subject,feature name and average as row to data frame - tidy set
save table in working directory under name - tidyset.txt

5.2 Create codebook with the description of each variable
- create code book describing variables in tidy set

To open tidyset.txt use space as field separator 
(in OpenOffice use : insert> sheet>from file mark space as separator)




