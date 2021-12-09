#Put this at the top of every file, unless you really really want to work with factors
#this will save you a lot of confusion
options(stringsAsFactors = FALSE)
options(device=.Platform$OS.type)

#these are from two separate packages
library(ggplot2)

# needed for reshaping data frames
# library(reshape2)
#
# #used for querying data, performing aggregations, filtering, etc.
# library(sqldf)

##### PRE-EXPERIMENT #####
df_preExperiment = read.table("netlogo/pre-experiment.csv", skip = 6, sep = ",", head=TRUE)
# Remove the X. in the column names
colnames(df_preExperiment) = gsub("X\\.", "", colnames(df_preExperiment))
summary(df_preExperiment)

# Array of curves
ggplot(data=df_preExperiment, aes(x=step., y=n.sick.people, group=run.number.)) + #use myDataFrame for the data, columns for x and y
  geom_line(aes(colour = as.factor(run.number.))) + #we want to use points, colored by runNumber
  xlab("Days") +  #specify x and y labels
  ylab("Number of infected people") +
  ggtitle("Number of infected people over time") + #give the plot a title
  scale_colour_manual("Run",values = rainbow(max(df_preExperiment$run.number., na.rm = FALSE)))
ggsave("./diagrams/pre-ex/arrayOfCurves.png")

ggplot(data=df_preExperiment, aes(x=step., y=n.sick.people, group=round(step./7))) +
  geom_boxplot() +
  xlab("Days") +  #specify x and y labels
  ylab("Number of infected people") +
  ggtitle("Number of infected people over time (7 day bins)")
ggsave("./diagrams/pre-ex/boxplot.png")

duration = aggregate(df_preExperiment$step., by = list(df_preExperiment$run.number.), max)
colnames(duration)[0] = 'run'
colnames(duration)[1] = 'duration'

duration

ggplot(data = duration, aes(x='run', y=x)) +
  geom_boxplot() +
  ylab("Duration of epidemic in days") +
  xlab("runs") +
  ggtitle("Distribution of duration")
ggsave("./diagrams/pre-ex/duration.png")

# 23 times, the virus was wiped out earlier
# According to the previous boxplot these are still outliers
lengths(duration[duration$x < 720, ])

##### SIMILAR-VARIANT #####
