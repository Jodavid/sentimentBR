
# sentimentBR <img src="man/figures/logo.png" align="right" height="139"/>

<!-- badges: start -->

[![CRAN
version](https://www.r-pkg.org/badges/version/sentimentBR)](https://cran.r-project.org/package=sentimentBR)
[![CRAN
Download](https://cranlogs.r-pkg.org/badges/grand-total/sentimentBR)](https://cran.r-project.org/package=sentimentBR)
<!-- badges: end -->

## Visão geral

No CRAN do R, existe um pacote arquivado denominado
[sentiment](https://cran.r-project.org/web/packages/sentiment/index.html),
no qual é possível baixar e fazer uma análise de sentimento em
**Inglês**. Então, inspirado nesse pacote, foram replicadas as funções
existentes, entretanto adicionando o dicionário da **língua
portuguesa**, mais precisamente do Brasil.

Este é um *pacote inicial* com o intuito de juntar as funções e
dicionários cada vez mais em português para que seja possível realizar
uma **Análise de Sentimento** cada vez mais eficiente e com boa
confiabilidade.

Foi mantido o nome do pacote e o nome do pimeiro autor nas partes dos
códigos que foram replicados nesse pacote. Foi adicionado o BR de Brasil
no fim do nome para dar ênfase ao sentido de replicar as funções para
utilizar na língua portuguesa. É importante deixar claro, que também é
possível utilizar as funções na língua **inglesa**, como existe no
pacote original arquivado.

## Instalação

``` r
# Instalação utilizando o pacote devtools
install.packages("devtools")
devtools::install_github("jodavid/sentimentBR")
```

## Utilização

``` r
# Pacote
library(sentimentBR)

# Texto a ser classficado
documento <- c("A alegria que se tem em pensar e aprender faz-nos pensar e aprender ainda mais.",
               "Um pouco de desprezo economiza bastante ódio.")

# Classificando Emoções
classify_emotion(documento,algorithm="bayes",verbose=FALSE, lang = "pt")
#>      RAIVA              DESGOSTO           MEDO              
#> [1,] "1.46871776464786" "3.09234031207392" "2.06783599555953"
#> [2,] "13.2129533435987" "3.09234031207392" "2.06783599555953"
#>      ALEGRIA            TRISTEZA          SURPRESA           BEST_FIT 
#> [1,] "7.34083555412328" "1.7277074477352" "7.34083555412327" "alegria"
#> [2,] "1.02547755260094" "1.7277074477352" "2.78695866252273" "raiva"

# Classificando Polaridade
classify_polarity(documento,algorithm="bayes",verbose=FALSE, lang = "pt")
#>      POS                NEG                 POS/NEG             BEST_FIT  
#> [1,] "9.47547003995745" "0.445453222112551" "21.2715265477714"  "positive"
#> [2,] "9.47547003995745" "27.5355036756473"  "0.344118275502535" "negative"
```

Um post iniciando com Scraping e concluíndo com alguns gráficos para
análisar os sentimentos de textos pode ser encontrado no meu blog:
<https://jodavid.github.io/post/>
