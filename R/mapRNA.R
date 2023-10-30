#' Pre-processing of sRNAseq and mRNAseq (Alignment, raw count, cluster analysis)
#'
#' @description For the mobileRNA workflow, undertakes pre-processing of clean
#' sequencing reads. For sRNAseq, undertakes alignment with Bowtie and sRNA 
#' cluster analysis with ShortStack. For mRNAseq, undertakes alignment with 
#' HISAT2 and HTSeq. All OS software should be installed within a Conda 
#' environment. 
#' 
#' @details
#' Please ensure all OS software is installed within a Conda environment. 
#' See appendix of vignette for manual pipeline. Alignment statistics are 
#' reported for each analysis. 
#' 
#' ** For sRNA analysis** 
#' The function invokes a number of OS commands, and is dependent 
#' on the installation of `ShortStack` (>= 4.0) with Conda.  Please refer to 
#' \link{https://github.com/MikeAxtell/ShortStack} for more information. Please 
#' note that `ShortStack` is only compatible with Linux and Mac operating 
#' systems. 
#' 
#' The pipeline undertakes de novo detection of sRNA-producing loci and
#' alignment, where the output of each are stored in their respective folders in 
#' the users desired location. The de novo detection of sRNA-producing loci
#' analyses each sample to identify de novo sRNA-producing loci (ie. sRNA
#' clusters), and joins these results into a single file called "locifile.txt". 
#' The alignment step aligns and clusters each sample to the genome reference
#' along with the file containing the de novo sRNA clusters. The final reports
#' are imported into R using [RNAimport()].
#' 
#' ** For mRNA analysis** 
#' The function invokes a number of OS commands, and is dependent 
#' on the installation of `HISAT2`,  `HTSeq` and `SAMtools` with Conda. Please 
#' refer to \link{https://anaconda.org/bioconda/hisat2}, 
#' \link{https://anaconda.org/bioconda/htseq} and 
#' \link{https://anaconda.org/bioconda/samtools} for more information. 
#' 
#' The pipeline can undertake single- or pair-end analysis, and do to do so 
#' requires a data frame stating the sample information where each row 
#' represents a sample. The cleaned reads are mapped using HISAT and then the 
#' raw counts are estimated by HTSeq.
#' 
#' 
#' @references ShortStack \link{https://github.com/MikeAxtell/ShortStack}
#' HISAT2 \link{https://anaconda.org/bioconda/hisat2}
#' HTSeq \link{https://anaconda.org/bioconda/htseq} 
#' SAMtools \link{https://anaconda.org/bioconda/samtools}
#' @param input_files_dir path; directory containing only the FASTQ sRNAseq 
#' samples for analysis. Note that all samples in this directory will be used by 
#' this function. 
#' @param condaenv character; name or directory of the Conda environment to use
#' where `ShortStack` (>4.0) is installed for sRNA analysis or `HISAT` & `HTSeq`
#' for mRNA analysis. 
#' 
#' @param output_dir path; directory to store output. 
#' @param genomefile path; path to a FASTA file. 
#' @param threads numeric; set the number of threads to use where more threads 
#' means a faster completion time. Default is 6. 
#' 
#' @param mmap character; define how to handle multi-mapped reads. Choose from 
#' "u", "f" or "r" or "n". For core sRNA analysis, use either "u", "f" or "r" 
#' options. Where "u" means only uniquely-aligned reads are used as 
#' weights for placement of multi-mapped reads. Where "f" means fractional 
#' weighting scheme for placement of multi-mapped reads and "r" mean 
#' multi-mapped read placement is random. While for mobile sRNAseq, it is 
#' important to use "n", to not consider multi-mapped reads, only unique reads 
#' as we cannot distinguish which genome the reads mapped to multiple locations
#' in. 
#' 
#' @param dicermin integer; the minimum size in nucleotides of a valid small 
#' RNA. This option sets the bounds to discriminate dicer-derived small RNA loci 
#' from other loci. Default is 20. For sRNA analysis only. 
#' @param dicermax integer; the maximum size in nucleotides of a valid small 
#' RNA. This option sets the bounds to discriminate dicer-derived small RNA loci 
#' from other loci.  Default is 24.For sRNA analysis only. 
#' 
#' @param mincov numeric; minimum alignment depth, in units of reads per 
#' million, required to nucleate a small RNA cluster during de novo cluster 
#' search. Must be an floating point number > 0. Default is 2. For sRNA analysis 
#' only. 
#' 
#' @param pad integer; initial peaks are merged if they are this distance or 
#' less from each other. Must >= 1, default is 75. For sRNA analysis only. 
#' @param tidy logical; removes unnecessary extra output files when set to TRUE. 
#' 
#' @param sampleData dataframe; stores mRNA sample data where rows represent 
#' each sample in the analysis. Column one stores the sample names, while column
#' two stores the the name(s) of the fastq file(s) for mate 1 (e.g. flyA_1.fq,
#' flyB_1.fq) and column three stores the the name(s) of the fastq file(s) for 
#' mate 2 (e.g. flyA_2.fq,flyB_2.fq). If data is single ended, column three 
#' will not hold any values. Only for mRNA analysis.  
#' 
#'  
#' @param annotationfile path; path to a GFF file. Only for mRNA analysis.  
#'  For mRNA analysis only. 
#' @param order character; either "name" or "pos" to indicate how the input data
#' has been sorted. For paired-end data only, this sorts the data either by 
#' read name or by alignment position. Default is "pos", to sort by position. 
#'  For mRNA analysis only. 
#' @param stranded whether the data is from a strand-specific assay, either 
#' "yes"/"no"/"reverse". Default is "no".  For mRNA analysis only. 
#'
#' @param mode character; states mode to handle reads overlapping more than one 
#' feature. Either "union", "intersection-strict" and "intersection-nonempty".
#' Default is "union". For mRNA analysis only. 
#' 
#' @param type character; feature type (3rd column in GFF file) to be used, 
#' all features of other type are ignored. Default is "mRNA". 
#' 
#' @param idattr character; GFF attribute to be used as feature ID. Several GFF 
#' lines with the same feature ID will be considered as parts of the same 
#' feature. The feature ID is used to identity the counts in the output table. 
#' Default is "Name". 
#' 
#' @param nonunique character; states the mode to handle reads that align to or
#'  are assigned to more than one feature in the overlap. Either "none" and 
#'  "all". Default is "none". For mobile mRNA, ensure the default is utilized to 
#'  exclude multimapped reads. 
#'  
#'  
#' @return
#' 
#' ** For sRNA analysis**
#' The OS commands generate output into the users desired location, generating
#' two folders:
#' 
#' * "1_de_novo_detection" : Stores output from the detection of de novo sRNA-producing loci
#' * "2_alignment_results" : Stores output from alignment 
#' 
#' 
#' The first folder stores the novo detection of sRNA-producing loci and
#' alignment, where the output of each are stored in their respective folders in 
#' the users desired location. The de novo detection of sRNA-producing loci
#' analyses each sample to identify de novo sRNA-producing loci (ie. sRNA
#' clusters), and joins these results into a single file called "locifile.txt". 
#' The second folder stores the alignment and clustering results for each sample 
#' to the genome reference along with the file containing the de novo sRNA 
#' clusters. The output of each sample is stored within its own sample folder. 
#' 
#' The alignment results generate one folder per sample, where the results 
#' are stored. As default this includes the alignment files (BAM) and 
#' sRNA results (.txt). The sRNA results (.txt) are imported into R for 
#' downstream analysis by utilizing the [mobileRNA::RNAimport()] function. 
#' 
#' The function generates a number of extra files for each sample and are not 
#' required for the downstream analysis. See `ShortStack` documentation for more
#' information (\link{https://github.com/MikeAxtell/ShortStack}). As default
#' these files are deleted. This is determined by the `tidy` argument. 
#' 
#' ** For mRNA analysis**
#' For mRNA analysis, generate a new folder which stores the results in the 
#' users desired output location, known as "1_mRNA_preprocessing". Within this
#' folder, there will contain one folder per sample storing it's sorted 
#' alignment file (BAM) and raw counts file ("Result.txt"). Note, that the 
#' function excludes multi-mapped mRNAs. 
#' 
#' 
#' @examples \dontrun{
#' 
#' samples <- file.path(system.file("extdata",package="mobileRNA"))
#' 
#' output_location <- tempdir()
#' 
#' mapRNA(input = "sRNA", 
#' input_files_dir = samples, 
#' output_dir = output_location, 
#' genomefile = output_assembly_file,
#' condaenv = "ShortStack4", 
#' mmap = "n".)
#' }
#' 
#' @importFrom reticulate "use_condaenv" 
#' @importFrom GenomicRanges GRangesList
#' @importFrom Repitools annoGR2DF
#' @importFrom rtracklayer import.gff
#' @importFrom GenomicRanges reduce
#' @importFrom utils write.table
#' 
#' @export
mapRNA <- function(input = c("mRNA", "sRNA"), 
                   sampleData = NULL, 
                       input_files_dir, 
                       output_dir, 
                       genomefile, 
                       annotationfile=NULL,
                       condaenv,
                       threads = 6, 
                       mmap = "n", 
                       dicermin = 20,
                       dicermax = 24, 
                       mincov = 0.5, 
                       pad = 200,
                       order = pos,
                       stranded = no,
                       mode = union,
                       nonunique = none,
                       type = mRNA,
                       idattr=Name, 
                       tidy = TRUE){
  # check inputs 
  if (base::missing(input) || !input %in% c("sRNA", "mRNA")) {
    stop("Please state the data-type to the `input` paramter.")
  }
  if (base::missing(input_files_dir)) {
    stop("Please specify an accessable directory where files are stored")
  }
  # check it only contains fq 
  files <- list.files(input_files_dir)
  fastq_files <- files[grep("\\.(fq|fastq)$", files)]
  other_files <- files[!grepl("\\.(fq|fastq)$", files)]
  if (!length(other_files) == 0) {
    stop("input_files_dir location either does not store any fastq files or it 
 contain additional file types. This location must only contain fastq files.")
  }

  if (missing(genomefile) || !file.exists(genomefile) || 
      !grepl("\\.fa$", genomefile)) {
    stop("Please specify genomefile, a connection to a FASTA file in local")
  }
  
  if (missing(output_dir) || !file.exists(output_dir)) {
    stop("Please specify a location to save output")
  }
  
  
  # 1 - Verify that the OS is either Linux or macOS
  os <- tolower(Sys.info()[['sysname']])
  if (os != "linux" && os != "darwin") {
    stop("ShortStack can only run on Linux or macOS.")
  }
  # set conda envrioment of shortstack
  reticulate::use_condaenv(condaenv, required = TRUE)   
  t <- reticulate::py_config()
  exists_res <- t$prefix
  if(exists_res != condaenv){
    stop("R has not connected to the conda environment")
  }
  
  if(input == "sRNA"){
    exists_res2 <- shortstack_exists()
    if(exists_res2 < 4 | is.null(exists_res2)){
      stop("ShortStack application :
    --- ShortStack is either not installed or installed incorrectly
    --- Or the version is too old, please ensure most updated version is installed.")
    }
    if(mmap != "n"){
      core_map(input_files_dir, 
               output_dir,
               genomefile, 
               condaenv, 
               threads,
               mmap,
               dicermin,
               dicermax,
               mincov,
               pad,
               tidy)
    } else {
      mobile_map(input_files_dir, 
                 output_dir,
                 genomefile, 
                 condaenv, 
                 threads,
                 mmap,
                 dicermin,
                 dicermax,
                 mincov,
                 pad,
                 tidy)
    }
  } else 
    if(input == "mRNA"){
      if (base::missing(sampleData) || !base::inherits(sampleData,
                                                       c("matrix","data.frame", 
                                                         "DataFrame"))) {
        stop("sampleData must be an object of class matrix, data.frame, DataFrame.
          See ?plotHeatmap for more information.")
      }
      
      if (missing(annotationfile) || !file.exists(annotationfile) || 
          !grepl("\\.(gff|gff1|gff2|gff3)$",annotationfile)) {
        stop("Please specify genomefile, a connection to a FASTA file in local")
      }
      exists_res_hisat <- exists_conda("hisat2")
      if(exists_res_hisat == FALSE){
        stop("HISAT2 application :
    --- HISAT2 is not installed within conda environment.")
      }
      
      exists_res_htseq <- exists_conda("htseq")
      if(exists_res_htseq == FALSE){
        stop("HTSeq application :
    --- HTSeq is not installed within conda environment.")
      }
      
      exists_res_samtools <- exists_conda("samtools")
      if(exists_res_samtools == FALSE){
        stop("SAMtools application :
    --- SAMtools is not installed within conda environment.")
      }
      mRNA_map(sampleData,
               input_files_dir, 
               output_dir,
               genomefile, 
               annotationfile,
               condaenv,
               threads,  
               order ,
               stranded,
               mode,
               nonunique,
               type,
               idattr)

    }
}