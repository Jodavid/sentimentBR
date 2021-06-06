#' Creates an object of class \code{DocumentTermMatrix} from \pkg{tm}.
#'
#' \code{create_matrix} creates a document-term matrix
#'
#' @param textColumns Either character vector (e.g. data$Title) or a \code{cbind()} of columns to use for training the algorithms (e.g. \code{cbind(data$Title,data$Subject)}).
#' @param language The language to be used for stemming the text data.
#' @param minDocFreq The minimum number of times a word should appear in a document for it to be included in the matrix. See package \pkg{tm} for more details.
#' @param minWordLength The  minimum number of letters a word should contain to be included in the matrix. See package \pkg{tm} for more details.
#' @param removeNumbers A \code{logical} parameter to specify whether to remove numbers.
#' @param removePunctuation A \code{logical} parameter to specify whether to remove punctuation.
#' @param removeSparseTerms See package \pkg{tm} for more details.
#' @param removeStopwords A \code{logical} parameter to specify whether to remove stopwords using the language specified in language.
#' @param stemWords A \code{logical} parameter to specify whether to stem words using the language specified in language.
#' @param stripWhitespace A \code{logical} parameter to specify whether to strip whitespace.
#' @param toLower A \code{logical} parameter to specify whether to make all text lowercase.
#' @param weighting Either \code{weightTf} or \code{weightTfIdf}. See package \pkg{tm} for more details.
#'
#' @author Timothy P. Jurka <tpjurka@@ucdavis.edu>
#'
#' @examples
#' # DEFINE THE DOCUMENTS
#'
#' documents <- c("I am very happy, excited, and optimistic.",
#' "I am very scared, annoyed, and irritated.",
#' "Iraq's political crisis entered its second week one step closer to the potential
#' dissolution of the government, with a call for elections by a vital coalition partner
#' and a suicide attack that extended the spate of violence that has followed the withdrawal
#' of U.S. troops.",
#' "With nightfall approaching, Los Angeles authorities are urging residents to keep their
#' outdoor lights on as police and fire officials try to catch the person or people responsible
#' for nearly 40 arson fires in the last three days.")
#' matrix <- create_matrix(documents, language="english", removeNumbers=TRUE,
#'                         stemWords=FALSE, weighting=weightTfIdf)
#'
create_matrix <- function(textColumns, language="english", minDocFreq=1, minWordLength=3, removeNumbers=TRUE, removePunctuation=TRUE, removeSparseTerms=0, removeStopwords=TRUE, stemWords=FALSE, stripWhitespace=TRUE, toLower=TRUE, weighting=weightTf) {

    stem_words <- function(x) {
        split <- strsplit(x," ")
        return(wordStem(split[[1]],language=language))
    }

	control <- list(language=language,tolower=toLower,removeNumbers=removeNumbers,removePunctuation=removePunctuation,stripWhitespace=stripWhitespace,minWordLength=minWordLength,stopwords=removeStopwords,minDocFreq=minDocFreq,weighting=weighting)

    if (stemWords == TRUE) control <- append(control,list(stemming=stem_words),after=6)

    trainingColumn <- apply(as.matrix(textColumns),1,paste,collapse=" ")
    trainingColumn <- sapply(as.vector(trainingColumn,mode="character"),iconv,to="UTF8",sub="byte")

	corpus <- Corpus(VectorSource(trainingColumn),readerControl=list(language=language))
	matrix <- DocumentTermMatrix(corpus,control=control);
    if (removeSparseTerms > 0) matrix <- removeSparseTerms(matrix,removeSparseTerms)

	gc()
	return(matrix)
}
