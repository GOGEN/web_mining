library(lubridate)

logs = read.table('access.log')
logs$V4 = gsub("\\[", "", logs$V4)
logs$V5 = gsub("\\]", "", logs$V5)
logs$V10 = paste(logs$V4, logs$V5, " ")

# backup original locale
bkp <- Sys.getlocale('LC_TIME')
# change locale
Sys.setlocale('LC_TIME','C')
logs$V10 = strptime(logs$V10,format='%d/%b/%Y:%H:%M:%S')
logs$V11 = hour(logs$V10)
logs = logs[c("V1", "V6", "V7", "V8", "V9", "V10", "V11")]
colnames(logs) <- c("ip", "request", "http_code", "V8", "user_id", "datetime", "time_hour")
library("DBI")
library("RSQLite")
con = dbConnect(SQLite(), dbname="mining.db")
dbSendQuery(con,"CREATE TABLE logs_v2 (ip TEXT, request TEXT, http_code TEXT, V8 TEXT, user_id TEXT, datetime TEXT, time_hour TEXT)")

dbWriteTable(con, "logs_v2", logs, append=TRUE)
dbReadTable(con, "logs_v2")

uniqueCards = as.data.frame(table(rep(logs$V9, 1)))

uniqueHours = as.data.frame(table(rep(logs$V11, 1)))
mean(uniqueHours$Freq, trim=1)

orderLogs = subset(logs, V6 == "GET /order.phtml HTTP 1.1")
uniqueOrders = as.data.frame(table(rep(orderLogs$V9, 1)))
