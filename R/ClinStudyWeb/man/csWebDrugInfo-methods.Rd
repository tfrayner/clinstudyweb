\name{csWebDrugInfo-methods}
\docType{methods}
\alias{csWebDrugInfo-methods}
\alias{csWebDrugInfo,AffyBatch-method}
\alias{csWebDrugInfo,ExpressionSet-method}
\alias{csWebDrugInfo,ExonFeatureSet-method}
\alias{csWebDrugInfo,GeneFeatureSet-method}
\alias{csWebDrugInfo,RGList-method}
\alias{csWebDrugInfo,MAList-method}

\title{ Annotate a data object with drug information from the ClinStudyWeb database }
\description{

  Given a data object from one of the supported classes, append drug
  information to the object sample annotation data frame.

}
\section{Methods}{
  \describe{

    \item{data = "AffyBatch"}{ When passed an AffyBatch object, this
      method will add a new column to the pData data frame. The data
      sampleNames() must correspond to the original CEL file names.}

    \item{data = "ExpressionSet"}{ When passed an ExpressionSet object, this
      method will add a new column to the pData data frame. The data
      sampleNames() must correspond to the original CEL file names.}

    \item{data = "GeneFeatureSet"}{ When passed an GeneFeatureSet object, this
      method will add a new column to the pData data frame. The data
      sampleNames() must correspond to the original CEL file names.}

    \item{data = "ExonFeatureSet"}{ When passed an ExonFeatureSet object, this
      method will add a new column to the pData data frame. The data
      sampleNames() must correspond to the original CEL file names.}

    \item{data = "RGList"}{ Appends a new column to the data frame
      stored in the targets attribute of the supplied RGList. The input
      RGList object must contain a valid RGList$targets$FileName listing. }

    \item{data = "MAList"}{ Appends a new column to the data frame
      stored in the targets attribute of the supplied MAList. The input
      MAList object must contain a valid MAList$targets$FileName listing. }

  }
}
\keyword{methods}
