% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RNAdicercall.R
\name{RNAdicercall}
\alias{RNAdicercall}
\title{Define the consensus dicercall for each sRNA cluster}
\usage{
RNAdicercall(
  data,
  conditions = NULL,
  ties.method = NULL,
  tidy = FALSE,
  chimeric = FALSE,
  controls = NULL,
  genome.ID = NULL
)
}
\arguments{
\item{data}{data.frame; originally generated by \code{\link[=RNAimport]{RNAimport()}}.}

\item{conditions}{character; vector containing sample replicate names. When
supplied, the data from the named replicates will be the only ones used to
calculate the dicercall consensus for each sRNA cluster. Each
string should represent a sample name present in the dataframe supplied to
the \code{data} argument.}

\item{ties.method}{character; string specifying how ties are handled, choose
either "exclude" or "random". When using \code{random}, if there is a tie one of
the classes will be chosen at random. While, when using \code{exclude} if there is
a tie the class is set to undefined, however, if there is a tie between a
undefined and a known class, the known class takes president (eg 3x24-nt and
3xN-nt, then it will be classed as 24nt). Default setting
\code{ties.method="exclude"}.}

\item{tidy}{logical; tidy-up data by removing sRNA clusters with an unknown
or unclassified result. Default setting \code{tidy=FALSE}, removes excess
background noise.}

\item{chimeric}{logical; state whether the system is chimeric and contains
multiple genomes/genotypes.}

\item{controls}{character; vector of control condition sample names.}

\item{genome.ID}{character; chromosome identifier of the genome representing
either the origin of mobile molecules or the other genome in the chimeric
system.}
}
\value{
The original input data with two additional columns appended known as
\code{DicerCounts} and \code{DicerConsensus}. The \code{DicerCounts} column stores the number
of replicates that contributed to defining the consensus dicer-derived sRNA
class. Note that when utilising the \code{exclude} ties methods, the \code{DicerCounts}
will be represented as 0 when a tie is identified. While, the \code{DicerConsensus}
stores the consensus dicercall.
}
\description{
The sRNA dicercall represents the length in nucleotides of the
most abundant sRNA sequence within a cluster. The function calculates the
consensus dicercall classification.
}
\details{
For each sample, the alignment/clustering step predicted the sRNA
dicercall for each cluster. This value is stored in the columns starting
with "DicerCall_".  This value represents the length of nucleotides of
the most abundant sRNA within the cluster. For some clusters, there is no
particular sRNA which is more abundant than another, hence, it is stated as
"NA" or "N", which is referred to as unclassified. The \code{RNAdicercall()}
function calculate the consensus dicercall for each sRNA cluster based on
the values across replicates. There are several parameters which will alter
the output, including the handling of ties and the method to draw the
consensus from.

When ties.method = "random", as per default, ties are broken at random.
In this case, the determination of a tie assumes that the entries are
probabilities: there is a relative tolerance of 1e-5, relative to the
largest (in magnitude, omitting infinity) entry in the row.

When ties.method = "exclude", ties between sRNA classification are ruled as
unclassified ("N"). However, when there is a tie between the choice of a
class or unclassified result the \code{exclude} option will always select the
class choice over the unclassified result.

If users are working with a chimeric system, utilise the \code{chimeric=TRUE}
parameter and state \code{genome.ID} and \code{controls} parameter variables. This will
remove any potential mapping errors which could introduce false interpretation.

To remove excess data noise, \code{tidy=TRUE} can be used to removed unclassified
("N") sRNA clusters, resulting in a reduced data set size.
}
\examples{
 # load data 
 data("sRNA_data")

# define consensus sRNA classes.
conditions <- c("heterograft_1", "heterograft_2", "heterograft_3")

# Run function to define sRNA class for each cluster.
sRNA_data_dicercall <- RNAdicercall(data = sRNA_data,
                                  conditions = conditions,
                                  tidy=TRUE)

}
