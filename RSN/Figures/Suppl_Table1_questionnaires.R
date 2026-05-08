# Clear plots
if(!is.null(dev.list())) dev.off()
# Clear console
cat("\014") 
# Clean workspace
rm(list=ls())

# install and load packages

install.packages("readxl")
install.packages("foreign")
install.packages("nnet")
install.packages("car")

library(readxl)
library(foreign)
library(nnet)
library(car)


setwd("F:/Valeria/RSN/data/for_sharing/data_to_make_figures")

# load KSS data

KSS_data <- read_excel("Suppl_Table1_KarolinskaSleepinessAnswers.xlsx")

head(KSS_data)

KSS_data$ID <- factor(KSS_data$ID)
KSS_data$daytime <- factor(KSS_data$daytime)


# mean and SD

KSS_eve = KSS_data$KSS[which(KSS_data$daytime == 'eve')]
KSS_mor = KSS_data$KSS[which(KSS_data$daytime == 'mor')]

mean(KSS_eve)
sd(KSS_eve)

mean(KSS_mor)
sd(KSS_mor)

KSS_data$KSS <- factor(KSS_data$KSS, order = TRUE)

head(KSS_data)


# ---------- Multinomial logistic regression for KSS  ---------------------
# Does the number of responses per response type vary for different stimulation conditions
KSS_data$daytime <- relevel(KSS_data$daytime, ref = "eve")
m_KSS <- multinom(KSS ~ daytime, data = KSS_data)
summary(m_KSS)
exp(coef(m_KSS))


# Check the Z-score for the model (wald Z)
z <- summary(m_KSS)$coefficients/summary(m_KSS)$standard.errors
z
p <- (1 - pnorm(abs(z), 0, 1))*2
p

Anova(m_KSS)


# load VAMS data

VAMS_data <- read_excel("Suppl_Table1_VisualAnalogueMoodAnswers.xlsx")

head(VAMS_data)

VAMS_data$ID <- factor(VAMS_data$ID)
VAMS_data$daytime <- factor(VAMS_data$daytime)


VAMS_data$happysad = VAMS_data$happy - VAMS_data$sad
VAMS_data$calmtense = VAMS_data$calm - VAMS_data$tense 
VAMS_data$energeticsleepy = VAMS_data$energetic - VAMS_data$sleepy 


# mean and SD

VAMS_happysad_eve = VAMS_data$happysad[which(VAMS_data$daytime == 'eve')]
VAMS_happysad_mor = VAMS_data$happysad[which(VAMS_data$daytime == 'mor')]

VAMS_calmtense_eve = VAMS_data$calmtense[which(VAMS_data$daytime == 'eve')]
VAMS_calmtense_mor = VAMS_data$calmtense[which(VAMS_data$daytime == 'mor')]

VAMS_energeticsleepy_eve = VAMS_data$energeticsleepy[which(VAMS_data$daytime == 'eve')]
VAMS_energeticsleepy_mor = VAMS_data$energeticsleepy[which(VAMS_data$daytime == 'mor')]

mean(VAMS_happysad_eve)
sd(VAMS_happysad_eve)

mean(VAMS_happysad_mor)
sd(VAMS_happysad_mor)

mean(VAMS_calmtense_eve)
sd(VAMS_calmtense_eve)

mean(VAMS_calmtense_mor)
sd(VAMS_calmtense_mor)

mean(VAMS_energeticsleepy_eve)
sd(VAMS_energeticsleepy_eve)

mean(VAMS_energeticsleepy_mor)
sd(VAMS_energeticsleepy_mor)


VAMS_data$happysad <- factor(VAMS_data$happysad, order = TRUE)
VAMS_data$calmtense <- factor(VAMS_data$calmtense, order = TRUE)
VAMS_data$energeticsleepy <- factor(VAMS_data$energeticsleepy, order = TRUE)

head(VAMS_data)


# ---------- Multinomial logistic regression for happysad ---------------------


VAMS_data$daytime <- relevel(VAMS_data$daytime, ref = "eve")
m_happysad <- multinom(happysad ~ daytime, data = VAMS_data)
summary(m_happysad)
exp(coef(m_happysad))


# Check the Z-score for the model (wald Z)
z <- summary(m_happysad)$coefficients/summary(m_happysad)$standard.errors
z
p <- (1 - pnorm(abs(z), 0, 1))*2
p

Anova(m_happysad)


# ---------- Multinomial logistic regression for calmtense ---------------------


VAMS_data$daytime <- relevel(VAMS_data$daytime, ref = "eve")
m_calmtense <- multinom(calmtense ~ daytime, data = VAMS_data)
summary(m_calmtense)
exp(coef(m_calmtense))


# Check the Z-score for the model (wald Z)
z <- summary(m_calmtense)$coefficients/summary(m_calmtense)$standard.errors
z
p <- (1 - pnorm(abs(z), 0, 1))*2
p

Anova(m_calmtense)



# ---------- Multinomial logistic regression for energeticsleepy ---------------------


VAMS_data$daytime <- relevel(VAMS_data$daytime, ref = "eve")
m_energeticsleepy <- multinom(energeticsleepy ~ daytime, data = VAMS_data)
summary(m_energeticsleepy)
exp(coef(m_energeticsleepy))


# Check the Z-score for the model (wald Z)
z <- summary(m_energeticsleepy)$coefficients/summary(m_energeticsleepy)$standard.errors
z
p <- (1 - pnorm(abs(z), 0, 1))*2
p

Anova(m_energeticsleepy)


