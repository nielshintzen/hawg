setClass("FLSAM.control",
	representation(
    range	          ="numeric",   ## minimum and miximum age represented internally in the assessment
    plus.group      ="logical",   ## should we model the maximum age as a plus group or not?
    states          ="matrix",   ## matrix describing the coupling of the states
    logN.vars           ="vector",   ## vector of coupling of the logN variables
    catchabilities  ="matrix",   ## matrix characterising the coupling of the catachability parameters
    power.law.exps  ="matrix",   ## matrix characterising the coupling of the power law expoonents
    f.vars          ="matrix",   ## matrix of fishing mortality couplings

    obs.vars        ="matrix",   ## matrix coupling the observation variances
    srr             ="integer"),    ## stock recruitment relationship
	prototype=prototype(
    range	          =as.numeric(1),   ## minimum age represented internally in the assessment
    plus.group      =as.logical(TRUE),   ## should we model the maximum age as a plus group or not?
		states          =as.matrix(0),   ## matrix describing the coupling of the states
    logN.vars           =as.vector(0),   ## vector of coupling of the logN variables
    catchabilities  =as.matrix(0),   ## matrix characterising the coupling of the parameters
    power.law.exps  =as.matrix(0),   ## matrix of survey catchabilities
    f.vars          =as.matrix(0),   ## matrix of fishing mortality couplings

    obs.vars        =as.matrix(0),   ## matrix coupling the observation variances
    srr             =as.integer(0)),    ## stock recruitment relationship
	validity=function(object){
                	if (any(object@lambda.age < 0))
                		return("weights must be > 0")
                	if (any(object@lambda.yr < 0))
                		return("value of rage must be >= -1")
                	if (object@lambda.sr < 0)
                		return("SR weight must be >= 0")
                	if (!is.na(object@sr.age))
                  	if (object@sr.age < 0)
                	   	return("sr.age must be >= 0")

                	# Everything is fine
                	return(TRUE)}
)



FLSAM.control <- function(stck,tun) {
  #Default constructor
  #Create object
  ctrl <- new("FLSAM.control")

  #Populate metadata
  ctrl@range <- stck@range[c("min","max","minfbar","maxfbar")]
  ctrl@plus.group <- stck@range["plusgroup"]==stck@range["max"]
  
  #Setup coupling structures
  default.coupling <- matrix(as.integer(NA),nrow=1+length(tun),ncol=dims(stck)$age,
                        dimnames=list(c("catch",names(tun)),dimnames(stck@catch.n)$age))
  ctrl@states           <- default.coupling
  ctrl@catchabilities   <- default.coupling
  ctrl@power.law.exps   <- default.coupling
  ctrl@f.vars           <- default.coupling
  ctrl@obs.vars         <- default.coupling

  #Other variables
  ctrl@logN.vars            <- default.coupling[1,]
  ctrl@srr <- as.integer(0)

  #Finished!
  return(ctrl)
}