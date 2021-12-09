#Put this at the top of every file, unless you really really want to work with factors
#this will save you a lot of confusion
options(stringsAsFactors = FALSE)
options(device=.Platform$OS.type)
options(gsubfn.engine = "R")

#these are from two separate packages
library(ggplot2)

# needed for reshaping data frames
# library(reshape2)

#used for querying data, performing aggregations, filtering, etc.
library(sqldf)

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
  ggtitle("Number of infected people over time [pre-experiment]") + #give the plot a title
  scale_colour_manual("Run",values = rainbow(max(df_preExperiment$run.number., na.rm = FALSE)))
ggsave("./diagrams/pre-ex/arrayOfCurves.png")
readline(prompt = "Press [enter] to continue")

ggplot(data=df_preExperiment, aes(x=step., y=n.sick.people, group=round(step./7))) +
  geom_boxplot() +
  xlab("Days") +  #specify x and y labels
  ylab("Number of infected people") +
  ggtitle("Number of infected people over time (7 day bins) [pre-experiment]")
ggsave("./diagrams/pre-ex/boxplot.png")
readline(prompt = "Press [enter] to continue")

duration = aggregate(df_preExperiment$step., by = list(df_preExperiment$run.number.), max)
colnames(duration)[0] = 'run'
colnames(duration)[1] = 'duration'

duration

ggplot(data = duration, aes(x='run', y=x)) +
  geom_boxplot() +
  ylab("Duration of epidemic in days") +
  xlab("runs") +
  ggtitle("Distribution of duration [pre-experiment]")
ggsave("./diagrams/pre-ex/duration.png")
readline(prompt = "Press [enter] to continue")

# 23 times, the virus was wiped out earlier
# According to the previous boxplot these are still outliers
lengths(duration[duration$x < 720, ])

###########################
##### SIMILAR-VARIANT #####
df_similarVariant = read.table("netlogo/similar-variant.csv", skip = 6, sep = ",", head=TRUE)
# Remove the X. in the column names
colnames(df_similarVariant) = gsub("X\\.", "", colnames(df_similarVariant))
summary(df_similarVariant)

# Array of curves
ggplot(data=df_similarVariant, aes(x=step., y=n.people.sick.var0, group=run.number., color=qsec)) + #use myDataFrame for the data, columns for x and y
  geom_line(aes(colour = as.factor(run.number.))) + #we want to use points, colored by runNumber
  xlab("Days") +  #specify x and y labels
  ylab("Number of infected people (variant 0)") +
  ggtitle("Number of with variant 0 infected people over time [similar-variant]") + #give the plot a title
  scale_colour_manual("Run",values = rainbow(max(df_similarVariant$run.number., na.rm = FALSE)))
  # scale_color_gradient(low="blue", high="red")
  # scale_fill_distiller(palette = "RdPu")
ggsave("./diagrams/sim-var/arrayOfCurvesVar0.png")
readline(prompt = "Press [enter] to continue")


ggplot(data=df_similarVariant, aes(x=step., y=n.people.sick.var0, group=round(step./7))) +
  geom_boxplot() +
  xlab("Days") +  #specify x and y labels
  ylab("Number of infected people (variant 0)") +
  ggtitle("Number of with variant 0 infected people over time (7 day bins) [similar-variant]")
ggsave("./diagrams/sim-var/boxplot0.png")
readline(prompt = "Press [enter] to continue")

ggplot(data=df_similarVariant, aes(x=step., y=n.people.sick.var1, group=round(step./7))) +
  geom_boxplot() +
  xlab("Days") +  #specify x and y labels
  ylab("Number of infected people (variant 1)") +
  ggtitle("Number of with variant 1 infected people over time (7 day bins) [similar-variant]")
ggsave("./diagrams/sim-var/boxplot1.png")
readline(prompt = "Press [enter] to continue")


duration = aggregate(df_similarVariant$step., by = list(df_similarVariant$run.number.), max)
colnames(duration)[1] = 'run'
colnames(duration)[2] = 'duration'


# 23 times, the virus was wiped out earlier
# According to the previous boxplot these are still outliers
lengths(duration[duration$x < 720, ])


duration$duration = round(duration$duration /7)

duration

ggplot(data = duration, aes(x=as.factor(duration)), group=round(step./7)) +
  geom_bar() +
  ylab("number / count") +
  xlab("length of epidemic in weeks") +
  scale_x_discrete(limits = as.factor(1:round(720/7)), breaks = seq(1, round(720/7), by=2)) +
  ggtitle("Distribution of duration [similar-variant]")
ggsave("./diagrams/sim-var/duration.png")
readline(prompt = "Press [enter] to continue")

# TODO Comparison with duration of pre-ex => shorter duration in general?

# Variant 0 died
df_simVar_var0died <- sqldf("select [step.] from df_similarVariant where [n.people.exposed.var0] = 0 and [n.people.sick.var0] = 0")
df_simVar_var0died

ggplot(data=df_simVar_var0died, aes(x=step., y = 0)) +
  geom_boxplot() +
  geom_point(alpha=0.25, position = position_jitter(w = 0, h = 0.1)) +
  # geom_jitter() +
  xlab("Day of extinction (variant 0)") +  #specify x and y labels
  ylab("") +
  ggtitle("Extinction of variant 0 over time (7 day bins) [similar-variant]")
ggsave("./diagrams/sim-var/timeOfExtinctionVar0.png")
readline(prompt = "Press [enter] to continue")

# 48 times var 0 died
lengths(df_simVar_var0died)


# Variant 1 died
df_simVar_var1died <- sqldf("select [step.] from df_similarVariant where [n.people.exposed.var1] = 0 and [n.people.sick.var1] = 0")
ggplot(data=df_simVar_var1died, aes(x=step., y = 0)) +
  geom_boxplot() +
  geom_point(alpha=0.25, position = position_jitter(w = 0, h = 0.1)) +
  # geom_jitter() +
  xlab("Day of extinction (variant 0)") +  #specify x and y labels
  ylab("") +
  ggtitle("Extinction of variant 0 over time (7 day bins) [similar-variant]")
ggsave("./diagrams/sim-var/timeOfExtinctionVar1.png")

# 37 times var 1 died
lengths(df_simVar_var1died)

# TODO run 1000 times (maybe concurrent)
