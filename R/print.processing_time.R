#' @title Processing Time Print
#'
#' @description  Print Processing Time Information
#' @param x Data to print
#' @param ... Additional arguments
#' @method print processing_time

#' @export

print.processing_time <- function(x, ...) {
	data <- x

	if(attr(data, "level") == "log") {
		attr(data, "raw") <- NULL
		attr(data, "level") <- NULL
		attr(data, "mapping") <- NULL
		print.default(data)
	}
	else {
		print(tibble::trunc_mat(data))
	}
}