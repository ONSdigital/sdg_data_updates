#' Install packages that are not already installed
#'
#' Takes a vector of package names that you need and installs
#' any packages that are not already installed. Returns a message to say all are
#' already installed, or installs any absent packages, with the usual 
#' install.packages messages.
#'
#' @param packages. A vector of packages you want to install if they are not already
#'
#' @examples
#' install_absent_packages(c("dpyr", "tidyr"))
#'
#' @export

install_absent_packages <- function(packages) {
  
  absent_packages <- setdiff(packages, rownames(installed.packages()))
  
  if (length(absent_packages) > 0) {
    install.packages(absent_packages,
                     dependencies = TRUE, 
                     type = "win.binary")
    
  } else {
    print("all packages already installed")
  }
}