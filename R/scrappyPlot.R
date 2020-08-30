
#' Make a scrappy plot
#'
#' Scrappy plot uses the percentage of mitochondrial gene expression to plot the single-cell data as emojis
#' corresponding to their quality score in a low dimensional reductions.
#'
#' @param object Single cell object. Scrappy recognizes \code{\link{SingleCellExperiment}} objects or \code{\link{Seurat}} objects
#' @param great_qual Percentage of mitochondrial gene expression for a cell to be considered great quality (smaller than).
#' @param good_qual Percentage of mitochondrial gene expression for a cell to be considered good quality (smaller than).
#' @param ok_qual Percentage of mitochondrial gene expression for a cell to be considered ok quality (smaller than). Any other percentage above is considered poop quality.
#' @param dimred dimension reductions object to be accessed.
#'
#' @return
#' @export
#'
#' @examples
#'
#' @importFrom SummarizedExperiment colData
#' @importFrom SingleCellExperiment reducedDim
#' @importFrom Seurat Embeddings
#' @importFrom ggplot2 ggplot aes theme_classic
#' @importFrom ggimage geom_image
#' @importFrom dplyr case_when
scrappyPlot <- function(object,
                        dimred,
                        great_qual = 5,
                        good_qual = 10,
                        ok_qual = 15) {

  ###############################
  ## SingleCellExperiment wrapper
  ###############################

  if(class(object) == "SingleCellExperiment") {

    # extract reduced dimension
    red_dim <- reducedDim(object,
                          dimred)

    # pull the mitochondrial percentage
    meta <- colData(object)$subsets_Mito_percent

  }

  ###############################
  ## Seurat wrapper
  ###############################

  if (class(object) == "Seurat") {

    meta <- object[["percent.mt"]]$percent.mt

    red_dim <- Embeddings(object,
                          dimred)

  }

  red_dim <- as.data.frame(red_dim)

  colnames(red_dim) <- c("dim1",
                         "dim2")

  # classify into emojis
  red_dim$emoji <- case_when(meta >= 0 & meta <= great_qual ~ "img/smile.png",
                             meta > great_qual & meta <= good_qual ~ "img/slightly_smile.png",
                             meta > good_qual & meta <= ok_qual ~ "img/nauseated.png",
                             meta > ok_qual ~ "img/tpoop.png",)

  # plotting
  ggplot(red_dim, aes(x = dim1,
                      y = dim2)) +
    geom_image(aes(image = emoji), size = .03) +
    theme_classic()

}

