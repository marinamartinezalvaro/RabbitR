
#' @title iCreateParam
#'
#' @description
#' This function creates a Parameter Configuration File Interactively.
#'
#' This function guides the user through an interactive process to create a
#' parameter configuration file. It asks a series of questions about the data file and analysis parameters, which it uses to generate a parameter list.
#'
#' @details
#' The user is prompted to specify the data file, which must be located in
#' the working directory. The function supports `.txt`, `.csv`, `.xls`, or `.xlsx`
#' file formats and allows for the specification of missing value codes. It also
#' queries the user for information on traits, treatments, noise effects, covariates,
#' interactions, and random effects to be included in the analysis.
#'
#' After gathering all necessary information, the function compiles a comprehensive
#' list of parameters that can be used for further statistical analysis or modeling.
#'
#' Data file must be located in the current working directory. Missing values can
#' be coded in various ways and should be explicitly identified during the interaction.
#'
#' @return A list containing all parameters specified by the user during the interaction.
#' This list includes information about the data file, missing value codes, number of
#' traits, treatments, noise effects, covariates, interactions, random effects, and
#' MCMC characteristics if specified.
#'
#' @section Side Effects:
#' - The function interacts with the user through the console.
#' - Depending on user input, it may generate warnings or stop execution if expected
#' conditions are not met (e.g., file not found, unsupported file format).
#'
#' @importFrom utils read.csv
#' @importFrom readxl read_excel
#' @importFrom data.table fread
#' @import knitr
#' @import dplyr
#' @import tibble
#' @examples
#' \dontrun{
#' # Run the function in an interactive R session
#' # Note: Actual usage requires user input during execution
#' # Example (single use)
#' parameter_list <- iCreateParam()
#'}
#' @export
iCreateParam <- function() {

# Read the file
  cat(sprintf("%s ", "\033[32mEnter the name of the datafile with its extension .txt, .csv, .xls or .xlsx \033[0m"))
  file.name <- readline()
  cat("\n")
  while(!file.exists(file.name)==TRUE) {
    cat("\033[32m", paste("DATA FILE", file.name, "NOT FOUND", sep = " "), "\033[0m\n")
    cat("\n")
    cat(sprintf("%s ", "\033[32mEnter the name of the datafile with its extension .txt, .csv, .xls or .xlsx \033[0m"))
    file.name <- readline()
     }

  cat(sprintf("%s ", "\033[32mHas the data file missing values? (Enter Yes=Y or No=N) \033[0m"))
  Missing <- readline()
  while((Missing!= "y") && (Missing!= "n") && (Missing!= "Y") && (Missing!= "N") ==TRUE){
    cat(sprintf("%s ", "\033[32mWeird response, try again! \033[0m"))
    cat("\n")
    cat(sprintf("%s ", "\033[32mHas the data file missing values? (Enter Yes=Y or No=N) \033[0m"))
    Missing <- readline()}

  if(Missing == "Y"| Missing == "y"){
    cat(sprintf("%s ", "\033[32mPlease enter the missing value. If its a blank enter a space \033[0m"))
    na.codes <- readline()
  } else {na.codes=c("", "NA", "NULL")}

  fileExtension <- tools::file_ext(file.name)

  # Choose the reading function based on the file extension
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

  # Additional processing for Excel files if needed
  if (fileExtension %in% c("xls", "xlsx")) {
    data[is.na(data)] <- NA  # Example: Converting custom NA codes if necessary
  }

  # Re-assure missing values are well coded
  data <- data %>%
    mutate(across(everything(), ~ replace(., . %in% na.codes, NA)))

  ri=nrow(data)
  cat("\033[32m", paste("The number of rows in the data file is", ri, sep = " "), "\033[0m\n")

  # Define the model

  # 1)  Traits (required)
    cat("\033[32m", "Help: the header of the datafile is", paste(colnames(data), collapse = ", "), "\033[0m\n")
    cat("\n")
    cat(sprintf("%s ", "\033[32mEnter the total number of traits \033[0m"))
    nTrait <- as.numeric(readline())
    hTrait<-NULL
    pTrait<-NULL

   # if (nTrait>1){ #If more than one trait
      for(n in 1:nTrait){
        cat("\033[32m", paste("Enter the name of the Trait ", n, sep = " "), "\033[0m\n")
        hTrait[n]<- readline()
          while (!hTrait[n]%in%colnames(data)==TRUE) {
            cat(sprintf("%s ", "\033[32mTrait not found. Please check that spelling is correct \033[0m"))
            cat("\n")
            cat("\033[32m", paste("Enter the name of the Trait ", n, sep = " "), "\033[0m\n")
            hTrait[n]<- readline()
          }
          pTrait[n] <- which(colnames(data)== hTrait[n])
        }


    #else {
     #   for(n in 1:nTrait){
     #     cat("\033[32m", paste("Enter the name of the Trait ", n, sep = " "), "\033[0m\n")
     #     hTrait[n]<- readline()
     #     while (!hTrait[n]%in%colnames(data)==TRUE) {
     #       cat(sprintf("%s ", "\033[32mTrait not found. Please check that spelling is correct \033[0m"))
     #       cat("\033[32m", paste("Enter the name of the Trait ", n, sep = " "), "\033[0m\n")
     #       hTrait[n]<- readline()
     #     }
     #     pTrait[n] <- which(colnames(data)== hTrait[n])
     #   }
     # }

    # Display descriptive stats of traits

    # Convert trait columns to numeric
    data[,pTrait] <- lapply(data[,pTrait, drop=FALSE], function(x) as.numeric(as.character(x)))

    cat("\n")
    cat("\033[32m", paste("See below the summary statistics of the traits: ", hTrait, sep = " "), "\033[0m\n")
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
    cat("\n")
    print(kable(summary_df, format = "simple", caption = "Summary Statistics of Traits"))
    cat("\n")

    # Set Effects
    cat(sprintf("%s ", "\033[32mLet's define the model. Remember, all traits will be analyzed with the same model! \033[0m"))
    cat("\n")

    # 2) Treatment effects (optional)
    cat("\033[32m", "Help: the header of the datafile is", paste(colnames(data), collapse = ", "), "\033[0m\n")
    cat("\n")
    cat(sprintf("%s ", "\033[32mEnter the number of treatments \033[0m"))
    nTreatment  <- as.numeric(readline())
    if(nTreatment != 0){
      hTreatment<-NULL
      pTreatment<-NULL
      nlevels_Treatment<-NULL
      cat("\n")
      for(n in 1:nTreatment){
      cat("\033[32m", paste("Enter the name of Treatment ", n, sep = " "), "\033[0m\n")
      hTreatment[n] <- readline()
      while (!hTreatment[n]%in%colnames(data)==TRUE) {
        cat(sprintf("%s ", "\033[32mTreatment not found. Please check that spelling is correct \033[0m"))
        cat("\n")
        cat("\033[32m", paste("Enter the name of Treatment ", n, sep = " "), "\033[0m\n")
          hTreatment[n] <- readline()
        }
        pTreatment[n] <- which(colnames(data)== hTreatment[n])
        data[,pTreatment[n]]<-as.factor(data[[pTreatment[n]]])
        # Check if there are missing values in the treatment column
        if (any(is.na(data[[pTreatment[n]]]))) {
          stop(sprintf("Error: Missing values found in treatment effect '%s'. Missing values in treatment effects are not supported.", hTreatment[n]))
        }
        nlevels_Treatment[n] <-nlevels(data[[pTreatment[n]]])
        cat("\033[32m", paste("The number of levels read in Treatment ", hTreatment[n], "are: ",nlevels_Treatment[n],sep = " "), "\033[0m\n")
      }

      cat(sprintf("%s ", "\033[32mComparisons between treatment levels:   (Enter DIFFERENCE=D or RATIO=R) \033[0m"))
      askCompare <- readline()
      while((askCompare!= "d") && (askCompare!= "D") && (askCompare!= "R") && (askCompare!= "r") ==TRUE){
        cat(sprintf("%s ", "\033[32mWeird response, try again! \033[0m"))
        cat("\n")
        cat(sprintf("%s ", "\033[32mComparisons between treatment levels:   (Enter DIFFERENCE=D or RATIO=R) \033[0m"))
        askCompare <- readline()}

    } else {
      hTreatment <- character(0)
      pTreatment <- numeric(0)
      nTreatment <-0
      askCompare<-"D"
      nlevels_Treatment <-0
      cat(sprintf("%s ", "\033[32mNote: No Treatment effects specified \033[0m"))
      cat("\n")
    } # End Treatments


    # 3) Noise effects (optional)
    cat("\033[32m", "Help: the header of the datafile is", paste(colnames(data), collapse = ", "), "\033[0m\n")
    cat("\n")
    cat(sprintf("%s ", "\033[32mEnter the number of noise effects \033[0m"))
    nNoise      <- as.numeric(readline())
    if(nNoise != 0){
      hNoise<-NULL
      pNoise<-NULL
      nlevels_Noise<-NULL
      for(n in 1:nNoise){
        cat("\033[32m", paste("Enter the name of the Noise effect ", n, sep = " "), "\033[0m\n")
        hNoise[n] <-readline()
        while (!hNoise[n]%in%colnames(data)==TRUE) {
          cat(sprintf("%s ", "\033[32mNoise effect not found. Please check that spelling is correct \033[0m"))
          cat("\n")
          cat("\033[32m", paste("Enter the name of the Noise effect ", n, sep = " "), "\033[0m\n")
          hNoise[n] <-readline()
        }
        pNoise[n] <- which(colnames(data)== hNoise[n])
        data[,pNoise[n]]<-as.factor(data[[pNoise[n]]])
        # Check if there are missing values in the noise column
        if (any(is.na(data[[pNoise[n]]]))) {
          stop(sprintf("Error: Missing values found in noise effect '%s'. Missing values in noise effects are not supported.", hNoise[n]))
        }
        nlevels_Noise[n] <-nlevels(data[[pNoise[n]]])
        cat("\033[32m", paste("The number of levels read in Noise ", hNoise[n],"are: ",nlevels_Noise[n], sep = " "), "\033[0m\n")
      }

    } else {
      hNoise <- character(0)
      pNoise <- numeric(0)
      nNoise <- 0
      nlevels_Noise <-0
      cat("\n")
      cat(sprintf("%s ", "\033[32mNote: No noise effects specified \033[0m"))
      cat("\n")
    } # End Noise


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
          cat("\n")
          cat(sprintf("%s ", "\033[32mContingency Tables across effects \033[0m"))
          cat("\n")
          print(paste(colnames(FE)[m],colnames(FE)[j], sep=" vs "))
          print(table(FE[,m],FE[,j])) }
      }
     } else {
      cat("\n")
      cat(sprintf("%s ", "\033[32mContingency tables cannot be created because there is none or only 1 effect \033[0m"))}
      cat("\n")

       # 4) Covariates (optional)
      cat("\033[32m", "Help: the header of the datafile is", paste(colnames(data), collapse = ", "), "\033[0m\n")
      cat("\n")
      cat(sprintf("%s ", "\033[32mEnter the number of covariates (0,1,2,...) \033[0m"))
      nCov <- as.numeric(readline())
        if(nCov != 0){
          hCov<-NULL
          pCov<-NULL
          cat("\n")
          for (n in 1:nCov){
            cat("\033[32m", paste("Enter the name of Covariate ", n, sep = " "), "\033[0m\n")
            hCov[n] <-  readline()
            while (!hCov[n]%in%colnames(data)==TRUE) {
              cat(sprintf("%s ", "\033[32mCovariate not found. Please check that spelling is correct \033[0m"))
              cat("\n")
              cat("\033[32m", paste("Enter the name of Covariate ", n, sep = " "), "\033[0m\n")
              hCov[n] <-  readline()
            }
            pCov[n] <- which(colnames(data)== hCov[n])
          }

        # Display descriptive stats of covariates
        if(nCov != 0){
          cat("\n")
          cat("\033[32m", paste("See below the summary statitics of covariates: ", hCov, sep = " "), "\033[0m\n")
          cat("\n")
          summary_stats <- sapply(data[, pCov, drop=FALSE], customSummary)
          summary_df <- as.data.frame(t(summary_stats))
          print(kable(summary_df, format = "simple", caption = "Summary Statistics of Covariates"))
          cat("\n")
          }
        } else {
          # When both hCov and pCov are NULL
          hCov <- character(0)
          pCov <- numeric(0)
          nCov <- 0
          cat("\n")
          cat(sprintf("%s ", "\033[32mNote: No covariates specified \033[0m"))
          cat("\n")
        } #End Cov

        # 5) Interactions (optional)
        cat(sprintf("%s ", "\033[32mDo you want to consider any interactions of order 2 ? (Enter Yes=Y or No=N)  \033[0m"))
        askInterFix <- readline()

        while((askInterFix!= "y") && (askInterFix!= "n") && (askInterFix!= "Y") && (askInterFix!= "N") ==TRUE){
          cat(sprintf("%s ", "\033[32mWeird response, try again! \033[0m"))
          cat("\n")
          cat(sprintf("%s ", "\033[32mDo you want to consider any interactions of order 2 ?  (Enter Yes=Y or No=N) \033[0m"))
          askInterFix <- readline()}

        if ((askInterFix=="Y") | (askInterFix == "y")){
          cat(sprintf("%s ", "\033[32mHow many interactions do you want to consider? \033[0m"))
          nInter <- as.numeric(readline())
          hInter <-matrix(ncol=2, nrow=nInter)
          pInter <-matrix(ncol=2, nrow=nInter)
          typeInter<-matrix(ncol=2, nrow=nInter)
          nlevels_Interaction<-NULL
          ShowInter<-NULL

          cat("\n")
          cat(sprintf("%s ", "\033[32mFor this package version, interactions can be considered only between fixed effects already declared as noise or treatments \033[0m"))
          cat("\n")
          for (n in 1:nInter){
            cat("\033[32m", paste("Let's define the Interaction ", n, sep = " "), "\033[0m\n")
            #First element
            cat("\033[32m", paste("Enter the name of the first effect to be considered in the interaction ", n, sep = " "), "\033[0m\n")
            hInter[n,1] <-readline()
            while (!hInter[n,1]%in%colnames(data)==TRUE) {
              cat(sprintf("%s ", "\033[32mEffect not found. Please check that spelling is correct \033[0m"))
              cat("\n")
              cat("\033[32m", paste("Enter the name of the first effect to be considered in the interaction ", n, sep = " "), "\033[0m\n")
              hInter[n,1] <-readline()
            }
            pInter[n,1] <-which(colnames(data)== hInter[n,1])

            # #If the element is still not used as Treatment, covariate or noise, ask which type of element it is
            # if (!(hInter[n,1] %in% c(hCov, hTreatment, hNoise))) {
            #   typeInter[n,1] <-readline(sprintf("%s\n",green(paste("Which type of variable is this effect (Enter Factor=F or Covariate=C) ? "))))
            # } else {
            #   if (hInter[n,1] %in% c(hTreatment, hNoise)){
            #     typeInter[n,1] <- "F"} else {typeInter[n,1] <- "C"}
            # }

            #Second element
            cat("\033[32m", paste("Enter the name of the second effect to be considered in the interaction ", n, sep = " "), "\033[0m\n")
            hInter[n,2] <-readline()

            while (!hInter[n,2]%in%colnames(data)==TRUE) {
              cat(sprintf("%s ", "\033[32mEffect not found. Please check that spelling is correct \033[0m"))
              cat("\n")
              cat("\033[32m", paste("Enter the name of the second effect to be considered in the interaction ", n, sep = " "), "\033[0m\n")
              hInter[n,1] <-readline()
            }
            pInter[n,2] <-which(colnames(data)== hInter[n,2])

            # #If the element is still not used as Treatment, covariate or noise, ask which type of element it is
            # if (!(hInter[n,2] %in% c(hCov, hTreatment, hNoise))) {
            #   typeInter[n,2] <-readline(sprintf("%s\n",green(paste("Which type of variable is this effect (Enter Factor=F or Covariate=C) ? "))))
            # } else {
            #   if (hInter[n,2] %in% c(hTreatment, hNoise)){
            #     typeInter[n,2] <- "F"} else {typeInter[n,2] <- "C"}
            # }

            nlevels_Interaction[n]<-nlevels(as.factor(data[[pInter[n,1]]]))*nlevels(as.factor(data[[pInter[n,2]]]))
            cat("\033[32m", paste("The number of levels for Interaction ", n," is: ", nlevels_Interaction[n], sep = " "), "\033[0m\n")
            cat("\n")

            #Ask whether Interaction should be consider as noise or as treatment
            cat(sprintf("%s ", "\033[32mDo you want to consider this interaction as Treatment or Noise ? (Enter Treatment=T or Noise=N) \033[0m"))
            ShowInter[n] <-readline()

          }}else{
            nInter <-0
            hInter <- character(0)
            pInter <- numeric(0)
            nlevels_Interaction <-0
            typeInter<-0
            ShowInter<-0
            cat("\n")
            cat(sprintf("%s ", "\033[32mNote: No interaction effects specified \033[0m"))
            cat("\n")
            }

        # 6) Random Effects (optional)
        cat("\033[32m", "Help: the header of the datafile is", paste(colnames(data), collapse = ", "), "\033[0m\n")
        cat("\n")
        cat(sprintf("%s ", "\033[32mEnter the number of random effects \033[0m"))
        nRand <- as.numeric(readline())
        if(nRand != 0){
          hRand<-NULL
          pRand<-NULL
          cat("\n")
          for (n in 1:nRand){
            cat("\033[32m", paste("Enter the name of the random effect ", n, sep = " "), "\033[0m\n")
            hRand[n] <- readline()
            while (!hRand[n]%in%colnames(data)==TRUE) {
              cat(sprintf("%s ", "\033[32mRandom effect not found. Please check that spelling is correct \033[0m"))
              cat("\n")
              cat("\033[32m", paste("Enter the name of the random effect ", n, sep = " "), "\033[0m\n")
              hRand[n] <- readline()
            }
            pRand[n] <- which(colnames(data)== hRand[n])
          }
        } else {
          # When both hRand and pRand are NULL
          hRand <- character(0)
          pRand <- numeric(0)
          nRand <- 0
          cat("\n")
          cat(sprintf("%s ", "\033[32mNote: No random effects specified \033[0m"))
          cat("\n")
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
            eq.I <- paste(hInter[1, ], collapse = ":")
          } else {
            # Apply for matrices with more than one row
            eq.I <- apply(hInter, 1, function(x) paste(x, collapse = ":"))
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
        cat("\n")
        cat("\033[32m", paste("Model equation for all Traits is : \033[31my = mean + ", eq.name, sep = ""), "\033[0m\n")
        cat("\n")

        # Define MCMC features
          cat(sprintf("%s ", "\033[32mDo you want to establish the MCMC characteristics ? (Enter Yes=Y or No=N) \033[0m"))
          askMCMC     <- readline()
          while((askMCMC!= "y") && (askMCMC!= "Y") && (askMCMC!= "n") && (askMCMC!= "N") ==TRUE){
            cat(sprintf("%s ", "\033[32mWeird response, try again! \033[0m"))
            cat("\n")
            cat(sprintf("%s ", "\033[32mDo you want to establish the MCMC characteristics ? (Enter Yes=Y or No=N) \033[0m"))
            askMCMC     <- readline()
            }

          if (askMCMC =="Y" | askMCMC =="y") {
            cat(sprintf("%s ", "\033[32mPlease enter a random seed \033[0m"))
            Seed   <- as.numeric(readline())
            cat(sprintf("%s ", "\033[32mEnter the chain length \033[0m"))
            iter   <- as.numeric(readline())
            cat(sprintf("%s ", "\033[32mEnter the burn-in \033[0m"))
            burnin <- as.numeric(readline())
            cat(sprintf("%s ", "\033[32mEnter the lag between samples \033[0m"))
            lag    <- as.numeric(readline())
          } else { #Default parameters
            Seed = 1234
            iter = 30000
            burnin = 5000
            lag = 10
          }


## Create a list with all the outputs  ------------------------------------------------------------------

          param_list <- list()
          param_list[["file.name"]] <- file.name
          #param_list[["Missing"]] <- Missing
          if(Missing == "Y"| Missing == "y"){
          param_list[["na.codes"]] <- na.codes}

          param_list[["ri"]] <- ri
          param_list[["nTrait"]] <- nTrait
          param_list[["hTrait"]] <- hTrait
          param_list[["pTrait"]] <- pTrait

          param_list[["nTreatment"]] <-nTreatment
          param_list[["hTreatment"]] <-hTreatment
          param_list[["pTreatment"]] <-pTreatment
          param_list[["nlevels_Treatment"]] <-nlevels_Treatment
          param_list[["askCompare"]] <-askCompare

          param_list[["nNoise"]]<- nNoise
          param_list[["hNoise"]]<- hNoise
          param_list[["pNoise"]]<- pNoise
          param_list[["nlevels_Noise"]]<-nlevels_Noise

          param_list[["nCov"]] <- nCov
          param_list[["hCov"]] <- hCov
          param_list[["pCov"]] <- pCov

          param_list[["nRand"]] <- nRand
          param_list[["hRand"]] <- hRand
          param_list[["pRand"]] <- pRand

          param_list[["nInter"]] <- nInter
          param_list[["hInter"]] <- hInter
          param_list[["pInter"]] <- pInter
          param_list[["typeInter"]] <- typeInter
          param_list[["nlevels_Interaction"]] <- nlevels_Interaction
          param_list[["ShowInter"]] <- ShowInter
          #param_list[["eq.total"]] <- eq.total
          param_list[["eq.name"]] <- eq.name
          param_list[["Seed"]]   <- Seed
          param_list[["iter"]]   <- iter
          param_list[["burnin"]] <- burnin
          param_list[["lag"]]    <- lag

        #Return the list
        cat(sprintf("%s ", "\033[32mYour parameter file its ready! \033[0m"))
        invisible(param_list)

} # End of function
