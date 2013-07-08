(**************************************************************************)

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

{ Esta UNIT e' responsavel pela montagem dos textos de entrada e saida
  do analisador, e pelo editor que visualiza/edita estes textos. }

Unit Texto ;
Interface
Const
  Tam_Linha_Texto = 77 ; { no maximo 77 colunas }

Type
  Ap_Texto = ^Rec_Texto ;
  Linha_Texto = String [Tam_Linha_Texto] ;
  Rec_Texto = Record
    Prox,Ant : Ap_Texto ;
    Cont     : Linha_Texto ;
  end ;

{ procedimentos para a gerencia de textos }
Procedure Usa_Texto   (Var Texto : Ap_Texto) ;
Procedure Apaga_Texto (Var Texto : Ap_Texto) ;

{ procedimentos para a construcao de textos }
Procedure Nova_Linha ;
Procedure WrtS   (St : Linha_Texto) ;
Procedure WrtLnS (St : Linha_Texto) ;
Procedure WrtN   (Num : Integer) ;
Procedure WrtLnN (Num : Integer) ;
Procedure WrtR   (Num : Real ;  Digitos,Decimais : Byte) ;
Procedure WrtLnR (Num : Real ;  Digitos,Decimais : Byte) ;
Procedure Posic  (Col : Integer) ;
Function  Col_Texto : Integer ;
Function  Lin_Texto : Integer ;
Procedure Tab_Inic (Posicao : Integer) ;

{ procedimento para a edicao de textos }
Procedure Edita_Texto (    Titulo        : String ;   { titulo da janela     }
                       Var Texto         : Ap_Texto ; { texto a editar       }
                           Coluna_Cursor : Byte ;     { coluna do cursor     }
                           Linha_Cursor  : Integer ;  { linha  do cursor     }
                           Y,Altura      : Byte ;     { dimensoes da janela  }
                           Editar        : Boolean ;  { permitir alteracoes  }
                       Var Alterou       : Boolean) ; { houve alteracao      }

(**************************************************************************)

Implementation
Uses Crt,Janelas,Ajuda ;

Var
  Coluna_Inicial,
  Coluna_Atual   : Integer ;
  Linha_Atual    : Ap_Texto ;

(****************************************)

Procedure Usa_Texto (Var Texto : Ap_Texto) ;
begin { ADOTA UM TEXTO COMO ATUAL }
   Linha_Atual  := Texto ;
   Coluna_Atual := 1 ;
   Coluna_Inicial := 1 ;
   if Texto = NIL then begin
      New (Texto) ;
      Linha_Atual := Texto ;
      Texto^.Prox := NIL ;
      Texto^.Ant  := NIL ;
      Texto^.Cont := '' ;
   end else
      While (Linha_Atual^.Prox <> NIL) do
         Linha_Atual := Linha_Atual^.Prox ;
end ; { ADOTA UM TEXTO COMO ATUAL }

(****************************************)

Procedure Apaga_Texto (Var Texto : Ap_Texto) ;
begin { APAGA UM TEXTO DA MEMORIA }
   if Texto <> NIL then begin
      Apaga_Texto (Texto^.Prox) ;
      Dispose (Texto) ;
      Texto := NIL ;
   end ;
end ; { APAGA UM TEXTO DA MEMORIA }

(****************************************)

Procedure Nova_Linha ;
begin
   if Linha_Atual^.Prox = NIL then begin
      New (Linha_Atual^.Prox) ;
      with Linha_Atual^.Prox^ do begin
         Ant := Linha_Atual ;
         Prox := NIL ;
         Cont := '' ;
      end ;
   end ;
   Linha_Atual := Linha_Atual^.Prox ;
   Coluna_Atual := 1 ;
end ;

(****************************************)

Procedure WrtS (St : Linha_Texto) ;
Var
   Restantes,
   Tamanho_St : Integer ;
   Lin,Resto  : Linha_Texto ;

begin { ESCREVE STRING }
   if (St <> '') then begin
      Lin := Linha_Atual^.Cont ;
      Restantes  := Succ (Tam_Linha_Texto - Coluna_Atual) ;
      Tamanho_St := Length (St) ;

      while Length (Lin) < Coluna_Atual do
         Lin := Lin + '    ' ;

      if (Tamanho_St > Restantes) then begin
         { string ultrapassa a linha }
         if (Tamanho_St + Pred (Coluna_Inicial) > Tam_Linha_Texto) then begin
           Resto := Copy (St,Succ (Restantes),Tam_Linha_Texto) ;
           St    := Copy (St,1,Restantes) ;
           Delete (Lin,Coluna_Atual,Restantes) ;
           Insert (St,Lin,Coluna_Atual) ;
           Linha_Atual^.Cont := Lin ;
         end else
           Resto := St ;
         Nova_Linha ;
         Coluna_Atual := Coluna_Inicial ;
         WrtS (Resto) ;
      end else begin
         { nao ultrapassa os limites da linha }
         Delete (Lin,Coluna_Atual,Tamanho_St) ;
         Insert (St,Lin,Coluna_Atual) ;
         Linha_Atual^.Cont := Lin ;
         Coluna_Atual := Coluna_Atual + Length (St) ;
         if Coluna_Atual > Tam_Linha_Texto then begin
           Nova_Linha ;
           Coluna_Atual := Coluna_Inicial ;
         end ;
      end ;
   end ;
end ; { ESCREVE STRING }

(****************************************)

Procedure WrtN (Num : Integer) ;
Var
   St : Linha_Texto ;

begin { ESCREVE NUMERO }
   Str (Num,St) ;
   WrtS (St) ;
end ; { ESCREVE NUMERO }

(****************************************)

Procedure WrtLnS (St : Linha_Texto) ;
begin { ESCREVE STRING E NOVA LINHA }
   WrtS (St) ;
   Nova_Linha ;
end ; { ESCREVE STRING E NOVA LINHA }

(****************************************)

Procedure WrtLnN (Num  : Integer) ;
begin { ESCREVE NUMERO E NOVA LINHA }
   WrtN (Num) ;
   Nova_Linha ;
end ; { ESCREVE NUMERO E NOVA LINHA }

(****************************************)

Procedure WrtR   (Num : Real ;   Digitos,Decimais : Byte) ;
Var
   St : Linha_Texto ;

begin { ESCREVE NUMERO REAL }
   Str (Num:Digitos:Decimais,St) ;
   WrtS (St) ;
end ; { ESCREVE NUMERO REAL }

(****************************************)

Procedure WrtLnR (Num : Real ;   Digitos,Decimais : Byte) ;

begin { ESCREVE NUMERO REAL E NOVA LINHA }
   WrtR (Num,Digitos,Decimais) ;
   Nova_Linha ;
end ; { ESCREVE NUMERO REAL E NOVA LINHA }

(****************************************)

Procedure Posic  (Col : Integer) ;
begin { POSICIONA O CURSOR }
   if Col in [1..Tam_Linha_Texto] then
      Coluna_Atual := Col
   else
      Coluna_Atual := 1 ;
end ; { POSICIONA O CURSOR }

(****************************************)

Procedure Tab_Inic (Posicao : Integer) ;
begin { DEFINE A TABULACAO INICIAL }
  if Posicao in [1..Tam_Linha_Texto] then
    Coluna_Inicial := Posicao ;
end ; { DEFINE A TABULACAO INICIAL }

(****************************************)

Function  Col_Texto : Integer ;
begin { INDICA A POSICAO DO CURSOR }
   Col_Texto := Coluna_Atual ;
end ; { INDICA A POSICAO DO CURSOR }

(****************************************)

Function Lin_Texto : Integer ;
Var
  i    : Integer ;
  Auxi : Ap_Texto ;

begin { INDICA LINHA ATUAL DO TEXTO }
  i := 0 ;
  Auxi := Linha_Atual ;
  while Auxi <> NIL do begin
    Inc (i) ;
    Auxi := Auxi^.Ant ;
  end ;
  Lin_Texto := i ;
end ; { INDICA LINHA ATUAL DO TEXTO }

(** PROCEDIMENTO DE EDICAO DOS TEXTOS ********************)

Procedure Edita_Texto (    Titulo        : String ;   { titulo da janela     }
                       Var Texto         : Ap_Texto ; { texto a editar       }
                           Coluna_Cursor : Byte ;     { coluna do cursor     }
                           Linha_Cursor  : Integer ;  { linha  do cursor     }
                           Y,Altura      : Byte ;     { dimensoes da janela  }
                           Editar        : Boolean ;  { alterar / visualizar }
                       Var Alterou       : Boolean) ; { houve alteracao      }
Var
   Linha_Inicial,               { primeira linha  da tela               }
   Linha_Atual,                 { linha  em edicao                      }
   Linha_Final   : Ap_Texto ;   { ultima   linha  da tela               }
   Maximo_Linhas,               { maximo de linhas  na tela             }
   Numero_Linha  : Integer ;    { indicador do numero de linha atual    }
   Linha_Tela    : Byte ;       { linha do cursor na tela               }
   Letra         : Char ;       { ultima tecla pressionada              }
   Escrever,                    { indica que deve ser escrita nova tela }
   Insere,                      { indica modo de insercao               }
   Funcao        : Boolean ;    { indica tecla de funcao pressionada    }

(*********************************************************)
(** FUNCOES BASICAS DE MANIPULACAO DO TEXTO **************)

   Function KeyBoard (Var Funcao : Boolean) : Char ;
   Var
      Ch : Char ;

   begin { LEITURA DO TECLADO }
      Ch := ReadKey ;
      if (Ch = #0) then begin
         Ch := ReadKey ;
         Funcao := TRUE ;
      end else
         Funcao := FALSE ;
      KeyBoard := Ch ;
   end ; { LEITURA DO TECLADO }

(*******************)

   Procedure Tecla_Errada ;
   begin { INDICA TECLA NAO RECONHECIDA }
      Sound (100) ;
      Delay (50) ;
      NoSound ;
   end ; { INDICA TECLA NAO RECONHECIDA }

(*******************)

   Procedure Escreve_Linha (Var Linha   : Ap_Texto ;
                                Posicao : Byte) ;
   begin { ESCREVE UMA LINHA EM UMA POSICAO DADA }
      GotoXY (1,Posicao) ;
      if (Linha <> NIL) then
        Write (Linha^.Cont) ;
      ClrEOL ;
   end ; { ESCREVE UMA LINHA EM UMA POSICAO DADA }

(*******************)

   Procedure Escreve_Tela (Inicial : Ap_Texto ;
                           Posicao : Byte) ;
   Var
      i : Byte ;

   begin { ESCREVE A TELA A PARTIR DE UMA POSICAO DADA }
      for i := Posicao to Maximo_Linhas do begin
         Escreve_Linha (Inicial,i) ;
         if (Inicial <> NIL) then
            Inicial := Inicial^.Prox ;
      end ;
   end ; { ESCREVE A TELA A PARTIR DE UMA POSICAO DADA }

(*******************)

   Procedure Tira_Lixo (Var Linha : Ap_Texto) ;
   Var
      St : Linha_Texto ;

   begin { TIRA LIXO DE LINHA DE TEXTO }
      St := Linha^.Cont ;
      While (Length (St) > 0) AND (St [Length (St)] = ' ') do
         Delete (St,Length (St),1) ;
      Linha^.Cont := St ;
   end ; { TIRA LIXO DE LINHA DE TEXTO }

(*******************)

   Procedure Atualiza ;
   begin { ATUALIZA INFORMACOES NA TELA }
      Window (1,1,80,25) ;
      GotoXY (61,Y) ;
      Seta_Cores (Atrib_Inverso) ;
      Write (' L:',Numero_Linha:3,'  C:',Coluna_Cursor:3) ;
      if Insere then Write ('  Ins ')
                else Write ('  Sob ') ;
      Window (2,Succ (Y),79,Y + Altura - 2) ;
      Seta_Cores (Atrib_Forte) ;
   end ; { ATUALIZA INFORMACOES NA TELA }

(*********************************************************)
(** MOVIMENTACAO DO CURSOR E DA TELA *********************)

   Procedure Avanca_Cursor ;
   begin { AVANCA O CURSOR UMA COLUNA }
      if (Coluna_Cursor < Tam_Linha_Texto) then
         Coluna_Cursor := Succ (Coluna_Cursor) ;
   end ; { AVANCA O CURSOR UMA COLUNA }

(*******************)

   Procedure Retrocede_Cursor ;
   begin { RETROCEDE O CURSOR UMA COLUNA }
      if (Coluna_Cursor > 1) then
         Coluna_Cursor := Pred (Coluna_Cursor) ;
   end ; { RETROCEDE O CURSOR UMA COLUNA }

(*******************)

   Procedure Sobe_Cursor ;
   begin { SOBE O CURSOR UMA LINHA }
      if (Linha_Atual <> Texto) then begin
         if (Linha_Tela = 1) then begin
            Linha_Inicial := Linha_Inicial^.Ant ;
            InsLine ;
            Escreve_Linha (Linha_Inicial,1) ;
         end else
            Linha_Tela := Pred (Linha_Tela) ;
         Numero_Linha := Pred (Numero_Linha) ;
         Linha_Atual := Linha_Atual^.Ant ;
      end ;
   end ; { SOBE O CURSOR UMA LINHA }

(*******************)

   Procedure Desce_Cursor ;
   begin { DESCE O CURSOR UMA LINHA }
      if (Linha_Atual^.Prox <> NIL) then begin
         Numero_Linha := Succ (Numero_Linha) ;
         Linha_Atual := Linha_Atual^.Prox ;
         if (Linha_Tela = Maximo_Linhas) then begin
            Linha_Inicial := Linha_Inicial^.Prox ;
            GotoXY (78,Linha_Tela) ;
            WriteLn ;
            Escreve_Linha (Linha_Atual,Maximo_Linhas) ;
         end else
            Linha_Tela := Succ (Linha_Tela) ;
      end ;
   end ; { DESCE O CURSOR UMA LINHA }

(*******************)

   Procedure Inicio_de_Linha ;
   begin { COLOCA O CURSOR NO INICIO DA LINHA }
      Tira_Lixo (Linha_Atual) ;
      Coluna_Cursor := 1 ;
   end ; { COLOCA O CURSOR NO INICIO DA LINHA }

(*******************)

   Procedure Fim_de_Linha ;
   begin { COLOCA O CURSOR NO FINAL DA LINHA }
      Tira_Lixo (Linha_Atual) ;
      Coluna_Cursor := Succ (Length (Linha_Atual^.Cont)) ;
      if (Coluna_Cursor > Tam_Linha_Texto) then
         Coluna_Cursor := Tam_Linha_Texto ;
   end ; { COLOCA O CURSOR NO FINAL DA LINHA }

(*******************)

   Procedure Sobe_Pagina ;
   Var
      i : Byte ;

   begin { SOBE UMA PAGINA }
      if Linha_Inicial <> Texto then begin
         for i := 1 to Maximo_Linhas do
            if Linha_Inicial^.Ant <> NIL then begin
               Linha_Inicial := Linha_Inicial^.Ant ;
               Linha_Atual := Linha_Atual^.Ant ;
               Numero_Linha := Pred (Numero_Linha) ;
            end ;
         Escreve_Tela (Linha_Inicial,1) ;
      end else begin
        Linha_Tela := 1 ;
        Linha_Atual := Linha_Inicial ;
        Numero_Linha := 1 ;
      end ;
   end ; { SOBE UMA PAGINA }

(*******************)

   Procedure Desce_Pagina ;
   Var
      i : Byte ;

   begin { DESCE UMA PAGINA }
      if Linha_Atual^.Prox <> NIL then begin
         for i := 1 to Maximo_Linhas do
            if Linha_Atual^.Prox <> NIL then begin
               Linha_Inicial := Linha_Inicial^.Prox ;
               Linha_Atual := Linha_Atual^.Prox ;
               Numero_Linha := Succ (Numero_Linha) ;
            end ;
      end else begin
        Linha_Tela := 1 ;
        Linha_Inicial := Linha_Atual ;
      end ;
      Escreve_Tela (Linha_Inicial,1) ;
   end ; { DESC UMA PAGINA }

(*******************)

   Procedure Inicio_de_Texto ;
   begin { VAI PARA O INICIO DO TEXTO }
      if Linha_Inicial <> Texto then
         Escreve_Tela (Texto,1) ;
      Coluna_Cursor := 1 ;
      Linha_Atual := Texto ;
      Linha_Inicial  := Texto ;
      Numero_Linha := 1 ;
      Linha_Tela := 1 ;
   end ; { VAI PARA O INICIO DO TEXTO }

(*******************)

   Procedure Fim_de_Texto ;
   begin { VAI PARA O FINAL DO TEXTO }
      while Linha_Atual^.Prox <> NIL do begin
         Linha_Atual := Linha_Atual^.Prox ;
         Numero_Linha := Succ (Numero_Linha) ;
      end ;
      Linha_Inicial := Linha_Atual ;
      Linha_Tela := 1 ;
      Escreve_Tela (Linha_Inicial,1) ;
   end ; { VAI PARA O FINAL DO TEXTO }

(*********************************************************)
(** EDICAO / ALTERACAO DO TEXTO **************************)

   Procedure Escreve_Caractere (Ch : Char ;  Escrever : Boolean) ;
   Var
      St : Linha_Texto ;

   begin { ESCREVE UM CARACTERE NA POSICAO ATUAL DO CURSOR }
      St := Linha_Atual^.Cont ;
      while Length (St) < Coluna_Cursor do
         St := St + ' ' ;
      if Insere then begin
         if (Length (St) < Tam_Linha_Texto) then begin
            Insert (Ch,St,Coluna_Cursor) ;
            if Escrever then begin
               Linha_Atual^.Cont := St ;
               Escreve_Linha (Linha_Atual,Linha_Tela) ;
            end ;
         end ;
      end else begin
         GotoXY (Coluna_Cursor,Linha_Tela) ;
         Write (Ch) ;
         St [Coluna_Cursor] := Letra ;
      end ;
      Linha_Atual^.Cont := St ;
      Avanca_Cursor ;
   end ; { ESCREVE UM CARACTERE NA POSICAO ATUAL DO CURSOR }

(*******************)

   Procedure Nova_Linha ;
   Var
      i        : Byte ;
      Auxiliar : Ap_Texto ;
      St       : Linha_Texto ;

   begin { CRIA NOVA LINHA APOS A ATUAL }
      New (Auxiliar) ;
      if Linha_Atual^.Prox <> NIL then
         Linha_Atual^.Prox^.Ant := Auxiliar ;
      Auxiliar^.Prox := Linha_Atual^.Prox ;
      Linha_Atual^.Prox := Auxiliar ;
      Auxiliar^.Ant := Linha_Atual ;
      if Coluna_Cursor > Length (Linha_Atual^.Cont) then
         Auxiliar^.Cont := ''
      else begin
         Auxiliar^.Cont := Copy (Linha_Atual^.Cont,Coluna_Cursor,Tam_Linha_Texto) ;
         Delete (Linha_Atual^.Cont,Coluna_Cursor,Tam_Linha_Texto) ;
      end ;
      Escreve_Linha (Linha_Atual,Linha_Tela) ;
      Tira_Lixo (Linha_Atual) ;
      Desce_Cursor ;
      Inicio_de_Linha ;
      St := Linha_Atual^.Ant^.Cont ;
      if St <> '' then begin
         i := 1 ;
         while (i <= Length (St)) AND (St [i] = ' ') do begin
            Escreve_Caractere (' ',FALSE) ;
            i := Succ (i) ;
         end ;
      end ;
      Escreve_Tela (Linha_Atual,Linha_Tela) ;
   end ; { CRIA NOVA LINHA APOS A ATUAL }

(*******************)

   Procedure Apaga_Linha ;
   Var
      i        : Byte ;
      Auxiliar : Ap_Texto ;

   begin { APAGA LINHA ATUAL }
      if Linha_Atual^.Prox = NIL then begin
         Linha_Atual^.Cont := '' ;
      end else begin
         Auxiliar := Linha_Atual ;
         Linha_Atual^.Prox^.Ant := Linha_Atual^.Ant ;
         if Linha_Atual^.Ant <> NIL then
            Linha_Atual^.Ant^.Prox := Linha_Atual^.Prox
         else
            Texto := Linha_Atual^.Prox ;
         if Linha_Inicial = Linha_Atual then
            Linha_Inicial := Linha_Atual^.Prox ;
         Linha_Atual := Linha_Atual^.Prox ;
         Dispose (Auxiliar) ;
         Auxiliar := Linha_Atual ;
         for i := Succ (Linha_Tela) to Maximo_Linhas do
            if Auxiliar <> NIL then
               Auxiliar := Auxiliar^.Prox ;
         DelLine ;
         Escreve_Linha (Auxiliar,Maximo_Linhas) ;
      end ;
      Escreve_Linha (Linha_Atual,Linha_Tela) ;
   end ; { APAGA LINHA ATUAL }

(*******************)

   Procedure Junta_Linhas ;
   Var
      St1,St2 : Linha_Texto ;

   begin { JUNTA LINHAS ATUAL E PROXIMA }
      if Linha_Atual^.Prox <> NIL then begin
         St1 := Linha_Atual^.Cont ;
         St2 := Linha_Atual^.Prox^.Cont ;
         if Length (St1 + St2) <= Tam_Linha_Texto then begin
            St2 := St1 + St2 ;
            Linha_Atual^.Prox^.Cont := St2 ;
            Apaga_Linha ;
         end ;
      end ;
   end ; { JUNTA LINHAS ATUAL E PROXIMA }

(*******************)

   Procedure Apaga_Caractere (Escrever : Boolean) ;
   begin { APAGA O CARACTERE NA POSICAO ATUAL DO CURSOR }
      if Coluna_Cursor > Length (Linha_Atual^.Cont) then
         Junta_Linhas
      else begin
         Delete (Linha_Atual^.Cont,Coluna_Cursor,1) ;
         if Escrever then
            Escreve_Linha (Linha_Atual,Linha_Tela) ;
      end ;
   end ; { APAGA O CARACTERE NA POSICAO ATUAL DO CURSOR }

(*******************)

   Procedure Retorna_Caractere ;
   begin { BACKSPACE }
      if Coluna_Cursor > 1 then begin
         Retrocede_Cursor ;
         Apaga_Caractere (TRUE) ;
      end else
         if Linha_Atual^.Ant <> NIL then begin
            Sobe_Cursor ;
            Fim_de_Linha ;
            Junta_Linhas ;
         end ;
   end ; { BACKSPACE }

(*******************)

   Procedure Tabulacao ;
   Var
      i : Byte ;

   begin { TABULACAO }
      if Insere then begin
         for i := 1 to 8 do
            Escreve_Caractere (' ',FALSE) ;
         Escreve_Linha (Linha_Atual,Linha_Tela) ;
      end else
         for i := 1 to 8 do
            Avanca_Cursor ;
   end ; { TABULACAO }

(*********************************************************)

begin { EDITA TEXTO }
   Cria_Janela (Titulo,1,Y,80,Altura,Atrib_Forte) ;
   Insere := TRUE ;
   Alterou := FALSE ;
   Escrever := FALSE ;
   if Texto = NIL then begin
      New (Texto) ;
      Linha_Atual := Texto ;
      Texto^.Prox := NIL ;
      Texto^.Ant  := NIL ;
      Texto^.Cont := '' ;
      Linha_Cursor := 1 ;
      Coluna_Cursor := 1 ;
   end ;
   if NOT (Coluna_Cursor in [1..Tam_Linha_Texto]) then
      Coluna_Cursor := 1 ;
   Maximo_Linhas  := Altura - 2 ;
   Linha_Inicial := Texto ;
   Linha_Atual := Texto ;
   Numero_Linha := 1 ;
   Linha_Tela := 1 ;
   while (Numero_Linha <> Linha_Cursor) AND (Linha_Atual^.Prox <> NIL) do begin
      if Linha_Tela = Maximo_Linhas then
         Linha_Inicial := Linha_Inicial^.Prox
      else
         Linha_Tela := Succ (Linha_Tela) ;
      Linha_Atual := Linha_Atual^.Prox ;
      Numero_Linha := Succ (Numero_Linha) ;
   end ;
   Escreve_Tela (Linha_Inicial,1) ;
   repeat
      if NOT KeyPressed then
         Atualiza ;
      GotoXY (Coluna_Cursor,Linha_Tela) ;
      Formato_Cursor (2) ;
      Letra := KeyBoard (Funcao) ;
      Formato_Cursor (0) ;
      if Funcao then begin
         Case Letra of
            'H': Sobe_Cursor ;
            'P': Desce_Cursor ;
            'M': Avanca_Cursor ;
            'K': Retrocede_Cursor ;
            'I': Sobe_Pagina ;
            'Q': Desce_Pagina ;
            'R': Insere := NOT Insere ;
            'S': if Editar then Apaga_Caractere (TRUE)
                           else Tecla_Errada ;
            'O': Fim_de_Linha ;
            'G': Inicio_de_Linha ;
           #132: Inicio_de_Texto ;
            'v': Fim_de_Texto ;
            'D': ;
         else
            Tecla_Errada ;
         end ;
         if (Letra = 'S') then
            Alterou := TRUE ;
      end else
         if Editar then  begin
            Case Letra of
              #8  : Retorna_Caractere ;
              #9  : Tabulacao ;
              #13 : Nova_Linha ;
              #25 : Apaga_Linha ;
              #27 : Tela_Ajuda (Editor) ;
            else
               if (Ord (Letra) > 31) AND Editar then
                  Escreve_Caractere (Letra,NOT KeyPressed)
               else
                  Tecla_Errada ;
            end ;
            if Letra in [#8,#13,#25,#31..#255] then
               Alterou := TRUE ;
         end ;
   until (Editar AND Funcao AND (Letra = 'D')) OR NOT (Funcao OR Editar) ;
   Apaga_Atual ;
end ; { EDITA TEXTO }

end.

(**************************************************************************)
