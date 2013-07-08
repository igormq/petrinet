(************************************************************************)

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

Unit Invarian ;
Interface

  Uses Variavel,Texto ;

  Procedure Analise_de_Invariantes (Var Rede         : Tipo_Rede ;
                                    Var Texto_Invar  : Ap_Texto ;
                                        Invar_Trans  : Boolean) ;

(************************************************************************)

Implementation

Uses Crt,Janelas,Interfac,Ajuda ;

Procedure Analise_de_Invariantes (Var Rede         : Tipo_Rede ;
                                  Var Texto_Invar  : Ap_Texto ;
                                      Invar_Trans  : Boolean) ;
Const
  Max_Invariantes = 3000 ; { +/- 20 vezes Max_Trans_Lugar }

Type
  Aponta_Vetor = ^Vetor_Inteiros ;
  Tipo_Matriz  = Array [1..Max_Invariantes] of Aponta_Vetor ;

Var
  Num_Lin,Fator,
  Num_Col,i,
  Num_Invar     : Integer ;
  Incid,Base    : Tipo_Matriz ;
  Escolha       : Char ;
  Auxi          : Byte ;
  Erro          : Boolean ;
  Proibidos,
  Obrigatorios  : Conj_Bytes ;

(************************************************************************)

   Procedure Escreve_Inibicoes (Var Rede            : Tipo_Rede ;
                                    Obrigat,Proibid : Conj_Bytes ;
                                    Invar_Trans     : Boolean) ;
   begin { ESCREVE INIBICOES USADAS NA ANALISE }
     { escreve inibicoes usadas na analise }
     WrtLnS ('Inhibitions used in this analysis:') ;
     Nova_Linha ;
     if Invar_Trans then begin
       WrtS ('  Obligatory Transitions : ') ;
       EscConj (Obrigat,Rede.Nome_Trans,Rede.Num_Trans) ;
       WrtS ('  Prohibited Transitions : ') ;
       EscConj (Proibid,Rede.Nome_Trans,Rede.Num_Trans) ;
     end else begin
       WrtS ('  Obligatory Places : ') ;
       EscConj (Obrigat,Rede.Nome_Lugar,Rede.Num_Lugar) ;
       WrtS ('  Prohibited Places : ') ;
       EscConj (Proibid,Rede.Nome_Lugar,Rede.Num_Lugar) ;
     end ;
   end ; { ESCREVE INIBICOES USADAS NA ANALISE }

(************************************)

   Procedure Escreve_Invariantes (Var Rede            : Tipo_Rede ;
                                  Var Base            : Tipo_Matriz ;
                                  Var Num_Lin,Num_Col : Integer ;
                                      Tipo            : String) ;
   Var i : Integer ;
   begin { ESCREVE INVARIANTES ENCONTRADOS }
     i := 1 ;
     while (i <= Num_Lin) AND NOT Erro do begin
       Erro := Pressiona_ESC ;
       WrtS (Tipo + StI (i)) ;
       Posic (6) ;
       WrtS (':') ;
       if Invar_Trans then
         EscVetor (Base [i]^,Rede.Nome_Trans,Num_Col,TipoInt,'',0,'',0)
       else
         EscVetor (Base [i]^,Rede.Nome_Lugar,Num_Col,TipoInt,'',0,'',0) ;
       i := Succ (i) ;
     end ;
     if Erro then WrtLnS (' Writting stopped by user ...') ;
   end ; { ESCREVE INVARIANTES ENCONTRADOS }

(************************************)

   Procedure Escreve_Teste_Cobertura (Var Rede            : Tipo_Rede ;
                                      Var Base            : Tipo_Matriz ;
                                          Num_Lin,Num_Col : Integer ;
                                          Invar_Trans     : Boolean) ;
   Var
     Todos,Nenhum : Conj_Bytes ;
     i,j          : Integer ;

   begin { ESCREVE O TESTE DE COBERTURA DOS INVARIANTES }
     { escreve teste de cobertura dos invariantes }
     Todos  := [1..Num_Col] ;
     Nenhum := [1..Num_Col] ;
     for i := 1 to Num_Lin do
       for j := 1 to Num_Col do
         if Base [i]^[j] <> 0 then
           Nenhum := Nenhum - [j]
         else
           Todos := Todos - [j] ;
     if Invar_Trans then begin
       if Num_Lin > 1 then begin
         WrtLnS ('Transitions in all invariants:') ;
         WrtS ('  T = ') ;
         EscConj (Todos,Rede.Nome_Trans,Rede.Num_Trans) ;
         Nova_Linha ;
       end ;
       WrtLnS ('Transitions at none invariant:') ;
       WrtS ('  T = ') ;
       EscConj (Nenhum,Rede.Nome_Trans,Rede.Num_Trans) ;
     end else begin
       if Num_Lin > 1 then begin
         WrtLnS ('Place in all invariants:') ;
         WrtS ('  P = ') ;
         EscConj (Todos,Rede.Nome_Lugar,Rede.Num_Lugar) ;
         Nova_Linha ;
       end ;
       WrtLnS ('Places at none invariant:') ;
       WrtS ('  P = ') ;
       EscConj (Nenhum,Rede.Nome_Lugar,Rede.Num_Lugar) ;
     end ;
   end ; { ESCREVE O TESTE DE COBERTURA DOS INVARIANTES }

(************************************)

   Procedure Escreve_Teste_Sub_Redes (Var Rede            : Tipo_Rede ;
                                      Var Base            : Tipo_Matriz ;
                                          Num_Lin,Num_Col : Integer ;
                                          Invar_Trans     : Boolean) ;
   Var
     Total,i   : Integer ;
     Sub_Rede  : Array [1..Max_Invariantes] of Boolean ;
     Tipo      : String [3] ;
     Sub_Nome  : String [40] ;

(**********)

     Function Invariante_Sub_Rede (Var Invar       : Vetor_Inteiros ;
                                   Var DimensA,
                                       DimensB     : Byte ;
                                   Var PredA,SuccA,
                                       PredB,SuccB : Lista_Rede ;
                                       Invar_Trans : Boolean) : Boolean ;
     Var
       NodoA,NodoB : Byte ;
       Sub_Rede    : Boolean ;
       Ligado      : Array [1..Max_Trans_Lugar] of Boolean ;

(*****)

       Procedure Identifica_Nodos_Ligados (Atual : Ap_Arco_Rede) ;
       begin { IDENTIF. QUAIS NODOS SAO ADJACENTES AOS DO INVARIANTE }
         while (Atual <> NIL) AND Sub_Rede do
           if Atual^.Peso > 1 then
             { somente arcos sem ponderacao sao aceitos }
             Sub_Rede := FALSE
           else
             { registra nodo adjacente ligado e avanca apontador }
             if Invar_Trans then begin
               Ligado [Atual^.Lugar_Ass] := TRUE ;
               Atual := Atual^.Par_Trans ;
             end else begin
               Ligado [Atual^.Trans_Ass] := TRUE ;
               Atual := Atual^.Par_Lugar ;
             end ;
       end ; { IDENTIF. QUAIS NODOS SAO ADJACENTES AOS DO INVARIANTE }

(*****)

       Procedure Testa_Multiplas_Ligacoes (Atual : Ap_Arco_Rede) ;
       Var
         NodoB              : Byte ;
         Registrou_Primeiro : Boolean ;
       begin
       { TESTA SE HA' MAIS QUE UM NODO DO TIPO B NA ENTRADA OU NA SAIDA
         DO NODO DE TIPO A SOB TESTE }
         Registrou_Primeiro := FALSE ;
         while (Atual <> NIL) AND Sub_Rede do begin
           { para todos os nodos B de entrada do nodo A }
           if Invar_Trans then NodoB := Atual^.Trans_Ass
                          else NodoB := Atual^.Lugar_Ass ;
           if Invar [NodoB] > 0 then
             { nodo B pertence ao invariante }
             if Registrou_Primeiro then
               { mais de um nodo B do invariante na entrada do nodo A }
               Sub_Rede := FALSE
             else
               { primeiro nodo B do invariante na entrada do nodo A }
               Registrou_Primeiro := TRUE ;
           if Invar_Trans then Atual := Atual^.Par_Lugar
                          else Atual := Atual^.Par_Trans ;
         end ;
       end ;

(*****)

     begin { INDICA SE UM INVARIANTE E' SUB-REDE }
       { verifica nodos A ligados `a sub-rede e respectivos pesos dos arcos }
       for NodoA := 1 to DimensA do
         Ligado [NodoA] := FALSE ;
       Sub_Rede := TRUE ;
       NodoB := 1 ;
       while (NodoB <= DimensB) AND Sub_Rede do begin
         if Invar [NodoB] > 0 then
           { para os nodos B pertencentes ao invariante }
           if Invar [NodoB] > 1 then
             { sub-rede nao deve ter ponderacao nos elementos }
             Sub_Rede := FALSE
           else begin
             { identifica nodos de tipo A ligados na entrada do nodo B }
             Identifica_Nodos_Ligados (PredB [NodoB]) ;
             if Sub_Rede then
               { identifica nodos de tipo A ligados na saida do nodo B }
               Identifica_Nodos_Ligados (SuccB [NodoB]) ;
           end ;
         NodoB := Succ (NodoB) ;
       end ;

       { p/ os nodos A ligados ao invariante testa multiplas ligacoes }
       NodoA := 1 ;
       while (NodoA <= DimensA) AND Sub_Rede do begin
         if Ligado [NodoA] then begin
           { testa se ha' mais de um nodo B do invariante na entrada do nodo A }
           Testa_Multiplas_Ligacoes (PredA [NodoA]) ;
           if Sub_Rede then
             { testa se ha' mais de um nodo B do invariante na saida do nodo A }
             Testa_Multiplas_Ligacoes (SuccA [NodoA]) ;
         end ;
         NodoA := Succ (NodoA) ;
       end ;

       Invariante_Sub_Rede := Sub_Rede ;
     end ; { INDICA SE UM INVARIANTE E' SUB-REDE }

(**********)

   begin { ESCREVE TESTE DE SUB-REDE SOBRE OS INVARIANTES }
     Total := 0 ;
     With Rede do
       if Invar_Trans then begin
         Tipo := 'IT' ;
         Sub_Nome := 'events graph' ;
         i := 1 ;
         while (i <= Num_Lin) AND NOT Erro do begin
           Erro := Pressiona_ESC ;
           if Invariante_Sub_Rede (Base [i]^,Num_Lugar,Num_Trans,
              Pred_Lugar,Succ_Lugar,Pred_Trans,Succ_Trans,TRUE) then begin
             Sub_Rede [i] := TRUE ;
             Total := Succ (Total) ;
           end else
             Sub_Rede [i] := FALSE ;
           i := Succ (i) ;
         end ;
       end else begin
         Tipo := 'IL' ;
         Sub_Nome := 'state machine' ;
         i := 1 ;
         while (i <= Num_Lin) AND NOT Erro do begin
           Erro := Pressiona_ESC ;
           if Invariante_Sub_Rede (Base [i]^,Num_Trans,Num_Lugar,
              Pred_Trans,Succ_Trans,Pred_Lugar,Succ_Lugar,FALSE) then begin
             Sub_Rede [i] := TRUE ;
             Total := Succ (Total) ;
           end else
             Sub_Rede [i] := FALSE ;
           i := Succ (i) ;
         end ;
       end ;

     WrtLnS ('Sub-Net existency test  ('+ Sub_Nome + '):') ;
     Nova_Linha ;
     if Total = 0 then
       WrtLnS ('None of found invariants is ' + Sub_Nome + '.')
     else
       if (Total = Num_Lin) then
         WrtLnS ('All found invariants are ' + Sub_Nome + '.')
       else begin
         WrtLnS ('Following invariants are ' + Sub_Nome + ':') ;
         Posic (4) ;
         Tab_Inic (4) ;
         for i := 1 to Num_Lin do
           if Sub_Rede [i] then
             WrtS (Tipo + StI (i) + '  ') ;
         Nova_Linha ;
         Tab_Inic (1) ;
       end ;
   end ; { ESCREVE TESTE DE SUB-REDE SOBRE OS INVARIANTES }

(************************************************************************)

   Procedure Apaga_Matriz (Var A : Tipo_Matriz) ;
   Var
      i : Integer ;

   begin { APAGA MATRIZ }
      for i := 1 to Max_Invariantes do
         if A [i] <> NIL then begin
            Dispose (A [i]) ;
            A [i] := NIL ;
         end ;
   end ; { APAGA MATRIZ }

(************************************)

   Procedure Retira_Linha (Var A       : Tipo_Matriz ;
                           Var Num_Lin : Integer ;
                               Lin     : Integer) ;
   begin { RETIRA LINHA DE UMA MATRIZ }
     if A [Lin] <> NIL then begin
       Dispose (A [Lin]) ;
       while (Lin < Num_Lin) do begin
         A [Lin] := A [Succ (Lin)] ;
         Lin := Succ (Lin) ;
       end ;
       A [Lin] := NIL ;
       Num_Lin := Pred (Num_Lin) ;
     end ;
   end ; { RETIRA LINHA DE UMA MATRIZ }

(************************************)

   Procedure Monta_Matriz_de_Incidencia (Var Rede    : Tipo_Rede ;
                                         Var Incid   : Tipo_Matriz ;
                                         Var Num_Lin,
                                             Num_Col : Integer) ;
   Var
      i,j           : Integer ;
      Atual         : Ap_Arco_Rede ;
      Vet_Zeros,Vet : Vetor_Inteiros ;

   begin { MONTA MATRIZ DE INCIDENCIA }
      { monta vetor de zeros }
      for j := 1 to Max_Trans_Lugar do
        Vet_Zeros [j] := 0 ;

      { limpa matriz de incidencia }
      for j := 1 to Max_Invariantes do
        Incid [j] := NIL ;

      with Rede do begin
         for i := 1 to Num_Trans do begin
            Vet := Vet_Zeros ;

            { verifica entradas das transicoes }
            Atual := Pred_Trans [i] ;
            while Atual <> NIL do begin
               Vet [Atual^.Lugar_Ass] := - Atual^.Peso ;
               Atual := Atual^.Par_Trans ;
            end ;

            { verifica saidas das transicoes }
            Atual := Succ_Trans [i] ;
            while Atual <> NIL do begin
               Vet [Atual^.Lugar_Ass] := Vet [Atual^.Lugar_Ass] + Atual^.Peso ;
               Atual := Atual^.Par_Trans ;
            end ;

            New (Incid [i]) ;
            Incid [i]^ := Vet ;
         end ;
         Num_Lin := Num_Trans ;
         Num_Col := Num_Lugar ;
      end ;
   end ; { MONTA MATRIZ DE INCIDENCIA }

(************************************)

  Procedure Transpoe_Matriz (Var A       : Tipo_Matriz ;
                             Var Num_Lin,
                                 Num_Col : Integer) ;
  Var
    Dimensao,i,
    Auxiliar,j : Integer ;

  begin { TRANSPOE MATRIZ }
    if Num_lin > Num_Col then Dimensao := Num_Lin
                         else Dimensao := Num_Col ;
    for i := Num_Lin + 1 to Dimensao do
      New (A [i]) ;
    for i := 1 to Dimensao do
      for j := i + 1 to Dimensao do begin
        Auxiliar  := A [i]^[j] ;
        A [i]^[j] := A [j]^[i] ;
        A [j]^[i] := Auxiliar ;
      end ;
    Auxiliar := Num_Lin ;
    Num_Lin  := Num_Col ;
    Num_Col  := Auxiliar ;

    { retira linhas excedentes }
    while Dimensao > Num_Lin do
      Retira_Linha (A,Dimensao,Dimensao) ;
  end ; { TRANSPOE MATRIZ }

(************************************)

  Function MDC (u,v : Integer) : Integer ;
  begin { MAXIMO DIVISOR COMUM }
    if v = 0 then MDC := u
             else MDC := MDC (v, u MOD v) ;
  end ; { MAXIMO DIVISOR COMUM }

(************************************)

  Function Reduz_Fator_Comum (Var A       : Vetor_Inteiros ;
                                  Num_Col : Integer) : Integer ;
  Var
    j,Inicial,Divisor : Integer ;

  begin { REDUZ VETOR `A FORMA MINIMA }
    { encontra primeiro valor nao nulo do vetor }
    j := 1 ;
    while (j <= Num_Col) AND (A [j] = 0) do
      j := Succ (j) ;
    Inicial := A [j] ;

    { calcula o fator comum dos valores nao nulos }
    Divisor := Inicial ;
    for j := 1 to Num_Col do
      if A [j] <> 0 then
        Divisor := MDC (Divisor,A [j]) ;

    if Divisor <> 0 then begin

      { garante o sinal positivo para o primeiro valor }
      if (Divisor > 0) XOR (Inicial > 0) then
        Divisor := - Divisor ;

      { divide o vetor pelo fator comum }
      if Divisor <> 1 then
        for j := 1 to Num_Col do
          A [j] := A [j] DIV Divisor ;
    end ;
    Reduz_Fator_Comum := Divisor ;
  end ; { REDUZ VETOR `A FORMA MINIMA }

(************************************)

  Procedure Calcula_Base_Invariantes (Var Incid,Base  : Tipo_Matriz ;
                                      Var Num_Linhas,
                                          Num_Colunas,
                                          Num_Invar   : Integer) ;
  Var
    i : Integer ;

(**********)

    Procedure Monta_Matriz_Identidade (Var A        : Tipo_Matriz ;
                                           Dimensao : Integer) ;
    Var
      i,j : Integer ;
      Vet : Vetor_Inteiros ;

    begin { MONTA MATRIZ IDENTIDADE }
      for i := 1 to Dimensao do begin
        for j := 1 to Dimensao do
          if i = j then Vet [j] := 1
                   else Vet [j] := 0 ;
        New (A [i]) ;
        A [i]^ := Vet ;
      end ;
    end ; { MONTA MATRIZ IDENTIDADE }

(**********)

    Function Vetor_Nulo (Var A : Vetor_Inteiros ;  Num_Col : Integer) : Boolean ;
    begin { INDICA SE O VETOR E' NULO }
      while (Num_Col > 0) AND (A [Num_Col] = 0) do
        Num_Col := Pred (Num_Col) ;
      Vetor_Nulo := (Num_Col = 0) ;
    end ; { INDICA SE O VETOR E' NULO }

(**********)

    Procedure Triangulariza_por_Gauss (Var Inci,Base   : Tipo_Matriz ;
                                       Var Num_Linhas,
                                           Num_Colunas : Integer) ;
    Var
      Auxi       : Aponta_Vetor ;
      L1,L2      : Vetor_Inteiros ;
      Fat1,Fat2,
      FatMDC,k1,
      k2,Pivot,
      Lin,j,k    : Integer ;

    begin { TRIANGULARIZA MATRIZ DE INCIDENCIA SEGUNDO GAUSS }
      Lin := 1 ;
      Pivot := 1 ;
      while (Lin <= Num_Linhas) AND
            (Pivot <= Num_Colunas) AND NOT Erro do begin

        Erro := Pressiona_ESC ;
        { troca de linhas para obter pivot nao nulo }
        while (Pivot <= Num_Colunas) AND (Inci [Lin]^[Pivot] = 0) do begin
          k := Lin + 1 ;
          while (k <= Num_Linhas) AND (Inci [Lin]^[Pivot] = 0) do
            if (Inci [k]^[Pivot] <> 0) then begin
              Auxi       := Inci [Lin] ;
              Inci [Lin] := Inci [k] ;
              Inci [k]   := Auxi ;
              Auxi       := Base [Lin] ;
              Base [Lin] := Base [k] ;
              Base [k]   := Auxi ;
            end else
              k := Succ (k) ;
          if Inci [Lin]^[Pivot] = 0 then
            Pivot := Succ (Pivot) ;
        end ;

        { cancelamento dos campos nao nulos na coluna do pivot }
        if (Pivot <= Num_Colunas) then begin
          k1 := Inci [Lin]^[Pivot] ;
          for k := Succ (Lin) to Num_Linhas do
            if Inci [k]^[Pivot] <> 0 then begin
              k2 := Inci [k]^[Pivot] ;
              for j := Pivot to Num_Colunas do
                Inci [k]^[j] := k1 * Inci [k]^[j] - k2 * Inci [Lin]^[j] ;
              for j := 1 to Num_Linhas do
                Base [k]^[j] := k1 * Base [k]^[j] - k2 * Base [Lin]^[j] ;

              { reducao do fator comum a ambas para evitar overflow }
              L1 := Inci [k]^ ;
              Fat1 := Reduz_Fator_Comum (L1,Num_Colunas) ;
              L2 := Base [k]^ ;
              Fat2 := Reduz_Fator_Comum (L2,Num_Linhas) ;

              if (Fat1 <> Fat2) then begin
                { fatores comuns diferentes, fatora com o MDC entre ambos }
                FatMDC := MDC (Fat1,Fat2) ;
                if FatMDC <> 1 then begin
                  for j := Pivot to Num_Colunas do
                    Inci [k]^[j] := Inci [k]^[j] DIV FatMDC ;
                  for j := 1 to Num_Linhas do
                    Base [k]^[j] := Base [k]^[j] DIV FatMDC ;
                end ;
              end else begin
                { mesmo fator comum, adota o resultado da fatoracao }
                Inci [k]^ := L1 ;
                Base [k]^ := L2 ;
              end ;

            end ;
        end ;

        Lin := Succ (Lin) ;
        Pivot := Succ (Pivot) ;
      end ;
    end ; { TRIANGULARIZA MATRIZ DE INCIDENCIA SEGUNDO GAUSS }

(**********)

  begin { CALCULA BASE DOS INVARIANTES }
    { inicia matriz base dos invariantes }
    for i := 1 to Max_Invariantes do
      Base [i] := NIL ;

    Monta_Matriz_Identidade (Base,Num_Linhas) ;
    Triangulariza_por_Gauss (Incid,Base,Num_Linhas,Num_Colunas) ;

    { limpa a matriz base, deixando so' os invariantes }
    if NOT Erro then begin
      Num_Invar := Num_Linhas ;
      for i := Num_Linhas downto 1 do
        if NOT Vetor_Nulo (Incid [i]^,Num_Colunas) then
          Retira_Linha (Base,Num_Invar,i) ;

      for i := 1 to Num_Invar do
        Fator := Reduz_Fator_Comum (Base [i]^,Num_Linhas) ;

    end ;
  end ; { CALCULA BASE DOS INVARIANTES }

(************************************)

  Procedure Elimina_Linhas_Irredutiveis (Var B       : Tipo_Matriz ;
                                         Var Num_Lin,
                                             Num_Col : Integer) ;
  Var
    Auxi    : Aponta_Vetor ;
    k1,k2,
    Pivot,
    Lin,j,k : Integer ;
    Mudou,
    Posit,
    Negat   : Boolean ;

  begin { ELIMINA LINHAS NAO REDUTIVEIS `A FORMA POSITIVA }

    { escalona a base }
    Lin   := 1 ;
    Pivot := 1 ;
    while (Lin <= Num_Lin) AND (Pivot <= Num_Col) AND NOT Erro do begin
      Erro := Pressiona_ESC ;

      { troca de linhas para obter pivot nao nulo }
      while (Pivot <= Num_Col) AND (B [Lin]^[Pivot] = 0) do begin
        k := Lin + 1 ;
        while (k <= Num_Lin) AND (B [Lin]^[Pivot] = 0) do
          if (B [k]^[Pivot] <> 0) then begin
            Auxi    := B [Lin] ;
            B [Lin] := B [k] ;
            B [k]   := Auxi ;
          end else
            k := Succ (k) ;
        if B [Lin]^[Pivot] = 0 then
          Pivot := Succ (Pivot) ;
      end ;

      { cancelamento dos campos nao nulos na coluna do pivot }
      if (Pivot <= Num_Col) then begin

         { retira fator comum para evitar overflow de inteiros,
           tambem garantindo que o pivot sera' positivo }
         Fator := Reduz_Fator_Comum (B [Lin]^,Num_Col) ;

         { cancela demais valores da coluna do pivot }
         k1 := B [Lin]^[Pivot] ;
         for k := 1 to Num_Lin do
           if k <> Lin then
             if B [k]^[Pivot] <> 0 then begin
               k2 := B [k]^[Pivot] ;
               for j := 1 to Num_Col do
                 B [k]^[j] := k1 * B [k]^[j] - k2 * B [Lin]^[j] ;

               { retira fator comum para evitar overflow de inteiros }
               Fator := Reduz_Fator_Comum (B [k]^,Num_Col) ;
             end ;
      end ;

      Lin   := Succ (Lin) ;
      Pivot := Succ (Pivot) ;
    end ;

    { retira linhas com negativos isolados em colunas }
    repeat
      Erro := Pressiona_ESC ;
      Mudou := FALSE ;
      for j := 1 to Num_Col do begin
        { detecta se ha' negativos isolados na coluna j }
        Posit := FALSE ;
        Negat := FALSE ;
        Lin := 1 ;
        while (NOT Posit) AND (Lin <= Num_Lin) do begin
          if B [Lin]^[j] > 0 then
            Posit := TRUE
          else
            if B [Lin]^[j] < 0 then
              Negat := TRUE ;
          Lin := Succ (Lin) ;
        end ;

        { retira linhas com negativos isolados na coluna j }
        if Negat AND NOT Posit then begin
          Mudou := TRUE ;
          for Lin := Num_Lin DownTo 1 do
            if B [Lin]^[j] < 0 then
              Retira_Linha (B,Num_Lin,Lin) ;
        end ;
      end ;
    until (NOT Mudou) OR Erro ;

  end ; { ELIMINA LINHAS NAO REDUTIVEIS `A FORMA POSITIVA }

(************************************************************************)

   Procedure Elimina_Valores_Negativos (Var B               : Tipo_Matriz ;
                                        Var Num_Lin,Num_Col : Integer) ;
   Var
     Existe       : Boolean ;
     Num_Posit,
     i,j,k,m      : Integer ;
     Nova_Linha   : Vetor_Inteiros ;
     Suporte      : Array [1..Max_Invariantes] of ^Conj_Bytes ;
     Suporte_Novo : Conj_Bytes ;

(************************************)

     Function Vetor_Positivo (Var Vet     : Vetor_Inteiros ;
                                  Tamanho : Byte) : Boolean ;
     begin { VERIFICA SE UM VETOR E' POSITIVO }
       while (Tamanho > 0) AND (Vet [Tamanho] >= 0) do
         Tamanho := Pred (Tamanho) ;
       Vetor_Positivo := (Tamanho = 0) ;
     end ; { VERIFICA SE UM VETOR E' POSITIVO }

(************************************)

     Procedure Calcula_Suporte (Var Vetor   : Vetor_Inteiros ;
                                    Tamanho : Byte ;
                                Var Suporte : Conj_Bytes) ;
     begin { CALCULA SUPORTE DE UM VETOR }
       Suporte := [] ;
       while (Tamanho > 0) do begin
         if Vetor [Tamanho] <> 0 then
           Suporte := Suporte + [Tamanho] ;
         Tamanho := Pred (Tamanho) ;
       end ;
     end ; { CALCULA SUPORTE DE UM VETOR }

(************************************)

     Procedure Soma_Linhas (Var L1,L2,L3      : Vetor_Inteiros ;
                                k1,k2,Num_Col : Integer) ;
     Var j : Integer ;
     begin { L3 := K1*L1+K2*L2 }
       for j := 1 to Num_Col do L3 [j] := k1 * L1 [j] + k2 * L2 [j] ;
     end ; { L1 := K1*L1+K2*L2 }

(************************************)

     Procedure Atualiza_Contador (Var Cont : Integer) ;
     begin { ATUALIZA CONTADOR DE POSITIVOS }
       Cont := Succ (Cont) ;
       GotoXY (24,8) ;
       Write (Cont:4) ;
     end ; { ATUALIZA CONTADOR DE POSITIVOS }

(************************************)

   begin { ENCONTRA UMA BASE POSITIVA MINIMA PARA OS INVARIANTES }
     { limpa variaveis de controle }
     for i := 1 to Max_Invariantes do
       Suporte   [i] := NIL ;

     { montagem dos suportes das linhas iniciais }
     for i := 1 to Num_Lin do begin
       New (Suporte [i]) ;
       Calcula_Suporte (B [i]^,Num_Col,Suporte [i]^) ;
     end ;

     { inicia contador de invariantes positivos }
     Num_Posit := 0 ;
     for i := 1 to Num_Lin do
       if Vetor_Positivo (B [i]^,Num_Col) then
         Atualiza_Contador (Num_Posit) ;

     { testa as combinacoes possiveis de cancelamento entre linhas }
     j := 1 ;
     while (j <= Num_Col) AND NOT Erro do begin
       i := 1 ;
       while (i <= Num_Lin) AND NOT Erro do begin
         Erro := Pressiona_ESC ;
         if (B [i]^[j] < 0) then begin
           k := 1 ;
           while (k <= Num_Lin) AND NOT Erro do begin
             if (B [k]^[j] > 0) then begin
               { gera a linha soma entre as linhas i e k }
               Soma_Linhas (B [k]^,B [i]^,Nova_Linha,
                            B [i]^[j],- B [k]^[j],Num_Col) ;

               { calcula suporte da nova linha }
               Calcula_Suporte (Nova_Linha,Num_Col,Suporte_Novo) ;

               { testa se o novo suporte e' igual a algum outro }
               Existe := FALSE ;
               m := Num_Lin ;
               while (m > 0) AND NOT Existe do
                 if (Suporte [m]^ <= Suporte_Novo) then
                   Existe := TRUE
                 else
                   m := Pred (m) ;

               if NOT Existe then begin
                 { retira fator comum da linha }
                 Fator := Reduz_Fator_Comum (Nova_Linha,Num_Col) ;

                 { guarda nova linha gerada }
                 Num_Lin := Succ (Num_Lin) ;
                 New (B [Num_Lin]) ;
                 B [Num_Lin]^ := Nova_Linha ;
                 New (Suporte [Num_Lin]) ;
                 Suporte [Num_Lin]^ := Suporte_Novo ;
                 if Vetor_Positivo (Nova_Linha,Num_Col) then
                   Atualiza_Contador (Num_Posit) ;
               end ;
             end ;
             k := Succ (k) ;
           end ;
         end ;
         i := Succ (i) ;
       end ;

       { apaga todas as linhas com valores negativos na coluna j }
       i := 1 ;
       while (i <= Num_Lin) AND NOT Erro do begin
         Erro := Pressiona_ESC ;
         if (B [i]^[j] < 0) then begin
           { apaga valores da linha i }
           Dispose (B [i]) ;
           Dispose (Suporte [i]) ;

           { substitui linha i pela ultima linha da matriz }
           B [i] := B [Num_Lin] ;
           Suporte   [i] := Suporte   [Num_Lin] ;

           { limpa valores da ultima linha }
           B [Num_Lin] := NIL ;
           Suporte   [Num_Lin] := NIL ;

           Num_Lin := Pred (Num_Lin) ;
         end else
           i := Succ (i) ;
       end ;
       j := Succ (j) ;
     end ;

     { apaga os suportes das linhas }
     for i := 1 to Num_Lin do
       Dispose (Suporte [i]) ;

   end ; { ENCONTRA UMA BASE POSITIVA MINIMA PARA OS INVARIANTES }

(************************************************************************)

   Procedure Filtra_Invariantes (Var B       : Tipo_Matriz ;
                                 Var Num_Lin,
                                     Num_Col : Integer ;
                                     Obrigat,
                                     Proibid : Conj_Bytes) ;
   Var
      i,j : Integer ;

   begin { FILTRA INVARIANTES ENCONTRADOS }
     if (Obrigat <> []) OR (Proibid <> []) then begin
       for j := 1 to Num_Col do
         { retira os invariantes que nao contem nodos obrigatorios }
         if j in Obrigat then begin
           for i := Num_Lin downto 1 do
             if B [i]^[j] = 0 then
               Retira_Linha (B,Num_Lin,i) ;
         end else
         { retira os invariantes que contem nodos proibidos }
           if j in Proibid then
             for i := Num_Lin downto 1 do
               if B [i]^[j] <> 0 then
                 Retira_Linha (B,Num_Lin,i) ;
     end ;
   end ; { FILTRA INVARIANTES ENCONTRADOS }

(************************************************************************)

begin { ANALISE DE INVARIANTES }
   Erro := FALSE ;
   { testa existencia de analise anterior }
   if (Texto_Invar <> NIL) then
     Escolha := Resp ('Want to lose last analysis ? ([Y/N])')
   else
     Escolha := 'Y' ;

   if Escolha = 'Y' then begin

     { cria janela com menu adequado }
     if Invar_Trans then begin
       Cria_Janela (' Transition Invariants Calculation ',1,12,80,4,Atrib_Forte) ;
       Msg ('\ [B]egin Calculation   [O]bligatory transitions   [P]rohibited'+
            ' transitions   [H]elp') ;
     end else begin
       Cria_Janela (' Place Invariants Calculations ',1,12,80,4,Atrib_Forte) ;
       Msg ('\ [B]egin Calculation      [O]bligatory places      [P]rohibited' +
            ' places       [H]elp') ;
     end ;

     { verifica opcoes do usuario }
     Obrigatorios := [] ;
     Proibidos    := [] ;
     repeat
       Escolha := Tecla (Funcao) ;
       if Funcao then
         Escolha := '*'
       else
         Case Escolha of
           'B':;
           'H': Tela_Ajuda (Invariantes) ;
           'O':begin
                 if Invar_Trans then
                   Seleciona_Nodos (' Obligatory ',Rede.Nome_Trans,[0..255],
                                    Obrigatorios,Auxi,FALSE,Rede.Num_Trans,Rede.Tam_Trans)
                 else
                   Seleciona_Nodos (' Obligatory ',Rede.Nome_Lugar,[0..255],
                                    Obrigatorios,Auxi,FALSE,Rede.Num_Lugar,Rede.Tam_Lugar) ;
                 Proibidos := Proibidos - (Obrigatorios * Proibidos) ;
               end ;
           'P':begin
                 if Invar_Trans then
                   Seleciona_Nodos (' Prohibited ',Rede.Nome_Trans,[0..255],
                                    Proibidos,Auxi,FALSE,Rede.Num_Trans,Rede.Tam_Trans)
                 else
                   Seleciona_Nodos (' Prohibited ',Rede.Nome_Lugar,[0..255],
                                    Proibidos,Auxi,FALSE,Rede.Num_Lugar,Rede.Tam_Lugar) ;
                 Obrigatorios := Obrigatorios - (Obrigatorios * Proibidos) ;
               end ;
         else
           Escolha := '*'
         end ;
     until Escolha in ['*','B'] ;

     if Escolha = 'B' then begin

       { calcula invariantes }
       Cria_Janela (' Invariants Calculation ',49,12,32,14,Atrib_Forte) ;
       Msg (' Press [ESC] to abort   ') ;
       Apaga_Texto (Texto_Invar) ;
       Usa_Texto (Texto_Invar) ;
       WrtLnS ('Invariants Analysis for the net ' + Rede.Nome + '.') ;
       Traco ;
       Escreve_Inibicoes (Rede,Obrigatorios,Proibidos,Invar_Trans) ;
       Traco ;
       Msg ('\\ Create  incidence matrix ') ;
       Monta_Matriz_de_Incidencia (Rede,Incid,Num_Lin,Num_Col) ;
       Erro := Pressiona_ESC ;
       if NOT Erro then begin
         Msg ('\ Transpose matrix') ;
         if NOT Invar_Trans then
           Transpoe_Matriz (Incid,Num_Lin,Num_Col) ;
         Msg ('\ Calculate invariant basis ') ;
         Calcula_Base_Invariantes (Incid,Base,Num_Lin,Num_Col,Num_Invar) ;
         Apaga_Matriz (Incid) ;

         { escreve base encontrada para os invariantes }
         Msg ('\ Write invariant basis') ;
         if NOT Erro then begin
           if Invar_Trans then WrtS ('Transition')
                          else WrtS ('Place') ;
           WrtLnS (' invariant basis:') ;
           Nova_Linha ;
           Escreve_Invariantes (Rede,Base,Num_Invar,Num_Lin,'BI') ;
           Traco ;
         end ;

         if NOT Erro then begin
           Msg ('\ Drop irreducible lines ') ;
           Elimina_Linhas_Irredutiveis (Base,Num_Invar,Num_Lin) ;
           Msg ('\ Get positive invariants     ') ;
           Elimina_Valores_Negativos (Base,Num_Invar,Num_Lin) ;
           Msg ('\ Filter obtained invariants ') ;
           Filtra_Invariantes (Base,Num_Invar,Num_Lin,Obrigatorios,Proibidos) ;
         end ;

         { escreve resultados }
         Msg ('\ Write invariants') ;
         if NOT Erro then begin
           WrtS ('Minimum positive ') ;
           if Invar_Trans then WrtS ('transition')
                          else WrtS ('place') ;
           WrtLnS (' invariants for this net:') ;
           Nova_Linha ;
           if Invar_Trans then
             Escreve_Invariantes (Rede,Base,Num_Invar,Num_Lin,'IT')
           else
             Escreve_Invariantes (Rede,Base,Num_Invar,Num_Lin,'IL') ;
           Traco ;
         end ;
         if (NOT Erro) AND (Num_Invar <> 0) then begin
           Escreve_Teste_Cobertura (Rede,Base,Num_Invar,Num_Lin,Invar_Trans) ;
           Traco ;
           Escreve_Teste_Sub_Redes (Rede,Base,Num_Invar,Num_Lin,Invar_Trans) ;
           Traco ;
         end ;
       end ;
       Apaga_Matriz (Base) ;
       Apaga_Atual ;
     end ;
     Apaga_Atual ;
   end else
     Escolha := 'B' ;

   if NOT Erro then begin
     if Escolha = 'B' then
       if Invar_Trans then
         Edita_Texto (' Transition Invariants Analysis ',
                      Texto_Invar,1,1,8,18,FALSE,Funcao)
       else
         Edita_Texto (' Place Invariants Analysis ',
                      Texto_Invar,1,1,8,18,FALSE,Funcao) ;
   end else begin
     Apaga_Texto (Texto_Invar) ;
     Escolha := Resp ('aborted by user ...') ;
   end ;
end ; { ANALISE DE INVARIANTES }

end .

(************************************************************************)
