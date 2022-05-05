#-------------------------------------------------
# Set working directory
#-------------------------------------------------

setwd("/Users/witold/GitHub/SWITRS")

#-------------------------------------------------
# Load libraries
#-------------------------------------------------

# Libraries
library(tidyverse)
library(lubridate)
library(openxlsx)
library(RSQLite)
library(rpart.plot)

#-------------------------------------------------
# 1. Load data
#-------------------------------------------------

# Create connection
con <- dbConnect(SQLite(), "data/switrs.sqlite")

# View available tables
as.data.frame(dbListTables(con))

# Get tables
#case_ids	<- dbReadTable(con, 'case_ids') %>% as_tibble()
#collisions	<- dbReadTable(con, 'collisions') %>% as_tibble()
parties		<- dbReadTable(con, 'parties') %>% as_tibble()
#victims		<- dbReadTable(con, 'victims') %>% as_tibble()

# data is fetched so disconnect it.
dbDisconnect(con)

# Join
#df <- left_join(collisions,parties)
df <- parties

#-------------------------------------------------
# 2. Clean data set
#-------------------------------------------------

# Shuffle data
shuffle_index <- sample(1:nrow(df))
df <- df[shuffle_index, ]

# Drop NAs and Convert to factor level
clean_df <- df %>%

	# Select drivers only to test for fault
	#filter(
	#	party_type == "driver"
	#) %>%
    
    # Manually select reasonable independent vars
    select(
        at_fault
        ,party_type
        ,party_sex
        ,party_age
		,party_sobriety
		,party_drug_physical
		,party_safety_equipment_1
		,party_safety_equipment_2
		,financial_responsibility
		,hazardous_materials
		,cellphone_use
		,other_associate_factor_1
		,other_associate_factor_2
		,movement_preceding_collision
		,vehicle_year
		,vehicle_make
		,statewide_vehicle_type
		,party_race
    ) %>%
    
    # Remove troublesome values
    filter(
    	!movement_preceding_collision %in% c("S","0","4")
    ) %>%
    
    # Convert to appropriate format / factor levels
    mutate(
        at_fault = at_fault
        ,party_type = addNA(party_type)
        ,party_sex = addNA(party_type)
        ,party_age = party_age
		,party_sobriety = addNA(party_sobriety)
		,party_drug_physical = addNA(party_drug_physical)
		,party_safety_equipment_1 = addNA(party_safety_equipment_1)
		,party_safety_equipment_2 = addNA(party_safety_equipment_2)
		,financial_responsibility = addNA(financial_responsibility)
		,hazardous_materials = addNA(hazardous_materials)
		,cellphone_use = addNA(cellphone_use)
		,other_associate_factor_1 = addNA(other_associate_factor_1)
		,other_associate_factor_2 = addNA(other_associate_factor_2)
		,movement_preceding_collision = addNA(movement_preceding_collision)
		,vehicle_year = vehicle_year
		,vehicle_make = addNA(vehicle_make)
		,statewide_vehicle_type = addNA(statewide_vehicle_type)
		,party_race = addNA(party_race)
    )

#-------------------------------------------------
# 3. Create train / test subsets
#-------------------------------------------------

# Train / Test function
create_train_test <- function(data, train_proportion, train) {
    n_row = nrow(data)
    total_row = floor(train_proportion * n_row)
    train_sample <- 1:total_row
    if (train == TRUE) {
        return (data[train_sample, ])
    } else {
        return (data[-train_sample, ])
    }
}

# Define training & test subset
data_train	<- create_train_test(clean_df, 0.8, TRUE)
data_test	<- create_train_test(clean_df, 0.8, FALSE)

# Check that proportions are correct (proportion of survivors in both data sets should be same)
prop.table(table(data_train$at_fault))
prop.table(table(data_test$at_fault))

#-------------------------------------------------
# 4. Build model
#-------------------------------------------------

# Define model
fit <- rpart(at_fault~., data = data_train, method = 'class')

# Set = 106 (i.e. binary model, more in vignette: 
# https://cran.r-project.org/web/packages/rpart.plot/rpart.plot.pdf)
rpart.plot(fit,
           extra = 106, # show fitted class, probs, percentages
           box.palette = "GnBu", # color scheme
           branch.lty = 3, # dotted branch lines
           shadow.col = "gray", # shadows under the node boxes
           nn = TRUE) # display the node numbers

#-------------------------------------------------
# 5. Make prediction
#-------------------------------------------------

# Define
predict_unseen <-predict(fit, data_test, type = 'class')

# Check
table_mat <- table(data_test$at_fault, predict_unseen)

# Read output (Yes-Yes correct, No-No correct, variations Yes-No means model misclassified)
table_mat

#-------------------------------------------------
# 6. Calculate model accuracy / measure performance
#-------------------------------------------------

# Calculate accuracy
accuracy_Test <- sum(diag(table_mat)) / sum(table_mat)

# Print model accuracy
print(paste('Accuracy for test', accuracy_Test))