# Load packages
install.packages('tidyverse')
library(tidyverse)
library(readr)
library(ggplot2)
library(dplyr)

# Import dataset from Deliverable 1
Deliverable1Results <- read_csv("~/
                                mwatson_sql_query_results.csv")
View(mwatson_sql_query_results)
kennerdell_data <- mwatson_sql_query_results

# Create subset of data for pH testing
kennerdell_ph_data <- subset(kendell_data, 
                             kendell_data$updated_result_unit=="SU")

# Define outlier function to list outliers in visualization
findoutlier <- function(x) {
  return(x < quantile(x, .25) - 1.5*IQR(x) | x > quantile(x, .75) + 1.5*IQR(x))
}

# Add new column with outliers to pH dataset
kendell_ph_data <- kendell_ph_data %>%
  group_by(Exposure_Area) %>%
  mutate(outlier = ifelse(findoutlier(updated_result_num), sys_loc_code, NA))

# Create pH data boxplot by exposure area
ggplot(kendell_ph_data, aes(x=Exposure_Area, y=updated_result_num)) +
  geom_boxplot(fill="lightblue") +
  geom_text(aes(label=outlier), na.rm=TRUE, hjust=0) + 
  ggtitle("pH Results by Exposure Area") + 
  xlab("Exposure Area") + 
  ylab("pH (SU)") + 
  labs(
    caption = 
"• Median pH of downgradient samples is higher than upgradient samples \n
• Observably greater pH variability in upgradient samples, despite no outliers 
    being detected") + 
  theme(
    plot.title = element_text(hjust=0.5, face="bold.italic"),
    plot.caption=element_text(vjust=0, hjust=0, size=11),
    axis.title.x=element_text(face="italic", vjust=3),
    axis.title.y=element_text(face="italic")
  )
