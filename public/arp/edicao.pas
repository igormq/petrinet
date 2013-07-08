(***********************************************************************)

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

Unit Edicao ;
Interface
  Uses Variavel,Texto ;

  Procedure Edicao_Redes (Var Rede       : Tipo_Rede ;
                          Var Nome_Arq   : String ;
                          Var Texto_Rede : Ap_Texto ;
                          Var Alterou,
                              Salvo      : Boolean) ;

  Procedure Apaga_Rede (Var Rede : Tipo_Rede) ;

(***********************************************************************)

Implementation
  Uses Crt,Dos,Interfac,Janelas,Ajuda,Arquivo ;

(****************************************)

Procedure Apaga_Rede (Var Rede : Tipo_Rede) ;
Var
  i : Byte ;

  Procedure Apaga_Arcos_Trans (Var Arco : Ap_Arco_Rede) ;
  begin { APAGA OS ARCOS LIGADOS A UMA TRANSICAO }
    if (Arco <> NIL) then begin
      Apaga_Arcos_Trans (Arco^.Par_Trans) ;
      Dispose (Arco) ;
      Arco := NIL ;
    end ;
  end;  { APAGA OS ARCOS LIGADOS A UMA TRANSICAO }

begin { APAGA REDE }
  With Rede do begin
    for i := 1 to Max_Trans_Lugar do begin
      Apaga_Arcos_Trans (Pred_Trans [i]) ;
      Apaga_Arcos_Trans (Succ_Trans [i]) ;
      Pred_Lugar [i] := NIL ;
      Succ_Lugar [i] := NIL ;
      Mo [i] := 0 ;
      if Nome_Trans [i] <> NIL then begin
        Dispose (Nome_Trans [i]) ;
        Nome_Trans [i] := NIL ;
      end ;
      if Nome_Lugar [i] <> NIL then begin
        Dispose (Nome_Lugar [i]) ;
        Nome_Lugar [i] := NIL ;
      end ;
    end ;
    Num_Trans := 0 ;
    Num_Lugar := 0 ;
    Tam_Trans := 0 ;
    Tam_Lugar := 0 ;
    Temporizada := FALSE ;
    Nome := '' ;
  end ;
end ; { APAGA REDE }

(****************************************)

Procedure Obtem_Lista_Trans (    Trans,
                                 Num_Lugar   : Byte ;
                             Var Lista_Trans,
                                 Lista_Lugar : Lista_Rede) ;
var
   Atual_Trans,
   Atual_Lugar : Ap_Arco_Rede ;
   Lugar       : Byte ;

begin { OBTEM LISTA COMPLEMENTAR DE UMA TRANSICAO }
   Lista_Trans [Trans] := NIL ;
   Atual_Trans := NIL ;
   for Lugar := 1 to Num_Lugar do
      if Lista_Lugar [Lugar] <> NIL then begin
         Atual_Lugar := Lista_Lugar [Lugar] ;
         while (Atual_Lugar <> NIL) AND
          (Atual_Lugar^.Trans_Ass <> Trans) do
            Atual_Lugar := Atual_Lugar^.Par_Lugar ;
         if Atual_Lugar <> NIL then begin
            if Atual_Trans = NIL then
               Lista_Trans [Trans] := Atual_Lugar
            else
               Atual_Trans^.Par_Trans := Atual_Lugar ;
            Atual_Trans := Atual_Lugar ;
            Atual_Trans^.Par_Trans := NIL ;
         end ;
      end ;
end ; { OBTEM LISTA COMPLEMENTAR DE UMA TRANSICAO }

(****************************************)

Procedure Obtem_Lista_Lugar (    Lugar,
                                 Num_Trans   : Byte ;
                             Var Lista_Trans,
                                 Lista_Lugar : Lista_Rede) ;
var
   Atual_Trans,
   Atual_Lugar : Ap_Arco_Rede ;
   Trans       : Byte ;

begin { OBTEM LISTA COMPLEMENTAR DE UM LUGAR }
   Lista_Lugar [Lugar] := NIL ;
   Atual_Lugar := NIL ;
   for Trans := 1 to Num_Trans do
      if Lista_Trans [Trans] <> NIL then begin
         Atual_Trans := Lista_Trans [Trans] ;
         while (Atual_Trans <> NIL) AND
          (Atual_Trans^.Lugar_Ass <> Lugar) do
            Atual_Trans := Atual_Trans^.Par_Trans ;
         if Atual_Trans <> NIL then begin
            if Atual_Lugar = NIL then
               Lista_Lugar [Lugar] := Atual_Trans
            else
               Atual_Lugar^.Par_Lugar := Atual_Trans ;
            Atual_Lugar := Atual_Trans ;
            Atual_Lugar^.Par_Lugar := NIL ;
         end ;
      end ;
end ; { OBTEM LISTA COMPLEMENTAR DE UM LUGAR }

(****************************************)

Procedure Ordena_Lista_Rede (Var Lista_Nodo : Lista_Rede ;
                             Var Num_Nodos  : Byte ;
                                 Trans      : Boolean) ;
Var
   Prox,
   Atual : Ap_Arco_Rede ;
   Nodo  : Byte ;

   Procedure Troca (Var A,B : Byte) ;
   Var
      Auxi : Byte ;

   begin { TROCA }
      Auxi := A ;
      A := B ;
      B := Auxi ;
   end ; { TROCA }

begin { ORDENA LISTA DE REDE }
   for Nodo := 1 to Num_Nodos do begin
      Atual := Lista_Nodo [Nodo] ;
      while Atual <> NIL do begin
         if Trans then begin
            Prox := Atual^.Par_Trans ;
            if (Prox <> NIL) then
               if (Atual^.Lugar_Ass > Prox^.Lugar_Ass) then begin
                  Troca (Atual^.Lugar_Ass,Prox^.Lugar_Ass) ;
                  Troca (Atual^.Peso,Prox^.Peso) ;
               end ;
         end else begin
            Prox := Atual^.Par_Lugar ;
            if (Prox <> NIL) then
               if (Atual^.Trans_Ass > Prox^.Trans_Ass) then begin
                  Troca (Atual^.Trans_Ass,Prox^.Trans_Ass) ;
                  Troca (Atual^.Peso,Prox^.Peso) ;
               end ;
         end ;
         if Trans then Atual := Atual^.Par_Trans
                  else Atual := Atual^.Par_Lugar ;
      end ;
   end ;
end ; { ORDENA LISTA DE REDE }

(****************************************)

   Procedure Edicao_Redes (Var Rede       : Tipo_Rede ;
                           Var Nome_Arq   : String ;
                           Var Texto_Rede : Ap_Texto ;
                           Var Alterou,
                               Salvo      : Boolean) ;
   Var
      Erro,Funcao,
      Existe_Arq,
      Editou      : Boolean ;
      Lin_Erro    : Integer ;
      Col_Erro    : Byte ;
      Prox_Escolha,
      Escolha     : Char ;
      Nome_Aux    : String ;

(***********************************************************************)

Procedure Compila_Rede (Var Rede         : Tipo_Rede ;
                        Var Texto_Fonte  : Ap_Texto ;
                        Var Lin_Erro     : Integer ;
                        Var Col_Erro     : Byte ;
                        Var Ocorreu_Erro : Boolean) ;

Const
   Max_Digit = 5 ; { Numero maximo de digitos em um numero }
   Nome_Erro : Array [1..27] of String [27] =
         ('unexpected end of file','unknown character',
          'number out of [0..254]','wrong interval',
          'transition overflow','place overflow',
          'invalid weight on edge','edge already declared',
          'structure already declared','node without relation :',
          'unknown identifier','too long identifier',
          'identifier already declared','waiting constant',
          'waiting identifier','waiting positive integer',
          'waiting place name','waiting transition name',
          'waiting PLACE / TRANSITION','waiting STRUCTURE',
          'waiting NODES','waiting NET','waiting',
          'number out of [0..32000]','real out of [0,001..1000]',
          'real out of [1..1000]','waiting positive real') ;

(** TIPOS DE USO DO COMPILADOR **************)
Type
   Token = (abre_par,fecha_par,vezes,virg,ponto,dois_ptos,
            pto_virg,igual,abre_colch,fecha_colch,constant,
            endnet,exponencial,net,nodes,normal,place,structure,
            transition,ident,numer) ;

   Rec_Ident = Record
      Tipo_Id  : Char ;
      Ender    : Integer ;
      Nome     : Tipo_Ident ;
   end ;

(** CONSTANTES DE USO DO COMPILADOR *********)
Const
   Nome_Separa  : Array [abre_par..fecha_colch] of Char =
                 ('(',')','*',',','.',':',';','=','[',']') ;

   Nome_Reserv  : Array [constant..transition] of String [10] =
                 ('CONST','ENDNET','EXPON','NET','NODES',
                  'NORMAL','PLACE','STRUCTURE','TRANSITION') ;

   Nulos        : Set of Char = [#0..#32] ;
   Letras       : Set of Char = ['A'..'Z','a'..'z','?','!'] ;
   Digitos      : Set of Char = ['0'..'9'] ;
   Especiais    : Set of Char = ['#','$','^','&','@','%','+','-','_'] ;

   Max_Ident    = 600 ;

(** VARIAVEIS DE USO DO COMPILADOR **********)
Var
   Ch           : Char ;
   Simbolo      : Token ;
   Identif      : Tipo_Ident ;
   Num_Linha,
   Numero,i     : Integer ;
   Num_Real     : Real ;
   Estrut_Trans,
   Estrut_Lugar : Boolean ;

   Pos,
   Num_Ident    : Integer ;
   Lista_Ident  : Array [1..Max_Ident] of Rec_Ident ;

   Aponta_Topo  : Integer ;
   Pilha_Int    : Array [1..Max_Ident] of Integer ;

   Lin_Atual    : Ap_Texto ;
   Col_Atual    : Byte ;

(********************************************)

   Procedure Erro (Codigo   : Byte ;
                   Auxiliar : Tipo_Ident) ;
   begin
      if NOT Ocorreu_Erro then begin
         Ocorreu_Erro := TRUE ;
         Msg ('\ Error : [') ;
         Write (Nome_Erro [Codigo]) ;
         if Auxiliar <> '' then
           write (' ',Auxiliar,'') ;
         Msg (']  (on cursor line).') ;
      end ;
   end ;

(********************************************)

   Procedure Pega_Car ;
   Var
      St : Linha_Texto ;

   begin { PEGA CARACTERE }
      if (Lin_Atual = NIL) then
         Erro (1,'')
      else begin
         St := Lin_Atual^.Cont ;
         if (Col_Atual = Length (St)) then begin
            Lin_Atual := Lin_Atual^.Prox ;
            Col_Atual := 0 ;
            Num_Linha := Succ (Num_Linha) ;
            GotoXY (1,WhereY) ;
            if (Lin_Atual <> NIL) then begin
               GotoXY (20,1) ;
               Write (Num_Linha:3) ;
            end ;
            Ch := ' ' ;
         end else begin
            Col_Atual := Succ (Col_Atual) ;
            Ch := St [Col_Atual] ;
         end ;
      end ;
   end ; { PEGA CARACTERE }

(********************************************)

   Procedure Pula_Nulos_e_Comentarios ;
   begin { PULA CARACTERES NULOS E COMENTARIOS }
      while (Ch in Nulos) AND NOT Ocorreu_Erro do
         Pega_Car ;
      if (Ch = '{') then begin
         repeat
            Pega_Car ;
         until (Ch = '}') OR Ocorreu_Erro ;
         Pega_Car ;
         Pula_Nulos_e_Comentarios ;
      end ;
   end ; { PULA CARACTERES NULOS E COMENTARIOS }

(********************************************)

   Procedure Pega_Simbolo ;
   Var
      Tok : Token ;
      i   : Byte ;
      St  : Tipo_Ident ;

(*******************)

      Procedure Processa_Identificador ;
      begin { PROCESSA IDENTIFICADOR }
         Identif := '' ;
         i := 0 ;
         while (Ch in (Letras + Digitos + Especiais)) AND NOT Ocorreu_Erro do begin
            i := Succ (i) ;
            Identif := Identif + Ch ;
            Pega_Car ;
         end ;
         if (i > Car_Max_Ident) then
            Erro (12,'') ;
         if NOT Ocorreu_Erro then begin
            St := UpString (Identif) ;
            Tok := constant ;           { TOKEN INICIAL : CONSTANTE }
            Simbolo := Ident ;
            repeat
              if (St = Nome_Reserv [Tok]) then
                 Simbolo := Tok
              else
                 if (St < Nome_Reserv [Tok]) then
                    Tok := Succ (transition)
                 else
                    Tok := Succ (Tok) ;
            until (Simbolo <> Ident) OR (Tok > transition) ;
         end ;
      end ; { PROCESSA IDENTIFICADOR }

(*******************)

      Procedure Processa_Numero ;
      begin { PROCESSA NUMERO }
         Simbolo := Numer ;
         Numero := 0 ;
         i := 0 ;
         while (Ch in Digitos) AND NOT Ocorreu_Erro do begin
            i := Succ (i) ;
            if (i > 5) then
               Erro (3,'')
            else begin
               Numero := 10 * Numero + (Ord (Ch) - Ord ('0')) ;
               Pega_Car ;
            end ;
         end ;
      end ; { PROCESSA NUMERO }

(*******************)

      Procedure Processa_Separador ;
      begin { PROCESSA SEPARADOR }
         Identif := Ch ;
         Pega_Car ;
         Case Identif [1] of
           ':': Simbolo := dois_ptos ;
           '(': Simbolo := abre_par ;
           ')': Simbolo := fecha_par ;
           '*': Simbolo := vezes ;
           ',': Simbolo := virg ;
           '.': Simbolo := ponto ;
           ';': Simbolo := pto_virg ;
           '=': Simbolo := igual ;
           '[': Simbolo := abre_colch ;
           ']': Simbolo := fecha_colch ;
         else
            if Identif [1] in Especiais then
               Erro (23,'character in [A-z]')
            else
               Erro (2,'"' + Identif [1] + '"') ;
         end ;
      end ; { PROCESSA SEPARADOR }

(*******************)

   begin { PEGA SIMBOLO }
      if NOT Ocorreu_Erro then begin
         Pula_Nulos_e_Comentarios ;
         Lin_Erro := Num_Linha ;
         Col_Erro := Col_Atual ;
         if (Ch in Letras) then
            Processa_Identificador
         else
            if (Ch in Digitos) then
               Processa_Numero
            else
               Processa_Separador ;
      end ;
   end ; { PEGA SIMBOLO }

(********************************************)

   Procedure Empilha (B : Integer)  ;
   begin { EMPILHA  INTEIRO }
      Aponta_Topo := Succ (Aponta_Topo) ;
      Pilha_Int [Aponta_Topo] := B ;
   end ; { EMPILHA INTEIRO }

(********************************************)

   Function Topo_Pilha : Integer ;
   begin { RETORNA O TOPO DA PILHA }
      if (Aponta_Topo > 0) then begin
         Topo_Pilha := Pilha_Int [Aponta_Topo] ;
         Aponta_Topo := Pred (Aponta_Topo) ;
      end  else
         Topo_Pilha := 0 ;
   end ; { RETORNA O TOPO DA PILHA }

(********************************************)

   Function Base_Pilha : Integer ;
   Var
      i : Integer ;

   begin { RETORNA A BASE DA PILHA }
      if (Aponta_Topo > 0) then begin
         Base_Pilha := Pilha_Int [1] ;
         for i := 2 to Aponta_Topo do
            Pilha_Int [Pred (i)] := Pilha_Int [i] ;
         Aponta_Topo := Pred (Aponta_Topo) ;
      end  else
         Base_Pilha := 0 ;
   end ; { RETORNA A BASE DA PILHA }

(********************************************)

   Function Existe (Var Identif : Tipo_Ident ;
                    Var Posicao : Integer) : Boolean ;
   Var
      Inicio,
      Final,Meio : Integer ;
      Exist,Fim  : Boolean ;
      Id_Novo,
      Id_Lista   : Tipo_Ident ;

   begin { EXISTE O IDENTIF NA LISTA }
      Id_Novo := UpString (Identif) ;
      Inicio := 1 ;
      Final := Num_Ident ;
      Exist := FALSE ;
      Fim := FALSE ;
      repeat
         Meio := (Inicio + Final + 1) div 2 ;
         Id_Lista := UpString (Lista_Ident [Meio].Nome) ;
         if (Id_Novo = Id_Lista) then
            Exist := TRUE
         else
            if (Id_Novo > Id_Lista) then
               Inicio := Meio
            else
               if (Final = Meio) then
                  Fim := TRUE
               else
                  Final := Meio ;
      until Exist OR Fim ;
      Posicao := Meio ;
      Existe := Exist ;
   end ; { EXISTE O IDENTIF NA LISTA }

(********************************************)

   Procedure Coloca (Var Identif  : Tipo_Ident ;
                         Posicao  : Integer ;
                         Tipo     : Char ;
                         Endereco : Byte) ;
   Var
      i : Integer ;

   begin { COLOCA IDENTIFICADOR NA LISTA }
      Num_Ident := Succ (Num_Ident) ;
      for i := Num_Ident DownTo Succ (Posicao) do
         Lista_Ident [i] := Lista_Ident [Pred (i)] ;
      with Lista_Ident [Posicao] do begin
         Nome := Identif ;
         Tipo_Id := Tipo ;
         Ender := Endereco ;
      end ;
   end ; { COLOCA IDENTIFICADOR NA LISTA }

(********************************************)

   Procedure Compila_Numero_Real ;
   Var
      K : Real ;

   begin { COMPILA NUMERO REAL }
      Pula_Nulos_e_Comentarios ;
      Lin_Erro := Num_Linha ;
      Col_Erro := Col_Atual ;
      if (Ch in Digitos) then begin
         Num_Real := 0 ;
         while (Ch in Digitos) do begin
            Num_Real := 10 * Num_Real + (Ord (Ch) - Ord ('0')) ;
            Pega_Car ;
         end ;
         if Ch = '.' then begin
            Pega_Car ;
            K := 1 ;
            while (Ch in Digitos) do begin
               K := K / 10 ;
               Num_Real := Num_Real + K * (Ord (Ch) - Ord ('0')) ;
               Pega_Car ;
            end ;
         end ;
      end else
         Erro (27,'') ;
   end ; { COMPILA NUMERO REAL }

(********************************************)

   Procedure Compila_Lista_Identificadores ;
   Var
      Fim_Lista : Boolean ;

   begin { COMPILA LISTA DE IDENTIFICADORES }
      Fim_Lista := FALSE ;
      repeat
         if (Simbolo = Ident) then
            if NOT Existe (Identif,Pos) then begin
               Coloca (Identif,Pos,'?',0) ;
               Pega_Simbolo ;
               if (Simbolo = virg) then
                  Pega_Simbolo
               else
                  Fim_Lista := TRUE ;
            end else
               Erro (13,'')
         else
            Erro (15,'') ;
      until Fim_Lista OR Ocorreu_Erro ;
   end ; { COMPILA LISTA DE IDENTIFICADORES }

(********************************************)

   Procedure Compila_Constantes ;
   Var
      Id : Integer ;

   begin { COMPILA DECLARACAO DE CONSTANTES }
      Pega_Simbolo ;
      if (Simbolo = Ident) then
         While (Simbolo = Ident) AND NOT Ocorreu_Erro do begin
            Compila_Lista_Identificadores ;
            if NOT Ocorreu_Erro then
               if (Simbolo = igual) then begin
                  Pega_Simbolo ;
                  if (Simbolo = Numer) then begin
                     Id := 1 ;
                     While (Id <= Num_Ident) AND NOT Ocorreu_Erro do
                        with Lista_Ident [Id] do begin
                           if (Tipo_Id = '?') then
                              with Lista_Ident [Id] do begin
                                 Tipo_Id := 'C' ;
                                 Ender := Numero ;
                              end ;
                           Id := Succ (Id) ;
                        end ;
                     Pega_Simbolo ;
                     if (Simbolo = pto_virg) then
                        Pega_Simbolo
                     else
                        Erro (23,'";"') ;
                  end else
                     Erro (16,'') ;
               end else
                  Erro (23,'"="') ;
         end
      else
         Erro (15,'') ;
   end ; { COMPILA DECLARACAO DE CONSTANTES }

(********************************************)

   Procedure Compila_Nodos ;
   Var
      T_Min,
      T_Max  : Integer ;
      Marc   : Byte ;
      Id,Pos : Integer ;
      Dist   : Tipo_Distrib ;

   begin { COMPILA DECLARACAO DE NODOS }
     Pega_Simbolo ;
     if (Simbolo = Ident) then
       While (Simbolo = Ident) AND NOT Ocorreu_Erro do begin
         Compila_Lista_Identificadores ;
         if NOT Ocorreu_Erro then
           if (Simbolo = dois_ptos) then begin
             Pega_Simbolo ;
             if (Simbolo = transition) then begin
               T_Min := 0 ;
               T_Max := 0 ;
               Pega_Simbolo ;

               { leitura do intervalo de disparo }
               if (Simbolo = Abre_Colch) then begin

                 Pega_Simbolo ;

                 if (Simbolo = Numer) then
                   T_Min := Numero
                 else
                   if (Simbolo = Ident) then
                     if Existe (Identif,Pos) then
                       if (Lista_Ident [Pos].Tipo_Id = 'C') then
                         T_Min := Lista_Ident [Pos].Ender
                       else
                         Erro (14,'')
                     else
                        Erro (11,'')
                   else
                     Erro (16,'') ;

                 if (T_Min < 0) OR (T_Min > 32000) then
                   Erro (24,'') ;

                 if NOT Ocorreu_Erro then begin
                   Pega_Simbolo ;
                   if (Simbolo = virg) then begin
                     Pega_Simbolo ;
                     if (Simbolo = Numer) then
                       T_Max := Numero
                     else
                       if (Simbolo = Ident) then
                         if Existe (Identif,Pos) then
                           if (Lista_Ident [Pos].Tipo_Id = 'C') then
                             T_Max := Lista_Ident [Pos].Ender
                           else
                             Erro (14,'')
                         else
                           Erro (11,'')
                       else
                         Erro (16,'') ;

                     if (T_Max < 0) OR (T_Max > 32000) then
                       Erro (24,'') ;
                     if T_Min > T_Max then
                       Erro (4,'') ;

                     Pega_Simbolo ;
                     if (Simbolo = Fecha_Colch) then
                       Pega_Simbolo
                     else
                       Erro (23,'"]"') ;
                   end else
                     Erro (23,'","') ;
                 end ;
               end ;

               { leitura do tipo de distribuicao de probabilidade }
               Dist := Unif ;
               Num_Real := 1 ;
               if (Simbolo in [Exponencial,Normal]) AND (NOT Ocorreu_Erro) then begin
                 Case Simbolo of
                    Exponencial : Dist := Expon ;
                    Normal      : Dist := Norm ;
                 end ;
                 Pega_Simbolo ;
                 if Simbolo = Abre_Par then begin
                   Compila_Numero_Real ;
                   if Num_Real = 1 then
                      Dist := Unif
                   else
                      if (Dist = Expon) then begin
                        if (Num_Real > 10000) OR (Num_Real < 0.0001) then
                           Erro (25,'') ;
                      end else
                        if (Num_Real > 10000) OR (Num_Real < 1) then
                           Erro (26,'') ;
                   Pega_Simbolo ;
                   if Simbolo = Fecha_Par then
                     Pega_Simbolo
                   else
                     Erro (23,'")"')
                 end else
                   Erro (23,'"("') ;
               end ;

               { atribuicao dos tempos lidos `as transicoes }
               Id := 1 ;
               While (Id <= Num_Ident) AND NOT Ocorreu_Erro do
                 with Lista_Ident [Id] do begin
                   if (Tipo_Id = '?') then
                     if (Rede.Num_Trans < Max_Trans_Lugar) then begin
                       Rede.Num_Trans := Succ (Rede.Num_Trans) ;
                       with Lista_Ident [Id] do begin
                         Tipo_Id := 'T' ;
                         Ender := Rede.Num_Trans ;
                         Rede.SEFT    [Ender] := T_Min ;
                         Rede.SLFT    [Ender] := T_Max ;
                         if (T_Min > 0) OR (T_Max > 0) then
                            Rede.Temporizada := TRUE ;
                         if T_Min = T_Max then
                            Rede.Distrib [Ender] := Unif
                         else
                            Rede.Distrib [Ender] := Dist ;
                         Rede.Coef    [Ender] := Num_Real ;
                       end ;
                     end else
                       Erro (5,'') ;
                   Id := Succ (Id) ;
                 end ;

               if (Simbolo = pto_virg) then
                 Pega_Simbolo
               else
                 Erro (23,'";"') ;

             end else
               if (Simbolo = place) then begin
                 Marc := 0 ;
                 Pega_Simbolo ;

                 if (Simbolo = abre_par) then begin
                   Pega_Simbolo ;
                   if (Simbolo = Numer) then
                     if Numero in [0..254] then begin
                       Marc := Numero ;
                       Pega_Simbolo ;
                       if (Simbolo = fecha_par) then
                         Pega_Simbolo
                       else
                         Erro (23,'")"')
                     end else
                       Erro (3,'')
                   else
                     if (Simbolo = Ident) then
                       if Existe (Identif,Pos) then
                         if (Lista_Ident [Pos].Tipo_Id = 'C') then
                            if (Lista_Ident [Pos].Ender in [0..254]) then begin
                              Marc := Lista_Ident [Pos].Ender ;
                              Pega_Simbolo ;
                              if (Simbolo = fecha_par) then
                                Pega_Simbolo
                              else
                                Erro (23,'")"') ;
                            end else
                              Erro (3,'')
                         else
                           Erro (14,'')
                       else
                         Erro (11,'')
                     else
                       Erro (16,'') ;
                 end ;

                 if NOT Ocorreu_Erro then begin
                   Id := 1 ;
                   While (Id <= Num_Ident) AND NOT Ocorreu_Erro do
                     with Lista_Ident [Id] do begin
                       if (Tipo_Id = '?') then
                         if (Rede.Num_Lugar < Max_Trans_Lugar) then begin
                           Rede.Num_Lugar := Succ (Rede.Num_Lugar) ;
                           with Lista_Ident [Id] do begin
                             Tipo_Id := 'L' ;
                             Ender := Rede.Num_Lugar ;
                             Rede.Mo [Rede.Num_Lugar] := Marc ;
                           end ;
                         end else
                           Erro (6,'') ;
                       Id := Succ (Id) ;
                     end ;
                   if (Simbolo = pto_virg) then
                     Pega_Simbolo
                   else
                     Erro (23,'";"') ;
                 end ;
               end else
                 Erro (19,'')
           end else
             Erro (23,'":"') ;
       end
     else
       Erro (15,'') ;
   end ; { COMPILA DECLARACAO DE NODOS }

(********************************************)

   Procedure Compila_Estrutura ;
   Var
      Nodo  : Byte ;

(*******************)

      Procedure Compila_Arcos ;
      Var
        Peso       : Byte ;
        Declarados : Conj_Bytes ;

      begin { COMPILA ARCOS }
        Declarados := [] ;
        Pega_Simbolo ;
        if (Simbolo = abre_par) then begin
          Pega_Simbolo ;
          while (Simbolo <> fecha_par) AND NOT Ocorreu_Erro do begin
            Peso := 1 ;
            if (Simbolo = Numer) then begin
              if (Numero in [1..254]) then begin
                Peso := Numero ;
                Pega_Simbolo ;
                if (Simbolo = vezes) then
                  Pega_Simbolo
                else
                  Erro (23,'"*"') ;
              end else
                 Erro (3,'') ;
            end else
              if (Simbolo = Ident) then
                if Existe (Identif,Pos) then
                  if (Lista_Ident [Pos].Tipo_Id = 'C') then
                    if (Lista_Ident [Pos].Ender in [0..254]) then begin
                      Peso := Lista_Ident [Pos].Ender ;
                      Pega_Simbolo ;
                      if (Simbolo = vezes) then
                        Pega_Simbolo
                      else
                        Erro (23,'"*"') ;
                    end else
                      Erro (7,'') ;

            if NOT Ocorreu_Erro then
              if (Simbolo = Ident) then
                if Existe (Identif,Pos) then
                  if Estrut_Trans then
                    if (Lista_Ident [Pos].Tipo_Id = 'L') then
                      if NOT (Pos in Declarados) then begin
                        Declarados := Declarados + [Pos] ;
                        Empilha (Peso) ;
                        Empilha (Lista_Ident [Pos].Ender) ;
                      end else
                        Erro (8,'')
                    else
                      Erro (17,'')
                  else
                    if (Lista_Ident [Pos].Tipo_Id = 'T') then
                      if NOT (Pos in Declarados) then begin
                        Declarados := Declarados + [Pos] ;
                        Empilha (Peso) ;
                        Empilha (Lista_Ident [Pos].Ender) ;
                      end else
                        Erro (8,'')
                    else
                      Erro (18,'')
                else
                  Erro (11,'')
              else
                Erro (15,'') ;
            Pega_Simbolo ;
              if (Simbolo <> fecha_par) then
                if (Simbolo = virg) then begin
                  Pega_Simbolo ;
                  if NOT (Simbolo in [Ident,Numer]) then
                    Erro (15,'') ;
                end else
                  Erro (23,'","') ;
          end ;
        end else
          Erro (23,'"("') ;
      end ; { COMPILA ARCOS }

(*******************)

      Procedure Monta_Arcos (Var Arco_Nodo : Ap_Arco_Rede) ;
      Var
         Nodo_Pilha,
         Peso_Arco  : Byte ;
         Atual      : Ap_Arco_Rede ;

      begin { MONTA ARCOS }
         Atual := Arco_Nodo ;
         while (Aponta_Topo <> 0) do begin
            if (Atual = NIL) then begin
               New (Arco_Nodo) ;
               Atual := Arco_Nodo ;
            end else
               if Estrut_Trans then begin
                  New (Atual^.Par_Trans) ;
                  Atual := Atual^.Par_Trans ;
               end else begin
                  New (Atual^.Par_Lugar) ;
                  Atual := Atual^.Par_Lugar ;
               end ;
            Atual^.Par_Trans := NIL ;
            Atual^.Par_Lugar := NIL ;
            if Estrut_Trans then begin
               Atual^.Trans_Ass := Nodo ;
               Atual^.Lugar_Ass := Topo_Pilha ;
            end else begin
               Atual^.Trans_Ass := Topo_Pilha ;
               Atual^.Lugar_Ass := Nodo ;
            end ;
            Atual^.Peso := Topo_Pilha ;
         end ;
      end ; { MONTA ARCOS }

(*******************)

   begin { COMPILA DECLARACAO DE ESTRUTURA }
      Pega_Simbolo ;
      if (Simbolo = Ident) then
         repeat
            if Existe (Identif,Pos) then begin
               Nodo := Lista_Ident [Pos].Ender ;
               if Estrut_Trans then
                  if (Lista_Ident [Pos].Tipo_Id = 'T') then
                     if (Rede.Pred_Trans [Nodo] = NIL) AND
                        (Rede.Succ_Trans [Nodo] = NIL) then
                        Estrut_Lugar := FALSE
                     else
                        Erro (9,'')
                  else
                     if NOT Estrut_Lugar then
                        Erro (18,'') ;
               if Estrut_Lugar then
                  if (Lista_Ident [Pos].Tipo_Id = 'L') then
                     if (Rede.Pred_Lugar [Nodo] = NIL) AND
                        (Rede.Succ_Lugar [Nodo] = NIL) then
                        Estrut_Trans := FALSE
                     else
                        Erro (9,'')
                  else
                     if NOT Estrut_Trans then
                        Erro (17,'')
                     else
                        Erro (18,'') ;
            end else
               Erro (11,'') ;
            if NOT Ocorreu_Erro then begin
               Pega_Simbolo ;
               if (Simbolo = dois_ptos) then begin
                  Compila_Arcos ;
                  if NOT Ocorreu_Erro then begin
                     if Estrut_Trans then
                        Monta_Arcos (Rede.Pred_Trans [Nodo])
                     else
                        Monta_Arcos (Rede.Pred_Lugar [Nodo]) ;
                     if NOT Ocorreu_Erro then begin
                        Pega_Simbolo ;
                        if (Simbolo = virg) then begin
                           Compila_Arcos ;
                           if NOT Ocorreu_Erro then begin
                           if Estrut_Trans then
                              Monta_Arcos (Rede.Succ_Trans [Nodo])
                           else
                              Monta_Arcos (Rede.Succ_Lugar [Nodo]) ;
                              if NOT Ocorreu_Erro then begin
                                 Pega_Simbolo ;
                                 if (Simbolo = pto_virg) then
                                    Pega_Simbolo
                                 else
                                    Erro (23,'";"') ;
                              end ;
                           end ;
                        end else
                           Erro (23,'","') ;
                     end ;
                  end ;
               end else
                  Erro (23,'":"') ;
            end ;
         until (Simbolo <> Ident) OR Ocorreu_Erro
      else
         Erro (15,'') ;
   end ; { COMPILA DECLARACAO DE ESTRUTURA }

(********************************************)

   Procedure Inicia_Compilacao ;
   begin { INICIA COMPILACAO }
      Pega_Simbolo ;
      if (Simbolo = net) then begin
         Pega_Simbolo ;
         if (Simbolo = Ident) AND NOT Ocorreu_Erro then begin
            Rede.Nome := Identif ;
            Pega_Simbolo ;
            if (Simbolo = pto_virg) then begin
               Pega_Simbolo ;
               if (Simbolo = constant) then
                  Compila_Constantes ;
               if (Simbolo = nodes) then begin
                  Compila_Nodos ;
                  if (Simbolo = constant) then
                     Compila_Constantes ;
                  if (Simbolo = structure) then
                     Compila_Estrutura
                  else
                     Erro (20,'') ;
               end else
                  Erro (21,'') ;
            end else
               Erro (23,'";"') ;
         end else
            Erro (15,'') ;
      end else
         Erro (22,'') ;
   end ; { INICIA COMPILACAO }

(********************************************)

begin { COMPILA REDE }
   Cria_Janela (' Compiler for Nets Description Language ',
                1,17,80,4,Atrib_Forte) ;
   Ch := ' ' ;
   Lin_Erro := 1 ;
   Col_Erro := 1 ;
   Lin_Atual := Texto_Fonte ;
   Col_Atual := 0 ;
   Num_Linha := 1 ;
   Num_Ident := 0 ;
   Aponta_Topo := 0 ;
   Identif := Chr (0) ;               { o ASCII mais baixo possivel }
   Coloca (Identif,1,' ',0) ;
   Identif := Chr (255) ;             { o ASCII mais alto  possivel }
   Coloca (Identif,2,' ',0) ;
   Estrut_Trans := TRUE ;
   Estrut_Lugar := TRUE ;
   Ocorreu_Erro := FALSE ;
   Apaga_Rede (Rede) ;
   Msg (' Compiling line [    1]') ;
   Inicia_Compilacao ;
   if NOT Ocorreu_Erro then begin
      with Rede do begin
         if Estrut_Trans then begin
            Ordena_Lista_Rede (Pred_Trans,Num_Trans,TRUE) ;
            Ordena_Lista_Rede (Succ_Trans,Num_Trans,TRUE) ;
            for i := 1 to Num_Lugar do begin
               Obtem_Lista_Lugar (i,Num_Trans,Pred_Trans,Succ_Lugar) ;
               Obtem_Lista_Lugar (i,Num_Trans,Succ_Trans,Pred_Lugar) ;
            end ;
         end else begin
            Ordena_Lista_Rede (Pred_Lugar,Num_Lugar,FALSE) ;
            Ordena_Lista_Rede (Succ_Lugar,Num_Lugar,FALSE) ;
            for i := 1 to Num_Trans do begin
               Obtem_Lista_Trans (i,Num_Lugar,Pred_Trans,Succ_Lugar) ;
               Obtem_Lista_Trans (i,Num_Lugar,Succ_Trans,Pred_Lugar) ;
            end ;
         end ;
      end ;
      Rede.Tam_Trans := 0 ;
      Rede.Tam_Lugar := 0 ;
      for i := 1 to Num_Ident do
         with Lista_ident [i] do
            Case Tipo_Id of
               'T': begin                { TRANSICAO }
                       New (Rede.Nome_Trans [Ender]) ;
                       Rede.Nome_Trans [Ender]^ := Nome ;
                       if Length (Nome) > Rede.Tam_Trans then
                          Rede.Tam_Trans := Length (Nome) ;
                    end ;
               'L': begin                { LUGAR }
                       New (Rede.Nome_Lugar [Ender]) ;
                       Rede.Nome_Lugar [Ender]^ := Nome ;
                       if Length (Nome) > Rede.Tam_Lugar then
                          Rede.Tam_Lugar := Length (Nome) ;
                    end ;
               'N': Rede.Nome := Nome ;  { NOME DA REDE }
            end ;
      with Rede do begin
         i := 1 ;
         While (i <= Num_Trans) AND NOT Ocorreu_Erro do
            if (Pred_Trans [i] = NIL) AND (Succ_Trans [i] = NIL) then
               Erro (10,'"' + Nome_Trans [i]^ + '"')
            else
               i := Succ (i) ;
         i := 1 ;
         While (i <= Num_Lugar) AND NOT Ocorreu_Erro do
            if (Pred_Lugar [i] = NIL) AND (Succ_Lugar [i] = NIL) then
               Erro (10,'"' + Nome_Lugar [i]^ + '"')
            else
               i := Succ (i) ;
      end ;
   end ;
   if NOT Ocorreu_Erro then begin
      Msg ('  ---  No errors detected.\ Net compiled : ['
           + Rede.Nome + ']  ') ;
      Write ('(',Rede.Num_Trans,' transitions and ',Rede.Num_Lugar,' places).') ;
   end else
      Apaga_Rede (Rede) ;
   Ch := Tecla (Funcao) ;
   Apaga_Atual ;
end ; { COMPILA REDE }

(***********************************************************************)

   begin { EDICAO DE REDES DE PETRI }
      Cria_Janela (' Petri Nets Edition ',1,21,80,5,Atrib_Forte) ;
      Msg (' Current Net : \\ [L]oad      [   S]ave        [  E]dit      ') ;
      Msg ('[C]ompile     [    D]irectory    [   H]elp ') ;
      Alterou := FALSE ;
      Prox_Escolha := ' ' ;
      repeat
         Editou := FALSE ;
         GotoXY (16,1) ;
         Write (Nome_Arq) ;
         ClrEoL ;
         if Prox_Escolha = ' ' then
            Escolha := Tecla (Funcao)
         else begin
            Escolha := Prox_Escolha ;
            Prox_Escolha := ' ' ;
         end ;
         if Funcao then
            Escolha := ' ' ;
         if (Escolha in ['C','S','E']) AND (Nome_Arq = '') then begin
            Prox_Escolha := Escolha ;
            Escolha := 'L' ;
         end ;
         Case Escolha of
           'L': begin
                   Escolha := 'Y' ;
                   if ((Texto_Rede <> NIL) AND NOT Salvo)
                     OR (Texto_Props <> NIL) OR (Texto_Simu <> NIL)
                     OR (Texto_Inv_Trans <> NIL) OR (Texto_Inv_Lugar <> NIL)
                     OR (Texto_Verif <> NIL) OR (Texto_Desemp <> NIL) then
                      Escolha := Resp ('Want to lose the last results ? ([Y/N])') ;
                   if (Escolha = 'Y') then begin
                      Apaga_Texto (Texto_Rede) ;
                      Apaga_Rede (Rede) ;
                      repeat
                         GotoXY (16,1) ;
                         Formato_Cursor (2) ;
                         TamBuffer := 60 ;
                         ReadF (Nome_Arq,TipoStr) ;
                         if (Nome_Arq <> '') then
                            Completa_Nome (Nome_Arq,'RDP') ;
                      until Nome_Valido (Nome_Arq,Existe_Arq) OR (Nome_Arq = '') ;
                      Formato_Cursor (0) ;
                      if (Nome_Arq = '') OR (Pos ('*',Nome_Arq) <> 0) then begin
                         Lista_Diretorio (Nome_Arq,TRUE) ;
                         ChDir (SubDir) ;
                         Existe_Arq := (Nome_Arq <> '') ;
                      end ;
                      if Existe_Arq then
                         Leitura_Texto (Texto_Rede,Nome_Arq) ;
                      if (Nome_Arq <> '') then
                         Escolha := Prox_Escolha
                      else
                         Prox_Escolha := ' ' ;
                      Alterou := TRUE ;
                      Salvo := TRUE ;
                   end ;
                end ;
           'C': begin
                   Compila_Rede (Rede,Texto_Rede,Lin_Erro,Col_Erro,Erro) ;
                   if Erro then begin
                      Edita_Texto (' Petri Nets Editor ',Texto_Rede,Col_Erro,
                                   Lin_Erro,8,18,TRUE,Editou) ;
                      if Editou then
                         Salvo := FALSE ;
                   end ;
                end ;
           'S': begin
                   Grava_Texto (Texto_Rede,Nome_Arq,FALSE) ;
                   Salvo := TRUE ;
                end ;
           'E': begin
                   Edita_Texto (' Petri Nets Editor ',Texto_Rede,
                                1,1,8,18,TRUE,Editou) ;
                   if Editou then begin
                      Apaga_Rede (Rede) ;
                      Salvo := FALSE ;
                   end ;
                end ;
           'D': begin
                   Lista_Diretorio (Nome_Aux,FALSE) ;
                   GetDir (0,SubDir) ;
                end ;
           'H': Tela_Ajuda (Edicao_Geral) ;
         else
            Escolha := '*' ;
         end ;
         if Editou then
            Alterou := TRUE ;
      until (Escolha = '*') AND NOT Funcao ;
      if (Texto_Rede <> NIL) then begin
         if (Rede.Num_Trans = 0) then
            Escolha := Resp ('Current text is not yet compiled') ;
         if NOT Salvo then begin
            Escolha := Resp ('Last edition was not saved. Save it ? ([Y]/[N])') ;
            if Escolha = 'Y' then begin
               Grava_Texto (Texto_Rede,Nome_Arq,FALSE) ;
               Salvo := TRUE ;
            end ;
         end ;
      end ;
      Apaga_atual ;
   end ; { EDICAO DE REDES DE PETRI }

end.

(***********************************************************************)
