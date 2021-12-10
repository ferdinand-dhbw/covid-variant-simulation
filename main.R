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
readline(prompt = "Press [enter] to continue")
ggsave("./diagrams/pre-ex/arrayOfCurves.png")

ggplot(data=df_preExperiment, aes(x=step., y=n.sick.people, group=round(step./7))) +
  geom_boxplot() +
  xlab("Days") +  #specify x and y labels
  ylab("Number of infected people") +
  ggtitle("Number of infected people over time (7 day bins) [pre-experiment]")
readline(prompt = "Press [enter] to continue")
ggsave("./diagrams/pre-ex/boxplot.png")


duration = aggregate(df_preExperiment$step., by = list(df_preExperiment$run.number.), max)
colnames(duration)[1] = 'run'
colnames(duration)[2] = 'duration'

duration

# 23 times, the virus was wiped out earlier
# According to the previous boxplot these are still outliers
lengths(duration[duration$duration < 720, ])

duration$duration = round(duration$duration /7)

# ggplot(data = duration, aes(x='run', y=x)) +
#   geom_boxplot() +
#   ylab("Duration of epidemic in days") +
#   xlab("runs") +
#   ggtitle("Distribution of duration [pre-experiment]")
# ggsave("./diagrams/pre-ex/duration.png")
# readline(prompt = "Press [enter] to continue")

ggplot(data = duration, aes(x=as.factor(duration)), group=round(step./7)) +
  geom_bar() +
  ylab("number / count") +
  xlab("length of epidemic in weeks") +
  scale_x_discrete(limits = as.factor(1:(round(720/7)+1)), breaks = seq(1, round(720/7), by=2)) +
  ggtitle("Distribution of duration [pre-ex]")
readline(prompt = "Press [enter] to continue")
ggsave("./diagrams/pre-ex/duration.png")


###########################
##### SIMILAR-VARIANT #####
df_similarVariant = read.table("netlogo/similar-variant.csv", skip = 6, sep = ",", head=TRUE)
# Remove the X. in the column names
colnames(df_similarVariant) = gsub("X\\.", "", colnames(df_similarVariant))
summary(df_similarVariant)

# Array of curves
ggplot(data=df_similarVariant, aes(x=step., y=n.people.sick.var0, group=run.number., color=qsec)) + #use myDataFrame for the data, columns for x and y
  geom_line(aes(colour = as.factor(run.number.))) + #we want to use points, colored by runNumber
  theme(legend.position = "none") +
  xlab("Days") +  #specify x and y labels
  ylab("Number of infected people (variant 0)") +
  ggtitle("Number of with variant 0 infected people over time [similar-variant]") + #give the plot a title
  scale_colour_manual("Run",values = rainbow(max(df_similarVariant$run.number., na.rm = FALSE)))
  # scale_color_gradient(low="blue", high="red")
  # scale_fill_distiller(palette = "RdPu")
readline(prompt = "Press [enter] to continue")
ggsave("./diagrams/sim-var/arrayOfCurvesVar0.png")



ggplot(data=df_similarVariant, aes(x=step., y=n.people.sick.var0, group=round(step./7))) +
  geom_boxplot() +
  xlab("Days") +  #specify x and y labels
  ylab("Number of infected people (variant 0)") +
  ggtitle("Number of with variant 0 infected people over time (7 day bins) [similar-variant]")
readline(prompt = "Press [enter] to continue")
ggsave("./diagrams/sim-var/boxplot0.png")


ggplot(data=df_similarVariant, aes(x=step., y=n.people.sick.var1, group=round(step./7))) +
  geom_boxplot() +
  xlab("Days") +  #specify x and y labels
  ylab("Number of infected people (variant 1)") +
  ggtitle("Number of with variant 1 infected people over time (7 day bins) [similar-variant]")
readline(prompt = "Press [enter] to continue")
ggsave("./diagrams/sim-var/boxplot1.png")



duration = aggregate(df_similarVariant$step., by = list(df_similarVariant$run.number.), max)
colnames(duration)[1] = 'run'
colnames(duration)[2] = 'duration'


# 243 times, the viruses were wiped out earlier  TODO similar to pre-ex
# According to the previous boxplot these are still outliers
lengths(duration[duration$duration < 720, ])
# A X and B X


duration$duration = round(duration$duration /7)

duration

ggplot(data = duration, aes(x=as.factor(duration)), group=round(step./7)) +
  geom_bar() +
  ylab("number / count") +
  xlab("length of epidemic in weeks") +
  scale_x_discrete(limits = as.factor(1:round(720/7)), breaks = seq(1, round(720/7), by=2)) +
  ggtitle("Distribution of duration [similar-variant]")
readline(prompt = "Press [enter] to continue")
ggsave("./diagrams/sim-var/duration.png")



## Variant 0 died ##
# get every tuple after variant 0 died
# A X, B X and V
df_simVar_var0died <- sqldf("select [run.number.], [step.], [n.people.exposed.var1], [n.people.sick.var1] from df_similarVariant where [n.people.exposed.var0] = 0 and [n.people.sick.var0] = 0")
head(df_simVar_var0died)

# get the first point in time => time of extinction of each run
df_simVar_var0died = df_simVar_var0died[!duplicated(df_simVar_var0died$run.number.),]
head(df_simVar_var0died)

ggplot(data=df_simVar_var0died, aes(x=step., y = 0)) +
  geom_boxplot() +
  geom_point(alpha=0.25, position = position_jitter(w = 0, h = 0.1)) +
  # geom_jitter() +
  xlab("Day of extinction (variant 0)") +  #specify x and y labels
  ylab("") +
  ggtitle("Extinction of variant 0 over time [similar-variant]")
readline(prompt = "Press [enter] to continue")
ggsave("./diagrams/sim-var/timeOfExtinctionVar0.png")


# was the other variant also on a low?
df_simVar_var0died$n.people.var1 = df_simVar_var0died$n.people.exposed.var1 + df_simVar_var0died$n.people.sick.var1
ggplot(data=df_simVar_var0died, aes(x=0, y = n.people.var1)) +
  geom_boxplot() +
  geom_point(alpha=0.25, position = position_jitter(w = 0.1, h = 0)) +
  # geom_jitter() +
  xlab("") +  #specify x and y labels
  ylab("Number of people with var1 (E+I)") +
  ggtitle("Number of people with var1 during time of extinction of var 1 [similar-variant]")
readline(prompt = "Press [enter] to continue")
ggsave("./diagrams/sim-var/levelVar1AfterExtinctionVar0.png")


# 48 times var 0 died
# 481
lengths(df_simVar_var0died)


## Variant 1 died ##
# get every tuple after variant 1 died
# A X, B X and V
df_simVar_var1died <- sqldf("select [run.number.], [step.], [n.people.exposed.var0], [n.people.sick.var0] from df_similarVariant where [n.people.exposed.var1] = 0 and [n.people.sick.var1] = 0")
head(df_simVar_var1died)

# A X and B X
df_simVar_var1thenvar0died <- sqldf("select [run.number.] from df_simVar_var1died where [n.people.exposed.var0] = 0 and [n.people.sick.var0] = 0")
head(df_simVar_var1thenvar0died)

# A V and B X
df_simVar_var1diedvar0survived <- df_simVar_var1died[!(df_simVar_var1died$run.number. %in% df_simVar_var1thenvar0died$run.number.),]
df_simVar_var1diedvar0survived = df_simVar_var1diedvar0survived[!duplicated(df_simVar_var1diedvar0survived$run.number.),]
lengths(df_simVar_var1diedvar0survived)
head(df_simVar_var1diedvar0survived)

# get the first point in time => time of extinction of each run
df_simVar_var1died = df_simVar_var1died[!duplicated(df_simVar_var1died$run.number.),]
head(df_simVar_var1died)




ggplot(data=df_simVar_var1died, aes(x=step., y = 0)) +
  geom_boxplot() +
  geom_point(alpha=0.25, position = position_jitter(w = 0, h = 0.1)) +
  # geom_jitter() +
  xlab("Day of extinction (variant 1)") +  #specify x and y labels
  ylab("") +
  ggtitle("Extinction of variant 1 over time [similar-variant]")
readline(prompt = "Press [enter] to continue")
ggsave("./diagrams/sim-var/timeOfExtinctionVar1.png")


# 37 times var 1 died
# 446 times
lengths(df_simVar_var1died)

# was the other variant also on a low?
df_simVar_var1died$n.people.var0 = df_simVar_var1died$n.people.exposed.var0 + df_simVar_var1died$n.people.sick.var0
ggplot(data=df_simVar_var1died, aes(x=0, y = n.people.var0)) +
  geom_boxplot() +
  geom_point(alpha=0.25, position = position_jitter(w = 0.1, h = 0)) +
  # geom_jitter() +
  xlab("") +  #specify x and y labels
  ylab("Number of people with var0 (E+I)") +
  ggtitle("Number of people with var0 during time of extinction of var 1 [similar-variant]")
readline(prompt = "Press [enter] to continue")
ggsave("./diagrams/sim-var/levelVar0AfterExtinctionVar1.png")

# TODO run 1000 times (maybe concurrent)
# TODO Tell why
# TODO Disclaimer that this is just script code
