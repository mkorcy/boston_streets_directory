# http://stackoverflow.com/questions/2261079/how-to-trim-leading-and-trailing-whitespace-in-r
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
'%&%' <- function(x, y) paste0(x,y)
log_error_to_console <- function(cond, id, display_name, last_name, first_name) {
  print("error")
  print(cond)
  print(id)
  print(display_name)
  print(last_name)
  print(first_name)
}