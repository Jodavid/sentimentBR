#' classifies the emotion (e.g. anger, disgust, fear, joy, sadness, surprise) of a set of texts.
#'
#' \code{classify_emotion} Classifies the emotion (e.g. anger, disgust, fear, joy, sadness, surprise) of a set of texts using a naive Bayes classifier trained on Carlo Strapparava and Alessandro Valitutti's \code{\link{emotions}} lexicon.
#'
#' @param textColumns A \code{data.frame} of text documents listed one per row.
#' @param algorithm A \code{string} indicating whether to use the naive \code{bayes} algorithm or a simple \code{voter} algorithm.
#' @param prior A \code{numeric} specifying the prior probability to use for the naive Bayes classifier.
#' @param verbose A \code{logical} specifying whether to print detailed output regarding the classification process.
#' @param lang Language, "en" for English and "pt" for Brazilian Portuguese.
#' @param \dots Additional parameters to be passed into the \code{\link{create_matrix}} function.
#'
#' @return Returns an object of class \code{data.frame} with seven columns and one row for each document.
#'        \item{anger}{The absolute log likelihood of the document expressing an angry sentiment.}
#'        \item{disgust}{The absolute log likelihood of the document expressing a disgusted sentiment.}
#'        \item{fear}{The absolute log likelihood of the document expressing a fearful sentiment.}
#'        \item{joy}{The absolute log likelihood of the document expressing a joyous sentiment.}
#'        \item{sadness}{The absolute log likelihood of the document expressing a sad sentiment.}
#'        \item{surprise}{The absolute log likelihood of the document expressing a surprised sentiment.}
#'        \item{trust}{The absolute log likelihood of the document expressing a trust sentiment.}
#'        \item{negative}{The absolute log likelihood of the document expressing a negative sentiment.}
#'        \item{positive}{The absolute log likelihood of the document expressing a positive sentiment.}
#'        \item{anticipation}{The absolute log likelihood of the document expressing a anticipation sentiment.}
#'        \item{best_fit}{The most likely sentiment category (e.g. anger, disgust, fear, joy, sadness, surprise) for the given text.}
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
#' # CLASSIFY EMOTIONS
#' classify_emotion(documents,algorithm="bayes",verbose=TRUE, lang = "en")
#'
#' # pt-BR
#' documentos <- c("Estou muito feliz, animado e otimista.",
#'                "Estou muito assustado e irritado.")
#'
#' # CLASSIFY EMOTIONS
#' classify_emotion(documentos,algorithm="bayes",verbose=TRUE, lang = "pt")
#'
#'
classify_emotion <- function(textColumns,algorithm="bayes",prior=1.0,verbose=FALSE,lang = "en",...) {
	matrix <- create_matrix(textColumns,...)

	if(lang == "en"){
	lexicon <- read.csv(system.file("data/emotions.csv.gz",package="sentimentBR"),header=FALSE, sep=",")
	# ---------
	lexicon[,1] <- rm_accent(lexicon[,1])
	# ---------
	counts <- list(anger=length(which(lexicon[,2]=="anger")),disgust=length(which(lexicon[,2]=="disgust")),
	               fear=length(which(lexicon[,2]=="fear")),joy=length(which(lexicon[,2]=="joy")),
	               sadness=length(which(lexicon[,2]=="sadness")),surprise=length(which(lexicon[,2]=="surprise")),
	               trust=length(which(lexicon[,2]=="trust")),positive=length(which(lexicon[,2]=="positive")),
	               negative=length(which(lexicon[,2]=="negative")),anticipation=length(which(lexicon[,2]=="anticipation")),
	               total=nrow(lexicon))
	}else if(lang == "pt"){
	  lexicon <- read.csv(system.file("data/emotionspt.csv.gz",package="sentimentBR"),header=FALSE,
	                      quote = "", sep=",", row.names = NULL)
	  # ---------
	  lexicon[,1] <- rm_accent(lexicon[,1])
	  # ---------
	  counts <- list(anger=length(which(lexicon[,2]=="anger")),disgust=length(which(lexicon[,2]=="disgust")),
	                 fear=length(which(lexicon[,2]=="fear")),joy=length(which(lexicon[,2]=="joy")),
	                 sadness=length(which(lexicon[,2]=="sadness")),surprise=length(which(lexicon[,2]=="surprise")),
	                 trust=length(which(lexicon[,2]=="trust")),positive=length(which(lexicon[,2]=="positive")),
	                 negative=length(which(lexicon[,2]=="negative")),anticipation=length(which(lexicon[,2]=="anticipation")),
	                 total=nrow(lexicon))
	}

	# ----------------
	#lexicon[,1] <- rm_accent(lexicon[,1])
	documents <- c()
	# ----------------

	for (i in 1:nrow(matrix)) {
		if (verbose) print(paste("DOCUMENT",i))
		scores <- list(anger=0,disgust=0,fear=0,joy=0,sadness=0,surprise=0, trust=0, positive=0,negative=0,anticipation=0)
		doc <- matrix[i,]
		words <- findFreqTerms(doc,lowfreq=1)

		# ----------------
		words <- rm_accent(words)
		# ---------------

		for (word in words) {
            for (key in names(scores)) {
                emotions <- lexicon[which(lexicon[,2]==key),]
                index <- pmatch(word,emotions[,1],nomatch=0)
                if (index > 0) {
                    entry <- emotions[index,]

                    category <- as.character(entry[[2]])
                    count <- counts[[category]]

                    score <- 1.0
                    if (algorithm=="bayes") score <- abs(log(score*prior/count))

                    if (verbose) {
                        print(paste("WORD:",word,"CAT:",category,"SCORE:",score))
                    }

                    scores[[category]] <- scores[[category]]+score
                }
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
        if (best_fit == "disgust" && as.numeric(unlist(scores[2]))-3.09234 < .01) best_fit <- NA
		documents <- rbind(documents,c(scores$anger,scores$disgust,scores$fear,scores$joy,
		                               scores$sadness,scores$surprise,scores$trust,scores$positive,
		                               scores$negative, scores$anticipation,
		                               best_fit))
	}

	if(lang == "en"){
	  colnames(documents) <- c("ANGER","DISGUST","FEAR","JOY","SADNESS","SURPRISE",
	                           "TRUST", "POSITIVE", "NEGATIVE", "ANTICIPATION","BEST_FIT")
	}else if(lang == "pt"){
	  #-------------------------
	  class <- function(x){

	    vetor <- array(NA, dim = length(x))
	    for( i in 1:length(x)){
	      vetor[i] <- switch (x[i],
	                          "anger" = "raiva",
	                          "disgust" = "desgosto",
	                          "fear" = "medo",
	                          "joy" = "alegria",
	                          "sandness" = "triteza",
	                          "surprise" = "surpresa",
	                          "trust" = "confiança",
	                          "positive" = "positiva",
	                          "negative" = "negativa",
	                          "anticipation" = "antecipação",
	                          "NA" = NA
	      )
	    }
	    return(vetor)

	  }
	  #-------------------------
	  colnames(documents) <- c("RAIVA","DESGOSTO","MEDO","ALEGRIA","TRISTEZA","SURPRESA",
	                           "CONFIANÇA", "POSITIVA", "NEGATIVA", "ANTECIPAÇÃO","BEST_FIT")
	  documents[,11] <- class(documents[,11])
  }
	return(documents)
}
