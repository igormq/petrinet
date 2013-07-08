(*************************************************************)

(***********************************************************************
ARP - Analisador de Redes de Petri (Petri Net Analyser)
Copyright (C) 1990 Carlos Maziero, LCMI/EEL/UFSC
Contact: maziero@ppgia.pucpr.br, www.ppgia.pucpr.br/~maziero/

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public
License along with this program; if not, write to the Free
Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA  02111-1307, USA.
************************************************************************)

{$O+,F+}  { permissao para realizar overlay }
Unit Desemp ;

Interface
  Uses Variavel,Texto ;

  Procedure Avaliacao_Desempenho (Var Rede         : Tipo_Rede ;
                                  Var Texto_Desemp : Ap_Texto) ;

(*************************************************************)

Implementation
  Uses Crt,Janelas,Interfac,Ajuda ;

Procedure Avaliacao_Desempenho (Var Rede          : Tipo_Rede ;
                                Var Texto_Desemp  : Ap_Texto) ;

(************** DECLARACAO DE TIPOS E CONSTANTES *************)

Const
  Max_M_Dest = 20 ; {numero maximo de marcacoes ou eventos destino}
  Tam_Tabela = 20 ; {limite superior da tabela de dist. de probab.}
  Estab_Prec = 10 ; {numero de estabilizacao da precisao desejada }

Type
  Vetor_Contador = Array [1..Max_M_Dest] of Integer ;

  Vetor_Tempo    = Array [1..Max_M_Dest] of Real ;

  Vetor_Precisao = Array [1..Max_M_Dest] of Boolean ;

  Vetor_Nomes    = Array [1..Max_M_Dest] of Tipo_Ident ;

  Nodo_Fila      = Record
                     Ant,Post : Byte ;
                     Tempo    : Real ;
                     ISens    : Byte ;
                   end ;

(******************* VARIAVEIS DA AVALIACAO ******************)
Var
  Fila                : Array [0..Max_Trans_Lugar] of Nodo_Fila ;

  M_Dest              : Array [1..Max_M_Dest] of Vetor_Inteiros ;

  Trans,Finais        : Conj_Bytes ;

  Inicial             : Tipo_Ident ;

  IE_Inic,IExist,Cont : Vetor_Contador ;

  Soma_T,Soma_T2,
  Temp_Min,Temp_Max,
  Ult_Tempo           : Vetor_Tempo ;

  Prec                : Vetor_Precisao ;

  Evento              : Vetor_Nomes ;

  Tot_Disp,Aux_Disp,
  M_Ant,M_Inic,M_nova,
  M_Atual,IS_Inicial,
  Codigo              : Vetor_Inteiros ;

  Conflito,Num_Prec   : Vetor_Bytes ;

  STE,Aux_STE,
  STM,Aux_STM,
  TPM,Aux_TPM,
  Prob_Conf,
  Clock_Ant,Instante  : Vetor_Reais ;

  i,Iterac,
  Alcance,Local,
  Calc_Precisao,
  Improd,Disp_Max     : Integer ;

  j,Num,Tam,Unico,
  Elem,Esc,Num_Conf,
  Num_MD,Prim         : Byte ;

  Clock,Clock_Inicial,
  Sorteado,Precisao   : Real ;

  Acao_do_Operador,
  Precisao_Alcancada,
  Contando,Esc_Unica,
  Existe_Conf,Pronto,
  Resetar,Fim_Inic    : Boolean ;

  Orientacao          : (Eventos,Estados) ;

  Ch,Escolha          : Char ;

  C                   : String [2] ;

(*********** DECLARACAO DAS TABELAS DE DISTRIBUICAO **********)

Type
  Tabela = Array [0..Tam_Tabela] of Real ;

  Ap_Tab = ^Tabela ;

  Vetor_Ap_Tab = Array [1..Max_Trans_Lugar] of Ap_Tab ;

Var
  Tab_Distrib : Vetor_Ap_Tab ;

(********************** INICIO DO CODIGO *********************)

Procedure Le_Marc_Dest (Var Num_MD : Byte) ;
{------------------ -----------------
 Faz a leitura das marcacoes destino.
 -----------------------------------}
Var
  Maximo,j : Byte ;

begin
  Maximo := Num_MD + 1 ;
  if Maximo > Max_M_Dest then
    Maximo := Max_M_Dest ;

  TamBuffer := 2 ;
  ValorMinimo := 1 ;
  ValorMaximo := Maximo ;
  Num := Maximo ;
  Pergunta ('Targed marcation number: ',Num,TipoByte) ;

  if Num = Num_MD + 1 then begin
    Inc (Num_MD) ;
    for j := 1 to Rede.Num_Lugar do
      M_Dest [Num,j] := Rede.Mo [j] ;
  end ;

  Str (Num,C) ;
  TamBuffer := 3 ;
  ValorMinimo := 0 ;
  ValorMaximo := 999 ;
  Leitura_Vetor (' Dest' + C + ' ',Rede.Nome_Lugar, M_Dest [Num],
                 [1..Rede.Num_Lugar],Rede.Num_Lugar,Rede.Tam_Lugar,
                 '?',-1,'',0) ;
end ;

(************************************************)

Procedure Atualiza_Janela (Ch : Char) ;
{-----------------------------------------------------------------------
 Atualiza na janela de Avaliacao de desempenho o valor da precisao ou
 do numero maximo de disparos de transicao em cada ciclo de simulacao.
 ----------------------------------------------------------------------}
begin
  Formato_Cursor (2) ;
  Case Ch of
    'P' : begin
            GotoXY (42,1) ;
            TamBuffer := 5 ;
            ValorMinimo := 0 ;
            ValorMaximo := 99.99 ;
            ReadF (Precisao,TipoReal) ;
          end ;
    'X' : begin
            GotoXY (46,2) ;
            TamBuffer := 5 ;
            ValorMinimo := 0 ;
            ReadF (Disp_Max,TipoInt) ;
          end ;
  end ;
  Formato_Cursor (0) ;
end ;

(***********************************************)

Procedure Escreve_Texto (Var Texto : Ap_Texto ) ;
{-----------------------------------------------------------------------
 Escreve em um texto os resultados obtidos no ciclo global de simulacao.
 ----------------------------------------------------------------------}
Var
  Auxi,Auxi1 : Real    ;
  i,Ind      : Byte    ;
  Alc        : Integer ;
  Vetor_Aux  : Vetor_Reais ;

(****************************)

Procedure EscVetReal (Var Vetor_Real : Vetor_Reais ;
                          Lim_Sup    : Integer ;
                      Var Nome       : Lista_Ident) ;
{----------------------------------------------
 Procedure auxiliar da procedure Escreve_Texto.
 ---------------------------------------------}
Var
  i : Byte ;

begin
  Tab_Inic (Col_Texto) ;
  for i := 1 to Lim_Sup do
    if Vetor_Real [i] >= 0 then
      WrtS ('(' + Nome [i]^ + ':' + StRe (Vetor_Real [i],6,2) + ') ') ;
  Nova_Linha ;
end ;

(****************************)

begin
  Usa_Texto (Texto) ;
  WrtS ('Performance Evaluation Oriented to ') ;
  if Orientacao = Eventos then
    WrtS ('EVENTS ')
  else
    WrtS ('STATES ') ;
  WrtLnS ('of Net ' + Rede.Nome + '.' ) ;
  Nova_Linha ;

  WrtS ('Inicial Marking : ') ;
  EscVetor (M_Inic,Rede.Nome_Lugar,Rede.Num_Lugar,TipoInt,'?',-1,'',0) ;
  WrtLnS ('Desired Precision : ' + StRe (Precisao,4,2) + ' %') ;
  WrtLnS ('Max. of Fires : ' + StI (Disp_Max)) ;

  if Orientacao = Estados then begin
    WrtLnS ('Num. of Interactions : ' + StI (Iterac)) ;
    Alc := Iterac ;
  end else begin
    WrtLnS ('Num. of Reaching : ' + StI (Alcance)) ;
    Alc := Alcance + Improd ;
  end ;
  WrtS ('Improdutive Interac.: ' + StI (Improd)) ;
  if Alc <> 0 then begin
    Auxi := Improd ;
    Auxi := Auxi * 100 ;
    Auxi := Auxi / Alc ;
  end else
    Auxi := 0 ;
  WrtLnS ('  (' + StRe (Auxi,6,2) + ' % )') ;

  if Existe_Conf then begin
    Traco ;
    Nova_Linha ;
    WrtLnS ('Fire probability  attributed to conflict groups: ') ;
    Nova_Linha ;
    Ind := 1 ;
    while Ind <= Num_Conf do begin
      Auxi := 0 ;
      WrtS ('Group' + StI (Ind) + ': ') ;
      for i := 1 to Rede.Num_Trans do
        if Conflito [i] = Ind then begin
          Auxi1 := Prob_Conf [i] * 100 ;
          WrtS ('(' + Rede.Nome_Trans [i]^ + ': ' +
                StI (Round (Auxi1 - Auxi)) + '%) ') ;
          Auxi := Auxi1 ;
        end ;
      Nova_Linha ;
      Inc (Ind) ;
    end ;
  end ;

  if Orientacao = Estados then
    Auxi1 := Iterac
  else
    Auxi1 := Alcance ;
  for i := 1 to Rede.Num_Trans do
    if Auxi1 <> 0 then begin
      Auxi := Tot_Disp [i] ;
      Vetor_Aux [i] := Auxi/Auxi1 ;
    end else
      Vetor_Aux [i] := -1 ;
  Traco ;
  Nova_Linha ;
  WrtLnS ('Average number of fires from cycle transitions : ') ;
  EscVetReal (Vetor_Aux,Rede.Num_Trans,Rede.Nome_Trans) ;

  if Rede.Temporizada then begin
    for i := 1 to Rede.Num_Trans do begin
      Vetor_Aux [i] := 0 ;
      if (Tot_Disp [i] > 0) AND (STE [i] > 0) then
        Vetor_Aux [i] := STE [i]/Tot_Disp [i]
      else
        Vetor_Aux [i] := -1 ;
    end ;
    Nova_Linha ;
    WrtLnS ('Average time of fire :') ;
    EscVetReal (Vetor_Aux,Rede.Num_Trans,Rede.Nome_Trans) ;

    for i := 1 to Rede.Num_Lugar do begin
      Vetor_Aux [i] := 0 ;
      if (TPM [i] > 0) AND (STM [i] > 0) then
        Vetor_Aux [i] := STM [i]/TPM [i]
      else
        Vetor_Aux [i] := -1 ;
    end ;
    Nova_Linha ;
    WrtLnS ('Average marking in places :') ;
    EscVetReal (Vetor_Aux,Rede.Num_Lugar,Rede.Nome_Lugar) ;
  end ;

  Traco ;
  Nova_Linha ;
  if Orientacao = Eventos then begin
    WrtLnS ('Inicial Event: ' + Inicial) ;
    Nova_Linha ;
  end ;

  for i := 1 to Num_MD do begin
    if Orientacao = Estados then begin
      WrtS ('Md ' + StI (i) + ': ') ;
      EscVetor (M_Dest [i],Rede.Nome_Lugar,Rede.Num_Lugar,TipoInt,'?',-1,'',0) ;
    end else
      WrtLnS (' Ed ' + StI (i) + ': ' + Evento [i] ) ;
    WrtS ('  Average Time:') ;
    if Cont [i] <> 0 then
      WrtR (Soma_T [i]/Cont [i],8,2)
    else
      WrtS ('        ') ;
    WrtS (' Deviation:') ;
    if Cont [i] > 1 then begin
      Auxi := Cont [i] ;
      Auxi := Auxi * (Cont [i] - 1) ;
      Auxi := Sqrt ((Cont [i] * Soma_T2 [i] - Sqr (Soma_T [i]))
                     / Auxi) ;
      WrtR (Auxi,8,2) ;
    end else
      WrtS ('        ') ;

    Auxi := Cont [i] ;
    Auxi := Auxi * 100 ;
    if Orientacao = Estados then
      Auxi1 := Iterac
    else
      Auxi1 := Alcance + Improd ;
    if Auxi1 <> 0 then
      Auxi := Auxi / Auxi1
    else
      Auxi := 0 ;
    WrtS ('   Probab: ' + StRe (Auxi,6,2) + ' %') ;
    WrtLnS ('    Reach: ' + StI (Cont [i])) ;
    WrtS ('  Minimum time of reaching : ' + StRe (Temp_Min [i],6,2)) ;
    WrtLnS ('  Maximum time of reaching : ' + StRe (Temp_Max [i],6,2)) ;
    Nova_Linha ;
  end ;
  Traco ;
end ;

(************************************************)

Procedure Probabilizar_Conflitos (Var Conflito  : Vetor_Bytes;
                                  Var Prob_Conf : Vetor_Reais) ;
Var
  j,i,k,Trans,Porcentagem : Byte ;
  Anterior                : Real ;
  Achou,Iguais,Correto    : Boolean ;
  Vetor_Aux               : Vetor_Inteiros ;
  Hab                     : Conj_Bytes ;

(****************************)

Procedure Verifica_Entradas (Var Iguais    : Boolean;
                             Trans1,Trans2 : Byte ) ;
Var
  Apont1, Apont2 : Ap_Arco_Rede ;
  Continua       : Boolean ;

begin
  Iguais   := TRUE ;
  Continua := TRUE ;
  Apont1 := Rede.Pred_Trans [Trans1] ;
  Apont2 := Rede.Pred_Trans [Trans2] ;


  While (Iguais) AND (Continua) do begin
    if (Apont1^.Lugar_Ass = Apont2^.Lugar_Ass) then
      if (Apont1^.Peso = Apont2^.Peso) then begin
        Apont1 := Apont1^.Par_Trans ;
        Apont2 := Apont2^.Par_Trans ;
      end else
        Iguais := FALSE
    else
      Iguais := FALSE ;
    if Iguais then
      Iguais := ((Apont1 <> NIL) AND (Apont2 <> NIL)) OR
                ((Apont1 = NIL ) AND (Apont2 = NIL )) ;
    Continua := (Apont1 <> NIL) AND (Apont2 <> NIL) ;
  end ;
end ;

(****************************)

begin
  Existe_Conf := FALSE ;
  Num_Conf := 1 ;

  for Trans := 1 to Rede.Num_Trans do begin
    Vetor_Aux [Trans] := 0 ;
    Conflito  [Trans] := 0 ;
  end ;

  for Trans := 1 to Rede.Num_Trans do
    if (Conflito [Trans] = 0) AND
       (Rede.SEft [Trans] = Rede.SLft [Trans]) then begin
      Hab := [] ;
      Achou := FALSE ;
      Conflito [Trans] := Num_Conf ;
      Hab := Hab + [Trans] ;
      for j := Trans+1 to Rede.Num_Trans do
        if Conflito [j] = 0 then
          if Rede.SEft [Trans] = Rede.SEft [j] then
            if Rede.SLft [Trans] = Rede.SLft [j] then begin
              Verifica_Entradas (Iguais,Trans,j) ;
              if Iguais then begin
                Achou := TRUE ;
                Conflito [j] := Num_Conf ;
                Hab := Hab + [j] ;
              end ;
            end ;
      if Achou then begin
        Existe_Conf := TRUE ;
        Str (Num_Conf,C) ;
        repeat
          Correto := FALSE ;
          Porcentagem := 0 ;
          TamBuffer := 3 ;
          ValorMinimo := 0 ;
          ValorMaximo := 100 ;
          Leitura_Vetor (' Conf' + C + ' ',Rede.Nome_Trans,Vetor_Aux,Hab,
                         Rede.Num_Trans,Rede.Tam_Trans,'',0,'',0) ;
          Anterior := 0 ;
          for k := 1 to Rede.Num_Trans do
            if k in Hab then begin
              Porcentagem := Porcentagem + Vetor_Aux [k] ;
              Prob_Conf [k] := Anterior + (Vetor_Aux [k] / 100) ;
              Anterior := Prob_Conf [k] ;
            end ;
          Correto := (Porcentagem = 100) ;
          if Not Correto then
            Ch := Resp (' Sum of probabilities is different of 100 % ') ;
        until Correto ;
        Inc (Num_Conf) ;
      end else Conflito [Trans] := 0
    end ;

  if Not Existe_Conf then
    Ch := Resp (' No conflicts at net ') ;
  Dec (Num_Conf) ;
end ;

(************************************************)

Function Interpolacao (X1,Y1,X2,Y2,Y3 : Real) : Real ;
{---------------------------
 Efetua interpolacao linear.
 --------------------------}
begin
  if X1 <> X2 then
    Interpolacao := X1 + ((Y3-Y1) * (X2-X1) / (Y2-Y1))
  else
    Interpolacao := X1 ;
end ;

(************************************************)

Procedure Monta_Tabela_Normal (    Coeficiente : Real ;
                               Var Ap_Atual    : Ap_Tab) ;
{--------------------------------------------------------------------------
 Monta, a partir da tabela normal standard, uma tabela normal com determi -
 nado coeficiente passado como parametro.
 -------------------------------------------------------------------------}
Var
  Desvio,k,X : Real ;
  i,j        : Byte ;

(************************** Tabela Normal Standard *************************)

Type
  Tab_Normal = Array [0..60] of Real ;

Const
  Normal_Std : Tab_Normal = (0.50000,0.51994,0.53983,0.55982,0.57926,0.59871,
                             0.61791,0.63683,0.65542,0.67365,0.69146,0.70884,
                             0.72575,0.74215,0.75804,0.77337,0.78814,0.80234,
                             0.81594,0.82894,0.84134,0.85314,0.86433,0.87493,
                             0.88493,0.89435,0.90320,0.91149,0.91924,0.92647,
                             0.93319,0.93943,0.94520,0.95053,0.95543,0.95994,
                             0.96407,0.96784,0.97128,0.97441,0.97725,0.97982,
                             0.98214,0.98422,0.98610,0.98778,0.98928,0.99061,
                             0.99180,0.99286,0.99379,0.99461,0.99534,0.99598,
                             0.99653,0.99702,0.99744,0.99781,0.99813,0.99841,
                             1.00000) ;

(***************************************************************************)

begin
  New (Ap_Atual) ;

  {  Calculo da parte alta da tabela }
  Desvio := 1 / Sqrt (8 * Ln(Coeficiente)) ;
  for i := 10 to 20 do begin
    X := (0.05 * i - 0.5) / Desvio ;
    if X >= 3 then
      Ap_Atual^ [i] := 1
    else begin
      j := Trunc (X * 20) ;
      if j = X * 20 then
        Ap_Atual^ [i] := Normal_Std [j]
      else
        Ap_Atual^ [i] := Interpolacao (Normal_Std [j],0.05 * j,
                                       Normal_Std [j+1],0.05 * (j+1),X) ;
    end ;
  end ;

  { Ajuste da parte alta da tabela }
  if Ap_Atual^ [20] <> 1.00 then begin
    k := 0.50 / (Ap_Atual^ [20] - 0.50) ;
    for j := 10 to 20 do
      Ap_Atual^ [j] := 0.50 + (Ap_Atual^ [j] - 0.50) * k ;
  end ;

  { Calculo da parte baixa da tabela }
  for j := 0 to 9 do
    Ap_Atual^ [j] := 1 - Ap_Atual^ [20 - j] ;
end ;

(************************************************)

Procedure Monta_Tabela_Expon (    Coeficiente : Real ;
                              Var Ap_Atual    : Ap_Tab ) ;
{---------------------------------------------------------
 Monta uma tabela exponencial com determinado coeficiente.
 --------------------------------------------------------}
Var
  Aux,X : Real    ;
  j     : Integer ;

begin
  New (Ap_Atual) ;

  X := 0 ;
  for j := 0 to 20 do begin
    X := j * 0.05 ;
    Aux := Exp (Ln(Coeficiente)*X) ;
    Ap_Atual^ [j] := Coeficiente / (Coeficiente-1) * (1 - 1/Aux) ;
  end ;
end ;

(************************************************)

Procedure Cria_Tabelas_Distribuicao (     Coef        : Vetor_Reais ;
                                      Var Distrib     : Vetor_Distrib ;
                                      Var Tab_Distrib : Vetor_Ap_Tab) ;
{-------------------------------------------------------------------------
 Procedimento principal para criacao das tabelas de distribuicao. Inicia -
 liza todos os apontadores de tabelas, verifica quais tabelas necessitam
 ser criadas evitando que existam tabelas duplicadas. Todas as transicoes
 que necessitem de uma mesma tabela terao um apontador para esta tabela.
 ------------------------------------------------------------------------}
Var
  i      : Byte    ;
  Existe : Boolean ;

begin
  for i := 1 to Rede.Num_Trans do
    Tab_Distrib [i] := NIL ;

  for i := 1 to Rede.Num_Trans do begin
    j := 1 ;
    Existe := FALSE ;
    if Distrib [i] <> unif then
      while (j < i) AND (Not Existe) do
        if Distrib [j] = Distrib [i] then
          if Coef [j] = Coef [i] then begin
            Existe := TRUE ;
            Tab_Distrib [i] := Tab_Distrib [j] ;
          end else
            Inc (j)
        else
          Inc (j) ;
    if Not Existe then
      Case Distrib [i] of
        unif  : Tab_Distrib [i] := NIL ;
        expon : Monta_Tabela_Expon (Coef [i],Tab_Distrib [i]) ;
        norm  : Monta_Tabela_Normal (Coef [i],Tab_Distrib [i]) ;
      end ;
  end ;
end ;

(************************************************)

Procedure Libera_Tabelas_Distribuicao (Var Tab_Distrib : Vetor_Ap_Tab) ;

Var
  Ap_Atual : Ap_Tab ;
  i,Trans  : Byte ;

begin
  Trans := 1 ;
  repeat
    if Tab_Distrib [Trans] <> NIL then begin
      Ap_Atual := Tab_Distrib [Trans] ;
      for i := Trans + 1 to Rede.Num_Trans do
        if Tab_Distrib [i] = Ap_Atual then
          Tab_Distrib [i] := NIL ;
      Dispose (Ap_Atual) ;
      Tab_Distrib [Trans] := NIL ;
    end ;
    repeat
      Inc (Trans) ;
    until (Tab_Distrib [Trans] <> NIL) OR (Trans > Rede.Num_Trans) ;
  until Trans > Rede.Num_Trans ;
end ;

(************************************************)

Function Sorteia_Tempo (  Tmin,Tmax   : Real ;
                         Var Ap_Atual : Ap_Tab) : Real ;
{-------------------------------------------------------------
 Sorteia um tempo aleatorio no qual a transicao deve disparar.
 ------------------------------------------------------------}

(****************************)

  Function Aleatorio : Real ;
  Var
    S : Real ;
    i : Byte ;

  begin { SORTEIA VALOR ALEATORIO PONDERADO PELA TABELA }
    S := Random ;
    i := 1 ;
    if Ap_Atual <> NIL then begin
      while S > Ap_Atual^ [i] do
       Inc (i) ;
      if S < Ap_Atual^ [i] then
        Aleatorio := Interpolacao (0.05 * (i-1),Ap_Atual^ [Pred (i)],
                                   0.05 * i,Ap_Atual^ [i],S)
      else
        if (Ap_Atual^ [i] <> 1) then
          if (Ap_Atual^ [i] = Ap_Atual^ [Succ (i)]) then
            Aleatorio := Aleatorio
          else
            Aleatorio := 0.05 * i
        else
          Aleatorio := 1 ;
    end else
      Aleatorio := S ;
  end ; { SORTEIA VALOR ALEATORIO PONDERADO PELA TABELA }

begin { SORTEIA TEMPO DE DISPARO NO INTERVALO DADO }
  if TMin = TMax then
    Sorteia_Tempo := TMin
  else begin
    Sorteado := Aleatorio ;
    if TMin = 0 then
      if TMax = 1 then
        Sorteia_Tempo := Sorteado
      else
        Sorteia_Tempo := Sorteado * TMax
    else
      Sorteia_Tempo := Interpolacao (Tmin,0,Tmax,1,Sorteado) ;
  end ;
end ; { SORTEIA TEMPO DE DISPARO NO INTERVALO DADO }

(************************************************)

Procedure Poe_Na_Lista (Trans : Byte ; Tempo : Real) ;
{-------------------------------------------------------------------------
 Coloca a transicao Trans na lista de transicoes sensibilizadas, com tempo
 de disparo igual a Tempo.
 --------------------------------------------------------------}
Var
   Ind,Posic : Byte ;

begin
   Instante [Trans] := Clock ;
   Fila [Trans].Tempo := Tempo ;
   Ind := Fila [0].Post ;
   Posic := 0 ;
   while (Ind <> 0) AND (Fila [Trans].Tempo >= Fila [Ind].Tempo) do begin
      if Fila [Trans].Tempo = Fila [Ind].Tempo then
         Inc (Posic) ;
      Ind := Fila [Ind].Post ;
   end ;
   if Posic <> 0 then begin
      Posic := Trunc (Random (Succ (Posic))) ; { sorteia inteiro em [0..Posic] }
      While Posic <> 0 do begin
         Ind := Fila [Ind].Ant ;
         Dec (Posic) ;
      end ;
   end ;
   Fila [Trans].Post := Ind ;
   Fila [Trans].Ant := Fila [Ind].Ant ;
   Fila [Fila [Ind].Ant].Post := Trans ;
   Fila [Ind].Ant := Trans ;
end ;

(************************************************)

Procedure Tira_Da_Lista (Trans : Byte) ;
{--------------------------------------------------------
 Tira uma transicao da lista de transicoes sensibilizadas.
 --------------------------------------------------------}
begin
  Fila [Fila [Trans].Post].Ant := Fila [Trans].Ant ;
  Fila [Fila [Trans].Ant].Post := Fila [Trans].Post ;
end ;

(************************************************)

Procedure Atualiza_Lugares_Entrada (T_Disp : Byte) ;
{------------------------------------------------------------------------
 Atualiza os lugares de entrada da transicao que disparou, verificando as
 transicoes que ficaram desensibilizadas e atualizando o indice de exis -
 tencia das marcacoes destino caso a orientacao seja a Estados.
 ------------------------------------------------------------------------}
Var
  i                 : Byte ;
  Ap_Lugar,Ap_Trans : Ap_Arco_Rede ;

begin
  M_nova := M_Atual ;

  Ap_Trans := Rede.Pred_Trans [T_Disp] ;
  while Ap_Trans <> NIL do begin

    M_nova [Ap_Trans^.Lugar_Ass] := M_nova [Ap_Trans^.Lugar_Ass]
                                    - Ap_trans^.Peso ;

    Ap_Lugar := Rede.Succ_Lugar [Ap_Trans^.Lugar_Ass] ;
    while Ap_Lugar <> NIL do begin

      if (M_nova [Ap_Trans^.Lugar_Ass] < Ap_Lugar^.Peso) then
        if (Ap_Lugar^.Peso <= M_Atual [Ap_Trans^.Lugar_Ass]) then begin
          if Fila [Ap_Lugar^.Trans_Ass].ISens = 0 then
            if Ap_Lugar^.Trans_Ass <> T_Disp then
              Tira_Da_Lista (Ap_Lugar^.Trans_Ass) ;
          Fila [Ap_Lugar^.Trans_Ass].ISens := Fila [Ap_Lugar^.Trans_Ass].ISens
                                               + Ap_Lugar^.Peso ;
        end ;
      Ap_Lugar := Ap_Lugar^.Par_Lugar ;
    end ;

    if Orientacao = Estados then begin
      With Ap_Trans^ do
        for i := 1 to Num_MD do
          if M_Dest [i,Lugar_Ass] <> -1 then
            if M_Dest [i,Lugar_Ass] = M_Atual [Lugar_Ass] then
              Inc (IExist [i])
            else
              if M_Dest [i,Lugar_Ass] = M_nova [Lugar_Ass] then
                Dec (IExist [i]) ;
    end ;


    Ap_Trans := Ap_Trans^.Par_Trans ;
  end ;
end ;

(************************************************)

Procedure Atualiza_Lugares_Saida (T_Disp : Byte) ;
{----------------------------------------------------------------------
 Atualiza os lugares de saida da transicao que disparou, verificando as
 transicoes que ficaram sensibilizadas e atualizando o indice de exis -
 tencia das marcacoes destino caso a orientacao seja a Estados.
 ----------------------------------------------------------------------}
Var
  i                 : Byte ;
  Ap_Lugar,Ap_Trans : Ap_Arco_Rede ;


begin
  M_Atual := M_nova ;

  Ap_Trans := Rede.Succ_Trans [T_Disp] ;
  while Ap_Trans <> NIL do begin
    M_nova [Ap_Trans^.Lugar_Ass] := M_nova [Ap_Trans^.Lugar_Ass]
                                    + Ap_Trans^.Peso ;

    Ap_Lugar := Rede.Succ_Lugar [Ap_Trans^.Lugar_Ass] ;
    while Ap_Lugar <> NIL do begin

      if (M_nova [Ap_Trans^.Lugar_Ass] >= Ap_Lugar^.Peso) then
        if (Ap_Lugar^.Peso > M_Atual [Ap_Trans^.Lugar_Ass]) then begin
          Fila [Ap_Lugar^.Trans_Ass].ISens := Fila [Ap_Lugar^.Trans_Ass].ISens
                                                 - Ap_Lugar^.Peso ;
          if Fila [Ap_Lugar^.Trans_Ass].ISens = 0 then begin
            Sorteado := Sorteia_Tempo (Rede.SEft [Ap_Lugar^.Trans_Ass],
                                       Rede.SLft [Ap_Lugar^.Trans_Ass],
                                       Tab_Distrib [Ap_Lugar^.Trans_Ass])
                                       + Clock ;
            Poe_Na_Lista (Ap_Lugar^.Trans_Ass,Sorteado) ;
          end ;
        end ;
      Ap_Lugar := Ap_Lugar^.Par_Lugar ;
    end ;

    if Orientacao = Estados then begin
      With Ap_Trans^ do
        for i := 1 to Num_MD do
          if M_Dest [i,Lugar_Ass] <> -1 then
            if M_Dest [i,Lugar_Ass] = M_Atual [Lugar_Ass] then
              Inc (IExist [i])
            else
              if M_Dest [i,Lugar_Ass] = M_nova [Lugar_Ass] then
                Dec (IExist [i]) ;
    end ;

    Ap_Trans := Ap_Trans^.Par_Trans ;
  end ;
  M_Atual := M_Nova ;
end ;

(************************************************)

Procedure Inicializacao_Simulador (Var IS_Inicial     : Vetor_Inteiros ;
                                   Var IE_Inic,Cont   : Vetor_Contador ;
                                   Var Soma_T,Soma_T2,
                                       Ult_Tempo      : Vetor_Tempo ;
                                   Var Iterac,Improd,
                                       Calc_Precisao  : Integer) ;
{---------------------------------------------------------------------
 Inicializa as variaveis globais da avaliacao, levando em consideracao
 a orientacao da avaliacao escolhida pelo usuario.
 --------------------------------------------------------------------}
Var
  i,j   : Byte         ;
  Atual : Ap_Arco_Rede ;

begin
  for i := 1 to Rede.Num_Trans do begin
    Tot_Disp   [i] := 0 ;
    STE        [i] := 0 ;
    IS_Inicial [i] := 0 ;
    Atual := Rede.Pred_Trans [i] ;
    while Atual <> NIL do begin
      if M_Inic [Atual^.Lugar_Ass] < Atual^.Peso then
        IS_Inicial [i] := IS_Inicial [i] + Atual^.Peso ;
      Atual := Atual^.Par_Trans ;
    end ;
  end ;

  for i := 1 to Rede.Num_Lugar do begin
    STM [i] := 0 ;
    TPM [i] := 0 ;
  end ;

  for i := 1 to Num_MD do begin
    Prec [i]      := FALSE ;
    Soma_T [i]    := 0 ;
    Soma_T2 [i]   := 0 ;
    Ult_Tempo [i] := 0 ;
    Cont [i]      := 0 ;
    Num_Prec [i]  := 0 ;
    Temp_Min [i]  := 0 ;
    Temp_Max [i]  := 0 ;

    if Orientacao = Estados then begin
      Calc_Precisao := 100 * Rede.Num_Trans ;
      IE_Inic [i] := 0 ;
      for j := 1 to Rede.Num_Lugar do
        if M_Dest [i,j] <> -1 then
          if (M_Dest [i,j] <> M_Inic [j])  then
            Inc (IE_Inic [i]) ;
      Iterac  := 0 ;
    end else begin
      Calc_Precisao := 80 * Rede.Num_Trans ;
      Alcance := 0 ;
    end ;
  end ;

  Improd := 0 ;
  Fila [0].Tempo := 0 ;
  Fila [0].ISens := 0 ;
  Acao_do_Operador   := FALSE ;
  Precisao_Alcancada := FALSE ;
end ;

(************************************************)

Procedure Realiza_Ciclo_Simulacao ;
{------------------------------------------------------------------------
 Realiza um ciclo de simulacao, calculando as medidas desejadas e levando
 em conta a orientacao escolhida pelo usuario.
 -----------------------------------------------------------------------}
Var
  i,j,Ind,T_Disp,Novo_Disp : Byte    ;
  Num_Disparos             : Integer ;
  Alcancou,Chegou_Final,
  Ciclo_Valido,Inicio      : Boolean ;

(****************************)

  Procedure Atualiza_Valores (    Indice             : Byte ;
                                  Relogio            : Real ;
                              Var Iteracao           : Integer ;
                              Var Precisao_Alcancada : Boolean) ;
  {-----------------------------------------------------------------------
    Atualiza um conjunto de variaveis que representam os valores acumulados
    durante os Ciclos de Simulacao,  e mostra na tela os resultados obtidos
    em cada ciclo de simulacao.
   -----------------------------------------------------------------------}
  Var
    A,B,C,Aux,Valor : Real ;
    i : byte ;
  begin
    { atualiza valores do destino alcancado }
    Ult_Tempo [Indice] := Relogio ;
    Soma_T    [Indice] := Soma_T [Indice] + Relogio ;
    Soma_T2   [Indice] := Soma_T2 [Indice] + Relogio * Relogio ;
    Inc (Cont [Indice]) ;

    if Cont [Indice] = 1 then begin
      Temp_Min [Indice] := Relogio ;
      Temp_Max [Indice] := Relogio ;
    end else
      if Relogio < Temp_Min [Indice] then
        Temp_Min [Indice] := Relogio
      else
        if Relogio > Temp_Max [Indice] then
          Temp_Max [Indice] := Relogio ;

    { mostra na tela os valores atualizados }
    GotoXY (25,5 + Indice) ;
    write ((Soma_T [Indice] / Cont [Indice]):8:2,Cont [Indice]:19) ;

    if (Iteracao > Calc_Precisao) AND (Precisao <> 0) AND
       (Not Prec [Indice]) AND (Cont [Indice] > 1) then begin

      { calcula a precisao atual dos resultados para este destino }
      if Soma_T [Indice] <> 0 then begin
        Aux := Cont [Indice] ;
        A := Aux / (Aux - 1) ;
        B := Ult_Tempo [Indice] / Soma_T [Indice] ;
        C := A * (B - 1) ;
        Valor := ABS ((1 + C) * 100) ;
      end else
        Valor := Precisao ;

      { verifica se a precisao desejada para o destino esta' estavel }
      if Valor <= Precisao then begin
        Inc (Num_Prec [Indice]) ;
        if Num_Prec [Indice] = Estab_Prec then
          Prec [Indice] := TRUE ;
      end else
        Num_Prec [Indice] := 0 ;

      { verifica se todos os destinos alcancaram a precisao desejada }
      i := 1 ;
      Precisao_Alcancada := TRUE ;
      while (i <= Num_MD) AND Precisao_Alcancada do
        if Prec [i] then
          Inc (i)
        else
          Precisao_Alcancada := FALSE ;

    end ;
  end ;

(****************************)

Procedure Calcula_Marc_Media (Var Temp_Perm,
                                  Soma_Temp   : Vetor_Reais ;
                              Var Marc1,Marc2 : Vetor_Inteiros) ;
{----------------------------------------------------------------------
 Calcula a marcacao media apenas dos lugares cuja marcacao foi alterada
  pelo disparo da transicao.
 ---------------------------------------------------------------------}
Var
  i : Byte ;

begin
  for i := 1 to Rede.Num_Lugar do
    if Marc1 [i] <> Marc2 [i] then begin
      Temp_Perm [i] := Temp_Perm [i] + (Clock - Clock_Ant [i]) ;
      Soma_Temp [i] := Soma_Temp [i] + Marc1 [i] * (Clock - Clock_Ant [i]) ;
      Clock_Ant [i] := Clock ;
    end
end ;

(****************************)

Procedure Pondera_Conflito (Var T_Disp,Novo_Disp : Byte ;
                            Var Conflito         : Vetor_Bytes ;
                            Var Prob_Conf        : Vetor_Reais) ;
{------------------------------------------------------------------------
 Verifica se a transicao pertence a algum grupo de conflito e caso posi -
 tivo pondera o disparo da transicao com as pertencentes ao grupo.
 -----------------------------------------------------------------------}
Var
 i,Aux : Byte ;
 Sorte : Real ;

begin
  Sorte := Random ;
  i := 1 ;
  while i <= Rede.Num_Trans do
    if Conflito [i] = Conflito [T_Disp] then
      if Sorte >= Prob_Conf [i] then
        Inc (i)
      else begin
        Novo_Disp := i ;
        i := Succ (Rede.Num_Trans) ;
      end
    else
      Inc (i) ;

  if Novo_Disp <> T_Disp then begin
    Fila [0].Post := Novo_Disp ;
    Fila [Fila [Novo_Disp].Post].Ant := T_Disp ;
    Aux := Fila [T_Disp].Post ;
    Fila [T_Disp].Post := Fila [Novo_Disp].Post ;
    if Aux <> Novo_Disp then begin
      Fila [Aux].Ant := Novo_Disp ;
      Fila [Fila [Novo_Disp].Ant].Post := T_Disp ;
      Fila [Novo_Disp].Post := Aux ;
      Fila [T_Disp].Ant := Fila [Novo_Disp].Ant ;
    end else begin {quando T_Disp.Post aponta para Novo_Disp}
      Fila [T_Disp].Ant := Novo_Disp ;
      Fila [Novo_Disp].Post := T_Disp ;
    end ;
    Fila [Novo_Disp].Ant := 0 ;
    T_Disp := Novo_Disp ;
  end ;
end ;

(****************************)

Procedure Inicia_Auxiliares (Var Aux_STM,Aux_TPM,Aux_STE : Vetor_Reais ;
                             Var Aux_Disp                : Vetor_Inteiros) ;
Var
  i : Byte ;

begin
  for i := 1 to Rede.Num_Lugar do begin
    Aux_STM   [i] := 0 ;
    Aux_TPM   [i] := 0 ;
  end ;

  for i := 1 to Rede.Num_Trans do begin
    Aux_Disp [i] := 0 ;
    Aux_STE  [i] := 0 ;
  end ;
end ;

(****************************)

begin

  {inicia o cabeca da fila, o clock e a marcacao atual}
  Fila [0].Ant  := 0 ;
  Fila [0].Post := 0 ;
  Clock         := 0 ;
  Clock_Inicial := 0 ;
  M_Atual       := M_Inic ;

  if Orientacao = Estados then begin
    IExist := IE_Inic ;
    for i := 1 to Rede.Num_Lugar do
      Clock_Ant [i] := 0 ;
    Inicia_Auxiliares (Aux_STM,Aux_TPM,Aux_STE,Aux_Disp) ;
  end ;

  { monta fila inicial de transicoes sensibilizadas }
  for i := 1 to Rede.Num_Trans do begin
    Fila [i].ISens := IS_Inicial [i] ;
    if Fila [i].ISens = 0 then
      Poe_Na_Lista (i,Sorteia_Tempo (Rede.SEft [i],Rede.SLft [i],
                                     Tab_Distrib [i])) ;
  end ;

  {inicia as demais variaveis do ciclo de simulacao}
  Num_Disparos := 0 ;
  Alcancou     := FALSE ;
  Contando     := FALSE ;
  Chegou_Final := FALSE ;
  Ciclo_Valido := (Fila [0].Post <> 0) ; {fila nao vazia}
  Inc (Iterac) ;

  while (NOT Chegou_Final) AND Ciclo_Valido do begin

    {pondera conflito, dispara transicao e atualiza o clock}
    T_Disp := Fila [0].Post ;
    if Conflito [T_Disp] <> 0 then
      Pondera_Conflito (T_Disp,Novo_Disp,Conflito,Prob_Conf) ;
    Clock  := Fila [T_Disp].Tempo ;

    Inicio := FALSE ;

    if Orientacao = Eventos then begin
      if Contando then begin  {evento de inicio de contagem ja ocorreu}

        {atualiza o numero de disparos e o tempo de espera para disparo
         da transicao que dispara}
        Inc (Aux_Disp [T_Disp]) ;
        Aux_STE  [T_Disp] := Aux_STE [T_Disp] + (Clock - Instante [T_Disp]) ;

        {transicao que dispara eh evento de fim de contagem}
        if (Codigo [T_Disp] >= 1) then begin

          {zera o numero de disparos e incrementa o numero de alcances}
          Num_Disparos := 0 ;
          Inc (Alcance) ;

          {calcula o indice referente ao evento destino alcancado}
          if Fim_Inic then
            Ind := Codigo [T_Disp]
          else
            Ind := Pred (Codigo [T_Disp]) ;

          {atualiza Ult_Tempo, Soma_T, Soma_T2, Temp_Min e Temp_Max}
          Atualiza_Valores (Ind,Clock - Clock_Inicial,Alcance,Precisao_Alcancada) ;
          Chegou_Final := Precisao_Alcancada ;

          {atualiza os contadores efetivos para as transicoes}
          for i := 1 to Rede.Num_Trans do begin
            Tot_Disp [i] := Tot_Disp [i] + Aux_Disp [i] ;
            STE      [i] := STE [i] + Aux_STE [i] ;
          end ;

          {interrupcao ou acao do operador}
          if KeyPressed then begin
            Chegou_Final := TRUE ;
            Acao_do_Operador := TRUE ;
          end ;

        end ;
      end else
        {evento de inicio de contagem}
        if (Codigo [T_Disp] = 1) OR (Codigo [T_Disp] = - 1) then begin

          Inicio := TRUE ;
          for i := 1 to Rede.Num_Trans do
            Clock_Ant [i] := Clock ;

          Inicia_Auxiliares (Aux_STM,Aux_TPM,Aux_STE,Aux_Disp) ;

          {atualiza o numero de disparos e o tempo de espera para disparo
           da transicao que indica inicio de contagem}
          Inc (Aux_Disp [T_Disp]) ;
          Aux_STE  [T_Disp] := Aux_STE [T_Disp] + (Clock - Instante [T_Disp]) ;

          {inicia a contagem, atualiza o clock inicial
           do futuro acesso e zera numero de disparos}
          Contando := TRUE ;
          Alcancou := FALSE ;
          Num_Disparos := 0 ;
          Clock_Inicial := Clock ;

        end ;
    end ;

    {faz o tempo da transicao que dispara igual a -1 para mais tarde verificar
     se a mesma continua habilitada depois de disparar e retira da lista}
    Fila [T_Disp].Tempo := - 1 ;
    Tira_Da_Lista (T_Disp) ;

    if Orientacao = Estados then begin
      {atualiza o numero de disparos e o tempo de espera para disparo
       da transicao que dispara}
      Inc (Aux_Disp [T_Disp]) ;
      Aux_STE [T_Disp] := Aux_STE [T_Disp] + (Clock - Instante [T_Disp]) ;
    end ;

    M_Ant := M_Atual ;
    Atualiza_Lugares_Entrada (T_Disp) ;
    Atualiza_Lugares_Saida (T_Disp) ;

    {calcula marcacao media dos lugares}
    if (Orientacao = Estados) OR ((Orientacao = Eventos) AND Contando) then
      Calcula_Marc_Media (Aux_TPM,Aux_STM,M_Ant,M_Atual) ;

    Inc (Num_Disparos) ;

    if Orientacao = Estados then begin
      {verifica se alguma marcacao destino foi alcancada}
      for i := 1 to Num_MD do
        if IExist [i] = 0 then begin
          Chegou_Final  := TRUE ;
          Atualiza_Valores (i,Clock,Iterac,Precisao_Alcancada) ;
          for j := 1 to Rede.Num_Trans do begin
            Tot_Disp [j] := Tot_Disp [j] + Aux_Disp [j] ;
            STE      [j] := STE [j] + Aux_STE [j] ;
          end ;

          for j := 1 to Rede.Num_Lugar do begin
            TPM [j] := Aux_TPM [j] ;
            STM [j] := Aux_STM [j] ;
          end ;
        end ;

    end else { Orientacao a Eventos }

      { caso a transicao que dispara eh um evento de fim
       de contagem e a contagem estava sendo feita }
      if (Codigo [T_Disp] >= 1) AND Contando AND (Not Inicio) then begin
        {atualiza os contadores efetivos para a marcacao media}
        for i := 1 to Rede.Num_Lugar do begin
          TPM [i] := Aux_TPM [i] ;
          STM [i] := Aux_STM [i] ;
        end ;

        {finaliza a contagem  e verifica se o usuario escolheu a opcao de
         resetar automatico}
        Contando := FALSE ;
        Alcancou := TRUE ;
        if Resetar then Chegou_Final := TRUE ;
      end ;

    {verifica se a transicao que disparou continua sensibilizada e coloca-a
     na fila caso isso ja nao tenha sido feito}
    if (Fila [T_Disp].ISens = 0) then
      if (Fila [T_Disp].Tempo = - 1) then begin
        Sorteado := Sorteia_Tempo (Rede.SEft [T_Disp],
                                   Rede.SLft [T_Disp],
                                   Tab_Distrib [T_Disp]) + Clock ;
        Poe_Na_Lista (T_Disp,Sorteado) ;
      end ;

    {verifica se o numero de disparos nao ultrapassou o limite definido pelo
     usuario e se ainda existem transicoes na fila para serem disparadas}
    Ciclo_Valido := (Fila [0].Post <> 0) AND (Num_Disparos < Disp_Max) ;

    if (Orientacao = Eventos) AND Contando AND (NOT Ciclo_Valido) then
      Contando := FALSE ;

  end ;

  {calcula a marcacao media final de todos os lugares}
  if (Orientacao = Estados) OR ((Orientacao = Eventos) AND Alcancou) then
    for i := 1 to Rede.Num_Lugar do begin
      TPM [i] := TPM [i] + (Clock - Clock_Ant [i]) ;
      STM [i] := STM [i] + M_Ant [i] * (Clock - Clock_Ant [i]) ;
    end ;
  if ((Orientacao = Estados) AND (Not Chegou_Final)) OR
     ((Orientacao = Eventos) AND (Not Alcancou)) then begin
     Inc (Improd) ;
     GotoXY (28,2) ;
     write (Improd:5) ;
  end ;
end ;

(************************************************)

Procedure Realiza_Ciclo_Global ;
{--------------------------------------------
 Realiza o ciclo global de simulacao da rede.
 -------------------------------------------}
Var
  Ch : Char ;
begin
  Inicializacao_Simulador (IS_Inicial,IE_Inic,Cont,Soma_T,Soma_T2,
                           Ult_Tempo,Iterac,Improd,Calc_Precisao) ;
  repeat
    Realiza_Ciclo_Simulacao ;
    if KeyPressed then
      Acao_do_Operador := TRUE ;
  until Precisao_Alcancada OR Acao_do_Operador ;

  { consome caracteres restantes no buffer do teclado }
  while KeyPressed do Ch := Tecla (Funcao) ;
end ;

(************************************************)

begin
  if Texto_Desemp <> NIL then
    Escolha := Resp ('Want to lose last evaluation ? [(Y/N)]')
  else
    Escolha := 'Y' ;

  if (Escolha = 'Y') then begin
    Precisao := 0.1 ;
    Disp_Max := 10 * Rede.Num_Trans ;
    for i := 1 to Rede.Num_Lugar do
      M_Inic [i] := Rede.Mo [i] ;

    {inicia os conflitos das transicoes}
    for i := 1 to Rede.Num_Trans do
      Conflito  [i] := 0 ;
    Existe_Conf := FALSE ;
    Num_Conf := 0 ;

    repeat
      Escolha := Resp ('Evaluation Orientation:     [E]vents     [S]tates') ;
      Case Escolha of
        'E': Orientacao := Eventos ;
        'S': Orientacao := Estados ;
      end ;
    until Escolha in ['E','S'] ;
    Esc := 0 ;
    Pronto := FALSE ;

    if Orientacao = Estados then begin
      Num_MD := 1 ;
      for i := 1 to Rede.Num_Lugar do
        M_Dest [1,i] := Rede.Mo [i] ;
      Cria_Janela (' Performance Evaluation - Oriented to States ',
                   1,21,80,5,Atrib_Forte) ;
      Msg ('   Inicial [M]arking          [P]recision =  [0.10] %     ') ;
      Msg (' Beg[I]n  Evaluation') ;
{D}   Msg ('\   [T]arged Marking           ma[X]. Fires =         ') ;
      Msg ('    [C]onflicts ') ;
{A}   Msg ('\   [H]elp ') ;
      GotoXY (46,2) ;
      write (Disp_Max) ;
    end else begin        {Orientacao a Eventos}
      Resetar := TRUE ;
      Prim := 0 ;
      Trans := [] ;

      {cria conjunto de bytes com todas as transicoes}
      {zera o codigo de todas as transicoes}
      for i:= 1 to Rede.Num_Trans do begin
        Trans := Trans + [i] ;
        Codigo [i] := 0 ;
      end ;

      Cria_Janela (' Performance Evaluation - Oriented to Events ',
                   1,21,80,5,Atrib_Forte) ;
      Msg ('   Inicial [M]arking          [P]recision  =  [0.10] %       ') ;
{I}   Msg ('Beg[I]n   Evaluation') ;
      Msg ('\   Inicial [E]vent            ma[X]. Fires = ') ;
      Msg ('              [C]onflicts ') ;
{D}   Msg ('\   [T]arged Events            [R]eset ([YES])           ') ;
{A}   Msg ('     [H]elp') ;
      GotoXY (46,2) ;
      write (Disp_Max) ;
    end ;

    repeat
      Escolha := Tecla (Funcao) ;
      Case Escolha of
        'M' : begin
                TamBuffer := 3 ;
                ValorMinimo := 0 ;
                ValorMaximo := 999 ;
                Leitura_Vetor (' Inicial Mark.',Rede.Nome_Lugar,M_Inic,
                               [1..Rede.Num_Lugar],Rede.Num_Lugar,
                               Rede.Tam_Lugar,'',0,'',0) ;
              end ;

        'E' : begin
                if Orientacao = Eventos then begin
                  if Prim <> 0 then begin
                    Codigo [Prim] := 0 ;
                    Dec (Esc) ;
                  end ;
                  Inc (Esc) ;
                  Esc_Unica := TRUE ;
                  Finais := [] ;
                  Seleciona_Nodos (' E0 ',Rede.Nome_Trans,Trans,Finais,Unico,
                                   Esc_Unica,Rede.Num_Trans,Rede.Tam_Trans) ;
                  Prim := Unico ;
                  Codigo [Prim] := -1 ;
                  Inicial := Rede.Nome_Trans [Prim]^ ;
                end else
                  Escolha := '*' ;
              end ;

        'T' : begin
                if Orientacao = Eventos then begin
                  Fim_Inic := FALSE ;
                  {verifica se ja foi escolhido o evento inicial}
                  if Prim <> 0 then begin
                    Inc (Esc) ;
                    repeat
                      Esc_Unica := FALSE ;
                      Finais := [] ;
                      Seleciona_Nodos (' Ed ',Rede.Nome_Trans,Trans,Finais,
                                       Unico,Esc_Unica,Rede.Num_Trans,
                                       Rede.Tam_Trans) ;
                      Elem := 1 ;
                      j := 0 ;

                      {evento de inicio e fim de contagem}
                      if Prim in Finais then begin
                        Fim_Inic := TRUE ;
                        Codigo [Prim] := 1 ;
                        Evento [1] := Rede.Nome_Trans [Prim]^ ;
                        j := 1 ;
                      end ;

                      {calcula o codigo das transicoes}
                      for i := 1 to Rede.Num_Trans do begin
                        if (I in Finais) AND (I <> Prim) then begin
                          Inc (j) ;
                          Inc (Elem) ;
                          Codigo [i] := Elem ;
                          Evento [j] := Rede.Nome_Trans [i]^ ;
                        end ;
                      end ;

                      if Not Fim_Inic then Dec (Elem) ;
                      {verifica o numero de eventos detinos}
                      if Elem > Max_M_Dest then begin
                        for i := 1 to Rede.Num_Trans do
                          if (Codigo [i] <> 1) AND (Codigo [i] <> -1) then
                            Codigo [i] := 0 ;
                        Ch := Resp ('Number of final events exceeds the allowed ') ;
                      end ;
                    until Elem <= Max_M_Dest ;
                    Num_MD := Elem ;
                  end else
                    Ch := Resp ('First select the inicial event')
                end else
                  Le_Marc_Dest (Num_MD) ;
              end ;

        'R' : begin
                if Orientacao = Eventos then begin
                  Resetar := Not (Resetar) ;
                  GotoXY (36,3) ;
                  if Resetar then write ('YES')
                             else write ('NOT') ;
                end else
                  Escolha := '*' ;
              end ;

        'C' : Probabilizar_Conflitos (Conflito,Prob_Conf) ;

    'P','X' : Atualiza_Janela (Escolha) ;

        'H' : Tela_Ajuda (Desempenho) ;

        'I' : begin
                if Esc >= 2 then Pronto := TRUE ;
                if (Orientacao = Estados) OR
                   ((Orientacao = Eventos) AND Pronto) then begin
                  Apaga_Texto (Texto_Desemp) ;
                  Tam := Num_MD + 7 ;

                  Aviso (' Creating Destribuction Tables ') ;
                  Cria_Tabelas_Distribuicao (Rede.Coef,Rede.Distrib,
                                             Tab_Distrib) ;
                  Apaga_Atual ;

                  Local := Round ((25-Tam)/2) ;
                  Cria_Janela (' Performance Evaluation ',
                               10,Local,60,Tam,Atrib_Forte) ;
{????}            Msg ('\  Improdutive Interactions :     [0]\\') ;
                  if Orientacao = Estados then
                    Msg ('  Targed Mark.          Average Time        Num. of Reach ')
                  else
                    Msg ('  Targed Event        Average Time       Num. of Reach ') ;
                  for i := 1 to Num_MD do begin
                    GotoXY (7,5+i) ;
                    if Orientacao = Estados then
                      write ('Md ',i)
                    else
                      write ('Ed',i);
                    GotoXY (47,5+i) ;
                    write (0:5) ;
                  end ;
                  Realiza_Ciclo_Global ;
                  Escreve_Texto (Texto_Desemp) ;
                  Apaga_Atual ;
                  Aviso (' Getting Free Destribuction Tables ') ;
                  Libera_Tabelas_Distribuicao (Tab_Distrib) ;
                  Apaga_Atual ;
                end else
                  Escolha := 'N' ; { nao iniciar a avaliacao }
              end ;
        else
          Escolha := '*' ;
      end ;
    until Escolha in ['*','I'] ;
    Apaga_Atual ;
  end else
     Escolha := 'I';

  if Escolha = 'I' then
     Edita_Texto (' Performance Evaluation ',Texto_Desemp,
                  1,1,8,18,FALSE,Funcao) ;
end ;

end. { end unit }

(************************************************)
