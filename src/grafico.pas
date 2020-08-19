(*Programma per l'analisi di una funzione matematica - Marco Olivo, 1998*)
(*Versione 4.0*)

(*Questo programma ? liberamente distribuibile e modificabile, a patto che rimanga
il mio nome nei crediti e a patto che non venga utilizzato per scopi di lucro e/o commerciali*)
(*Contiene parti Copyright (c) 1985, 1990 by Borland International, Inc.*)

(*In nessun caso sar? responsabile per i danni (inclusi, senza limitazioni, il danno per
perdita mancato guadagno, interruzione dell'attivit?, perdita di informazioni o altre perdite
economiche) derivanti dall'uso del prodotto "Grafico", anche nel caso io sia stato avvertito
dalla possibilit? di danni.*)

(*Per la compilazione utilizzare il comando:
                        make -fgrafico.mak
*)

(*Impostiamo alcune "Switch directives"; la prima ({$A+}) serve per velocizzare
l'esecuzione del programma sulle CPU 80x86; la seconda ({$G-}) per far funzionare il programma
anche sugli 8086; la terza ({$N+}) e la quarta ({$E+}) servono per rendere il programma
portabile su macchine senza il coprocessore numerico 8087 e la quinta ({$S-}) per non permettere al
programma di dare eventuali errori di "stack overflow"*)
{$A+,G-,N+,E+,S-}

program Analizza_Funzione;

(********************************************************************
*   Dichiarazione "uses"
********************************************************************)

uses Crt,
    Graph,
    BGIDriv,
    BGIFont;

(********************************************************************
*   Dichiarazione "type"
********************************************************************)

type
    coordxy=record
        x,y:Integer;
end;

(********************************************************************
*   Variabili globali del programma
********************************************************************)

var
    vertici:array[1..4] of coordxy; (*Array per il riempimento della grafica 3D*)
    funzione:string;                (*Variabile temporanea per la nostra funzione*)
    numero,array_funzione:array[1..100] of string;  (*Variabili per valutare l'equazione*)
    lista_funzioni:array[1..16] of string;  (*Contiene le ultime 16 funzioni*)
    array_x,array_y:array[1..500] of real;  (*Arrays per la rotazione della curva*)
    num_valori:Integer;             (*Per il conteggio dei valori presenti negli array sopra*)
    numero_funzioni:Integer;        (*Numero di funzioni correntemente salvate*)
    funzione_corrente:Integer;      (*Numero della funzione correntemente selezionata*)
    lunghezza:Integer;              (*Lunghezza della nostra funzione*)
    decrementa:Integer;             (*Variabile per l'analisi dei dati immessi*)
    i,oparen,cparen:Integer;        (*Variabili per l'analisi dei dati immessi*)
    OrigMode:Integer;               (*Contiene modalit? di testo iniziale*)
    grDriver:Integer;               (*Per la grafica*)
    grMode:Integer;                 (*Per la grafica*)
    ErrCode:Integer;                (*Per la grafica*)
    AsseXx1, AsseXy1, AsseXx2, AsseXy2, AsseYx1, AsseYy1, AsseYx2, AsseYy2:Integer; (*Posizioni degli assi cartesiani*)
    risoluzione,scala:Integer;      (*Fattori per la precisione del grafico*)
    lunghezza_funzione:Integer;     (*Variabile temporanea*)
    PuntiSx,PuntiDx:Integer;        (*Punti principali tracciati a sinistra ed a destra dell'origine*)
    Linee:Boolean;                  (*Grafico per linee o per punti?*)
    Limita:Boolean;                 (*Per la limitazione del dominio*)
    x_precedente,y_precedente:Longint;  (*Per unire il punto precedente del grafico con quello corrente con una linea*)
    sx,dx:extended;                 (*Se il dominio ? limitato, allora queste variabili contengono limitazione*)
    Disegna,Errore:Boolean;         (*Per disegnare correttamente la funzione quando ci sono errori*)
    Grafico_Rotazione:Boolean;      (*Grafico (True) o rotazione (False)?*)
    Griglia:Boolean;                (*Per la griglia*)
    FuoriDominio:Boolean;           (*Per il dominio*)
    FileDelleFunzioni:string;       (*Nome del file che contiene la lista delle funzioni*)
    errore_da,errore_a:extended;    (*Per il dominio*)
    Dominio:Boolean;                (*Dobbiamo disegnare il dominio?*)
    h:real;                         (*Incremento tra due valori consecutivi di X*)
    path:string;                    (*Percorso BGI*)
    InizializzatoX,InizializzatoY:Boolean;  (*Per vedere se abbiamo inizializzato correttamente
                                                                                            le posizioni degli assi*)
    Radianti:Boolean;               (*Punti sul grafico in interi od in radianti?*)
    DisegnaDerivata:Boolean;        (*Dobbiamo disegnare la derivata della funzione?*)

(********************************************************************
*   Prototipi di funzioni e procedure di tutto il programma
********************************************************************)

function Power(x:extended;y:extended):extended; forward;
function sinh(x:extended):extended; forward;
function cosh(x:extended):extended; forward;
function tanh(x:extended):extended; forward;
function sgn(x:extended):extended; forward;
function asinh(x:extended):extended; forward;
function acosh(x:extended):extended; forward;
function atanh(x:extended):extended; forward;
function ArcSen(x:extended):extended; forward;
function ArcCos(x:extended):extended; forward;
function ArcCotan(x:extended):extended; forward;
function ControllaSintassi:Boolean; forward;
function TrovaPrimoTermine(pos:Integer):Integer; forward;
function TrovaSecondoTermine(pos:Integer):Integer; forward;
procedure CalcolaPrecedenze; forward;
procedure AnalizzaDati; forward;
function CalcolaParentesi(da,a:Integer):extended; forward;
procedure Scrivi(valore:extended;da,a:Integer); forward;
function CalcolaValore(da,a:Integer):extended; forward;
procedure LeggiFunzione; forward;
procedure Abort(Msg:string); forward;
procedure DisegnaTitolo(titolo:string); forward;
procedure DisegnaMascherinaInformazioni; forward;
procedure DisegnaMascherinaTasti; forward;
procedure DisegnaGriglia; forward;
procedure DisegnaAssi; forward;
procedure DisegnaAssiSussidiari; forward;
procedure DisegnaNumeri; forward;
procedure DisegnaValore(x,y:Longint;color:Integer); forward;
procedure Sostituisci(x:real); forward;
procedure DisegnaDominio; forward;
procedure DisegnaGrafico(flag:Boolean); forward;
procedure DisegnaMascherinaRotazione; forward;
procedure VisualizzaGrafico; forward;
procedure Grafico; forward;
procedure Rotazione; forward;
procedure Derivata; forward;
procedure RuotaCurva; forward;
function ReadChar:Char; forward;
procedure Beep; forward;
procedure SchermataDiBenvenuto; forward;
procedure Messaggio(testo:string); forward;
procedure MenuPrincipale; forward;
procedure InserisciFunzione(espressione:string); forward;
procedure EstrapolaPunti; forward;
procedure LimitaDominio; forward;
procedure Informazioni_Guida; forward;
function Conferma(testo:string):Boolean; forward;
function ConfermaUscita:Boolean; forward;
procedure ImpostaValoriDiDefault; forward;
procedure ImpostaDefault; forward;
function FileExists(FileName:string):Boolean; forward;
procedure CaricaListaFunzioni(FileName:string); forward;
procedure SalvaListaFunzioni(FileName:string); forward;
procedure MostraListaFunzioni; forward;
procedure SelezionaFunzione(da_selezionare,precedente:Integer); forward;
procedure ChiediNomeFile; forward;
procedure FinestraPrincipale; forward;

(********************************************************************
*   Funzioni e procedure per il calcolo dei valori della funzione
********************************************************************)

function Power(x:extended;y:extended):extended;
begin
    if (x=0) AND (y=0) then
        begin
            Power:=0;
            Errore:=True;
            Disegna:=False;
        end
    else if (x>0) then
        Power:=Exp(y*ln(x))
    else if (x<0) then
        begin
            if ((1/y)>1) then
                begin
                    if (Odd(Round(1/y))) then
                        Power:=-Exp(y*ln(-x))
                    else if (NOT (Odd(Round(1/y)))) then
                        begin
                            if (y>1) then
                                Power:=Exp(y*ln(-x))
                            else if (y<1) then
                                begin
                                    Power:=0;
                                    Errore:=True;
                                end
                            else if (y=1) then
                                Power:=x;
                        end;
                end
            else
                begin
                    if (Odd(Round(y))) then
                        Power:=-Exp(y*ln(-x))
                    else if (NOT (Odd(Round(y)))) then
                        begin
                            if (y>1) then
                                Power:=Exp(y*ln(-x))
                            else if (y<1) then
                                begin
                                    Power:=0;
                                    Errore:=True;
                                end
                            else if (y=1) then
                                Power:=x;
                        end;
                end;
        end
    else if (x=0) AND (y>0) then
        Power:=0
    else if (x=0) AND (y<0) then
        begin
            Errore:=True;
            Power:=0;
        end
    else
        Power:=1;
end;
(*******************************************************************)

function sinh(x:extended):extended;
begin
    sinh:=(exp(x)-exp(-x))/2;
end;
(*******************************************************************)

function cosh(x:extended):extended;
begin
    cosh:=(exp(x)+exp(-x))/2;
end;
(*******************************************************************)

function tanh(x:extended):extended;
begin
    tanh:=(exp(2*x)-1)/(exp(2*x)+1)
end;
(*******************************************************************)

function sgn(x:extended):extended;
begin
    if (x>0) then
        sgn:=1
    else if (x<0) then
        sgn:=-1
    else    (*x=0*)
        sgn:=0;
end;
(*******************************************************************)

function asinh(x:extended):extended;
begin
    asinh:=ln(x+sqrt(sqr(x)+1));
end;
(*******************************************************************)

function acosh(x:extended):extended;
begin
    if (x>=1) then
        acosh:=ln(x+sqrt(sqr(x)-1))
    else
        begin
            acosh:=0;
            Errore:=True;
        end;
end;
(*******************************************************************)

function atanh(x:extended):extended;
begin
    if (x>-1) AND (x<1) then
        atanh:=ln(sqrt((1+x)/(1-x)))
    else
        begin
            atanh:=0;
            Errore:=True;
        end;
end;
(*******************************************************************)

function ArcSen(x:extended):extended;
begin
    if (x>-1) AND (x<1) then
        ArcSen:=ArcTan(x/sqrt(1-sqr(x)))
    else
        begin
            ArcSen:=0;
            Errore:=True;
        end;
end;
(*******************************************************************)

function ArcCos(x:extended):extended;
begin
    if (x>-1) AND (x<1) then
        ArcCos:=Pi/2-ArcTan(x/sqrt(1-sqr(x)))
    else
        begin
            ArcCos:=0;
            Errore:=True;
        end;
end;
(*******************************************************************)

function ArcCotan(x:extended):extended;
begin
    ArcCotan:=Pi/2-ArcTan(x);
end;
(*******************************************************************)

function ControllaSintassi:Boolean;
var
    k,i:Integer;
    posizione_parentesi:Integer;
    testo:string;
begin
    ControllaSintassi:=True;
    if (oparen<>cparen) then
        begin
            Messaggio('Errore di sintassi: parentesi aperte e chiuse in numero diverso');
            ControllaSintassi:=False;
        end;
    for i:=1 to lunghezza do
        begin
            if (array_funzione[i]<>'(') AND (array_funzione[i]<>')') AND (array_funzione[i]<>'+') AND (array_funzione[i]<>'-')
                AND (array_funzione[i]<>'*') AND (array_funzione[i]<>'^') AND (array_funzione[i]<>'/')
                AND (array_funzione[i]<>'SIN') AND (array_funzione[i]<>'COS') AND (array_funzione[i]<>'TAN') AND
                (array_funzione[i]<>'ATAN') AND (array_funzione[i]<>'COTAN') AND
                (array_funzione[i]<>'LOG') AND (array_funzione[i]<>'ABS') AND (array_funzione[i]<>'SQR') AND
                (array_funzione[i]<>'SQRT') AND (array_funzione[i]<>'X') AND (array_funzione[i]<>'ARCSIN')
                AND (array_funzione[i]<>'ARCCOS') AND (array_funzione[i]<>'ARCCOTAN') AND (array_funzione[i]<>'SINH')
                AND (array_funzione[i]<>'ASINH') AND (array_funzione[i]<>'COSH') AND (array_funzione[i]<>'ACOSH')
                AND (array_funzione[i]<>'TANH') AND (array_funzione[i]<>'ATANH') AND (array_funzione[i]<>'SGN') AND
                                (array_funzione[i]<>'INT')then
                                begin
                    if (array_funzione[i][1]='0') OR (array_funzione[i][1]='1')
                        OR (array_funzione[i][1]='2') OR (array_funzione[i][1]='3')
                        OR (array_funzione[i][1]='4') OR (array_funzione[i][1]='5')
                        OR (array_funzione[i][1]='6') OR (array_funzione[i][1]='7')
                        OR (array_funzione[i][1]='8') OR (array_funzione[i][1]='9') then
                        begin
                            for k:=2 to Length(array_funzione[i]) do
                                begin
                                    if (array_funzione[i][k]<>'0') AND (array_funzione[i][k]<>'1')
                                        AND (array_funzione[i][k]<>'2') AND (array_funzione[i][k]<>'3')
                                        AND (array_funzione[i][k]<>'4') AND (array_funzione[i][k]<>'5')
                                        AND (array_funzione[i][k]<>'6') AND (array_funzione[i][k]<>'7')
                                        AND (array_funzione[i][k]<>'8') AND (array_funzione[i][k]<>'9') then
                                        begin
                                            Messaggio('Errore di sintassi: carattere non valido');
                                            ControllaSintassi:=False;
                                        end;
                                end;
                        end
                    else if (array_funzione[i]='E') then
                        begin
                            Str(Exp(1.0),array_funzione[i]);    (*Sostituiamo "e" con il suo valore,
                                                                dal momento che non lo abbiamo fatto prima
                                                                per poter controllare la sintassi*)
                        end
                    else
                        begin
                            Messaggio('Errore di sintassi: carattere non valido');
                            ControllaSintassi:=False;
                        end;
                end;
        end;
    for i:=1 to lunghezza do
        begin
            if (array_funzione[i]='(') then
                begin
                    if (array_funzione[i+1]=')') then
                        begin
                            Messaggio('Errore di sintassi: nessun argomento nella parentesi');
                            ControllaSintassi:=False;
                        end;
                end;
        end;
    oparen:=0;
    cparen:=0;
    for i:=1 to lunghezza do
        begin
            if (array_funzione[i]='(') then
                Inc(oparen)
            else if (array_funzione[i]=')') then
                Inc(cparen);
            if cparen>oparen then
                begin
                    Messaggio('Errore di sintassi: parentesi chiusa prima di parentesi aperta');
                    ControllaSintassi:=False;
                end;
        end;
    for i:=1 to lunghezza do
        begin
            if (array_funzione[i]='SIN') OR (array_funzione[i]='COS') OR (array_funzione[i]='TAN') OR
                (array_funzione[i]='ATAN') OR (array_funzione[i]='COTAN') OR
                (array_funzione[i]='LOG') OR (array_funzione[i]='ABS') OR (array_funzione[i]='SQR') OR
                (array_funzione[i]='SQRT') OR (array_funzione[i]='ARCSIN') OR (array_funzione[i]='ARCCOS') OR
                (array_funzione[i]='ARCCOTAN') OR (array_funzione[i]='SINH') OR (array_funzione[i]='ASINH') OR
                (array_funzione[i]='COSH') OR (array_funzione[i]='ACOSH')  OR (array_funzione[i]='TANH') OR
                (array_funzione[i]='ATANH') OR (array_funzione[i]='SGN') OR (array_funzione[i]='INT') then
                begin
                    if (array_funzione[i+1]<>'(') then
                        begin
                            testo:=Concat('Errore di sintassi: nessun argomento di ',array_funzione[i]);
                            Messaggio(testo);
                            ControllaSintassi:=False;
                        end;
                end;
        end;
end;
(*******************************************************************)

function TrovaPrimoTermine(pos:Integer):Integer;
var
    i:Integer;
    paren:Integer;
begin
    paren:=0;
    for i:=pos downto 1 do
        begin
            (*Se la posizione dell'array ? un numero oppure una parentesi, l'abbiamo trovato e
            ritorniamo la posizione; non ammettiamo errori, dato che abbiamo gi? controllato la
            sintassi precedentemente*)
            if (array_funzione[i]<>')') AND (array_funzione[i]<>'+') AND (array_funzione[i]<>'-') AND
                (array_funzione[i]<>'*') AND (array_funzione[i]<>'^') AND (array_funzione[i]<>'/') AND (paren=0) then
                begin
                    TrovaPrimoTermine:=i;
                    i:=1;   (*Usciamo dal ciclo*)
                end
            else if (array_funzione[i]=')') then
                inc(paren)
            else if (array_funzione[i]='(') AND (paren>0) then
                begin
                    dec(paren);
                    if (paren=0) then
                        begin
                            TrovaPrimoTermine:=i;
                            i:=1;
                        end;
                end;
        end;
end;
(*******************************************************************)

function TrovaSecondoTermine(pos:Integer):Integer;
var
    i:Integer;
    paren:Integer;
begin
    paren:=0;
    for i:=pos to lunghezza do
        begin
            (*Se la posizione dell'array ? un numero oppure una parentesi, l'abbiamo trovato e
            ritorniamo la posizione; non ammettiamo errori, dato che abbiamo gi? controllato la
            sintassi precedentemente*)
            if (array_funzione[i]<>'(') AND (array_funzione[i]<>'+') AND (array_funzione[i]<>'-')
                AND (array_funzione[i]<>'*') AND (array_funzione[i]<>'^') AND (array_funzione[i]<>'/')
                AND (array_funzione[i]<>'SIN') AND (array_funzione[i]<>'COS') AND (array_funzione[i]<>'TAN') AND
                (array_funzione[i]<>'ATAN') AND (array_funzione[i]<>'COTAN') AND
                (array_funzione[i]<>'LOG') AND (array_funzione[i]<>'ABS') AND (array_funzione[i]<>'SQR')
                AND (array_funzione[i]<>'SQRT') AND (array_funzione[i]<>'ARCSIN') AND (array_funzione[i]<>'ARCCOS')
                AND (array_funzione[i]<>'ARCCOTAN') AND (array_funzione[i]<>'SINH') AND (array_funzione[i]<>'ASINH')
                AND (array_funzione[i]<>'COSH') AND (array_funzione[i]<>'ACOSH') AND (array_funzione[i]<>'TANH')
                AND (array_funzione[i]<>'ATANH') AND (array_funzione[i]<>'SGN') AND (array_funzione[i]<>'INT')
                                AND (paren=0) then
                begin
                    TrovaSecondoTermine:=i;
                    i:=lunghezza;   (*Usciamo dal ciclo*)
                end
            else if (array_funzione[i]='(') then
                inc(paren)
            else if (array_funzione[i]=')') AND (paren>0) then
                begin
                    dec(paren);
                    if (paren=0) then
                        begin
                            TrovaSecondoTermine:=i-1;
                            i:=lunghezza;
                        end;
                end;
        end;
end;
(*******************************************************************)

procedure CalcolaPrecedenze;
var
    n,f:Integer;
    primo_termine,secondo_termine:Integer;
begin
    for f:=1 to 100 do
        begin
            if (array_funzione[f]='SIN') OR (array_funzione[f]='COS') OR
                (array_funzione[f]='TAN') OR (array_funzione[f]='ATAN') OR
                (array_funzione[f]='LOG') OR (array_funzione[f]='COTAN') OR
                (array_funzione[f]='ABS') OR (array_funzione[f]='SQR') OR
                (array_funzione[f]='SQRT') OR (array_funzione[f]='ARCSIN') OR
                (array_funzione[f]='ARCCOS') OR (array_funzione[f]='ARCCOTAN') OR
                (array_funzione[f]='SINH') OR (array_funzione[f]='ASINH') OR
                (array_funzione[f]='COSH') OR (array_funzione[f]='ACOSH') OR
                (array_funzione[f]='TANH') OR (array_funzione[f]='ATANH') OR (array_funzione[f]='INT') OR
                (array_funzione[f]='SGN') then
                begin
                    primo_termine:=f;
                    secondo_termine:=TrovaSecondoTermine(f);
                    for n:=lunghezza+1 downto primo_termine do
                        array_funzione[n]:=array_funzione[n-1];
                    array_funzione[primo_termine]:='(';
                    inc(lunghezza);
                    for n:=lunghezza+1 downto secondo_termine+2 do
                        array_funzione[n]:=array_funzione[n-1];
                    array_funzione[secondo_termine+2]:=')';
                    inc(lunghezza);
                    inc(f); (*Evitiamo ripetizioni*)
                end;
        end;
    for f:=1 to 100 do
        begin
            if (array_funzione[f]='^') then
                begin
                    primo_termine:=TrovaPrimoTermine(f);
                    secondo_termine:=TrovaSecondoTermine(f);
                    for n:=lunghezza+1 downto primo_termine do
                        array_funzione[n]:=array_funzione[n-1];
                    array_funzione[primo_termine]:='(';
                    inc(lunghezza);
                    for n:=lunghezza+1 downto secondo_termine+2 do
                        array_funzione[n]:=array_funzione[n-1];
                    array_funzione[secondo_termine+2]:=')';
                    inc(lunghezza);
                    inc(f); (*Evitiamo ripetizioni*)
                end;
            end;
    for f:=1 to 100 do
        begin
            if (array_funzione[f]='*') then
                begin
                    primo_termine:=TrovaPrimoTermine(f);
                    secondo_termine:=TrovaSecondoTermine(f);
                    for n:=lunghezza+1 downto primo_termine do
                        array_funzione[n]:=array_funzione[n-1];
                    array_funzione[primo_termine]:='(';
                    inc(lunghezza);
                    for n:=lunghezza+1 downto secondo_termine+2 do
                        array_funzione[n]:=array_funzione[n-1];
                    array_funzione[secondo_termine+2]:=')';
                    inc(lunghezza);
                    inc(f); (*Evitiamo ripetizioni*)
                end
            else if (array_funzione[f]='/') then
                begin
                    primo_termine:=TrovaPrimoTermine(f);
                    secondo_termine:=TrovaSecondoTermine(f);
                    for n:=lunghezza+1 downto primo_termine do
                        array_funzione[n]:=array_funzione[n-1];
                    array_funzione[primo_termine]:='(';
                    inc(lunghezza);
                    for n:=lunghezza+1 downto secondo_termine+2 do
                        array_funzione[n]:=array_funzione[n-1];
                    array_funzione[secondo_termine+2]:=')';
                    inc(lunghezza);
                    inc(f); (*Evitiamo ripetizioni*)
                end;
        end;
    (*Non ci interessano altri casi*)
end;
(*******************************************************************)

procedure AnalizzaDati;
var
    n,k,i:Integer;
    IsNumber:Boolean;
begin
    IsNumber:=False;
    decrementa:=0;
    for i:=1 to lunghezza do
        begin
            if (array_funzione[i]='0') OR (array_funzione[i]='1') OR (array_funzione[i]='2') OR
                (array_funzione[i]='3') OR (array_funzione[i]='4') OR (array_funzione[i]='5') OR
                (array_funzione[i]='6') OR (array_funzione[i]='7') OR (array_funzione[i]='8') OR
                (array_funzione[i]='9') then
                    begin
                        if (IsNumber=False) then
                            IsNumber:=True
                        else    (*Accorpiamo la stringa*)
                            begin
                                array_funzione[i-1]:=Concat(array_funzione[i-1], array_funzione[i]);
                                for k:=i to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                                inc(decrementa);
                                dec(i);
                            end;
                    end
            else if (array_funzione[i]='X') then
                IsNumber:=False
            else if (array_funzione[i]='+') OR (array_funzione[i]='-') OR (array_funzione[i]='*') OR
                    (array_funzione[i]='/') OR (array_funzione[i]='^') then
                IsNumber:=False
            else
                begin
                    IsNumber:=False;
                        if (array_funzione[i]='S') AND (array_funzione[i+1]='I') AND
                            (array_funzione[i+2]='N') AND (array_funzione[i+3]='H') then
                            begin
                                array_funzione[i]:='SINH';
                                for n:=1 to 3 do
                                    for k:=i+1 to lunghezza do
                                        array_funzione[k]:=array_funzione[k+1];
                                inc(decrementa,3);
                                dec(i,3);
                            end
                        else if (array_funzione[i]='C') AND (array_funzione[i+1]='O') AND
                            (array_funzione[i+2]='S') AND (array_funzione[i+3]='H') then
                            begin
                                array_funzione[i]:='COSH';
                                for n:=1 to 3 do
                                    for k:=i+1 to lunghezza do
                                        array_funzione[k]:=array_funzione[k+1];
                                inc(decrementa,3);
                                dec(i,3);
                            end
                        else if (array_funzione[i]='T') AND (array_funzione[i+1]='A') AND
                            (array_funzione[i+2]='N') AND (array_funzione[i+3]='H') then
                            begin
                                array_funzione[i]:='TANH';
                                for n:=1 to 3 do
                                    for k:=i+1 to lunghezza do
                                        array_funzione[k]:=array_funzione[k+1];
                                inc(decrementa,3);
                                dec(i,3);
                            end
                        else if (array_funzione[i]='A') AND (array_funzione[i+1]='S') AND
                            (array_funzione[i+2]='I') AND (array_funzione[i+3]='N') AND
                            (array_funzione[i+4]='H')then
                            begin
                                array_funzione[i]:='ASINH';
                                for n:=1 to 4 do
                                    for k:=i+1 to lunghezza do
                                        array_funzione[k]:=array_funzione[k+1];
                                inc(decrementa,4);
                                dec(i,4);
                            end
                        else if (array_funzione[i]='A') AND (array_funzione[i+1]='C') AND
                            (array_funzione[i+2]='O') AND (array_funzione[i+3]='S') AND
                            (array_funzione[i+4]='H')then
                            begin
                                array_funzione[i]:='ACOSH';
                                for n:=1 to 4 do
                                    for k:=i+1 to lunghezza do
                                        array_funzione[k]:=array_funzione[k+1];
                                inc(decrementa,4);
                                dec(i,4);
                            end
                        else if (array_funzione[i]='A') AND (array_funzione[i+1]='T') AND
                            (array_funzione[i+2]='A') AND (array_funzione[i+3]='N') AND
                            (array_funzione[i+4]='H')then
                            begin
                                array_funzione[i]:='ATANH';
                                for n:=1 to 4 do
                                    for k:=i+1 to lunghezza do
                                        array_funzione[k]:=array_funzione[k+1];
                                inc(decrementa,4);
                                dec(i,4);
                            end
                    else if (array_funzione[i]='S') AND ((array_funzione[i+1]='I') OR (array_funzione[i+1]='E')) AND
                        (array_funzione[i+2]='N') then
                        begin
                            array_funzione[i]:='SIN';
                            for n:=1 to 2 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,2);
                            dec(i,2);
                        end
                    else if (array_funzione[i]='C') AND (array_funzione[i+1]='O') AND (array_funzione[i+2]='S') then
                        begin
                            array_funzione[i]:='COS';
                            for n:=1 to 2 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,2);
                            dec(i,2);
                        end
                    else if (array_funzione[i]='L') AND (array_funzione[i+1]='O') AND (array_funzione[i+2]='G') then
                        begin
                            array_funzione[i]:='LOG';
                            for n:=1 to 2 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,2);
                            dec(i,2);
                        end
                    else if (array_funzione[i]='S') AND (array_funzione[i+1]='G') AND (array_funzione[i+2]='N') then
                        begin
                            array_funzione[i]:='SGN';
                            for n:=1 to 2 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,2);
                            dec(i,2);
                        end
                    else if (array_funzione[i]='L') AND (array_funzione[i+1]='N') then
                        begin
                            array_funzione[i]:='LOG';
                            for k:=i+1 to lunghezza do
                                array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa);
                            dec(i,2);
                        end
                    else if (array_funzione[i]='A') AND (array_funzione[i+1]='B') AND (array_funzione[i+2]='S') then
                        begin
                            array_funzione[i]:='ABS';
                            for n:=1 to 2 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,2);
                            dec(i,2);
                        end
                    else if (array_funzione[i]='C') AND (array_funzione[i+1]='O') AND
                        (array_funzione[i+2]='T') AND (array_funzione[i+3]='G') then
                        begin
                            array_funzione[i]:='COTAN';
                            for n:=1 to 3 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,3);
                            dec(i,3);
                        end
                    else if (array_funzione[i]='C') AND (array_funzione[i+1]='O') AND
                        (array_funzione[i+2]='T') AND (array_funzione[i+3]='A') AND
                        ((array_funzione[i+4]='G') OR (array_funzione[i+4]='N')) then
                        begin
                            array_funzione[i]:='COTAN';
                            for n:=1 to 4 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,4);
                            dec(i,4);
                        end
                    else if (array_funzione[i]='T') AND (array_funzione[i+1]='A') AND
                        ((array_funzione[i+2]='G') OR (array_funzione[i+2]='N')) then
                        begin
                            array_funzione[i]:='TAN';
                            for n:=1 to 2 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,2);
                            dec(i,2);
                        end
                    else if (array_funzione[i]='T') AND (array_funzione[i+1]='G') then
                        begin
                            array_funzione[i]:='TAN';
                            for k:=i+1 to lunghezza do
                                array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa);
                            dec(i,2);
                        end
                    else if (array_funzione[i]='A') AND (array_funzione[i+1]='R') AND
                        (array_funzione[i+2]='C') AND (array_funzione[i+3]='T') AND
                        (array_funzione[i+4]='A') AND ((array_funzione[i+5]='G') OR (array_funzione[i+5]='N')) then
                        begin
                            array_funzione[i]:='ATAN';
                            for n:=1 to 5 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,5);
                            dec(i,5);
                        end
                    else if (array_funzione[i]='A') AND (array_funzione[i+1]='R') AND
                        (array_funzione[i+2]='C') AND (array_funzione[i+3]='T') AND
                        (array_funzione[i+4]='G') then
                        begin
                            array_funzione[i]:='ATAN';
                            for n:=1 to 4 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,4);
                            dec(i,4);
                        end
                    else if (array_funzione[i]='A') AND (array_funzione[i+1]='T') AND
                        (array_funzione[i+2]='A') AND ((array_funzione[i+3]='G') OR
                        (array_funzione[i+3]='N')) then
                        begin
                            array_funzione[i]:='ATAN';
                            for n:=1 to 3 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,3);
                            dec(i,3);
                        end
                    else if (array_funzione[i]='S') AND (array_funzione[i+1]='Q') AND
                        (array_funzione[i+2]='R') AND (array_funzione[i+3]='T') then
                        begin
                            array_funzione[i]:='SQRT';
                            for n:=1 to 3 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,3);
                            dec(i,3);
                        end
                    else if (array_funzione[i]='S') AND (array_funzione[i+1]='Q') AND (array_funzione[i+2]='R') then
                        begin
                            array_funzione[i]:='SQR';
                            for n:=1 to 2 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,2);
                            dec(i,2);
                        end
                    else if (array_funzione[i]='A') AND (array_funzione[i+1]='R') AND
                        (array_funzione[i+2]='C') AND (array_funzione[i+3]='S') AND
                        ((array_funzione[i+4]='E') OR (array_funzione[i+4]='I')) AND (array_funzione[i+5]='N') then
                        begin
                            array_funzione[i]:='ARCSIN';
                            for n:=1 to 5 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,5);
                            dec(i,5);
                        end
                    else if (array_funzione[i]='A') AND (array_funzione[i+1]='R') AND
                        (array_funzione[i+2]='C') AND (array_funzione[i+3]='C') AND
                        (array_funzione[i+4]='O') AND (array_funzione[i+5]='S') then
                        begin
                            array_funzione[i]:='ARCCOS';
                            for n:=1 to 5 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,5);
                            dec(i,5);
                        end
                    else if (array_funzione[i]='A') AND (array_funzione[i+1]='R') AND
                        (array_funzione[i+2]='C') AND (array_funzione[i+3]='C') AND
                        (array_funzione[i+4]='O') AND (array_funzione[i+5]='T') AND (array_funzione[i+6]='G') then
                        begin
                            array_funzione[i]:='ARCCOTAN';
                            for n:=1 to 6 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,6);
                            dec(i,6);
                        end
                    else if (array_funzione[i]='I') AND (array_funzione[i+1]='N') AND
                        (array_funzione[i+2]='T') then
                        begin
                            array_funzione[i]:='INT';
                            for n:=1 to 2 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,2);
                            dec(i,2);
                        end
                    else if (array_funzione[i]='A') AND (array_funzione[i+1]='R') AND
                        (array_funzione[i+2]='C') AND (array_funzione[i+3]='C') AND
                        (array_funzione[i+4]='O') AND (array_funzione[i+5]='T') AND (array_funzione[i+6]='A')
                        AND ((array_funzione[i+7]='G') OR (array_funzione[i+7]='N')) then
                        begin
                            array_funzione[i]:='ARCCOTAN';
                            for n:=1 to 7 do
                                for k:=i+1 to lunghezza do
                                    array_funzione[k]:=array_funzione[k+1];
                            inc(decrementa,7);
                            dec(i,7);
                        end;
                end;
        end;
    dec(lunghezza,decrementa);
end;
(*******************************************************************)

function CalcolaParentesi(da,a:Integer):extended;
var
    result:extended;
    i:Integer;
    sign:string;
    number:extended;
    code:Integer;
begin
    result:=0;
    sign:='';
    (*Calcoliamo il valore dell'espressione*)
    for i:=da to a do
        begin
            Val(numero[i],number,code);
            if (code=0) then
                begin
                    if (sign='+') then
                        result:=result+number
                    else if (sign='-') then
                        result:=result-number
                    else if (sign='*') then
                        result:=result*number
                    else if (sign='/') then
                        begin
                            if number<>0 then
                                result:=result/number
                            else
                                Errore:=True;
                        end
                    else if (sign='^') then
                        result:=Power(result,number)
                    else if (sign='SIN') then
                        result:=sin(number)
                    else if (sign='COS') then
                        result:=cos(number)
                    else if (sign='LOG') then
                        begin
                            if number>0 then
                                result:=ln(number)
                            else
                                Errore:=True;
                        end
                    else if (sign='TAN') then
                        begin
                            if cos(number)<>0 then
                                result:=sin(number)/cos(number)
                            else
                                Errore:=True;
                        end
                    else if (sign='COTAN') then
                        begin
                            if sin(number)<>0 then
                                result:=cos(number)/sin(number)
                            else
                                Errore:=True;
                        end
                    else if (sign='SINH') then
                        begin
                            result:=sinh(number);
                        end
                    else if (sign='COSH') then
                        begin
                            result:=cosh(number);
                        end
                    else if (sign='TANH') then
                        begin
                            result:=tanh(number);
                        end
                    else if (sign='INT') then
                        begin
                            result:=Int(number);
                        end
                    else if (sign='SGN') then
                        begin
                            result:=sgn(number);
                        end
                    else if (sign='ASINH') then
                        begin
                            result:=asinh(number);
                        end
                    else if (sign='ACOSH') then
                        begin
                            result:=acosh(number);
                        end
                    else if (sign='ATANH') then
                        begin
                            result:=atanh(number);
                        end
                    else if (sign='ATAN') then
                        result:=arctan(number)
                    else if (sign='ABS') then
                        result:=Abs(number)
                    else if (sign='SQR') then
                        result:=Power(number,2)
                    else if (sign='SQRT') then
                        result:=Power(number,1/2)
                    else if (sign='ARCSIN') then
                        result:=ArcSen(number)
                    else if (sign='ARCCOS') then
                        result:=ArcCos(number)
                    else if (sign='ARCCOTAN') then
                        result:=ArcCotan(number)
                    else
                        result:=number;
                end;
            sign:=numero[i];
        end;
    CalcolaParentesi:=result;
end;
(*******************************************************************)

procedure Scrivi(valore:extended;da,a:Integer);
var
    i:Integer;
begin
    Str(valore,numero[da]);
    for i:=da+1 to 100 do
        numero[i]:=numero[i+a-da];
end;
(*******************************************************************)

function CalcolaValore(da,a:Integer):extended;
var
    i,k:Integer;
    number,code:Integer;
    inizio,fine:Integer;
    risultato:extended;
    paren:Integer;
    IsParen:Boolean;
begin
    risultato:=0;
    paren:=0;
    IsParen:=True;

    (*Togliere il commento alle righe seguenti per mettere in grado il programma
    di valutare espressioni senza incognite (diventa una sorta di calcolatrice scientifica)*)
(*  for i:=1 to 100 do
        numero[i]:=array_funzione[i];*)

    (*Calcoliamo tutte le parentesi*)
    for i:=1 to lunghezza do
        begin
            if (numero[i]='(') then
                begin
                    paren:=1;
                    IsParen:=True;
                    inizio:=i+1;
                    for k:=i+1 to lunghezza do
                        begin
                            if (numero[k]=')') then
                                begin
                                    fine:=k-1;
                                    k:=lunghezza;
                                end
                            else if (numero[k]='(') then
                                begin
                                    inc(paren);
                                    inizio:=k+1;
                                end;
                        end;
                        risultato:=CalcolaParentesi(inizio,fine);
                        Scrivi(risultato,inizio-1,fine+1);
                        dec(lunghezza,fine-inizio+2);
                end
            else
                IsParen:=False;

            if (IsParen=True) then
                i:=1;
        end;

    (*Fa le varie operazioni, ormai soltanto tra numeri*)
    CalcolaValore:=CalcolaParentesi(1,lunghezza);
end;
(*******************************************************************)

procedure LeggiFunzione;
var
    token:string;
    i:Integer;
begin
    oparen:=0;
    cparen:=0;
    for i:=1 to 100 do
        begin
            array_funzione[i]:='';
        end;

    for i:=1 to lunghezza do
        begin
            token:=Copy(funzione, i, 1);

            (*Analizza la funzione*)
            if token='(' then
                begin
                    inc(oparen);
                    array_funzione[i]:='(';
                end
            else if token=')' then
                begin
                    inc(cparen);
                    array_funzione[i]:=')';
                end
            else if token='+' then array_funzione[i]:='+'
            else if token='-' then array_funzione[i]:='-'
            else if token='*' then array_funzione[i]:='*'
            else if token='/' then array_funzione[i]:='/'
            else if token='^' then array_funzione[i]:='^'
            else if (token='0') OR (token='1') OR (token='2') OR (token='3') OR
                    (token='4') OR (token='5') OR (token='6') OR (token='7') OR
                    (token='8') OR (token='9') then array_funzione[i]:=token
            else if (token='x') OR (token='X') then array_funzione[i]:='X'
            else
                array_funzione[i]:=token;
        end;
    AnalizzaDati;
end;

(********************************************************************
*   Funzioni e procedure per il grafico della funzione
********************************************************************)

procedure Abort(Msg:string);
begin
    (*E' occorso un errore molto grave*)
  Writeln(Msg,': ',GraphErrorMsg(GraphResult));
  Halt(1);
end;

procedure DisegnaTitolo(titolo:string);
begin
    SetViewPort(5,5,GetMaxX-5,25,ClipOn);
    ClearViewPort;
    SetViewPort(0,0,GetMaxX,GetMaxY,ClipOn);
    (*Creiamo la nostra mascherina del titolo*)
    SetColor(DarkGray);
    SetBkColor(Black);
    Line(5,5,GetMaxX-5,5);
    Line(5,5,5,25);
    Line(5,25,GetMaxX-5,25);
    Line(GetMaxX-5,5,GetMaxX-5,25);
    SetColor(Yellow);
    titolo:=Concat(titolo,funzione);
    SetTextStyle(DefaultFont,HorizDir,1);
    SetTextJustify(CenterText,CenterText);
    OutTextXY(GetMaxX div 2,15,titolo);
end;
(*******************************************************************)

procedure DisegnaMascherinaInformazioni;
var
    i:Integer;
    testo:string;
begin
    (*Impostiamo l'area di disegno*)
    SetViewPort(5,GetMaxY-50,GetMaxX-5,GetMaxY-40,ClipOn);
    ClearViewPort;
    SetViewPort(0,0,GetMaxX,GetMaxY,ClipOn);

    (*Iniziamo a disegnare*)
    SetColor(DarkGray);
    SetBkColor(Black);
    Line(5,GetMaxY-50,GetMaxX-5,GetMaxY-50);
    Line(5,GetMaxY-50,5,GetMaxY-40);
    Line(5,GetMaxY-40,GetMaxX-5,GetMaxY-40);
    Line(GetMaxX-5,GetMaxY-50,GetMaxX-5,GetMaxY-40);
    SetColor(LightGreen);
    SetTextStyle(DefaultFont,HorizDir,1);
    SetTextJustify(LeftText,TopText);
    if (Linee=True) then
        testo:='Linee'
    else
        testo:='Punti';
    OutTextXY(7,GetMaxY-48,testo);
    SetColor(DarkGray);
    Line(8+TextWidth(testo),GetMaxY-50,8+TextWidth(testo),GetMaxY-40);
    SetColor(LightBlue);
    if Dominio then
        OutTextXY(9+TextWidth(testo),GetMaxY-48,'Dominio');
    SetColor(DarkGray);
    Line(10+TextWidth(testo)+TextWidth('Dominio'),GetMaxY-50,10+TextWidth(testo)+TextWidth('Dominio'),GetMaxY-40);
    Str(scala*5/2:4:0,testo);
    testo:=Concat(testo,'%');
    SetColor(Red);
    OutTextXY(GetMaxX-TextWidth(testo)-5,GetMaxY-48,testo);
    SetColor(DarkGray);
    Line(12+TextWidth('Linee')+TextWidth('Dominio')+TextWidth('Radianti'),GetMaxY-50,
        12+TextWidth('Linee')+TextWidth('Dominio')+
        TextWidth('Radianti'),GetMaxY-40);
    Line(14+TextWidth('Linee')+TextWidth('Dominio')+TextWidth('Radianti')+TextWidth('Derivata'),GetMaxY-50,
        14+TextWidth('Linee')+
        TextWidth('Dominio')+TextWidth('Radianti')+TextWidth('Derivata'),GetMaxY-40);
    Line(16+TextWidth('Linee')+TextWidth('Dominio')+TextWidth('Radianti')+TextWidth('Derivata')+TextWidth('Griglia'),
        GetMaxY-50,
        16+TextWidth('Linee')+TextWidth('Dominio')+TextWidth('Radianti')+TextWidth('Derivata')+TextWidth('Griglia'),
        GetMaxY-40);
    SetColor(Yellow);
    if Radianti then
        OutTextXY(12+TextWidth('Linee')+TextWidth('Dominio'),GetMaxY-48,'Radianti');
    SetColor(LightMagenta);
    if DisegnaDerivata then
        OutTextXY(14+TextWidth('Linee')+TextWidth('Dominio')+TextWidth('Radianti'),GetMaxY-48,'Derivata');
    SetColor(Red);
    if Griglia then
        OutTextXY(16+TextWidth('Linee')+TextWidth('Dominio')+TextWidth('Radianti')+TextWidth('Derivata'),GetMaxY-48,'Griglia');
    SetColor(Cyan);
    i:=18+TextWidth('Linee')+TextWidth('Dominio')+TextWidth('Radianti')+TextWidth('Derivata')+TextWidth('Griglia');
    while (i<GetMaxX-TextWidth(testo)-5) do
        begin
            Line(i,GetMaxY-48,i,GetMaxY-42);
            Inc(i,risoluzione);
        end;
    SetColor(DarkGray);
    Line(GetMaxX-TextWidth(testo)-4,GetMaxY-50,GetMaxX-TextWidth(testo)-4,GetMaxY-40);
end;
(*******************************************************************)

procedure DisegnaMascherinaTasti;
begin
    SetViewPort(5,GetMaxY-35,GetMaxX-5,GetMaxY,ClipOn);
    ClearViewPort;
    SetViewPort(0,0,GetMaxX,GetMaxY,ClipOn);
    SetColor(DarkGray);
    SetBkColor(Black);
    Line(5,GetMaxY-35,GetMaxX-5,GetMaxY-35);
    Line(5,GetMaxY-35,5,GetMaxY-5);
    Line(GetMaxX-5,GetMaxY-35,GetMaxX-5,GetMaxY-5);
    Line(5,GetMaxY-5,GetMaxX-5,GetMaxY-5);
    SetColor(White);
    SetTextStyle(SmallFont,HorizDir,4);
    SetTextJustify(LeftText,TopText);
    OutTextXY(12,GetMaxY-35,'F1/F2 - Zoom +/-');
    OutTextXY(12,GetMaxY-20,'F3    - Punti/Linee');
    OutTextXY(130,GetMaxY-35,'F4    - Radianti/Interi');
    OutTextXY(130,GetMaxY-20,'F5/F6 - Risoluzione +/-');
    OutTextXY(273,GetMaxY-35,'F7  - Dominio');
    OutTextXY(273,GetMaxY-20,'F8  - Derivata');
    OutTextXY(362,GetMaxY-35,'F9      - Torna');
    OutTextXY(362,GetMaxY-20,'Cursori - Scorri');
    OutTextXY(462,GetMaxY-35,'F10   - Griglia');
    OutTextXY(462,GetMaxY-20,'INVIO - Rotazione');
    OutTextXY(562,GetMaxY-35,'ESC   - Esci');
end;
(*******************************************************************)

procedure DisegnaGriglia;
var
    row,col:real;
    fattore:real;
begin
    if NOT Radianti then
        fattore:=1
    else
        fattore:=Pi/2;
    if AsseYx1>=GetMaxX-6 then
        begin
            row:=AsseYx1;
            while row>0 do
                begin
                    col:=AsseXy1;
                    while col<GetMaxY-56 do
                        begin
                            PutPixel(Round(row),Round(col),Red);
                            col:=col+fattore*scala/2;
                        end;
                    row:=row-fattore*scala/2;
                end;
            row:=AsseYx1;
            while row>0 do
                begin
                    col:=AsseXy1;
                    while col<GetMaxY-56 do
                        begin
                            PutPixel(Round(row),Round(col),Red);
                            col:=col+fattore*scala/2;
                        end;
                    row:=row-fattore*scala/2;
                end;
            row:=AsseYx1;
            while row>0 do
                begin
                    col:=AsseXy1;
                    while col>0 do
                        begin
                            PutPixel(Round(row),Round(col),Red);
                            col:=col-fattore*scala/2;
                        end;
                    row:=row-fattore*scala/2;
                end;
            row:=AsseYx1;
            while row>0 do
                begin
                    col:=AsseXy1;
                    while col>0 do
                        begin
                            PutPixel(Round(row),Round(col),Red);
                            col:=col-fattore*scala/2;
                        end;
                    row:=row-fattore*scala/2;
            end;
        end
    else
        begin
            row:=AsseYx1;
            while row<GetMaxX-6 do
                begin
                    col:=AsseXy1;
                    while col<GetMaxY-56 do
                        begin
                            PutPixel(Round(row),Round(col),Red);
                            col:=col+fattore*scala/2;
                        end;
                    row:=row+fattore*scala/2;
                end;
            row:=AsseYx1;
            while row>0 do
                begin
                    col:=AsseXy1;
                    while col<GetMaxY-56 do
                        begin
                            PutPixel(Round(row),Round(col),Red);
                            col:=col+fattore*scala/2;
                        end;
                    row:=row-fattore*scala/2;
                end;
            row:=AsseYx1;
            while row<GetMaxX-6 do
                begin
                    col:=AsseXy1;
                    while col>0 do
                        begin
                            PutPixel(Round(row),Round(col),Red);
                            col:=col-fattore*scala/2;
                        end;
                    row:=row+fattore*scala/2;
                end;
            row:=AsseYx1;
            while row>0 do
                begin
                    col:=AsseXy1;
                    while col>0 do
                        begin
                            PutPixel(Round(row),Round(col),Red);
                            col:=col-fattore*scala/2;
                        end;
                    row:=row-fattore*scala/2;
            end;
        end;
end;
(*******************************************************************)

procedure DisegnaAssi;
var
    i:real;
    fattore:real;
begin
    SetViewPort(22,30,GetMaxX-5,GetMaxY-72,ClipOn);
    ClearViewPort;
    SetViewPort(0,0,GetMaxX,GetMaxY,ClipOn);

    if NOT Radianti then
        fattore:=1
    else
        fattore:=Pi;

    (*Creiamo la zona del grafico*)
    SetColor(DarkGray);
    SetBkColor(Black);
    Line(23,30,GetMaxX-5,30);
    Line(23,30,23,GetMaxY-75);
    Line(23,GetMaxY-75,GetMaxX-5,GetMaxY-75);
    Line(GetMaxX-5,30,GetMaxX-5,GetMaxY-75);

    SetViewPort(24,31,GetMaxX-6,GetMaxY-75,ClipOn);

    (*Assi cartesiani*)
    SetColor(White);
    Line(AsseYx1,AsseYy1,AsseYx2,AsseYy2);
    Line(AsseXx1,AsseXy1,AsseXx2,AsseXy2);

    SetColor(Brown);
    SetLineStyle(SolidLn,1,NormWidth);

    (*Costruiamo la nostra griglia sull'asse delle X*)
    i:=AsseYx1;
    while (i<GetMaxX-6) do
        begin
            Line(Round(i),AsseXy1+3,Round(i),AsseXy1-3);
            i:=i+fattore*scala;
        end;
    i:=AsseYx1;
    while (i<GetMaxX-6) do
        begin
            Line(Round(i),AsseXy1+2,Round(i),AsseXy1-2);
            i:=i+fattore*scala/2;
        end;
    i:=AsseYx1;
    while (i<GetMaxX-6) do
        begin
            Line(Round(i),AsseXy1+1,Round(i),AsseXy1-1);
            i:=i+fattore*scala/4;
        end;
    i:=AsseYx1;
    while (i>0) do
        begin
            Line(Round(i),AsseXy1+3,Round(i),AsseXy1-3);
            i:=i-fattore*scala;
        end;
    i:=AsseYx1;
    while (i>0) do
        begin
            Line(Round(i),AsseXy1+2,Round(i),AsseXy1-2);
            i:=i-fattore*scala/2;
        end;
    i:=AsseYx1;
    while (i>0) do
        begin
            Line(Round(i),AsseXy1+1,Round(i),AsseXy1-1);
            i:=i-fattore*scala/4;
        end;

    (*Costruiamo la nostra griglia sull'asse delle Y*)
    i:=AsseXy1;
    while (i<GetMaxY-56) do
        begin
            Line(AsseYx1+3,Round(i),AsseYx1-3,Round(i));
            i:=i+fattore*scala;
        end;
    i:=AsseXy1;
    while (i<GetMaxY-56) do
        begin
            Line(AsseYx1-2,Round(i),AsseYx1+2,Round(i));
            i:=i+fattore*scala/2;
        end;
    i:=AsseXy1;
    while (i<GetMaxY-56) do
        begin
            Line(AsseYx1+1,Round(i),AsseYx1-1,Round(i));
            i:=i+fattore*scala/4;
        end;
    i:=AsseXy1;
    while (i>0) do
        begin
            Line(AsseYx1+3,Round(i),AsseYx1-3,Round(i));
            i:=i-fattore*scala;
        end;
    i:=AsseXy1;
    while (i>0) do
        begin
            Line(AsseYx1-2,Round(i),AsseYx1+2,Round(i));
            i:=i-fattore*scala/2;
        end;
    i:=AsseXy1;
    while (i>0) do
        begin
            Line(AsseYx1+1,Round(i),AsseYx1-1,Round(i));
            i:=i-fattore*scala/4;
        end;
    if Griglia then
        DisegnaGriglia;
    DisegnaAssiSussidiari;
end;
(*******************************************************************)

procedure DisegnaAssiSussidiari;
var
    i:real;
    fattore:real;
begin
    (*Inizializzazione variabili*)
    PuntiSx:=0;
    PuntiDx:=0;
    if NOT Radianti then
        fattore:=1
    else
        fattore:=Pi;

    SetViewPort(5,30,21,GetMaxY-56,ClipOn);
    ClearViewPort;
    SetViewPort(0,0,GetMaxX,GetMaxY,ClipOn);

    SetColor(DarkGray);
    Line(5,30,5,GetMaxY-75);
    Line(5,30,19,30);
    Line(19,30,19,GetMaxY-75);
    Line(5,GetMaxY-75,19,GetMaxY-75);

    SetViewPort(22,GetMaxY-72,GetMaxX-6,GetMaxY-56,ClipOn);
    ClearViewPort;
    SetViewPort(0,0,GetMaxX,GetMaxY,ClipOn);

    Line(23,GetMaxY-72,GetMaxX-5,GetMaxY-72);
    Line(23,GetMaxY-72,23,GetMaxY-56);
    Line(23,GetMaxY-56,GetMaxX-5,GetMaxY-56);
    Line(GetMaxX-5,GetMaxY-72,GetMaxX-5,GetMaxY-56);

    SetColor(Brown);
    SetLineStyle(SolidLn,1,NormWidth);

    (*Costruiamo la nostra griglia sull'asse delle X*)
    SetViewPort(23,0,GetMaxX-6,GetMaxY,ClipOn);
    i:=AsseYx1;
    while (i<GetMaxX-6) do
        begin
            Line(Round(i),GetMaxY-64,Round(i),GetMaxY-57);
            i:=i+fattore*scala;
            Inc(PuntiDx);
        end;
    i:=AsseYx1;
    while (i<GetMaxX-6) do
        begin
            Line(Round(i),GetMaxY-62,Round(i),GetMaxY-57);
            i:=i+fattore*scala/2;
        end;
    i:=AsseYx1;
    while (i<GetMaxX-6) do
        begin
            Line(Round(i),GetMaxY-60,Round(i),GetMaxY-57);
            i:=i+fattore*scala/4;
        end;
    i:=AsseYx1;
    while (i>0) do
        begin
            Line(Round(i),GetMaxY-64,Round(i),GetMaxY-57);
            i:=i-fattore*scala;
            Inc(PuntiSx);
        end;
    i:=AsseYx1;
    while (i>0) do
        begin
            Line(Round(i),GetMaxY-62,Round(i),GetMaxY-57);
            i:=i-fattore*scala/2;
        end;
    i:=AsseYx1;
    while (i>0) do
        begin
            Line(Round(i),GetMaxY-60,Round(i),GetMaxY-57);
            i:=i-fattore*scala/4;
        end;

    (*Costruiamo la nostra griglia sull'asse delle Y*)
    SetViewPort(5,30,21,GetMaxY-76,ClipOn);
    i:=AsseXy1;
    while (i<GetMaxY) do
        begin
            Line(1,Round(i),7,Round(i));
            i:=i+fattore*scala;
        end;
    i:=AsseXy1;
    while (i<GetMaxY-85) do
        begin
            Line(1,Round(i),5,Round(i));
            i:=i+fattore*scala/2;
        end;
    i:=AsseXy1;
    while (i<GetMaxY-85) do
        begin
            Line(1,Round(i),3,Round(i));
            i:=i+fattore*scala/4;
        end;
    i:=AsseXy1;
    while (i>0) do
        begin
            Line(1,Round(i),7,Round(i));
            i:=i-fattore*scala;
        end;
    i:=AsseXy1;
    while (i>0) do
        begin
            Line(1,Round(i),5,Round(i));
            i:=i-fattore*scala/2;
        end;
    i:=AsseXy1;
    while (i>0) do
        begin
            Line(1,Round(i),3,Round(i));
            i:=i-fattore*scala/4;
        end;
    PuntiSx:=PuntiSx*3;
    PuntiDx:=PuntiDx*3;
    SetViewPort(0,0,GetMaxX,GetMaxY,ClipOn);
end;
(*******************************************************************)

procedure DisegnaNumeri;
var
    numero:real;
    pos:Integer;
    testo:string;
    aumento:Integer;
    posRad:real;
begin
    SetViewPort(23,31,GetMaxX-6,GetMaxY-75,ClipOn);

    SetColor(Yellow);
    SetTextStyle(SmallFont,HorizDir,2);
    SetTextJustify(LeftText,TopText);

    if NOT Radianti then
        begin
            aumento:=2;
            (*Prima parte: asse delle X*)
            numero:=0;
            pos:=AsseYx1+6;
            while (pos<GetMaxX-6) do
                begin
                    Str(numero:4:2,testo);
                    if (TextWidth(testo)+pos<(GetMaxX-6)) then
                        OutTextXY(pos,AsseXy1+5,testo);
                    Inc(pos,scala*aumento);
                    numero:=numero+aumento;
                end;
            numero:=-aumento;
            pos:=AsseYx1+6-(aumento-1)*scala;
            while (pos>6) do
                begin
                    Str(numero:4:2,testo);
                    if (pos-scala>6) then
                        OutTextXY(pos-scala,AsseXy1+5,testo);
                    Dec(pos,scala*aumento);
                    numero:=numero-aumento;
                end;
            (*Seconda parte: asse delle Y*)
            numero:=aumento;
            pos:=AsseXy1+3;
            while (pos>31) do
                begin
                    Str(numero:4:2,testo);
                    if (TextHeight(testo)+pos-aumento*scala>31) then
                        OutTextXY(AsseYx1-TextWidth(testo)-5,pos-aumento*scala-TextHeight(testo)-5,testo);
                    Dec(pos,scala*aumento);
                    numero:=numero+aumento;
                end;
            numero:=aumento;
            pos:=AsseXy1-3;
            while (pos<GetMaxY-56) do
                begin
                    Str(-numero:4:2,testo);
                    if (TextHeight(testo)+pos+aumento*scala<(GetMaxY-56)) then
                        OutTextXY(AsseYx1-TextWidth(testo)-5,pos+aumento*scala+TextHeight(testo)-5,testo);
                    Inc(pos,scala*aumento);
                    numero:=numero+aumento;
                end;
        end
    else
        begin
            aumento:=1;
            (*Prima parte: asse delle X*)
            numero:=0;
            posRad:=AsseYx1+3;
            while (posRad<GetMaxX-6) do
                begin
                    Str(numero:4:1,testo);
                    testo:=Concat(testo,'?');
                    if (TextWidth(testo)+Round(posRad)<(GetMaxX-6)) then
                        OutTextXY(Round(posRad),AsseXy1+5,testo);
                    posRad:=posRad+scala*Pi;
                    numero:=numero+aumento;
                end;
            numero:=-aumento;
            posRad:=AsseYx1+3-(Pi-1)*scala;
            while (posRad>6) do
                begin
                    Str(numero:4:1,testo);
                    testo:=Concat(testo,'?');
                    if (Round(posRad)-scala>6) then
                        OutTextXY(Round(posRad)-scala,AsseXy1+5,testo);
                    posRad:=posRad-scala*Pi;
                    numero:=numero-aumento;
                end;
            (*Seconda parte: asse delle Y*)
            numero:=aumento;
            posRad:=AsseXy1+3-scala*2;
            while (posRad>31) do
                begin
                    Str(numero:4:1,testo);
                    testo:=Concat(testo,'?');
                    if (TextHeight(testo)+Round(posRad)-aumento*scala>31) then
                        OutTextXY(AsseYx1-TextWidth(testo)-5,Round(posRad)-aumento*scala-TextHeight(testo)-5,testo);
                    posRad:=posRad-scala*Pi;
                    numero:=numero+aumento;
                end;
            numero:=aumento;
            posRad:=AsseXy1-3+scala*2;
            while (posRad<GetMaxY-56) do
                begin
                    Str(-numero:4:1,testo);
                    testo:=Concat(testo,'?');
                    if (TextHeight(testo)+Round(posRad)+aumento*scala<(GetMaxY-56)) then
                        OutTextXY(AsseYx1-TextWidth(testo)-5,Round(posRad)+aumento*scala+TextHeight(testo)-5,testo);
                    posRad:=posRad+scala*Pi;
                    numero:=numero+aumento;
                end;
        end;
end;
(*******************************************************************)

procedure DisegnaValore(x,y:Longint;color:Integer);
begin
    if Linee then
        begin
            SetColor(color);
            if (x+AsseYx1<32767) AND (x+AsseYx1>-32768) AND
                (-y+AsseXy1<32767) AND (-y+AsseXy1>-32768) then
                begin
                    if Disegna then
                        Line(x_precedente+AsseYx1,-y_precedente+AsseXy1,x+AsseYx1,-y+AsseXy1)
                    else
                        Disegna:=True;
                    (*Salviamo i nostri valori correnti*)
                    x_precedente:=x;
                    y_precedente:=y;
                end;
        end
    else
        begin
            if (x+AsseYx1<32767) AND (x+AsseYx1>-32768) AND
                (-y+AsseXy1<32767) AND (-y+AsseXy1>-32768) then
                PutPixel(x+AsseYx1,-y+AsseXy1,color);
        end;
end;
(*******************************************************************)

procedure Sostituisci(x:real);
var
    z:Integer;
    temp: array[1..100] of string;
begin
    for z:=1 to 100 do
        begin
            numero[z]:='';
            temp[z]:=array_funzione[z];
            array_funzione[z]:='';
        end;
    for z:=1 to 100 do
        begin
            array_funzione[z]:=temp[z];
        end;

    (*Copiamo il nostro array in un nuovo array*)
    for z:=1 to lunghezza_funzione do
        begin
            numero[z]:=array_funzione[z];
            if (numero[z]='X') then
                Str(x,numero[z]);
        end;
end;
(*******************************************************************)

procedure DisegnaDominio;
var
    col,row:Integer;
begin
    if (Round(errore_da*scala)+AsseYx1<32767) AND (Round(errore_da*scala)+AsseYx1>-32768) AND
        (Round(errore_a*scala)+AsseYx1<32767) AND (Round(errore_a*scala)+AsseYx1>-32768) then
        begin
            SetColor(LightBlue);
            Line(Round(errore_da*scala)+AsseYx1,0,Round(errore_da*scala)+AsseYx1,GetMaxY-56);
            Line(Round(errore_a*scala)+AsseYx1,0,Round(errore_a*scala)+AsseYx1,GetMaxY-56);
            col:=Round(errore_da*scala)+AsseYx1;
            if errore_da>errore_a then
                while col>Round(errore_a*scala)+AsseYx1 do
                    begin
                        row:=0;
                        while row<GetMaxY-56 do
                            begin
                                PutPixel(col,row,LightBlue);
                                Inc(row,5);
                            end;
                        Dec(col,5);
                    end
            else
                while col<Round(errore_a*scala)+AsseYx1 do
                    begin
                        row:=0;
                        while row<GetMaxY-56 do
                            begin
                                PutPixel(col,row,LightBlue);
                                Inc(row,5);
                            end;
                        Inc(col,5);
                    end;
        end;
end;
(*******************************************************************)

procedure DisegnaGrafico(flag:Boolean);
var
    k,z:Integer;
    x,y:extended;
    temp:array[1..100] of string;
    FuoriDominio,NonNelDominio:Boolean;
begin
    (*Copiamo il nostro array in un nuovo array*)
    for z:=1 to 100 do
        numero[z]:=array_funzione[z];

    (*Inizializzazione di alcune variabili*)
    lunghezza_funzione:=lunghezza;
    h:=risoluzione/20;
    k:=4;

    (*Impostiamo l'area in cui disegneremo*)
    SetViewPort(24,31,GetMaxX-6,GetMaxY-75,ClipOn);

    (*Azzeramento di alcune variabili*)
    num_valori:=0;
    for z:=1 to 500 do
        begin
            array_x[z]:=0;
            array_y[z]:=0;
        end;

    (*Disegnamo la curva dal centro a sinistra...*)
    x:=0;
    Disegna:=False;
    FuoriDominio:=False;
    NonNelDominio:=False;
    while (x>-PuntiSx) do
        begin
            Sostituisci(x);
            lunghezza:=lunghezza_funzione;
            Errore:=False;
            y:=CalcolaValore(1,lunghezza);
            if (y*scala<2147483647.0) AND (y*scala>-2147483648.0) AND NOT Errore then
                begin
                    if Limita then
                        begin
                            if (x*scala<dx*scala) AND (x*scala>sx*scala) AND flag then
                                DisegnaValore(Round(x*scala),Round(y*scala),LightGreen);
                        end
                    else if NOT Limita AND flag then
                        DisegnaValore(Round(x*scala),Round(y*scala),LightGreen);
                    if (k=4) AND ((Limita AND (x*scala<dx*scala) AND (x*scala>sx*scala)) OR
                        NOT Limita) then
                        begin
                            array_x[num_valori]:=x*scala;
                            if y<0 then
                                y:=-y;
                            array_y[num_valori]:=y*scala;
                            k:=1;
                            Inc(num_valori);
                        end
                    else if k<>4 then
                        Inc(k);
                end;
            if Errore then
                begin
                    if NOT NonNelDominio then
                        begin
                            Disegna:=False;
                            FuoriDominio:=True;
                            errore_da:=x;
                            errore_a:=x;
                            NonNelDominio:=True;
                        end
                    else
                        begin
                            errore_a:=x;
                        end;
                end
            else
                begin
                    if NonNelDominio AND Dominio then
                        DisegnaDominio;
                    FuoriDominio:=False;
                    NonNelDominio:=False;
                end;
            x:=x-h;
        end;
    if Dominio AND FuoriDominio then
        DisegnaDominio;
    (*... e dal centro a destra*)
    x_precedente:=0;
    y_precedente:=0;
    Disegna:=False;
    FuoriDominio:=False;
    NonNelDominio:=False;
    x:=0;
    while (x<PuntiDx) do
        begin
            Sostituisci(x);
            lunghezza:=lunghezza_funzione;
            Errore:=False;
            y:=CalcolaValore(1,lunghezza);
            if (y*scala<2147483647.0) AND (y*scala>-2147483648.0) AND NOT Errore then
                begin
                    if Limita then
                        begin
                            if (x*scala<dx*scala) AND (x*scala>sx*scala) AND flag then
                                DisegnaValore(Round(x*scala),Round(y*scala),LightGreen);
                        end
                    else if NOT Limita AND flag then
                        DisegnaValore(Round(x*scala),Round(y*scala),LightGreen);
                    if (k=4) AND ((Limita AND (x*scala<dx*scala) AND (x*scala>sx*scala)) OR
                        NOT Limita) then
                        begin
                            array_x[num_valori]:=x*scala;
                            if y<0 then
                                y:=-y;
                            array_y[num_valori]:=y*scala;
                            k:=1;
                            Inc(num_valori);
                        end
                    else if k<>4 then
                        Inc(k);
                end;
            if Errore then
                begin
                    if NOT NonNelDominio then
                        begin
                            Disegna:=False;
                            FuoriDominio:=True;
                            errore_da:=x;
                            errore_a:=x;
                            NonNelDominio:=True;
                        end
                    else
                        begin
                            errore_a:=x;
                        end;
                end
            else
                begin
                    if NonNelDominio AND Dominio then
                        DisegnaDominio;
                    FuoriDominio:=False;
                    NonNelDominio:=False;
                end;
            x:=x+h;
        end;
    if Dominio AND FuoriDominio then
        DisegnaDominio;

    lunghezza:=lunghezza_funzione;
    for z:=1 to 100 do
        begin
            numero[z]:='';
            temp[z]:=array_funzione[z];
            array_funzione[z]:='';
        end;
    for z:=1 to 100 do
        begin
            array_funzione[z]:=temp[z];
        end;
    x_precedente:=0;
    y_precedente:=0;
    Disegna:=False;
end;
(*******************************************************************)

procedure DisegnaMascherinaRotazione;
begin
    SetViewPort(5,GetMaxY-35,GetMaxX-5,GetMaxY,ClipOn);
    ClearViewPort;
    SetViewPort(0,0,GetMaxX,GetMaxY,ClipOn);
    SetColor(DarkGray);
    SetBkColor(Black);
    Line(5,GetMaxY-35,GetMaxX-5,GetMaxY-35);
    Line(5,GetMaxY-35,5,GetMaxY-5);
    Line(GetMaxX-5,GetMaxY-35,GetMaxX-5,GetMaxY-5);
    Line(5,GetMaxY-5,GetMaxX-5,GetMaxY-5);
    SetColor(White);
    SetTextStyle(SmallFont,HorizDir,4);
    SetTextJustify(LeftText,TopText);
    OutTextXY(15,GetMaxY-35,'F1/F2  - Zoom +/-');
    OutTextXY(15,GetMaxY-20,'F3     - Punti/Linee');
    OutTextXY(160,GetMaxY-35,'F5/F6   - Risoluzione +/-');
    OutTextXY(160,GetMaxY-20,'F10     - Griglia');
    OutTextXY(325,GetMaxY-35,'INVIO - Grafico');
    OutTextXY(325,GetMaxY-20,'ESC   - Esci');
end;
(*******************************************************************)

procedure VisualizzaGrafico;
var
    c:Char;
    LowMode,HiMode:Integer;
begin
    repeat
      (*Registrazione dei drivers grafici*)
    if RegisterBGIdriver(@CGADriverProc)<0 then
        Abort('CGA');
      if RegisterBGIdriver(@EGAVGADriverProc)<0 then
      Abort('EGA/VGA');
      if RegisterBGIdriver(@HercDriverProc)<0 then
      Abort('Herc');
      if RegisterBGIdriver(@ATTDriverProc)<0 then
      Abort('AT&T');
      if RegisterBGIdriver(@PC3270DriverProc)<0 then
      Abort('PC 3270');

        (*Registrazione dei font*)
    if RegisterBGIfont(@GothicFontProc)<0 then
        Abort('Gothic');
      if RegisterBGIfont(@SansSerifFontProc)<0 then
      Abort('SansSerif');
      if RegisterBGIfont(@SmallFontProc)<0 then
      Abort('Small');
      if RegisterBGIfont(@TriplexFontProc)<0 then
      Abort('Triplex');

        grDriver:=Detect;
        InitGraph(grDriver,grMode,path);
        ErrCode:=GraphResult;
        if ErrCode<>grOK then
            begin
                if ErrCode=grFileNotFound then
                    begin
                        (*Creiamo la nostra finestra*)
                        Window(1,1,80,25);
                        TextBackground(Black);
                        TextColor(LightGray);
                        ClrScr;
                        Writeln('Errore grafico: ', GraphErrorMsg(ErrCode));
                        Writeln;
                        Writeln('Se non si desidera immettere il percorso dei drivers ora, premere Esc');
                        c:=ReadChar;
                        if ord(c)<>27 then
                            begin
                                Writeln('Inserire il percorso dei drivers BGI:');
                                WriteLn;
                                Readln(path);
                            end
                        else
                            ErrCode:=grOK;
                    end
                else
                    begin
                        Writeln('Errore grafico: ', GraphErrorMsg(ErrCode));
                        Delay(5000);
                        Halt(1);
                    end;
            end;
    until ErrCode=grOK;

    (*Impostiamo alcune caratteristiche della modalit? grafica*)
    GetModeRange(grDriver,LowMode,HiMode);
    SetGraphMode(HiMode);

    if ord(c)<>27 then
        begin
            if Grafico_Rotazione then
                Grafico
            else
                Rotazione;
        end;
        CloseGraph;
end;
(*******************************************************************)

procedure Grafico;
var
    ch:Char;
    done:Boolean;
begin
    if NOT InizializzatoX then
        begin
            AsseXx1:=0;
            AsseXy1:=GetMaxY div 2;
            AsseXx2:=GetMaxX;
            AsseXy2:=GetMaxY div 2;
            InizializzatoX:=True;
        end;
    if NOT InizializzatoY then
        begin
            AsseYx1:=GetMaxX div 2;
            AsseYy1:=0;
            AsseYx2:=GetMaxX div 2;
            AsseYy2:=GetMaxY;
            InizializzatoY:=True;
        end;
    DisegnaAssi;
    DisegnaNumeri;
    DisegnaMascherinaInformazioni;
    DisegnaMascherinaTasti;
    DisegnaTitolo('Grafico di Y=');
    DisegnaGrafico(True);
    Derivata;
    done:=False;
    repeat
        ch:=ReadChar;
        case ch of
            #13:    (*CR*)
                begin
                    done:=True;
                    (*Richiamo della procedura*)
                    Rotazione;
                end;
            #27:    (*ESC*)
                done:=True;
            #59:    (*F1*)
                begin
                    if scala<640 then
                        begin
                            scala:=scala*2;
                            DisegnaMascherinaInformazioni;
                            DisegnaAssi;
                            DisegnaNumeri;
                            DisegnaGrafico(True);
                            Derivata;
                        end
                    else
                        Beep;
                end;
            #60:    (*F2*)
                begin
                    if scala>20 then
                        begin
                            scala:=scala div 2;
                            DisegnaMascherinaInformazioni;
                            DisegnaAssi;
                            DisegnaNumeri;
                            DisegnaGrafico(True);
                            Derivata;
                        end
                    else
                        Beep;
                end;
            #61:    (*F3*)
                begin
                    Linee:=NOT Linee;
                    DisegnaMascherinaInformazioni;
                    if NOT Linee then
                        begin
                            DisegnaAssi;
                            DisegnaNumeri;
                        end;
                    DisegnaGrafico(True);
                    Derivata;
                end;
            #62:    (*F4*)
                begin
                    Radianti:=NOT Radianti;
                    DisegnaMascherinaInformazioni;
                    DisegnaAssi;
                    DisegnaNumeri;
                    DisegnaGrafico(True);
                    Derivata;
                end;
            #63:    (*F5*)
                begin
                    if risoluzione>1 then
                        begin
                            risoluzione:=risoluzione div 2;
                            DisegnaMascherinaInformazioni;
                            DisegnaAssi;
                            DisegnaNumeri;
                            DisegnaGrafico(True);
                            Derivata;
                        end
                    else
                        Beep;
                end;
            #64:    (*F6*)
                begin
                    if risoluzione<GetMaxX/40 then
                        begin
                            risoluzione:=risoluzione*2;
                            DisegnaMascherinaInformazioni;
                            DisegnaAssi;
                            DisegnaNumeri;
                            DisegnaGrafico(True);
                            Derivata;
                        end
                    else
                        Beep;
                end;
            #65:    (*F7*)
                begin
                    Dominio:=NOT Dominio;
                    DisegnaMascherinaInformazioni;
                    if NOT Dominio then
                        begin
                            DisegnaAssi;
                            DisegnaNumeri;
                        end;
                        DisegnaGrafico(True);
                        Derivata;
                end;
            #66:    (*F8*)
                begin
                    DisegnaDerivata:=NOT DisegnaDerivata;
                    DisegnaMascherinaInformazioni;
                    if NOT DisegnaDerivata then
                        begin
                            DisegnaAssi;
                            DisegnaNumeri;
                            DisegnaGrafico(True);
                        end;
                    Derivata;
                end;
      #67:  (*F9*)
        begin
            (*Assegnazione dei valori standard delle posizioni degli assi*)
                    AsseXx1:=0;
                    AsseXy1:=GetMaxY div 2;
                    AsseXx2:=GetMaxX;
                    AsseXy2:=GetMaxY div 2;
                    AsseYx1:=GetMaxX div 2;
                    AsseYy1:=0;
                    AsseYx2:=GetMaxX div 2;
                    AsseYy2:=GetMaxY;
            DisegnaMascherinaInformazioni;
                    DisegnaAssi;
                    DisegnaNumeri;
                    DisegnaGrafico(True);
                    Derivata;
                end;
            #68:    (*F10*)
                begin
                    Griglia:=NOT Griglia;
                    DisegnaMascherinaInformazioni;
                    DisegnaAssi;
                    DisegnaNumeri;
                    DisegnaGrafico(True);
                    Derivata;
                end;
            #72:    (*Freccia in alto*)
                begin
                    Inc(AsseXy1,30);
                    Inc(AsseXy2,30);
                    DisegnaAssi;
                    DisegnaNumeri;
                    DisegnaGrafico(True);
                    Derivata;
                end;
            #75:    (*Freccia a sinistra*)
                begin
                    Inc(AsseYx1,30);
                    Inc(AsseYx2,30);
                    DisegnaAssi;
                    DisegnaNumeri;
                    DisegnaGrafico(True);
                    Derivata;
                end;
            #77:    (*Freccia a destra*)
                begin
                    Dec(AsseYx1,30);
                    Dec(AsseYx2,30);
                    DisegnaAssi;
                    DisegnaNumeri;
                    DisegnaGrafico(True);
                    Derivata;
                end;
            #80:    (*Freccia in basso*)
                begin
                    Dec(AsseXy1,30);
                    Dec(AsseXy2,30);
                    DisegnaAssi;
                    DisegnaNumeri;
                    DisegnaGrafico(True);
                    Derivata;
                end;
            else
                Beep;
        end;
    until done;
end;
(*******************************************************************)

procedure Rotazione;
var
    ch:Char;
    old_griglia,old_dominio,old_derivata,old_linee,done:Boolean;
begin
    if NOT InizializzatoX then
        begin
            AsseXx1:=0;
            AsseXy1:=GetMaxY div 2;
            AsseXx2:=GetMaxX;
            AsseXy2:=GetMaxY div 2;
            InizializzatoX:=True;
        end;
    if NOT InizializzatoY then
        begin
            AsseYx1:=GetMaxX div 2;
            AsseYy1:=0;
            AsseYx2:=GetMaxX div 2;
            AsseYy2:=GetMaxY;
            InizializzatoY:=True;
        end;

    (*Salvataggio valori vecchi*)
    old_griglia:=Griglia;
    old_dominio:=Dominio;
    old_derivata:=DisegnaDerivata;
    old_linee:=Linee;

    (*Assegnazione dei nuovi valori (provvisori)*)
    Griglia:=False;
    Dominio:=False;
    DisegnaDerivata:=False;
    Linee:=True;

  (*Assegnazione dei valori standard delle posizioni degli assi*)
    AsseXx1:=0;
    AsseXy1:=GetMaxY div 2;
    AsseXx2:=GetMaxX;
    AsseXy2:=GetMaxY div 2;
    AsseYx1:=GetMaxX div 2;
    AsseYy1:=0;
    AsseYx2:=GetMaxX div 2;
    AsseYy2:=GetMaxY;

    DisegnaAssi;
    DisegnaMascherinaInformazioni;
    DisegnaMascherinaRotazione;
    DisegnaTitolo('Grafico di rotazione di Y=');
    DisegnaGrafico(False);
    RuotaCurva;
    done:=False;
    repeat
        ch:=ReadChar;
        case ch of
            #13:    (*CR*)
                begin
                    done:=True;
                    (*Ripristino dei valori vecchi*)
                    Griglia:=old_griglia;
                    Dominio:=old_dominio;
                    DisegnaDerivata:=old_derivata;
                    Linee:=old_linee;
                    (*Richiamo della procedura*)
                    Grafico;
                end;
            #27:    (*ESC*)
                done:=True;
            #59:    (*F1*)
                begin
                    if scala<640 then
                        begin
                            scala:=scala*2;
                            DisegnaMascherinaInformazioni;
                            DisegnaAssi;
                            DisegnaGrafico(False);
                            RuotaCurva;
                        end
                    else
                        Beep;
                end;
            #60:    (*F2*)
                begin
                    if scala>20 then
                        begin
                            scala:=scala div 2;
                            DisegnaMascherinaInformazioni;
                            DisegnaAssi;
                            DisegnaGrafico(False);
                            RuotaCurva;
                        end
                    else
                        Beep;
                end;
            #61:    (*F3*)
                begin
                    Linee:=NOT Linee;
                    DisegnaMascherinaInformazioni;
                    DisegnaAssi;
                    DisegnaGrafico(False);
                    RuotaCurva;
                end;
            #63:    (*F5*)
                begin
                    if risoluzione>1 then
                        begin
                            risoluzione:=risoluzione div 2;
                            DisegnaMascherinaInformazioni;
                            DisegnaAssi;
                            DisegnaGrafico(False);
                            RuotaCurva;
                        end
                    else
                        Beep;
                end;
            #64:    (*F6*)
                begin
                    if risoluzione<GetMaxX/40 then
                        begin
                            risoluzione:=risoluzione*2;
                            DisegnaMascherinaInformazioni;
                            DisegnaAssi;
                            DisegnaGrafico(False);
                            RuotaCurva;
                        end
                    else
                        Beep;
                end;
            #68:    (*F10*)
                begin
                    Griglia:=NOT Griglia;
                    DisegnaMascherinaInformazioni;
                    DisegnaAssi;
                    DisegnaGrafico(False);
                    RuotaCurva;
                end;
            else
                Beep;
        end;
    until done;

    (*Ripristino dei valori vecchi*)
    Griglia:=old_griglia;
    Dominio:=old_dominio;
    DisegnaDerivata:=old_derivata;
    Linee:=old_linee;
end;
(*******************************************************************)

procedure Derivata;
var
    x,y,y1,y2:extended;
    old_linee,return_value:Boolean;
    z:Integer;
    temp:array[1..100] of string;
begin
    if DisegnaDerivata then
        begin
            (*Salviamo alcuni valori*)
            old_linee:=Linee;
            Linee:=False;

            (*Copiamo il nostro array in un nuovo array*)
            for z:=1 to 100 do
                numero[z]:=array_funzione[z];
            lunghezza_funzione:=lunghezza;

            (*Impostiamo l'area di disegno*)
            SetViewPort(24,31,GetMaxX-6,GetMaxY-75,ClipOn);

            (*Disegnamo la derivata dal centro a destra...*)
            Disegna:=False;
            x_precedente:=0;
            y_precedente:=0;
            x:=0;
            h:=1/100;
            while x<PuntiDx do
                begin
                    Errore:=False;
                    Sostituisci(x+0.01);
                    lunghezza:=lunghezza_funzione;
                    y1:=CalcolaValore(1,lunghezza);
                    if Errore then
                        begin
                            Disegna:=False;
                            Errore:=False;
                            Sostituisci(x);
                            lunghezza:=lunghezza_funzione;
                            y:=CalcolaValore(1,lunghezza);
                            if NOT Errore then
                                begin
                                    PutPixel(AsseYx1+Round(x*scala),AsseXy1-Round(y*scala),White);
                                    PutPixel(AsseYx1+Round(x*scala)-1,AsseXy1-Round(y*scala)-1,White);
                                    PutPixel(AsseYx1+Round(x*scala),AsseXy1-Round(y*scala)-1,White);
                                    PutPixel(AsseYx1+Round(x*scala)-1,AsseXy1-Round(y*scala),White);
                                end;
                        end
                    else if NOT Errore then
                        begin
                            Sostituisci(x-0.01);
                            lunghezza:=lunghezza_funzione;
                            y2:=CalcolaValore(1,lunghezza);
                            y:=(y1-y2)/0.02;
                            if (Errore) OR ((y*scala<2147483647.0) AND (y*scala>-2147483648.0) AND (Round(y*scala)=0)) then
                                begin
                                    Disegna:=False;
                                    Errore:=False;
                                    Sostituisci(x);
                                    lunghezza:=lunghezza_funzione;
                                    y:=CalcolaValore(1,lunghezza);
                                    if NOT Errore then
                                        begin
                                            PutPixel(AsseYx1+Round(x*scala),AsseXy1-Round(y*scala),White);
                                            PutPixel(AsseYx1+Round(x*scala)-1,AsseXy1-Round(y*scala)-1,White);
                                            PutPixel(AsseYx1+Round(x*scala),AsseXy1-Round(y*scala)-1,White);
                                            PutPixel(AsseYx1+Round(x*scala)-1,AsseXy1-Round(y*scala),White);
                                        end;
                                end
                            else if (y*scala<2147483647.0) AND (y*scala>-2147483648.0) AND NOT Errore then
                                begin
                                    if Limita then
                                        begin
                                            if (x*scala<dx*scala) AND (x*scala>sx*scala) then
                                                DisegnaValore(Round(x*scala),Round(y*scala),LightMagenta);
                                        end
                                    else if NOT Limita then
                                        DisegnaValore(Round(x*scala),Round(y*scala),LightMagenta)
                                end
                            else if Errore then
                                Disegna:=False;
                        end
                    else
                        Disegna:=False;
                    x:=x+h;
                end;

            (*... e dal centro a sinistra*)
            Disegna:=False;
            x_precedente:=0;
            y_precedente:=0;
            x:=0;
            while x>-PuntiSx do
                begin
                    Disegna:=False;
                    Errore:=False;
                    Sostituisci(x+0.01);
                    lunghezza:=lunghezza_funzione;
                    y1:=CalcolaValore(1,lunghezza);
                    if Errore then
                        begin
                            Errore:=False;
                            Sostituisci(x);
                            lunghezza:=lunghezza_funzione;
                            y:=CalcolaValore(1,lunghezza);
                            if NOT Errore then
                                begin
                                    PutPixel(AsseYx1+Round(x*scala),AsseXy1-Round(y*scala),White);
                                    PutPixel(AsseYx1+Round(x*scala)-1,AsseXy1-Round(y*scala)-1,White);
                                    PutPixel(AsseYx1+Round(x*scala),AsseXy1-Round(y*scala)-1,White);
                                    PutPixel(AsseYx1+Round(x*scala)-1,AsseXy1-Round(y*scala),White);
                                end;
                        end
                    else if NOT Errore then
                        begin
                            Sostituisci(x-0.01);
                            lunghezza:=lunghezza_funzione;
                            y2:=CalcolaValore(1,lunghezza);
                            y:=(y1-y2)/0.02;
                            if (Errore) OR ((y*scala<2147483647.0) AND (y*scala>-2147483648.0) AND (Round(y*scala)=0)) then
                                begin
                                    Disegna:=False;
                                    Errore:=False;
                                    Sostituisci(x);
                                    lunghezza:=lunghezza_funzione;
                                    y:=CalcolaValore(1,lunghezza);
                                    if NOT Errore then
                                        begin
                                            PutPixel(AsseYx1+Round(x*scala),AsseXy1-Round(y*scala),White);
                                            PutPixel(AsseYx1+Round(x*scala)-1,AsseXy1-Round(y*scala)-1,White);
                                            PutPixel(AsseYx1+Round(x*scala),AsseXy1-Round(y*scala)-1,White);
                                            PutPixel(AsseYx1+Round(x*scala)-1,AsseXy1-Round(y*scala),White);
                                        end;
                                end
                            else if (y*scala<2147483647.0) AND (y*scala>-2147483648.0) AND NOT Errore then
                                begin
                                    if Limita then
                                        begin
                                            if (x*scala<dx*scala) AND (x*scala>sx*scala) then
                                                DisegnaValore(Round(x*scala),Round(y*scala),LightMagenta);
                                        end
                                    else if NOT Limita then
                                        DisegnaValore(Round(x*scala),Round(y*scala),LightMagenta)
                                end
                            else if Errore then
                                Disegna:=False;
                        end
                    else
                        Disegna:=False;
                    x:=x-h;
                end;

            lunghezza:=lunghezza_funzione;
            for z:=1 to 100 do
                begin
                    numero[z]:='';
                    temp[z]:=array_funzione[z];
                    array_funzione[z]:='';
                end;
            for z:=1 to 100 do
                begin
                    array_funzione[z]:=temp[z];
                end;
            x_precedente:=0;
            y_precedente:=0;
            (*Ripristiniamo i valori salvati*)
            Linee:=old_linee;
        end;
end;
(*******************************************************************)

procedure RuotaCurva;
var
    theta,alpha,n,i,k:Integer;
    x_succ1,y_succ1,x_succ2,y_succ2,x_prec,y_prec,x,y:extended;
    sin_look,cos_look:array[1..360] of real;
    temp:real;
    Congiungi:Boolean;
begin
    (*Preparazione delle SIN e COS lookup tables*)
    for i:=1 to 360 do
        begin
            sin_look[i]:=sin(i*Pi/180);
            cos_look[i]:=cos(i*Pi/180);
        end;

    (*Inizializzazione di alcune variabili*)
    alpha:=330;
    theta:=1;
    x_prec:=0;
    y_prec:=0;
    Congiungi:=False;

    (*Impostiamo il colore ed il tipo di fill*)
    SetColor(Yellow);
    SetFillStyle(SolidFill,LightBlue);

    (*Impostiamo la zona di schermo in cui disegneremo*)
    SetViewPort(24,31,GetMaxX-6,GetMaxY-76,ClipOn);

    (*Ordiniamo i nostri arrays di valori (in base alla x, ordine crescente)*)
    for i:=1 to num_valori-1 do
        begin
            for k:=i+1 to num_valori-1 do
                if array_x[i]>array_x[k] then
                    begin
                        temp:=array_x[i];
                        array_x[i]:=array_x[k];
                        array_x[k]:=temp;
                        temp:=array_y[i];
                        array_y[i]:=array_y[k];
                        array_y[k]:=temp;
                    end;
        end;

    (*Controllo sui valori immagazzinati*)
    k:=num_valori-1;
    for i:=1 to k do
        begin
            if (AsseXy1-array_y[i]<0) OR (AsseXy1-array_y[i]>GetMaxY)
                OR (AsseYx1-array_x[i]<0) OR (AsseYx1-array_x[i]>GetMaxX) then
                begin
                    for n:=i to k do
                        begin
                            array_x[n]:=array_x[n+1];
                            array_y[n]:=array_y[n+1];
                        end;
                    Dec(num_valori);
                    Dec(i);
                end;
        end;

    (*Avevamo incrementato di un valore in pi? la variabile "num_valori" durante il salvataggio dei punti*)
    Dec(num_valori);

    (*Ciclo per il calcolo ed il disegno dei punti sullo schermo*)
    while alpha>=180 do
        begin
            for i:=1 to num_valori do
                begin
                    x:=array_x[i]-array_y[i]*sin_look[alpha]*sin_look[theta];
                    y:=array_y[i]*cos_look[alpha]-array_y[i]*sin_look[alpha]*cos_look[theta];
                    if (AsseXy1-Round(y)>-32768) AND (AsseXy1-Round(y)<32767) then
                        begin
                            if NOT Linee then
                                begin
                                    PutPixel(AsseYx1+Round(x),AsseXy1-Round(y),Yellow);
                                end
                            else
                                begin
                                    if Congiungi then
                                        begin
                                            if (AsseXy1-Round(y_prec)>-32768) AND (AsseXy1-Round(y_prec)<32767) then
                                                begin
                                                    vertici[1].x:=AsseYx1+Round(x);
                                                    vertici[1].y:=AsseXy1-Round(y);
                                                    vertici[2].x:=AsseYx1+Round(x_prec);
                                                    vertici[2].y:=AsseXy1-Round(y_prec);
                                                    if (i>0) then
                                                        begin
                                                            x_succ1:=array_x[i]-array_y[i]*sin_look[alpha-5]*sin_look[theta];
                                                            y_succ1:=array_y[i]*cos_look[alpha-5]-array_y[i]*sin_look[alpha-5]
                                                                    *cos_look[theta];
                                                            x_succ2:=array_x[i-1]-array_y[i-1]*sin_look[alpha-5]
                                                                    *sin_look[theta];
                                                            y_succ2:=array_y[i-1]*cos_look[alpha-5]-array_y[i-1]
                                                                    *sin_look[alpha-5]*cos_look[theta];
                                                            if (x_succ1>-32768) AND (x_succ1<32767) AND (y_succ1>-32768) AND
                                                                (y_succ1<32767) AND (x_succ2>-32768)
                                                                AND (x_succ2<32767) AND (y_succ2>-32768) AND (y_succ2<32767)
                                                                then
                                                                begin
                                                                    vertici[3].x:=AsseYx1+Round(x_succ2);
                                                                    vertici[3].y:=AsseXy1-Round(y_succ2);
                                                                    vertici[4].x:=AsseYx1+Round(x_succ1);
                                                                    vertici[4].y:=AsseXy1-Round(y_succ1);
                                                                    FillPoly(4,vertici);
                                                                end;
                                                        end;
                                                end
                                            else
                                                Congiungi:=False;
                                        end
                                    else
                                        Congiungi:=True;
                                end;
                        end;
                    x_prec:=x;
                    y_prec:=y;
                end;
            Dec(alpha,5);
            Congiungi:=False;
        end;
end;

(********************************************************************
*   Funzioni e procedure per le finestre del programma
********************************************************************)

function ReadChar:Char;
var
    ch:Char;
begin
    ch:=ReadKey;
    if ch=#0 then
        ch:=ReadKey;
    ReadChar:=ch;
end;
(*******************************************************************)

procedure Beep;
begin
    NoSound;
    Sound(2000);
    Delay(150);
    NoSound;
end;
(*******************************************************************)

procedure SchermataDiBenvenuto;
var
    c:Char;
begin
    (*Creiamo la nostra finestra*)
    Window(1,1,80,25);
    TextBackground(Black);
    TextColor(LightBlue);
  ClrScr;
    Writeln('                     ANALIZZATORE DI FUNZIONI MATEMATICHE - 4');
    Writeln('                           di Marco Olivo, 1998,1999');
    Writeln;
    Writeln;
    TextColor(Yellow);
    Writeln(' Questo programma ? in grado di tracciare il grafico approssimato di una');
    Writeln(' qualsiasi funzione. Queste sono le funzioni permesse dal programma:');
    Writeln;
    TextColor(White);
    Writeln(' arcsen/arcsin(x)                    ????????>  arco-seno di x');
    Writeln(' arccos(x)                           ????????>  arco-coseno di x');
    Writeln(' arccotg/arccotag/arccotan(x)        ????????>  arco-cotangente di x');
    Writeln(' sen/sin(x)                          ????????>  seno di x');
    Writeln(' cos(x)                              ????????>  coseno di x');
    Writeln(' tan/tag/tg(x)                       ????????>  tangente di x');
    Writeln(' arctan/arctag/atag/atan             ????????>  arco-tangente di x');
    Writeln(' cotan/cotag/cotg(x)                 ????????>  cotangente di x');
    Writeln(' log/ln(x)                           ????????>  logaritmo naturale di x');
    Writeln(' a^x,e^x                             ????????>  elevamento ad esponente x');
    Writeln(' abs,sgn(x)                          ????????>  valore assoluto, segno di x');
    Writeln(' sqr,sqrt(x)                         ????????>  quadrato, radice quadrata');
    Writeln(' sinh,cosh,tanh(x)                   ????????>  sin, cos, tan iperbolici');
    Writeln(' asinh,acosh,atanh(x)                ????????>  asin, acos, atan iperbolici');
    Writeln(' int(x)                              ????????>  parte intera di x');
    Writeln;
    TextColor(LightCyan+Blink);
    Writeln('                    Premere un tasto per iniziare il programma');
    Beep;
    c:=ReadKey;
end;
(*******************************************************************)

procedure Messaggio(testo:string);
var
    lunghezza_messaggio:Integer;
    k:Integer;
begin
    TextColor(Yellow);
    TextBackground(Blue);
    Window(2,24,79,25);
    GotoXY(1,1);
    Write(' ');
    lunghezza_messaggio:=Length(testo);
    if (lunghezza_messaggio<=75) then
        begin
            Write(testo);
            for k:=1+lunghezza_messaggio to 77 do
                Write(' ');
        end;
end;
(*******************************************************************)

procedure MenuPrincipale;
begin
    TextBackground(Black);
    TextColor(Yellow);
    Window(1,1,80,25);
    GotoXY(25,4);
    Write('Men? principale');

    (*Creiamo la nostra finestra*)
    Window(4,5,58,21);
    TextBackground(Black);
    ClrScr;
    (*Scriviamo nella nostra finestra*)
    TextColor(LightGreen);
    GotoXY(12,17);
    Write('Freccia Su/Gi?: cambiamento funzione');
    TextColor(White);
    GotoXY(10,2);
    Write('nserimento della funzione');
    GotoXY(10,4);
    Write('isualizzazione del grafico della funzione');
    GotoXY(10,5);
    Write('strapolazione dei punti dal grafico');
    GotoXY(10,6);
    Write('imitazione del dominio');
    GotoXY(10,7);
    Write('otazione della curva');
    GotoXY(9,9);
    Write('Informazioni/ uida');
    GotoXY(9,10);
    Write('V lori di default');
    GotoXY(10,12);
    Write('alvare lista funzioni');
    GotoXY(10,13);
    Write('aricare lista funzioni');
    GotoXY(10,15);
    Write('scita');
    TextColor(LightRed);
    GotoXY(9,2);
    Write('I');
    GotoXY(9,4);
    Write('V');
    GotoXY(9,5);
    Write('E');
    GotoXY(9,6);
    Write('L');
    GotoXY(9,7);
    Write('R');
    GotoXY(22,9);
    Write('g');
    GotoXY(10,10);
    Write('a');
    GotoXY(9,12);
    Write('S');
    GotoXY(9,13);
    Write('C');
    GotoXY(9,15);
    Write('U');
end;
(*******************************************************************)

procedure InserisciFunzione(espressione:string);
var
    i:Integer;
    posizione:Integer;
    ch:Char;
    done:Boolean;
    funzione_inserita,tasto:string;
begin
    TextBackground(Black);
    TextColor(Yellow);
    Window(1,1,80,25);
    GotoXY(22,4);
    Write('Inserimento funzione');

    (*Creiamo la nostra finestra*)
    Window(4,5,58,21);
    TextBackground(Black);
    ClrScr;
    TextColor(White);
    (*Richiediamo la funzione*)
    Writeln;
    Writeln('Immettere la funzione y=f(x) da valutare:');
    Writeln;
    TextColor(LightGray);
    Writeln('y=');
    TextColor(LightGreen);
    GotoXY(15,16);
    Writeln('Freccia Su/Gi?: cambiamento funzione');
    GotoXY(25,17);
    Write('Esc: esci');
    TextColor(LightGray);
    GotoXY(3,4);
    funzione:='';
    funzione_inserita:=espressione;
    if espressione<>'' then
        Write(espressione)
    else
        begin
            Write(lista_funzioni[funzione_corrente]);
            funzione_inserita:=lista_funzioni[funzione_corrente];
        end;
    posizione:=Length(funzione_inserita)+2;
    done:=False;
    GotoXY(1+posizione,4);

    repeat
        ch:=ReadChar;
        case ch of
            #8: (*BS*)
                begin
                    if posizione>2 then
                        begin
                            tasto:='';
                            for i:=1 to (posizione-3) do
                                tasto:=Concat(tasto,funzione_inserita[i]);
                            funzione_inserita:=tasto;
                            (*Creiamo la nostra finestra*)
                            Window(4,5,58,21);
                            TextColor(LightGray);
                            TextBackground(Black);
                            GotoXY(posizione,4);
                            Write(' ');
                            Dec(posizione);
                            GotoXY(1+posizione,4);
                        end;
                    if posizione=2 then
                        funzione_inserita:='';
                end;
            #13:    (*CR*)
                done:=True;
            #27:    (*ESC*)
                begin
                    done:=True;
                    funzione_inserita:='';
                end;
            #72:    (*Freccia in alto*)
                begin
                    if funzione_corrente>1 then
                        begin
                            SelezionaFunzione(funzione_corrente-1,funzione_corrente);
                            Dec(funzione_corrente);
                            if lista_funzioni[funzione_corrente]<>'' then
                                Messaggio(lista_funzioni[funzione_corrente])
                            else
                                Messaggio('Consultare la guida in linea per maggiori informazioni sul programma');
                            (*Creiamo la nostra finestra*)
                            Window(4,5,58,21);
                            TextColor(LightGray);
                            TextBackground(Black);
                            for i:=3 to 57 do
                                begin
                                    GotoXY(i,4);
                                    Write(' ');
                                end;
                            GotoXY(3,4);
                            Write(lista_funzioni[funzione_corrente]);
                            funzione_inserita:=lista_funzioni[funzione_corrente];
                            posizione:=Length(funzione_inserita)+2;
                            GotoXY(1+posizione,4);
                        end
                    else
                        Beep;
                end;
            #75,#77:    (*Freccia a sinistra, freccia a destra*)
                Beep;
            #80:    (*Freccia in basso*)
                begin
                    if funzione_corrente<16 then
                        begin
                            SelezionaFunzione(funzione_corrente+1,funzione_corrente);
                            Inc(funzione_corrente);
                            if lista_funzioni[funzione_corrente]<>'' then
                                Messaggio(lista_funzioni[funzione_corrente])
                            else
                                Messaggio('Consultare la guida in linea per maggiori informazioni sul programma');
                            (*Creiamo la nostra finestra*)
                            Window(4,5,58,21);
                            TextColor(LightGray);
                            TextBackground(Black);
                            for i:=3 to 57 do
                                begin
                                    GotoXY(i,4);
                                    Write(' ');
                                end;
                            GotoXY(3,4);
                            Write(lista_funzioni[funzione_corrente]);
                            funzione_inserita:=lista_funzioni[funzione_corrente];
                            posizione:=Length(funzione_inserita)+2;
                            GotoXY(1+posizione,4);
                        end
                    else
                        Beep;
                end;
            else
                case ch of
                    'A'..'Z','a'..'z','0'..'9','+', '-', '*', '/','^','(',')':
                        begin
                            if posizione<54 then
                                begin
                                    tasto:=ch;
                                    funzione_inserita:=Concat(funzione_inserita,tasto);
                                    Inc(posizione);
                                    (*Creiamo la nostra finestra*)
                                    Window(4,5,58,21);
                                    TextColor(LightGray);
                                    TextBackground(Black);
                                    GotoXY(posizione,4);
                                    Write(tasto);
                                end
                            else
                                Beep;
                        end;
                    else
                        Beep;
                end;
        end;
    until done;
    if funzione_inserita='' then
        funzione_inserita:=lista_funzioni[funzione_corrente];
    lunghezza:=Length(funzione_inserita);
    funzione:=funzione_inserita;
    if lunghezza>0 then
        begin
            (*Facciamo di modo che la nostra stringa sia tutta in maiuscolo*)
            for i:=1 to lunghezza do
                funzione[i]:=UpCase(funzione_inserita[i]);
            LeggiFunzione;
            if (ControllaSintassi=True) then
                begin
                    CalcolaPrecedenze;
                    (*Scriviamo la funzione nel nostro array delle ultime 16 funzioni*)
                    lista_funzioni[funzione_corrente]:=funzione_inserita;
                    if numero_funzioni<funzione_corrente then
                        numero_funzioni:=funzione_corrente;
                    Messaggio('E'' ora possibile visualizzare il grafico');
                end
            else
                InserisciFunzione(funzione_inserita);
        end
    else
        begin
            funzione_inserita:=lista_funzioni[funzione_corrente];
            (*Facciamo di modo che la nostra stringa sia tutta in maiuscolo*)
            for i:=1 to lunghezza do
                funzione[i]:=UpCase(funzione_inserita[i]);
            LeggiFunzione;
            if (ControllaSintassi=True) then
                begin
                    CalcolaPrecedenze;
                    (*Scriviamo la funzione nel nostro array delle ultime 16 funzioni*)
                    lista_funzioni[funzione_corrente]:=funzione_inserita;
                    if numero_funzioni<funzione_corrente then
                        numero_funzioni:=funzione_corrente;
                    Messaggio('E'' ora possibile visualizzare il grafico');
                end
            else
                InserisciFunzione(funzione_inserita);
        end;
end;
(*******************************************************************)

procedure EstrapolaPunti;
var
    ascissa:string;
    number:real;
    code:Integer;
    c:Char;
    valore:extended;
begin
    TextBackground(Black);
    TextColor(Yellow);
    Window(1,1,80,25);
    GotoXY(22,4);
    Write('Estrapolazione punti');

    (*Creiamo la nostra finestra*)
    Window(4,5,58,21);
    TextBackground(Black);
    ClrScr;
    TextColor(White);
    Writeln;
    Writeln('Inserire l''ascissa del punto (INVIO=nessuna):');
    Writeln;
    TextColor(LightGray);
    Write('x=');
    GotoXY(3,4);
    Readln(ascissa);
    if ascissa<>'' then
        begin
            Val(ascissa,number,code);
            if code=0 then
                begin
                    lunghezza_funzione:=lunghezza;
                    Sostituisci(number);
                    TextColor(Red);
                    Writeln;
                    Errore:=False;
                    lunghezza_funzione:=lunghezza;
                    valore:=CalcolaValore(1,lunghezza);
                    if NOT Errore then
                        Writeln('L''ordinata del punto scelto ?: ',valore:8:8)
                    else
                        Writeln('Il valore scelto non appartiene al dominio');
                    lunghezza:=lunghezza_funzione;
                end
            else
                begin
                    TextColor(Yellow+Blink);
                    TextBackground(Red);
                    Writeln;
                    Writeln('   Errore: il valore inserito non ? un numero reale    ');
                end;
            c:=ReadKey;
        end;
end;
(*******************************************************************)

procedure LimitaDominio;
var
    margine_dx,margine_sx:string;
    code1,code2:Integer;
    c:Char;
begin
    TextBackground(Black);
    TextColor(Yellow);
    Window(1,1,80,25);
    GotoXY(20,4);
    Write('Limitazione del dominio');

    (*Creiamo la nostra finestra*)
    Window(4,5,58,21);
    TextBackground(Black);
    ClrScr;
    TextColor(White);
    if Conferma('Si ? proprio sicuri di voler limitare il dominio?') then
        begin
            ClrScr;
            Writeln;
            Writeln('Inserire l''estremo sinistro:');
            Writeln;
            TextColor(LightGray);
            Readln(margine_sx);
            Writeln;
            TextColor(White);
            Writeln('Inserire l''estremo destro:');
            Writeln;
            TextColor(LightGray);
            Readln(margine_dx);
            Val(margine_sx,sx,code1);
            Val(margine_dx,dx,code2);
            if (code1=0) AND (code2=0) then
                begin
                    if sx>dx then
                        begin
                            TextColor(Yellow+Blink);
                            TextBackground(Red);
                            Writeln;
                            Writeln('    Errore: il margine SX ? maggiore del margine DX    ');
                            Limita:=False;
                            c:=ReadKey;
                        end
                    else
                        Limita:=True;
                end
            else
                begin
                    TextColor(Yellow+Blink);
                    TextBackground(Red);
                    Writeln;
                    Writeln('            Errore: il valore non ? reale              ');
                    Limita:=False;
                    c:=ReadKey;
                end;
        end
    else
        Limita:=False;
end;
(*******************************************************************)

procedure Informazioni_Guida;
begin
    SchermataDiBenvenuto;
end;
(*******************************************************************)

function Conferma(testo:string):Boolean;
var
    ch:Char;
    done,scelta:Boolean;
begin
    (*Creiamo la nostra finestra*)
    Window(4,5,58,21);
    TextBackground(Black);
    ClrScr;
    TextColor(LightGray);
    (*Scriviamo nella nostra finestra*)
    Writeln;
    Writeln(testo);
    TextBackground(Red);
    TextColor(Black);
    GotoXY(18,6);
    Write('   S?   ');
    TextBackground(Black);
    TextColor(White);
    GotoXY(32,6);
    Write('   No   ');
    done:=False;
    scelta:=True;
    repeat
        ch:=ReadChar;
        case ch of
            #13:    (*CR*)
                begin
                    done:=True;
                    scelta:=scelta;
                end;
            #27:    (*ESC*)
                begin
                    done:=True;
                    scelta:=False;
                end;
            's','S':
                begin
                    done:=True;
                    scelta:=True;
                end;
            'n','N':
                begin
                    done:=True;
                    scelta:=False;
                end;
            #75:    (*Freccia a sinistra*)
                begin
                    scelta:=True;
                    TextBackground(Red);
                    TextColor(Black);
                    GotoXY(18,6);
                    Write('   S?   ');
                    TextBackground(Black);
                    TextColor(White);
                    GotoXY(32,6);
                    Write('   No   ');
                end;
            #77:    (*Freccia a destra*)
                begin
                    scelta:=False;
                    TextBackground(Black);
                    TextColor(White);
                    GotoXY(18,6);
                    Write('   S?   ');
                    TextBackground(Red);
                    TextColor(Black);
                    GotoXY(32,6);
                    Write('   No   ');
                end;
            else
                Beep;
        end;
    until done;
    Conferma:=scelta;
end;
(*******************************************************************)

function ConfermaUscita:Boolean;
begin
    if (Conferma('Si ? proprio sicuri di voler uscire dal programma?')=True) then
        ConfermaUscita:=True
    else
        ConfermaUscita:=False;
end;
(*******************************************************************)

procedure ImpostaValoriDiDefault;
begin
    (*Assegnazione dei valori standard delle posizioni degli assi*)
    AsseXx1:=0;
    AsseXy1:=GetMaxY div 2;
    AsseXx2:=GetMaxX;
    AsseXy2:=GetMaxY div 2;
    AsseYx1:=GetMaxX div 2;
    AsseYy1:=0;
    AsseYx2:=GetMaxX div 2;
    AsseYy2:=GetMaxY;

    risoluzione:=1;         (*Vicinanza dei punti del grafico*)
    scala:=40;              (*Scala del grafico (100%)*)
    Linee:=False;           (*Grafico a punti o linee (punti)*)
    Dominio:=True;          (*Disegnamo il dominio*)
    Radianti:=False;        (*Numeri interi sul grafico*)
    Limita:=False;          (*Dominio non limitato*)
    DisegnaDerivata:=False; (*Non disegnamo la derivata*)
    path:='a:\';        (*Directory dei drivers BGI*)
    Grafico_Rotazione:=True;            (*Visualizziamo il grafico e non la rotazione*)
    Griglia:=True;          (*Visualizziamo la griglia*)
end;
(*******************************************************************)

procedure ImpostaDefault;
begin
    TextBackground(Black);
    TextColor(Yellow);
    Window(1,1,80,25);
    GotoXY(20,4);
    Write('Impostazione valori di default');

    if (Conferma('Con questa operazione si elimineranno tutti i settaggi correnti. Continuare?')=True) then
        begin
            (*Imposta i valori di default*)
            ImpostaValoriDiDefault;
        end;
end;
(*******************************************************************)

function FileExists(FileName:string):Boolean;
var
    f:file;
begin
    (*"Input/Output Checking Switch": attiva la generazione di codice che
    controlla i risultati delle chiamate a procedure di I/O*)
    {$I-}
    Assign(f, FileName);
    Reset(f);
    Close(f);
    (*"Input/Output Checking Switch": (ri)attiva la generazione di codice che
    controlla i risultati delle chiamate a procedure di I/O*)
    {$I+}
    FileExists:=(IOResult=0) AND (FileName<>'');
end;
(*******************************************************************)

procedure CaricaListaFunzioni(FileName:string);
var
    f:Text;
    i:Integer;
    str:string;
begin
    i:=1;
    TextColor(LightRed);
    if FileExists(FileName) then
        begin
            for i:=1 to 16 do
                lista_funzioni[i]:='';
            funzione_corrente:=1;
            numero_funzioni:=0;
            Assign(f,FileName);
            Reset(f);
            Readln(f,str);
            lista_funzioni[funzione_corrente]:=str;
            Inc(funzione_corrente);
            Inc(numero_funzioni);
            while NOT Eof(f) do
                begin
                    Readln(f,str);
                    if (funzione_corrente<17) AND (numero_funzioni<17) then
                        begin
                            lista_funzioni[funzione_corrente]:=str;
                            Inc(funzione_corrente);
                            Inc(numero_funzioni);
                        end;
                end;
            Close(f);
        end
  else
        FileDelleFunzioni:='';
end;
(*******************************************************************)

procedure SalvaListaFunzioni(FileName:string);
var
    f:Text;
    i:Integer;
begin
    Assign(f,FileName);
    Rewrite(f);
    for i:=1 to numero_funzioni do
        if lista_funzioni[i]<>'' then
            Writeln(f,lista_funzioni[i]);
    Close(f);
end;

(*******************************************************************)

procedure MostraListaFunzioni;
var
    n,k,i:Integer;
begin
    (*Creiamo la nostra finestra*)
    Window(63,5,77,22);
    TextBackground(Black);
    TextColor(LightGray);
    ClrScr;
    for i:=5 to 20 do
        begin
            GotoXY(68,i);
            TextColor(White);
            Write('y=?(x):');
            TextColor(DarkGray);
            GotoXY(73,i);
            Write(' -------');
        end;
    i:=1;
    TextColor(LightCyan);
    while (i<numero_funzioni+1) do
        begin
            if (Length(lista_funzioni[i])<8) AND (lista_funzioni[i]<>'') then
                begin
                    GotoXY(9,i);
                    Write(lista_funzioni[i]);
                    for k:=Length(lista_funzioni[i]) to 6 do
                        begin
                            GotoXY(9+k,i);
                            Write(' ');
                        end;
                end
            else if (Length(lista_funzioni[i])>=8) AND (lista_funzioni[i]<>'') then
                begin
                    for k:=1 to 7 do
                        begin
                            GotoXY(8+k,i);
                            Write(lista_funzioni[i][k]);
                        end;
                end;
            Inc(i);
        end;
end;
(*******************************************************************)

procedure SelezionaFunzione(da_selezionare,precedente:Integer);
var
    k:Integer;
begin
    (*Creiamo la nostra finestra*)
    Window(1,1,80,25);
    TextBackground(Black);
    TextColor(White);
    (*Togliamo la vecchia selezione...*)
    GotoXY(63,precedente+4);
    Write('y=?(x):');
    TextColor(DarkGray);
    GotoXY(70,precedente+4);
    Write(' -------');
    TextColor(LightCyan);
    if (Length(lista_funzioni[precedente])<8) AND (lista_funzioni[precedente]<>'') then
        begin
            GotoXY(71,precedente+4);
            Write(lista_funzioni[precedente]);
            for k:=Length(lista_funzioni[precedente]) to 6 do
                begin
                    GotoXY(71+k,precedente+4);
                    Write(' ');
                end;
        end
    else if (Length(lista_funzioni[precedente])>=8) AND (lista_funzioni[precedente]<>'') then
        begin
            for k:=1 to 7 do
                begin
                    GotoXY(70+k,precedente+4);
                    Write(lista_funzioni[precedente][k]);
                end;
        end;
    (*... e mostriamo la nuova*)
    TextBackground(Red);
    TextColor(White);
    GotoXY(63,da_selezionare+4);
    Write('y=?(x):');
    TextColor(DarkGray);
    GotoXY(70,da_selezionare+4);
    Write(' -------');
    TextColor(Yellow);
    if (Length(lista_funzioni[da_selezionare])<8) AND (lista_funzioni[da_selezionare]<>'') then
        begin
            GotoXY(71,da_selezionare+4);
            Write(lista_funzioni[da_selezionare]);
            for k:=Length(lista_funzioni[da_selezionare]) to 6 do
                begin
                    GotoXY(71+k,da_selezionare+4);
                    Write(' ');
                end;
        end
    else if (Length(lista_funzioni[da_selezionare])>=8) AND (lista_funzioni[da_selezionare]<>'') then
        begin
            for k:=1 to 7 do
                begin
                    GotoXY(70+k,da_selezionare+4);
                    Write(lista_funzioni[da_selezionare][k]);
                end;
        end;
end;
(*******************************************************************)

procedure ChiediNomeFile;
var
    done:Boolean;
    ch:Char;
    posizione:Integer;
    tasto,precedente:string;
begin
    TextBackground(Black);
    TextColor(Yellow);
    Window(1,1,80,25);
    GotoXY(21,4);
    Write('File delle funzioni');

    (*Creiamo la nostra finestra*)
    Window(4,5,58,21);
    TextBackground(Black);
    ClrScr;
    TextColor(White);
    Writeln;
    Writeln('Inserire il nome ed il percorso completo del file:');
    Writeln;
    TextColor(LightGreen);
    GotoXY(25,17);
    Write('Esc: esci');
    TextColor(LightGray);
    GotoXY(1,4);
    done:=False;
    Write(FileDelleFunzioni);
    posizione:=Length(FileDelleFunzioni);
    GotoXY(1+posizione,4);
    precedente:=FileDelleFunzioni;
    repeat
        ch:=ReadChar;
        case ch of
            #8:
                begin
                    if posizione>0 then
                        begin
                            tasto:='';
                            for i:=1 to (posizione-1) do
                                tasto:=Concat(tasto,FileDelleFunzioni[i]);
                            FileDelleFunzioni:=tasto;
                            (*Creiamo la nostra finestra*)
                            Window(4,5,58,21);
                            TextColor(LightGray);
                            TextBackground(Black);
                            GotoXY(posizione,4);
                            Write(' ');
                            Dec(posizione);
                            GotoXY(1+posizione,4);
                        end;
                    if posizione=0 then
                        FileDelleFunzioni:='';
                end;
            #13:
                done:=True;
            #27:
                begin
                    done:=True;
                    FileDelleFunzioni:=precedente;
                end;
            #72:
                Beep;
            #75,#77:
                Beep;
            #80:
                Beep;
            else
                begin
                    if posizione<54 then
                        begin
                            tasto:=ch;
                            Delete(FileDelleFunzioni,posizione+1,1);
                            Insert(tasto,FileDelleFunzioni,posizione+1);
                            Inc(posizione);
                            (*Creiamo la nostra finestra*)
                            Window(4,5,58,21);
                            TextColor(LightGray);
                            TextBackground(Black);
                            GotoXY(posizione,4);
                            Write(tasto);
                        end
                    else
                        Beep;
                end;
        end;
    until done;
end;
(*******************************************************************)

procedure FinestraPrincipale;
var
    ch:Char;
    done:Boolean;
begin
    (*Creiamo la nostra finestra*)
    Window(1,1,80,25);
    TextBackground(Black);
    ClrScr;
    TextColor(LightBlue);
    Writeln('                     ANALIZZATORE DI FUNZIONI MATEMATICHE - 4');
    Writeln('                           di Marco Olivo, 1998,1999');
    Writeln;
    TextColor(DarkGray);
    Writeln(' ????????????????????????????????????????????????????????????????????????????');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ?                                                         ??                 ?');
    Writeln(' ????????????????????????????????????????????????????????????????????????????');
    Messaggio('Consultare la guida in linea per maggiori informazioni sul programma');
    MenuPrincipale;
    MostraListaFunzioni;
    SelezionaFunzione(funzione_corrente,funzione_corrente);
    if lista_funzioni[funzione_corrente]<>'' then
        Messaggio(lista_funzioni[funzione_corrente]);
    done:=False;
    repeat
        ch:=ReadChar;
        case ch of
            'i','I':
                begin
                    done:=True;
                    InserisciFunzione('');
                    FinestraPrincipale;
                end;
            'v','V':
                begin
                    done:=True;
                    if lunghezza>0 then
                        begin
                            Grafico_Rotazione:=True;
                            VisualizzaGrafico;
                        end
                    else
                        Beep;
                    FinestraPrincipale;
                end;
            'e','E':
                begin
                    done:=True;
                    if lunghezza>0 then
                        EstrapolaPunti
                    else
                        Beep;
                    FinestraPrincipale;
                end;
            'l','L':
                begin
                    done:=True;
                    LimitaDominio;
                    FinestraPrincipale;
                end;
            'r','R':
                begin
                    done:=True;
                    if lunghezza>0 then
                        begin
                            Grafico_Rotazione:=False;
                            VisualizzaGrafico;
                        end
                    else
                        Beep;
                    FinestraPrincipale;
                end;
            'g','G':
                begin
                    done:=True;
                    Informazioni_Guida;
                    FinestraPrincipale;
                end;
            'a','A':
                begin
                    done:=True;
                    ImpostaDefault;
                    FinestraPrincipale;
                end;
            #72:    (*Freccia in alto*)
                begin
                    if funzione_corrente>1 then
                        begin
                            SelezionaFunzione(funzione_corrente-1,funzione_corrente);
                            Dec(funzione_corrente);
                            if lista_funzioni[funzione_corrente]<>'' then
                                Messaggio(lista_funzioni[funzione_corrente])
                            else
                                Messaggio('Consultare la guida in linea per maggiori informazioni sul programma');
                            funzione:=lista_funzioni[funzione_corrente];
                            lunghezza:=Length(funzione);
                            (*Facciamo di modo che la nostra stringa sia tutta in maiuscolo*)
                            for i:=1 to lunghezza do
                                funzione[i]:=UpCase(funzione[i]);
                            LeggiFunzione;
                            if (ControllaSintassi=True) then
                                begin
                                    CalcolaPrecedenze;
                                    if numero_funzioni<funzione_corrente then
                                        numero_funzioni:=funzione_corrente;
                                end
                            else
                                InserisciFunzione(funzione);
                        end
                    else
                        Beep;
                end;
            #80:    (*Freccia in basso*)
                begin
                    if funzione_corrente<16 then
                        begin
                            SelezionaFunzione(funzione_corrente+1,funzione_corrente);
                            Inc(funzione_corrente);
                            if lista_funzioni[funzione_corrente]<>'' then
                                Messaggio(lista_funzioni[funzione_corrente])
                            else
                                Messaggio('Consultare la guida in linea per maggiori informazioni sul programma');
                            funzione:=lista_funzioni[funzione_corrente];
                            lunghezza:=Length(funzione);
                            (*Facciamo di modo che la nostra stringa sia tutta in maiuscolo*)
                            for i:=1 to lunghezza do
                                funzione[i]:=UpCase(funzione[i]);
                            LeggiFunzione;
                            if (ControllaSintassi=True) then
                                begin
                                    CalcolaPrecedenze;
                                    if numero_funzioni<funzione_corrente then
                                        numero_funzioni:=funzione_corrente;
                                end
                            else
                                InserisciFunzione(funzione);
                        end
                    else
                        Beep;
                end;
            'c','C':
                begin
                    done:=True;
                    ChiediNomeFile;
                    CaricaListaFunzioni(FileDelleFunzioni);
                    funzione_corrente:=1;
                    if lista_funzioni[funzione_corrente]<>'' then
                        Messaggio(lista_funzioni[funzione_corrente]);
                    funzione:=lista_funzioni[funzione_corrente];
                    lunghezza:=Length(funzione);
                    (*Facciamo di modo che la nostra stringa sia tutta in maiuscolo*)
                    for i:=1 to lunghezza do
                        funzione[i]:=UpCase(funzione[i]);
                    LeggiFunzione;
                    if (ControllaSintassi=True) then
                        begin
                            CalcolaPrecedenze;
                            if numero_funzioni<funzione_corrente then
                                numero_funzioni:=funzione_corrente;
                        end
                    else
                        InserisciFunzione(funzione);
                    FinestraPrincipale;
                end;
            's','S':
                begin
                    done:=True;
                    ChiediNomeFile;
                    SalvaListaFunzioni(FileDelleFunzioni);
                    FinestraPrincipale;
                end;
            #27,'u','U':
                begin
                    if (ConfermaUscita=True) then
                        begin
                            done:=True;
                            Window(1,1,80,25);
                            TextColor(White);
                            ClrScr;
                            TextBackground(LightBlue);
                            TextColor(White);
                            Write('    ANALIZZATORE DI FUNZIONI MATEMATICHE - 4 di Marco Olivo, 1998      ');
                            Delay(1000);
                        end
                    else
                        MenuPrincipale;
                end;
            else
                Beep;
        end;
    until done;
end;

(********************************************************************
*   Programma principale
********************************************************************)

begin
    (*Impostiamo lo schermo secondo le nostre preferenze*)
    OrigMode:=LastMode;
    TextMode(CO80);

    (*Ripuliamo lo schermo*)
    ClrScr;

    (*Impostiamo i valori di default*)
    ImpostaValoriDiDefault;

    (*Inizializzazione di alcune variabili*)
    for i:=1 to 100 do
        begin
            array_funzione[i]:='';  (*Array per la funzione*)
            numero[i]:='';          (*Array per la funzione*)
        end;
    for i:=1 to 500 do
        begin
            array_x[i]:=0;      (*Array per la rotazione*)
            array_y[i]:=0;      (*Array per la rotazione*)
        end;
    num_valori:=0;          (*Numero di valori salvati per la rotazione*)
    numero_funzioni:=0;     (*Nessuna funzione correntemente immagazzinata*)
    for i:=1 to 16 do
        lista_funzioni[i]:='';  (*Array delle ultime 16 funzioni*)
    funzione_corrente:=1;   (*Funzione correntemente scelta*)
    FileDelleFunzioni:='';  (*Nessun file correntemente aperto*)
    Disegna:=False;         (*Non disegnamo la prima linea*)
    Errore:=False;          (*Non ci sono errori*)
    lunghezza:=0;           (*Nessuna funzione*)
    x_precedente:=0;        (*Evitiamo che vengano disegnate parti di curva sbagliate*)
    y_precedente:=0;        (*Evitiamo che vengano disegnate parti di curva sbagliate*)
    InizializzatoX:=False;
    InizializzatoY:=False;

    (*Mostriamo la schermata di benvenuto*)
    SchermataDiBenvenuto;

    (*"Costruiamo" la nostra finestra principale*)
    FinestraPrincipale;

    (*Facciamo ritornare lo schermo alle impostazioni originali*)
    NormVideo;
    TextMode(OrigMode);
    TextBackground(Black);
    TextColor(LightGray);
  ClrScr;
end.
