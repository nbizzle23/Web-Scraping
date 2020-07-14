

#Scraping NBA game data from basketball-reference.com
# Scraping the data
# Load packages for web scraping
install.packages('rvest')
install.packages('lubridate')
library(rvest)
library(lubridate)


#Parameters
year<-"2019"
monthList<-c("october","november","december","january","february", "march","april","may","june")
playoff_startDate <- ymd("2019-04-13")
outputfile<- "NBA-2019_game_data.rds"
  
  
#Script for Scraping data
#Create at data frame, df, that loops over the months
#and scapes the webpage for each month
  
df <- data.frame()
for(month in monthList){
  #get the webpage
  url <-paste0("https://www.basketball-reference.com/leagues/NBA_",year,"_games-", month,".html")
  webpage <- read_html(url)
  
  #get the column names
  col_names <- webpage %>%
    html_nodes("table#schedule > thead > tr > th") %>%
  html_attr("data-stat")
  col_names <- c("game_id", col_names)
  
  #extract dates column
  #april differs since the playoffs start
  #Playoffs mess with data so we get rid of it
dates <- webpage %>%
  html_nodes("table#schedule > tbody > tr > th") %>%
  html_text()
dates <- dates[dates != "Playoffs"]
  
  #extract game id
# to remove the NA effects on that row due to Playoffs in april
game_id <- webpage %>%
  html_nodes("table#schedule > tbody > tr > th")%>%
  html_attr("csk")
  game_id <- game_id[!is.na(game_id)]
  
  #extract all columns(except date)
  data <- webpage %>% 
    html_nodes("table#schedule > tbody > tr > td") %>% 
    html_text() %>%
    matrix(ncol = length(col_names) - 2, byrow = TRUE)
  
  # combine game IDs, dates and columns in dataframe for this month, add col names
  month_df <- as.data.frame(cbind(game_id, dates, data), stringsAsFactors = FALSE)
  names(month_df) <- col_names
  
  # add to overall dataframe
  df <- rbind(df, month_df)
}
#Copy and paste directly in console

#Performing some typecasting to get the data into the correct type 
#When webscraping the data comes out as character strings
#change columns to the correct types
df$visitor_pts <- as.numeric(df$visitor_pts)
df$home_pts <- as.numeric(df$home_pts)
df$attendance <- as.numeric(df$attendance)
df$date_game <- mdy(df$date_game)

#Add regular season and playoff columns
df$game_type <- with(df, ifelse(date_game >= playoff_startDate, "Playoffs", "Regular"))

#drop the boxscore column
df$box_score_text <- NULL

#save to file
saveRDS(df, outputfile)

#Table standings
#Recreate the regular season table standing
#Create winner and loser columns then just pull from regular season
df$winner <- with(df, ifelse(visitor_pts > home_pts, 
                             visitor_team_name, home_team_name))
df$loser <- with(df, ifelse(visitor_pts < home_pts,
                           visitor_team_name, home_team_name))

#Build regular season standings table
regular_df <- subset(df, game_type=="Regular")
teams <- sort(unique(regular_df$visitor_team_name))
standings <- data.frame(team = teams, stringsAsFactors = FALSE)

#Manually input conference information
standings$conf <- c("East", "East", "East", "East", "East",
                    "East", "West", "West", "East", "West",
                    "West", "East", "West", "West", "West",
                    "East", "East", "West", "West", "East",
                    "West", "East", "East", "West", "West",
                    "West", "West", "East", "West", "East")

#Manually input divison information
standings$div <- c("Southeast", "Atlantic", "Atlantic", "Southeast", "Central",
                   "Central", "Southwest", "Northwest", "Central", "Pacific",
                   "Southwest", "Central", "Pacific", "Pacific", "Southwest",
                   "Southeast", "Central", "Northwest", "Southwest", "Atlantic",
                   "Northwest", "Southeast", "Atlantic", "Pacific", "Northwest",
                   "Pacific", "Southwest", "Atlantic", "Northwest", "Southeast")

#Find the number of times for each team appears in the winner or loser columns
#Create for loop for all 30 teams
standings$win <- 0; standings$loss <- 0
for(i in 1:nrow(standings)){
  standings$win[i] <- sum(regular_df$winner == standings$team[i])
  standings$loss[i] <- sum(regular_df$loser == standings$team[i])
}

#Win-loss percentage column
standings$wl_pct <- with(standings, win/(win+loss))


#Create Western conference standings
west_standings <- subset(standings, conf=="West")
west_standings[with(west_standings, order(-wl_pct, team)),c("team", "win","loss")]

#Create Eastern conference standings
east_standings <- subset(standings, conf=="East")
east_standings[with(west_standings, order(-wl_pct, team)),c("team", "win","loss")]

#Change to NBA2019
NBA2019 <- df
View(NBA2019)
#Change to NBA2019Standings
NBA2019Standings <- standings
View(NBA2019Standings)


