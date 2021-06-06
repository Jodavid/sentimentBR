#' Function to remove accents from words
#'
#' \code{rm_accent} Function to remove accents from words
#'
#' @param str vector of strings that will have their accents removed.
#' @param pattern string vector with one or more elements indicating which accents should be removed. To indicate which accents should be removed, a vector with the symbols should be passed. Example: pattern = c("´", "^") will strip out the acute and caret accents only. Other accepted words: "all" (remove all accents, which are "´", "`", "^", "~", "¨", "ç")
#'
#' @return vector without accent
#'
#' @examples
#' x <- "São Paulo"
#'
#' y <- rm_accent(x, pattern = "'")
#' print(y)
#'
#' y <- rm_accent(x, pattern = "~")
#' print(y)
#'
#' y <- rm_accent(x, pattern = "all")
#' print(y)
#'
rm_accent <- function(str, pattern = "all") {

  if(!is.character(str))
    str <- as.character(str)

  pattern <- unique(pattern)

  if(any(pattern == stringi::stri_unescape_unicode("\\u00c7") ))
    pattern[pattern == stringi::stri_unescape_unicode("\\u00c7") ] <- stringi::stri_unescape_unicode("\\u00e7")

  symbols <- c(
    acute = "\\u00e1\\u00e9\\u00ed\\u00f3\\u00fa\\u00c1\\u00c9\\u00cd\\u00d3\\u00da\\u00fd\\u00dd",
    grave = "\\u00e0\\u00e8\\u00ec\\u00f2\\u00f9\\u00c0\\u00c8\\u00cc\\u00d2\\u00d9",
    circunflex = "\\u00e2\\u00ea\\u00ee\\u00f4\\u00fb\\u00c2\\u00ca\\u00ce\\u00d4\\u00db",
    tilde = "\\u00e3\\u00f5\\u00c3\\u00d5\\u00f1\\u00d1",
    umlaut = "\\u00e4\\u00eb\\u00ef\\u00f6\\u00fc\\u00c4\\u00cb\\u00cf\\u00d6\\u00dc\\u00ff",
    cedil = "\\u00e7\\u00c7"
  )

  nudeSymbols <- c(
    acute = "aeiouAEIOUyY",
    grave = "aeiouAEIOU",
    circunflex = "aeiouAEIOU",
    tilde = "aoAOnN",
    umlaut = "aeiouAEIOUy",
    cedil = "cC"
  )

  accentTypes <- c(stringi::stri_unescape_unicode("\\u00b4"),
                   "`","^","~",
                   stringi::stri_unescape_unicode("\\u00a8"),
                   stringi::stri_unescape_unicode("\\u00e7"))

  if(any(c("all","al","a","todos","t","to","tod","todo")%in%pattern))
    return(chartr(paste(
      stringi::stri_unescape_unicode(symbols),
      collapse=""), paste(nudeSymbols, collapse=""), str))

  for(i in which(accentTypes%in%pattern))
    str <- chartr(
      stringi::stri_unescape_unicode(symbols[i]),
      nudeSymbols[i], str)

  return(str)
}
