
#' @title CreateParam
#'
#' @description
#' This function Generates a Parameter Configuration Non-interactively.
#'
#' This function allows users to specify parameters for a statistical analysis
#' or modeling through direct arguments, bypassing the interactive process.
#' It supports defining various model components, including traits, treatments,
#' noise effects, covariates, interactions, and random effects.
#'
#' @param file.name String between commas " " specifying the name or name and path to the data file (if its not in the working directory), which must be in`.csv`,`.xlsx` or format `.txt`. If the datafile its preloaded in the environment, the name of the data can be input as a string "" without extension.
#' @param na.codes Character vector specifying how missing values are encoded in the data file. Different values in the same file are allowed. Default codes are c("", "NA", "NULL").
#' @param hTrait Vector specifying the names of the traits. Users can specify traits using either hTrait, pTrait or both arguments.
#' @param pTrait Vector specifying the column positions in the data file of the traits. Users can specify traits using either hTrait, pTrait or both arguments.
#' @param hTreatment Vector specifying the names of the treatment effects. Users can specify treatment effects using either hTreatment, pTreatment or both arguments.
#' @param pTreatment Vector specifying the column positions in the data file of the treatment effects. Users can specify treatment effects using either hTreatment, pTreatment or both arguments.
#' @param askCompare Character specifying how to compare treatment levels: `"D"`for difference, `"R"` for ratio, or `"NA"` if not applicable. Default is `"D"`.
#' @param hNoise Vector specifying the names of the noise effects. Users can specify noise effects using either hNoise, pNoise or both arguments.
#' @param pNoise Vector specifying the column positions in the data file of the noise effects. Users can specify noise effects using either hNoise, pNoise or both arguments.
#' @param hCov Vector specifying the names of the covariates. Users can specify covariates using either hCov, pCov or both arguments.
#' @param pCov Vector specifying the column positions in the data file of the covariates. Users can specify covariates using either hCov, pCov or both arguments.
#' @param hInter Matrix of dimensions n x 2 with n being the number of order 2 interactions. Rows specify the names of the components involved in the interactions. Specification can be through either hInter, pInter or both arguments.
#' @param pInter Matrix of dimensions n x 2 with n being the number of order 2 interactions. Rows specify column positions in the data file of the components involved in the interactions. Specification can be through either hInter, pInter or both arguments.
#' @param typeInter Matrix n x 2 indicating whether components of each interaction are factors (`"F"`) or covariates (`"C"`). By default, "F".
#' @param ShowInter Character vector of length equal to number of interactions indicating how each interaction should be classified, as treatments (`"T"`) or noise (`"N"`). Mandatory if `hInter` or `pInter` are not `NULL`.
#' @param hRand Vector specifying the names of the random effects. Users can specify random effects using either hRand, pRand or both arguments.
#' @param pRand Vector specifying the column positions in the data file of the random effects. Users can specify random effects using either hRand, pRand or both arguments.
#' @param Seed Integer used as a random seed for MCMC sampling to ensure reproducibility.Default is `1234`.
#' @param iter Integer specifying the number of MCMC iterations. Default is `30000`.
#' @param burnin Integer specifying the number of initial MCMC iterations to be discarded.Default is `5000`.
#' @param lag Integer specifying the thinning interval for MCMC sampling. Default is `10`.
#'
#' @return A list of all specified parameters ready for use in subsequent statistical analysis
#' or modeling. This includes detailed specifications of traits, treatments, noise effects,
#' covariates, interactions, random effects, and MCMC characteristics.
#'
#' @section Side Effects:
#' - The function directly processes the specified parameters without interactive input,
#' facilitating script-based workflows.
#' - It reads the specified data file and may stop execution if the file does not exist
#' or is in an unsupported format.
#'
#' @importFrom utils read.csv
#' @importFrom readxl read_excel
#' @importFrom data.table fread
#' @import knitr
#' @import dplyr
#' @import tibble
#' @examples
#' \dontrun{
#'# Example usage :
#'# Example 1: Basic usage with mandatory parameters (model including only the mean) (data not imported and located outside the working directory)
#' param_list_basic <- CreateParam(
#'  file.name = "~/Dropbox/Rpackages/RabbitR/DataIMF.csv",
#'  hTrait = c("LW", "IMF", "PFat"))
#'
#'
#'# Example 2: using column positions instead of header in some arguments (data preloaded in the environment)
#' param_list_positions <- CreateParam(
#'   file.name = "DataIMF",
#'   pTrait = c(5, 7, 8),  # Corresponds to LW, IMF, PFat
#'   pTreatment = 1,       # Corresponds to AE
#'   pNoise = 2,           # Corresponds to OP
#'   pCov = "pH",
#'   Seed = 2024,
#'   iter = 30000,
#'   burnin = 6000,
#'   lag = 12
#' )
#'
#'# Example 3: model with treatment, noise, covariates, interactions and random effects (data not imported and located in the working directory )
#'param_list_complex <- CreateParam(
#'  file.name = "DataIMF.csv",
#'  hTrait = c("IMF", "PFat"),
#'  hTreatment = "AE",
#'  hNoise = "OP",
#'  hCov = c("pH", "LW"),
#'  hInter=matrix(c("AE","OP"), nrow=1),
#'  ShowInter=c("T"),
#'  hRand = "Sex",
#'  Seed = 1234,
#'  iter = 40000,
#'  burnin = 8000,
#'  lag = 20
#')
#'}
#' @export
CreateParam <- function(file.name,
                        na.codes=c("", "NA", "NULL"),
                        hTrait=NULL, pTrait=NULL,
                        hTreatment=NULL, pTreatment=NULL, askCompare="D",
                        hNoise=NULL, pNoise=NULL,
                        hCov=NULL, pCov=NULL,
                        hInter=NULL, pInter=NULL,typeInter=NULL, ShowInter=NULL,
                        hRand=NULL, pRand=NULL,
                        Seed=1234, iter=30000, burnin=5000, lag=10
                        ) {

      cat("\nLet's create you Parameter file:\n")
      cat("---------------------------------------------------\n")

      param_list <- list()

      param_list[["file.name"]] <- file.name
      if(!is.null(na.codes)){
      param_list[["na.codes"]] <- na.codes
      }

      #Read the file

      # a) Check if file.name is an object in the environment in dataframe or tibble formats
      if (exists(file.name, where = .GlobalEnv) && tools::file_ext(file.name) == "") {
        data <- get(file.name)

        # Check if the object is a dataframe or a tibble
        if (!(inherits(data, "data.frame") || inherits(data, "tbl_df"))) {
          stop("Error: The object is not a data frame or tibble.")
        }
      } else if (file.exists(file.name)) { #b) If its not imported yet

        # Determine the file extension
        fileExtension <- tools::file_ext(file.name)

        # Read xlsx, xls and use the modified approach for .csv and .txt files to apcept all kind of delim
        data <- switch(fileExtension,
                       csv = {
                         dt <- data.table::fread(file.name, na.strings = na.codes)
                         as.data.frame(dt) # outputs a data.frame
                       },
                       xls = readxl::read_excel(file.name), # outputs a tibble
                       xlsx = readxl::read_excel(file.name), # outputs a tibble
                       txt = {
                         dt <- data.table::fread(file.name, na.strings = na.codes)
                         as.data.frame(dt)  # outputs a data.frame
                       },
                       stop("Error: Unsupported file format")
        )

        # Additional processing for Excel files if needed as read_Excel handles missings automatically with NA and  "" but not with other na.strings
        if (fileExtension %in% c("xls", "xlsx")) {
          data[is.na(data)] <- NA  # Handling NA values
        }

      } else { #c) If it`s something else`
        stop("Error: The file does not exist.")
      }

      # Re-assure missing values are well coded
      data <- data %>%
        mutate(across(everything(), ~ replace(., . %in% na.codes, NA)))

      #Check format and re-asure missing values are well coded
      str(data)

      # Display number of rows and Descriptive summary
      ri=nrow(data)
      cat(paste0("The number of rows in the data file is ", ri))
      cat("\n")
      param_list[["ri"]] <- ri

      # Define the model

      # 1) Traits (required)
      if (!is.null(hTrait)) {
        # Initialize pTrait
        pTrait <- numeric(length(hTrait))
        # Update param_list
        param_list[["hTrait"]] <- hTrait
        param_list[["nTrait"]] <- length(hTrait)

        for (n in seq_along(hTrait)) {
          if (!hTrait[n] %in% colnames(data)) {
            stop(paste0("Error: Trait '", hTrait[n], "' not found. Please check that spelling is correct\n"))
          } else {
            pTrait[n] <- which(colnames(data) == hTrait[n])
          }
        }
        param_list[["pTrait"]] <- pTrait
      } else if (!is.null(pTrait)) {
        # Initialize hTrait
        hTrait <- character(length(pTrait))
        # Update param_list
        param_list[["pTrait"]] <- pTrait
        param_list[["nTrait"]] <- length(pTrait)

        for (n in seq_along(pTrait)) {
          if (pTrait[n] > ncol(data)) {
            stop(paste0("Error: Column number ", pTrait[n], " not found. Please check that column number is correct\n"))
          } else {
            hTrait[n] <- colnames(data)[pTrait[n]]
          }
        }
        param_list[["hTrait"]] <- hTrait
      } else {
        stop("Error: Both hTrait and pTrait are NULL. Please specify at least one.")
      }

      # Convert trait columns to numeric
      data[,pTrait] <- lapply(data[,pTrait, drop=FALSE], function(x) as.numeric(as.character(x)))

      # Display descriptive stats of traits
      cat(paste0(c("See below the summary statistics of the traits: ", hTrait),collapse=" "))
      cat("\n")

      # Custom summary function
      customSummary <- function(x) {
        mean_val <- mean(x, na.rm = TRUE)
        sd_val <- sd(x, na.rm = TRUE)
        # Initialize CV as NA
        cv_val <- NA
        # Check if all values are either positive or negative
        if (all(x > 0, na.rm = TRUE) || all(x < 0, na.rm = TRUE)) {
          cv_val <- sd_val / mean_val * 100  # Calculate CV in percentage
        } else {
          cv_val <- "CV not defined for positive and negative values"
        }
        # Count missing values
        missing_vals <- sum(is.na(x))

        return(c(Mean = mean_val,
                 SD = sd_val,
                 Min = min(x, na.rm = TRUE),
                 '1st Qu.' = quantile(x, 0.25, na.rm = TRUE),
                 Median = median(x, na.rm = TRUE),
                 '3rd Qu.' = quantile(x, 0.75, na.rm = TRUE),
                 Max = max(x, na.rm = TRUE),
                 CV = cv_val,
                 'Missing Values' = missing_vals))
      }

      # Calculate custom summary statistics for each selected trait
      summary_stats <- sapply(data[, pTrait, drop=FALSE], customSummary)

      # Convert to a dataframe
      summary_df <- as.data.frame(t(summary_stats))

      # Print the table using kable from knitr
      print(kable(summary_df, format = "simple", caption = "Summary Statistics of Traits"))


      # 2) Treatment effects (optional)
      # Initialize default values in case both hTreatment and pTreatment are NULL
      nlevels_Treatment <- NULL

      # When at least one of hTreatment or pTreatment is not NULL
      if (!is.null(hTreatment) || !is.null(pTreatment)) {
        if (!is.null(hTreatment)) {
          pTreatment <- sapply(hTreatment, function(ht) {
            colIndex <- which(colnames(data) == ht)
            if (length(colIndex) == 0) stop(paste0("Error: Treatment '", ht, "' not found. Please check spelling.\n"))
            return(colIndex)
          })
          param_list[["hTreatment"]] <- hTreatment
        } else {
          # When pTreatment is not NULL and hTreatment is NULL
          hTreatment <- colnames(data)[pTreatment]
        }

        # Update param_list for both scenarios
        param_list[["pTreatment"]] <- pTreatment
        param_list[["nTreatment"]] <- nTreatment <- length(pTreatment)
        param_list[["hTreatment"]] <- hTreatment

        # Common operations for both hTreatment and pTreatment
        for (n in seq_along(pTreatment)) {

          # Check if there are missing values in the treatment column
          if (any(is.na(data[[pTreatment[n]]]))) {
            stop(sprintf("Error: Missing values found in treatment effect '%s'. Missing values in treatment effects are not supported.", hTreatment[n]))
          }

          data[, pTreatment[n]] <- as.factor(data[[pTreatment[n]]])
          nlevels_Treatment[n] <- nlevels(data[[pTreatment[n]]])
        }
        param_list[["nlevels_Treatment"]] <- nlevels_Treatment
        cat(paste0("The number of levels read in Treatments are: ", paste(nlevels_Treatment, collapse=", "), "."))
        cat("\n")
      } else {
        # When both hTreatment and pTreatment are NULL
        param_list[["hTreatment"]] <- hTreatment <- character(0)
        param_list[["pTreatment"]] <- pTreatment <- numeric(0)
        param_list[["nTreatment"]] <- nTreatment <- 0
        param_list[["nlevels_Treatment"]] <- nlevels_Treatment
        cat("Note: No Treatment effects specified\n")
      }

      # Check askCompare value
      if (!is.null(askCompare) && !askCompare %in% c("D", "R", "NA")) {
        print("Error entry value for askCompare Parameter. Setting to default 'D'.")
        askCompare <- "D"  # Defaulting to 'D' if an incorrect value is provided
      }

      param_list[["askCompare"]] <- askCompare

      # 3) Noise effects (optional)
      # Initialize default values in case both hNoise and pNoise are NULL
      nlevels_Noise <- numeric(0)

      # When at least one of hNoise or pNoise is not NULL
      if (!is.null(hNoise) || !is.null(pNoise)) {
        if (!is.null(hNoise)) {
          pNoise <- sapply(hNoise, function(hn) {
            colIndex <- which(colnames(data) == hn)
            if (length(colIndex) == 0) stop(paste0("Error: Noise '", hn, "' not found. Please check spelling.\n"))
            return(colIndex)
          })
          param_list[["hNoise"]] <- hNoise
        } else {
          # When pNoise is not NULL and hNoise is NULL
          hNoise <- colnames(data)[pNoise]
        }

        # Update param_list for both scenarios
        param_list[["pNoise"]] <- pNoise
        param_list[["nNoise"]] <- nNoise <- length(pNoise)
        param_list[["hNoise"]] <- hNoise

        # Common operations for both hNoise and pNoise
        for (n in seq_along(pNoise)) {

          # Check if there are missing values in the noise column
          if (any(is.na(data[[pNoise[n]]]))) {
            stop(sprintf("Error: Missing values found in Noise effect '%s'. Missing values in noise effects are not supported.", hNoise[n]))
          }

          data[, pNoise[n]] <- as.factor(data[[pNoise[n]]])
          nlevels_Noise[n] <- nlevels(data[[pNoise[n]]])
        }
        param_list[["nlevels_Noise"]] <- nlevels_Noise
        cat(paste0("The number of levels read in Noise are: ", paste(nlevels_Noise, collapse=", "), "."))
      } else {
        # When both hNoise and pNoise are NULL
        param_list[["hNoise"]] <- hNoise <- character(0)
        param_list[["pNoise"]] <- pNoise <- numeric(0)
        param_list[["nNoise"]] <- nNoise <- 0
        param_list[["nlevels_Noise"]] <- nlevels_Noise
        cat("Note: No noise effects specified\n")
      }

      # Display a contingency table of effects
      if ((nTreatment+nNoise)>1) {

        fi=nTreatment+nNoise
        NTables=((fi*fi) - fi)/2

        if (nNoise != 0 && nTreatment != 0) {FE<-data.frame(data[,c(pTreatment, pNoise)])
        } else if (nNoise == 0)  {
          FE<-data.frame(data[,c(pTreatment)])
        } else if (nTreatment == 0)  {
          FE<-data.frame(data[,c(pNoise)])}

        for (m in 1:ncol(FE)){FE[,m] <- paste(names(FE)[m],FE[,m],sep="")}
        for (m in 1:ncol(FE)){
          for (j in (m+1):ncol(FE)) {
            if(j>ncol(FE)) break
            cat(" Contingency Tables across effects ")
            cat("\n")
            print(paste(colnames(FE)[m],colnames(FE)[j], sep=" vs "))
            print(table(FE[,m],FE[,j])) }
        }
      } else {
        print("Contingency tables cannot be created because there is none or only 1 effect")}


      # 4) Covariates (optional)
      # When at least one of hCov or pCov is not NULL
      if (!is.null(hCov) || !is.null(pCov)) {
        if (!is.null(hCov)) {
          pCov <- sapply(hCov, function(hc) {
            colIndex <- which(colnames(data) == hc)
            if (length(colIndex) == 0) stop(paste0("Error: Cov '", hc, "' not found. Please check spelling.\n"))
            return(colIndex)
          })
          param_list[["hCov"]] <- hCov
        } else {
          # When pCov is not NULL and hCov is NULL
          hCov <- colnames(data)[pCov]
        }

        # Update param_list for both scenarios
        param_list[["pCov"]] <- pCov
        param_list[["nCov"]] <- nCov <- length(pCov)
        param_list[["hCov"]] <- hCov

        # Display descriptive stats of covariates
          cat(paste0(c("See below the summary statitics of covariates: ", hCov),collapse=" "))
          cat("\n")
          summary_stats <- sapply(data[, pCov, drop=FALSE], customSummary)
          summary_df <- as.data.frame(t(summary_stats))
          print(kable(summary_df, format = "simple", caption = "Summary Statistics of Covariates"))

      } else {
        # When both hCov and pCov are NULL
        param_list[["hCov"]] <- hCov <- character(0)
        param_list[["pCov"]] <- pCov <- numeric(0)
        param_list[["nCov"]] <- nCov <- 0

        cat("Note: No covariates specified\n")
      }

      # 5) Interactions (optional)
      nlevels_Interaction <- numeric(0)

      # When at least one of hInter or pInter is not NULL
      if (!is.null(hInter) || !is.null(pInter)) {
        if (!is.null(pInter)) {
          hInter <- apply(pInter, 1, function(x) colnames(data)[x])
        } else {
          pInter <- sapply(hInter, function(hi) {
            colIndex <- which(colnames(data) == hi)
            if (length(colIndex) == 0) stop(paste0("Error: Interaction '", hi, "' not found. Please check spelling.\n"))
            return(colIndex)
          })
        }

        #Check that ShowInter has the same length as nrow of hInter
        if (nrow(hInter) != length(ShowInter)) {
          stop("Error: The number of interactions in 'ShowInter' and 'hInter' does not match .")
        }

        # Update param_list for both scenarios
        param_list[["pInter"]] <- pInter <- matrix(pInter, ncol = 2, byrow = TRUE)
        param_list[["nInter"]] <- nInter <- nrow(pInter)
        param_list[["hInter"]] <- hInter <- matrix(hInter, ncol = 2, byrow = TRUE)
        param_list[["typeInter"]] <- typeInter <- character(0) #To be changed If ever interactions with covariates are permitted
        param_list[["ShowInter"]] <- ShowInter

        # Common operations for both hInter and pInter
        for (n in 1:nInter) {
          nlevels_Interaction[n] <- nlevels(as.factor(data[[pInter[n,1]]])) * nlevels(as.factor(data[[pInter[n,2]]]))
        }
        param_list[["nlevels_Interaction"]] <- nlevels_Interaction
        cat(paste0("The number of levels of Interaction ",n, " is ", paste(nlevels_Interaction[n], collapse=", "), "."))
      } else {
        # When both hInter and pInter are NULL
        param_list[["hInter"]] <- hInter <- character(0)
        param_list[["pInter"]] <- pInter <- numeric(0)
        param_list[["nInter"]] <- nInter <- 0
        param_list[["typeInter"]] <- typeInter <- character(0)
        param_list[["ShowInter"]] <- ShowInter <- character(0)
        param_list[["nlevels_Interaction"]] <- nlevels_Interaction
        cat("Note: No interaction effects specified\n")
        }


      # 6) Random effects (optional)
      # When at least one of hRand or pRand is not NULL
      if (!is.null(hRand) || !is.null(pRand)) {
        if (!is.null(hRand)) {
          pRand <- sapply(hRand, function(hr) {
            colIndex <- which(colnames(data) == hr)
            if (length(colIndex) == 0) stop(paste0("Error: Random effect'", hr, "' not found. Please check spelling.\n"))
            return(colIndex)
          })
          param_list[["hRand"]] <- hRand
        } else {
          # When pRand is not NULL and hRand is NULL
          hRand <- colnames(data)[pRand]
        }

        # Update param_list for both scenarios
        param_list[["pRand"]] <- pRand
        param_list[["nRand"]] <- nRand <- length(pRand)
        param_list[["hRand"]] <- hRand

      } else {
        # When both hRand and pRand are NULL
        param_list[["hRand"]] <- hRand <- character(0)
        param_list[["pRand"]] <- pRand <- numeric(0)
        param_list[["nRand"]] <- nRand <- 0

        cat("Note: No random effects specified\n")
      }

      # Create the Formula
      eq.T <- eq.N <- eq.C <- eq.I <- eq.R <- eq.C.name <- eq.I.name <- eq.R.name <- ""
      # Part of the equation for Treatment
      if (nTreatment != 0) {
        eq.T <- paste(hTreatment, collapse = " + ")
      }

      # Part of the equation for Noise
      if (nNoise != 0) {
        eq.N <- paste(hNoise, collapse = " + ")
      }

      # Part of the equation for covariates
      if (nCov != 0) {
        #eq.C <- paste(hCov, collapse = " + ")
        eq.C <- paste("b*", hCov, sep = " ")
      }

      # Part of the equation for Interaction
      if (nInter != 0) {
        if (nrow(hInter) == 1) {
          # When there's only one row, handle concatenation directly
          eq.I <- paste(hInter[1, ], collapse = "*")
        } else {
          # Apply for matrices with more than one row
          eq.I <- apply(hInter, 1, function(x) paste(x, collapse = "*"))
        }
        eq.I.name <- paste(eq.I, collapse = " + ")
      }

      # Part of the equation for Random effects
      if (nRand != 0) {
        #eq.R <- paste("(1|", hRand, ")", sep = "", collapse = " + ")
        eq.R <- paste("Random(", hRand, ")", sep = "", collapse = " + ")
      }

      # Make a string
      # eq_parts<-c(eq.T, eq.N, eq.C, eq.I, eq.R)
      # eq_parts <- eq_parts[eq_parts != ""]
      # eq.total <- paste(eq_parts, collapse = " + ")

      eq_parts<-c(eq.T, eq.N, eq.C, eq.I.name, eq.R)
      eq_parts <- eq_parts[eq_parts != ""]
      eq.name <- paste(eq_parts, collapse = " + ")

      #param_list[["eq.total"]] <- eq.total
      param_list[["eq.name"]] <- eq.name

      cat("\nModel equation for all Traits is :", paste("y = mean + ", eq.name, sep = ""))
      cat("\n")

      # Define MCMC features
      param_list[["Seed"]]   <- Seed
      param_list[["iter"]]   <- iter
      param_list[["burnin"]] <- burnin
      param_list[["lag"]]    <- lag

      print("Your parameter file its ready!")
      invisible(param_list)
} #End of the function






