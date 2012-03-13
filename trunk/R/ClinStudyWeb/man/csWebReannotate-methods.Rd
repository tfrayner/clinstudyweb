\name{csWebReannotate-methods}
\docType{methods}
\alias{csWebReannotate-methods}
\alias{csWebReannotate,AffyBatch-method}
\alias{csWebReannotate,ExpressionSet-method}
\alias{csWebReannotate,ExonFeatureSet-method}
\alias{csWebReannotate,GeneFeatureSet-method}
\alias{csWebReannotate,RGList-method}
\alias{csWebReannotate,MAList-method}

\title{ Reannotate a data object using the ClinStudyWeb database }
\description{

  Given a data object from one of the supported classes, replace the
  object sample annotation data frame with a new data set extracted from
  the database.

}
\section{Methods}{
  \describe{

    \item{data = "AffyBatch"}{ When passed an AffyBatch object, this
      method will replace the pData slot with an updated annotation data
      frame. The data sampleNames() must correspond to the original CEL
      file names.}

    \item{data = "ExpressionSet"}{ When passed an ExpressionSet object, this
      method will replace the pData slot with an updated annotation data
      frame. The data sampleNames() must correspond to the original CEL
      file names.}

    \item{data = "GeneFeatureSet"}{ When passed an GeneFeatureSet object, this
      method will replace the pData slot with an updated annotation data
      frame. The data sampleNames() must correspond to the original CEL
      file names.}

    \item{data = "ExonFeatureSet"}{ When passed an ExonFeatureSet object, this
      method will replace the pData slot with an updated annotation data
      frame. The data sampleNames() must correspond to the original CEL
      file names.}

    \item{data = "RGList"}{ The targets attribute of the supplied RGList
      will be replaced with an updated targets data frame. The input
      RGList object must contain a valid RGList$targets$FileName listing. }

    \item{data = "MAList"}{ The targets attribute of the supplied MAList
      will be replaced with an updated targets data frame. The input
      MAList object must contain a valid MAList$targets$FileName listing. }

  }
}
\keyword{methods}
