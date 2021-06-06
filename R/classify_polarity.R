#' classifies the polarity (e.g. positive or negative) of a set of texts.
#'
#' \code{classify_polarity} Classifies the polarity (e.g. positive or negative) of a set of texts using a naive Bayes classifier trained on Janyce Wiebe's \code{\link{subjectivity}} lexicon.
#'
#' @param textColumns A \code{data.frame} of text documents listed one per row.
#' @param algorithm A \code{string} indicating whether to use the naive \code{bayes} algorithm or a simple \code{voter} algorithm.
#' @param pstrong A \code{numeric} specifying the probability that a strongly subjective term appears in the given text.
#' @param pweak A \code{numeric} specifying the probability that a weakly subjective term appears in the given text.
#' @param prior A \code{numeric} specifying the prior probability to use for the naive Bayes classifier.
#' @param verbose A \code{logical} specifying whether to print detailed output regarding the classification process.
#' @param lang Language, "en" for English and "pt" for Brazilian Portuguese.
#' @param \dots Additional parameters to be passed into the \code{\link{create_matrix}} function.
#'
#' @return Returns an object of class \code{data.frame} with four columns and one row for each document.
#'        \item{pos}{The absolute log likelihood of the document expressing a positive sentiment.}
#'        \item{neg}{The absolute log likelihood of the document expressing a negative sentiment.}
#'        \item{pos/neg}{The ratio of absolute log likelihoods between positive and negative sentiment scores. A score of 1 indicates a neutral sentiment, less than 1 indicates a negative sentiment, and greater than 1 indicates a positive sentiment.}
#'        \item{best_fit}{The most likely sentiment category (e.g. positive, negative, neutral) for the given text.}
#'
#' @author Timothy P. Jurka <tpjurka@@ucdavis.edu> and
#'         Jodavid Ferreira <jdaf1@@de.ufpe.br>
#'
#'
#' @examples
#' # DEFINE DOCUMENTS
#' documents <- c("I am very happy, excited, and optimistic.",
#'                "I am very scared, annoyed, and irritated.")
#'
#' # CLASSIFY POLARITY
#  classify_polarity(documents,algorithm="bayes",verbose=TRUE, lang = "en")
#'
#'
classify_polarity <- function(textColumns,algorithm="bayes",pstrong=0.5,pweak=1.0,prior=1.0,verbose=FALSE,lang = "en",...) {
	matrix <- create_matrix(textColumns,...)

	if(lang == "en"){
	  lexicon <- read.csv(system.file("data/subjectivity.csv.gz",package="sentimentBR"),header=FALSE)
	  counts <- list(positive=length(which(lexicon[,3]=="positive")),negative=length(which(lexicon[,3]=="negative")),total=nrow(lexicon))
	}else if(lang == "pt"){
	  lexicon <- read.csv(system.file("data/subjectivitypt.csv.gz",package="sentimentBR"),header=FALSE)
	  counts <- list(positive=length(which(lexicon[,3]=="positive")),negative=length(which(lexicon[,3]=="negative")),total=nrow(lexicon))
	}

	# ----------------
	lexicon[,1] <- rm_accent(lexicon[,1])
	documents <- c()
	# ----------------


	for (i in 1:nrow(matrix)) {
		if (verbose) print(paste("DOCUMENT",i))
		scores <- list(positive=0,negative=0)
		doc <- matrix[i,]
		words <- findFreqTerms(doc,lowfreq=1)

		# ----------------
		words <- rm_accent(words)
		# ---------------

		for (word in words) {
			index <- pmatch(word,lexicon[,1],nomatch=0)
			if (index > 0) {
				entry <- lexicon[index,]

				polarity <- as.character(entry[[2]])
				category <- as.character(entry[[3]])
				count <- counts[[category]]

				score <- pweak
                if (polarity == "strongsubj") score <- pstrong
				if (algorithm=="bayes") score <- abs(log(score*prior/count))

				if (verbose) {
                    print(paste("WORD:",word,"CAT:",category,"POL:",polarity,"SCORE:",score))
				}

				scores[[category]] <- scores[[category]]+score
			}
		}

		if (algorithm=="bayes") {
			for (key in names(scores)) {
				count <- counts[[key]]
				total <- counts[["total"]]
				score <- abs(log(count/total))
				scores[[key]] <- scores[[key]]+score
			}
		} else {
			for (key in names(scores)) {
				scores[[key]] <- scores[[key]]+0.000001
			}
		}

        best_fit <- names(scores)[which.max(unlist(scores))]
        ratio <- as.integer(abs(scores$positive/scores$negative))
        if (ratio==1) best_fit <- "neutral"
		documents <- rbind(documents,c(scores$positive,scores$negative,abs(scores$positive/scores$negative),best_fit))
		if (verbose) {
			print(paste("POS:",scores$positive,"NEG:",scores$negative,"RATIO:",abs(scores$positive/scores$negative)))
			cat("\n")
		}
	}

	colnames(documents) <- c("POS","NEG","POS/NEG","BEST_FIT")
	return(documents)
}
