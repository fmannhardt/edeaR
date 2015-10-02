#' @title Cases
#'
#' @description Provides a fine-grained summary of an event log with characteristics for each case:  the number of events,
#' the number of activity types, the timespan, the trace, the duration and the first and last event type.
#'
#'
#' @param eventlog The event log to be used. An object of class
#' \code{eventlog}.
#'
#'
#' @examples
#'
#'
#' data(example_log)
#' cases(example_log)
#'
#' @export cases



cases <- function(eventlog){
	stop_eventlog(eventlog)

	library(dplyr)
	library(lubridate)

	traces_per_case <- cases_light(eventlog)
	durations <- durations(eventlog)
	colnames(traces_per_case)[colnames(traces_per_case)==case_id(eventlog )] <- "case_classifier"
	colnames(durations)[colnames(durations)==case_id(eventlog)] <- "case_classifier"

	colnames(eventlog)[colnames(eventlog)==activity_instance_id(eventlog)] <- "activity_instance_classifier"
	colnames(eventlog)[colnames(eventlog)==activity_id(eventlog)] <- "event_classifier"
	colnames(eventlog)[colnames(eventlog)==life_cycle_id(eventlog)] <- "life_cycle_classifier"
	colnames(eventlog)[colnames(eventlog)==case_id(eventlog)] <- "case_classifier"
	colnames(eventlog)[colnames(eventlog)==timestamp(eventlog)] <- "timestamp_classifier"

	summary <- eventlog %>%
		group_by(case_classifier) %>%
		summarize(trace_length = n_distinct(activity_instance_classifier),
				  number_of_activities = n_distinct(event_classifier),
				  start_timestamp = min(timestamp_classifier),
				  complete_timestamp = max(timestamp_classifier))

	summary <- merge(summary, traces_per_case, "case_classifier")
	summary <- merge(summary, durations, "case_classifier")

	summary$start_timestamp <- ymd_hms(summary$start_timestamp)
	summary$complete_timestamp <- ymd_hms(summary$complete_timestamp)

	for(i in 1:nrow(summary)){
		summary$first_event[i] <- strsplit(summary$trace[i], split = ",")[[1]][1]
		summary$last_event[i] <- strsplit(summary$trace[i], split = ",")[[1]][length(strsplit(summary$trace[i], split =",")[[1]])]
	}

	colnames(summary)[colnames(summary)=="case_classifier"] <- case_id(eventlog)

	summary <- tbl_df(summary)
	return(summary)


}
