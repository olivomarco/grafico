# Grafico, a program for drawing math functions

This repo contains an old retro-computing program I wrote back in 1997 for MS-DOS. Its aim was to get a math function in input and draw it, also calculating and plotting first-degree and second-degree derived functions.

It was written in Turbo Pascal 6, and you can find the [source code here](/src) with the main code being [this file](/src/grafico.pas). The original [compile.bat](/compile.bat) was the file used to compile it all, and required the `tcp.exe` file which is the Turbo Pascal 6 compiler for MS-DOS.

I cannot provide this executable (I am not sure if it is still under copyright by Borland International or others), however I do not think anyone will try to compile this program anymore.
To compile it, maybe you can use Free Pascal:

```bash
sudo apt-get install fp-compiler fp-ide
```

See also <http://fusharblog.com/installing-free-pascal-in-ubuntu/>

However I haven't tried it myself (being Grafico more than 20 years old).

Theoretically, this program could be run under Linux with `dosbox`:

```bash
sudo apt-get install dosbox
dosbox grafico.exe
```

However, I tried and didn't succeed: the program starts graphical mode, and therefore I received lots of gibberish in the terminal. If you manage to make it run, please let me know how.

## Original instructions (italian)

Grafico è un programma che ho ideato nel dicembre del 1997 ed ho sviluppato nel corso dei primi mesi del 1998. Sebbene il suo nome sia tutt'altro che originale, questo programma è in grado di compiere diverse operazioni riguardo lo studio di funzioni matematiche. Alla fine di aprile 1999 sono state aggiunte alcune nuove funzionalità per quanto riguarda le funzioni supportate dal programma.

In breve, ecco le caratteristiche principali del programma in questione:

* possibilità di studiare una qualunque funzione matematica (razionale, irrazionale, fratta, goniometrica, logaritmica, ...)
* possibilità di visualizzarne la sua derivata prima con in più alcuni punti particolarmente significativi ricavabili da essa; la derivata seconda non è stata implementata, ma è possibile inserire una breve funzione anche per essa tramite semplici formule di calcolo numerico
* possibilità di visualizzare il grafico di rotazione della curva attorno all'asse delle ascisse (un problema che si trova spesso durante la discussione di volumi tramite integrali; a questo proposito anche qui non è stato implementato il calcolo dell'integrale della curva, ma il metodo è piuttosto facile, dato che è sufficiente utilizzare qualche formula del calcolo numerico)
* possibilità di caricare e salvare un file contenente un massimo di 16 funzioni, richiamabili molto facilmente per una rapida consultazione
* possibilità di cambiare la scala di visualizzazione da numeri interi a radianti (l'ideale per le funzioni goniometriche)
* possibilità di scorrere il grafico della curva, di ingrandire e di rimpicciolire parti di essa, di aumentare o diminuire la risoluzione della curva (modificando la distanza tra i punti) e possibilità di visualizzare il dominio della curva
* possibilità di estrapolare punti dal grafico, al fine di visualizzarne l'ordinata

Le funzioni matematiche base supportate sono numerose. Esempi:

* `abs(x)`
* `ln(x)`
* `sen(x)`
* `cos(x)`
* `tag(x)`
* `cotag(x)`
* `arcsen(x)`
* `arccos(x)`
* `arctag(x)`
* `arccotag(x)`
* `sqr(x)`
* `sqrt(x)`
* `x^3`
* `e^x`
* `(1/2)^x`
* `(x-1)/(x+4)`
* `asinh(x)`
* `acosh(x)`
* `atanh(x)`
* `sinh(x)`
* `cosh(x)`
* `tanh(x)`
* `sgn(x)`
* `int(x)`

oltre a tutte le possibili combinazioni delle stesse, come ad esempio:

* `4*cos(x)+2*cos(2*x)-1`
* `cos(x)/(sin(x)-1)`
* `(x^3)*(e^(-x))`
* `(1-abs(e^(2*x)-1))^(1/2)`
* `arctag(1/abs(x))`
* `x/(x^3-1)`
* `2*x+log(x)`
* `2*arctag(x)-x`
* `(x^2+x)^(1/3)`
* `x+(1-x^2)^(1/2)`
* `1/(1+x)+1/(1-abs(x))`
* `x/(x^2+1)`
* `abs(x^3-x^2)+x^3`
* `ln(x/(x^2-4))`
* `x+tag(x)`
* `(x-2)*(e^x-1)`
* `(1+x)/(abs(1-x))`
* `(1+x)/(1-abs(x))`
* `(1+abs(x))/(1-abs(x))`
* `(x^2-4)/(x+1)`
* `(x^3)/abs(x^2-1)`
* `sqrt(4-x^2)`
* `sqrt((1-abs(x))/(1+abs(x)))`
* `sqrt((1-x)/(1+x))`
* `3*((sen(x))^2)-3*((sen(x))^3)`
* `((cos(x))^2)/(1+2*sen(x))`
* `(abs(x))^x`
* `2^(x+1/x)`
* `(e^(tag(x))-1)/(e^(tag(x))+1)`
* `sqrt(1-e^x)`
* `arctag((e^x+1)/(e^x-1))`
* `25*(x^3)*(x-1)^2`

## Screenshot

La figura qui sotto mostra una sovrapposizione di schermate del programma (quella in alto a sinistra è uno studio di funzione in verde con la derivata prima in viola e l'asse `Y` fuori dal dominio evidenziato in blu e quella in basso a destra è la rotazione di una curva attorno all'asse delle `X`):

![Screenshot del programma](/images/grafico.jpg)

## Riconoscimenti

QUESTO PROGRAMMA E' STATO PUBBLICATO SULLA RIVISTA ITALIANA PCFLOPPY+PCMAGAZINE (EDITA DA JACKSON INFORMATICA) NEL MESE DI MAGGIO 1999 NELLO SPAZIO DEDICATO AI PROGRAMMATORI ITALIANI. DESIDERO RINGRAZIARE TUTTI COLORO CHE MI HANNO AIUTATO, IN UN MODO O NELL'ALTRO. UN GRAZIE SPECIALE A SILVIO D'ANGELO E ROBERTO FULIGNI, CHE MI HANNO AIUTATO ED INCORAGGIATO NELLA PRIMA VERSIONE DEL PROGRAMMA.

![Articolo su PC Magazine maggio 1999](/images/articolo.jpg)
