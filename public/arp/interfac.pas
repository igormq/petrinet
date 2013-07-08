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

Unit Interfac ;

Interface
  Uses Variavel ;

  Type
    TipoVariavel = (TipoByte, TipoInt, TipoReal, TipoStr, TipoChar) ;

  Const
    { defaults para a leitura formatada }
    TamBufferDefault  = 30 ; { no maximo 255 }
    MinimoByteDefault = 0 ;
    MaximoByteDefault = 255 ;
    MinimoIntDefault  = - MaxInt ;
    MaximoIntDefault  = + MaxInt ;
    MinimoRealDefault = -1.7e38 ;
    MaximoRealDefault = +1.7e38 ;

    { tamanho do buffer da leitura formatada }
    TamBuffer   : Byte = TamBufferDefault ;

    { string com o default da entrada }
    ValorDefault: String = '' ;

    { valores limites da leitura formatada }
    ValorMinimo : Real = MinimoRealDefault ;
    ValorMaximo : Real = MaximoRealDefault ;

  Procedure ReadF    (Var Entrada ;   Tipo : TipoVariavel) ;
  Procedure Pergunta (Frase : String ;  Var Resposta  ;  Tipo : TipoVariavel) ;
  Function  Resp     (Frase : String) : Char ;
  Procedure Aviso    (Frase : String) ;

  Function  Tecla    (Var Funcao : Boolean) : Char ;
  Function  Pressiona_ESC : Boolean ;
  Function  UpString (St : String) : String ;

  Function  StI      (X : Integer) : String ;
  Function  StRe     (X : Real ;  Dig,Dec : Byte) : String ;
  Function  MinI     (A,B : Integer) : Integer ;
  Function  MaxI     (A,B : Integer) : Integer ;

  Procedure Leitura_Vetor (    Titulo         : String ;
                           Var NomeCampo      : Lista_Ident ;
                           Var Vetor          : Vetor_Inteiros ;
                               Habilitados    : Conj_Bytes ;
                               NumCampos,
                               TamNomes       : Byte ;
                               SimbEspecial1  : String ;
                               ValorEspecial1 : Integer ;
                               SimbEspecial2  : String ;
                               ValorEspecial2 : Integer) ;

  Procedure Seleciona_Nodos (    Titulo      : String ;
                             Var Nome_Nodo   : Lista_Ident ;
                                 Habilitados : Conj_Bytes ;
                             Var Escolhidos  : Conj_Bytes ;
                             Var Unico       : Byte ;
                                 Esc_Unica   : Boolean ;
                                 Num_Nodos,
                                 Tamanho     : Byte) ;

  Procedure EscConj  (    Conjunto : Conj_Bytes ;
                      Var Nome     : Lista_Ident ;
                          Tamanho  : Byte) ;

  Procedure EscVetor (Var Vetor ;
                      Var NomeCampos     : Lista_Ident ;
                          NumCampos      : Byte ;
                          TipoCampos     : TipoVariavel ;
                          SimbEspecial1  : String ;
                          ValorEspecial1 : Integer ;
                          SimbEspecial2  : String ;
                          ValorEspecial2 : Integer) ;

  Procedure Traco ;

(**************************************************************************)

Implementation

Uses Crt,Texto,Janelas ;

(**************************************************************************)

Function Tecla (Var Funcao : Boolean) : Char ;
Var
    Ch : Char ;
begin
    Ch := ReadKey ;
    If (Ch = #0) then begin
        Ch := ReadKey ;
        Funcao := TRUE ;
    end else
        Funcao := FALSE ;
    Tecla := UpCase (Ch) ;
end;

(****************************************)

Function Pressiona_ESC : Boolean ;
Var Funcao : Boolean ;
begin
  Pressiona_ESC := FALSE ;
  while KeyPressed do
    if Tecla (Funcao) = #27 then
      Pressiona_ESC := TRUE ;
end ;

(****************************************)

Function UpString (St : String) : String ;
Var i : Byte ;
begin { TRANSFORMA UMA STRING EM MAIUSCULA }
  for i := 1 to Length (St) do
    St [i] := UpCase (St [i]) ;
  UpString := St ;
end ; { TRANSFORMA UMA STRING EM MAIUSCULA }

(****************************************)

Function StI (X : Integer) : String ;
Var St : String ;
begin { TRANSFORMA NUMERO INTEIRO EM STRING }
  Str (X,St) ;
  StI := St ;
end ; { TRANSFORMA NUMERO INTEIRO EM STRING }

(****************************************)

Function StRe (X : Real ;  Dig,Dec : Byte) : String ;
Var St : String ;
begin { TRANSFORMA NUMERO REAL EM STRING }
  Str (X:Dig:Dec,St) ;
  StRe := St ;
end ; { TRANSFORMA NUMERO REAL EM STRING }

(****************************************)

Function MinI (A,B : Integer) : Integer ;
begin
  if A < B then MinI := A else MinI := B ;
end ;

(****************************************)

Function MaxI (A,B : Integer) : Integer ;
begin
  if A > B then MaxI := A else MaxI := B ;
end ;

(****************************************)

Procedure LeStr (Var Entrada: String ;  Tamanho_Maximo : Byte) ;
Var
  Comprimento       : Byte Absolute Entrada ;
  PosicaoX,PosicaoY,
  X_Anter,Y_Anter   : Byte ;
  Caractere         : Char ;

begin { LEITURA DE STRING DE TAMANHO DEFINIDO }
  PosicaoX := WhereX ;
  PosicaoY := WhereY ;
  Entrada := '' ;
  repeat
    Caractere := ReadKey ;
    Case Caractere of
     #00: begin
            Caractere := ReadKey ;
            if Caractere = 'G' then begin
              GotoXY (PosicaoX,PosicaoY) ;
              while Comprimento > 0 do begin
                Write (' ') ;
                Dec (Comprimento) ;
              end ;
              GotoXY (PosicaoX,PosicaoY) ;
            end ;
          end ;
     #08: if Comprimento > 0 then begin
            Dec (Comprimento) ;
            GotoXY (PosicaoX,PosicaoY) ;
            Write  (Entrada,' ') ;
            GotoXY (PosicaoX,PosicaoY) ;
            Write (Entrada) ;
          end ;
     #13: ;
    else
      if (Comprimento < Tamanho_Maximo) AND (Caractere >= #32) then begin
        X_Anter := WhereX ;
        Y_Anter := WhereY ;

        Entrada := Entrada + Caractere ;
        Write (Caractere) ;

        { testa se pulou para nova linha no final da tela, com scrool }
        if (X_Anter > WhereX) AND (Y_Anter = WhereY) then
          PosicaoY := Pred (PosicaoY) ;
      end ;
    end ;
  until Caractere = #13 ;
end ; { LEITURA DE STRING DE TAMANHO DEFINIDO }

(****************************************)

Procedure ReadF (Var Entrada ;   Tipo : TipoVariavel) ;
Var
  ValByte   : Byte    Absolute Entrada ;
  ValInt    : Integer Absolute Entrada ;
  ValReal   : Real    Absolute Entrada ;
  ValStr    : String  Absolute Entrada ;
  ValChar   : Char    Absolute Entrada ;

  Auxiliar    : String ;
  AuxReal     : Real ;
  PosX,PosY,i : Byte ;
  PosErro     : Integer ;

begin { PROCEDIMENTO DE LEITURA FORMATADA }
  { critica dos valores de controle da entrada }
  Case Tipo of
    TipoByte : begin
                 if ValorMinimo < MinimoByteDefault then
                   ValorMinimo := MinimoByteDefault ;
                 if ValorMaximo > MaximoByteDefault then
                   ValorMaximo := MaximoByteDefault ;
                 if TamBuffer = TamBufferDefault then TamBuffer := 3 ;
               end ;
    TipoInt  :begin
                 if ValorMinimo < MinimoIntDefault then
                   ValorMinimo := MinimoIntDefault ;
                 if ValorMaximo > MaximoIntDefault then
                   ValorMaximo := MaximoIntDefault ;
                 if TamBuffer = TamBufferDefault then TamBuffer := 6 ;
               end ;
    TipoReal : if TamBuffer = TamBufferDefault then TamBuffer := 15 ;
    TipoChar : TamBuffer := 0 ;
    TipoStr  : ;
  end ;

  PosX := WhereX ;
  PosY := WhereY ;
  { ajusta digitos do valor default }
  while Length (ValorDefault) > TamBuffer do
    Dec (ValorDefault [0]) ;

  repeat
    { limpa area da entrada de dados na tela }
    GotoXY (PosX,PosY) ;
    for i := 1 to TamBuffer do Write (' ') ;
    GotoXY (PosX,PosY) ;
    if ValorDefault <> '' then begin
      Write (ValorDefault) ;
      GotoXY (PosX,PosY) ;
      repeat until KeyPressed ;
      for i := 1 to TamBuffer do Write (' ') ;
      GotoXY (PosX,PosY) ;
    end ;

    { executa a leitura de acordo com o formato pedido }
    Case Tipo of
      TipoByte,
      TipoInt,
      TipoReal,
      TipoStr  : LeStr (Auxiliar,TamBuffer) ;
      TipoChar : ValChar := Tecla (Funcao) ;
    end ;
    if Auxiliar = '' then
      Auxiliar := ValorDefault ;

    { transfere o valor lido para a variavel dada }
    PosErro := 0 ;
    if (Tipo in [TipoByte, TipoInt, TipoReal]) AND (Auxiliar <> '') then begin
      Val (Auxiliar,AuxReal,PosErro) ;
      if (PosErro = 0) then
        if (AuxReal >= ValorMinimo) AND (AuxReal <= ValorMaximo) then
          Case Tipo of
            TipoByte: Val (Auxiliar,ValByte,PosErro) ;
            TipoInt : Val (Auxiliar,ValInt,PosErro) ;
            TipoReal: ValReal := AuxReal ;
          end
        else
          PosErro := 1 ;
    end else
      if Tipo = TipoStr then
        for i := 0 to Length (Auxiliar) do
          ValStr [i] := Auxiliar [i] ;
  until (PosErro = 0) ;

  { reestabelecimento dos valores default de entrada }
  ValorMinimo  := MinimoRealDefault ;
  ValorMaximo  := MaximoRealDefault ;
  TamBuffer    := TamBufferDefault ;
  ValorDefault := '' ;
end ; { PROCEDIMENTO DE LEITURA FORMATADA }

(****************************************)

Procedure Aviso (Frase : String) ;
Var
  i,NumLin,NumCol : Byte ;

begin { AVISO AO USUARIO }
  NumCol := Length (Frase) + 4 ;
  NumLin := 4 ;
  for i := 1 to Length (Frase) do
    if Frase [i] in ['[',']','|','\','#'] then
      NumCol := Pred (NumCol) ;

  NumLin := NumLin + (NumCol DIV 80) ;
  NumCol := MinI (80,NumCol) ;

  Cria_Janela ('',40 - (NumCol DIV 2),14 - (NumLin DIV 2),
               NumCol,NumLin,Atrib_Forte) ;
  Msg ('\ ' + Frase) ;
end ; { AVISO AO USUARIO }

(****************************************)

Procedure Pergunta_Old (Frase : String ;   Var Resposta  ;   Tipo : TipoVariavel) ;
Var
  i,NumLin,NumCol : Byte ;

begin { FAZ PERGUNTA AO USUARIO }
  NumCol := Length (Frase) + 4 + TamBuffer ;
  NumLin := 4 ;
  for i := 1 to Length (Frase) do
    if Frase [i] in ['[',']','|','\','#'] then
      NumCol := Pred (NumCol) ;
  NumLin := NumLin + (NumCol DIV 80) ;
  NumCol := MinI (80,NumCol) ;
  Cria_Janela ('',40 - (NumCol DIV 2),14 - (NumLin DIV 2),
               NumCol,NumLin,Atrib_Forte) ;
  Msg ('\ ' + Frase) ;
  if Tipo <> TipoChar then
    Formato_Cursor (2) ;
  ReadF (Resposta,Tipo) ;
  Formato_Cursor (0) ;
  Apaga_Atual ;
end ; { FAZ PERGUNTA AO USUARIO }

Procedure Pergunta (Frase : String ;   Var Resposta  ;   Tipo : TipoVariavel) ;
Var
  i,j,ColMem,NumLin,NumCol : Byte ;

begin { FAZ PERGUNTA AO USUARIO }
  { Determina numero de linhas e de colunas da janela }
  NumLin := 1 ;
  NumCol := 0 ;
  j := 0 ;
  for i := 1 to Length (Frase) do
    case Frase [i] of
      '\'    : begin
                 NumCol := MaxI (NumCol, j) ;
                 j := 0 ;
                 NumLin := succ (NumLin) ;
               end ;
      '|'    : ColMem := j ;
      '#'    : j := ColMem ;
      '[',']': begin
               end ;
    else
      j := succ (j) ;
    end ;
  NumCol := MaxI (NumCol,j) + 3 + TamBuffer ;
  NumLin := NumLin + 2 ;

  Cria_Janela ('',40 - (NumCol DIV 2),14 - (NumLin DIV 2),
               NumCol,NumLin,Atrib_Forte) ;

  Msg (Frase) ;
  if Tipo <> TipoChar then
    Formato_Cursor (2) ;
  ReadF (Resposta,Tipo) ;
  Formato_Cursor (0) ;
  Apaga_Atual ;
end ; { FAZ PERGUNTA AO USUARIO }

(****************************************)

Function Resp (Frase : String) : Char ;
Var Ch : Char ;
begin { RESPOSTA A PERGUNTA SIMPLES }
   TamBuffer := 0 ;
   Pergunta (Frase,Ch,TipoChar) ;
   Resp := UpCase (Ch) ;
end ; { RESPOSTA A PERGUNTA SIMPLES }

(**************************************************************************)

Procedure Seleciona_Nodos (    Titulo      : String ;
                           Var Nome_Nodo   : Lista_Ident ;
                               Habilitados : Conj_Bytes ;
                           Var Escolhidos  : Conj_Bytes ;
                           Var Unico       : Byte ;
                               Esc_Unica   : Boolean ;
                               Num_Nodos,
                               Tamanho     : Byte) ;
Var
   Posicao,Num_Nodos_Hab,
   Inicial,Final,Atual,
   i,j,Num_Lin,Num_Col,
   Lin_Inic,Col_Inic    : Integer ;
   Escolheu,
   Mudou,Funcao,Subindo : Boolean ;
   Escolha              : Char ;
   Nome_Habilitado      : Lista_Ident ;

   Procedure Destaca (Atrib : Byte) ;
   begin { DESTACA UM TRECHO DA TELA }
      Modifica_Atributo (Col_Inic + 1,Lin_Inic + Posicao,
                         Num_Col - 2,1,Atrib) ;
   end ; { DESTACA UM TRECHO DA TELA }

begin { SELECIONA NODOS DA REDE }
   Num_Nodos_Hab := 0 ;

   for i := 1 to Num_Nodos do
     if (i in Habilitados) then begin
       Num_Nodos_Hab := Succ (Num_Nodos_Hab) ;
       Nome_Habilitado [Num_Nodos_Hab] := Nome_Nodo [i] ;
       if (i in Escolhidos) then
         Escolhidos := Escolhidos - [i] + [Num_Nodos_Hab] ;
     end else
       if (i in Escolhidos) then
         Escolhidos := Escolhidos - [i] ;

   Num_Lin := MinI (25,Num_Nodos_Hab + 3) ;
   Lin_Inic := 13 - (Num_Lin DIV 2) ;

   Num_Col := Tamanho + 6 ;
   if Num_Col < (Length (Titulo) + 2) then
      Num_Col := Length (Titulo) + 2 ;
   Col_Inic := 81 - Num_Col ;

   Cria_Janela (Titulo,Col_Inic,Lin_Inic,Num_Col,Num_Lin,Atrib_Forte) ;
   Inicial  := 1 ;
   Atual    := 1 ;
   Unico    := 0 ;
   Mudou    := TRUE ;
   Subindo  := TRUE ;
   Escolheu := FALSE ;
   repeat
      if Mudou  then begin
         Final := MinI (Num_Nodos_Hab,Inicial + Num_Lin - 4) ;
         if Subindo then Atual := Inicial
                    else Atual := Final ;
         ClrScr ;
         for i := Inicial to Final do begin
            Posicao := i - Inicial + 2 ;
            GotoXY (3,Posicao) ;
            Write (Nome_Habilitado [i]^) ;
            if i in Escolhidos then Destaca (Atrib_Forte)
                               else Destaca (Atrib_Fraco) ;
         end ;
         Mudou := FALSE ;
      end ;
      if Inicial > 1 then begin
         GotoXY (1,2) ;
         Write (#30) ;
      end ;
      if Final < Num_Nodos_Hab then begin
         GotoXY (1,Num_Lin - 2) ;
         Write (#31) ;
      end ;
      Posicao := Atual - Inicial + 2 ;
      if Atual in Escolhidos then begin
         i := Atrib_Forte ;
         Destaca (Atrib_Inverso) ;
      end else begin
         i := Atrib_Fraco ;
         Destaca (Atrib_Destaque) ;
      end ;
      Escolha := Tecla (Funcao) ;
      Destaca (i) ;
      if Funcao then begin
         Case Escolha of
           'P'..'Q' : if (Atual = Final) OR (Escolha = 'Q') then begin
                         if (Inicial + Num_Lin - 3) <= Num_Nodos_Hab then begin
                            Inicial := Inicial + Num_Lin - 3 ;
                            Subindo := TRUE ;
                            Mudou := TRUE ;
                         end ;
                      end else
                         Atual := Succ (Atual) ;
           'H'..'I' : if (Atual = Inicial) OR (Escolha = 'I') then begin
                         if (Inicial - Num_Lin + 3) >= 1 then begin
                            Inicial := Inicial - Num_Lin + 3 ;
                            Subindo := FALSE ;
                            Mudou := TRUE ;
                         end ;
                      end else
                         Atual := Pred (Atual) ;
                'G' : Atual := Inicial ;
                'O' : Atual := Final ;
         else
            Escolha := '*' ;
         end ;
      end else
         if Escolha = #13 then
            if Esc_Unica then begin
               Unico := Atual ;
               Escolhidos := [Atual] ;
               Escolheu := TRUE ;
            end else
               if Atual in Escolhidos then
                  Escolhidos := Escolhidos - [Atual]
               else
                  Escolhidos := Escolhidos + [Atual]
         else
            Escolha := '*' ;
   until (Escolha = '*') OR (Escolheu AND Esc_Unica) ;
   Apaga_Atual ;
   i := Num_Nodos_Hab ;
   j := Num_Nodos ;
   while (i > 0) do begin
      if (i in Escolhidos) then begin
         while (j > 0) AND (Nome_Nodo [j] <> Nome_Habilitado [i]) do
            j := Pred (j) ;
         Escolhidos := Escolhidos - [i] + [j] ;
         if Unico = i then
            Unico := j ;
      end ;
      i := Pred (i) ;
   end ;
end ; { SELECIONA NODOS DA REDE }

(****************************************)

Procedure Leitura_Vetor (    Titulo         : String ;
                         Var NomeCampo      : Lista_Ident ;
                         Var Vetor          : Vetor_Inteiros ;
                             Habilitados    : Conj_Bytes ;
                             NumCampos,
                             TamNomes       : Byte ;
                             SimbEspecial1  : String ;
                             ValorEspecial1 : Integer ;
                             SimbEspecial2  : String ;
                             ValorEspecial2 : Integer) ;
Const   ChrDesce = #31 ;
        ChrSobe  = #30 ;
Var
  i,j,
  NumLinVet,             { numero de linhas  do vetor  }
  NumLinJan,             { numero de linhas  da janela }
  NumColJan,             { numero de colunas da janela }
  LinInicJan,            { linha  inicial da janela    }
  ColInicJan,            { coluna inicial da janela    }
  LinCurTela,            { linha do cursor na tela     }
  LinCurJan,             { linha do cursor na janela   }
  LinCurVet,             { linha do cursor no vetor    }
  ColCurJan,             { coluna do cursor na janela  }
  LinInicVet,            { linha  inicial do vetor  na janela   }
  ColCurInic,            { coluna inicial do cursor na janela   }
  ColCurEntr : Integer ; { coluna do cursor na entrada de dados }

  { entrada de dados }
  Entrada        : String ;
  Comprimento    : Byte Absolute Entrada ;
  Escolha        : Char ;

  { controle de fluxo }
  MudaEntrada,
  Final,MudaTela : Boolean ;
  VetorEntr      : Vetor_Inteiros ;
  NomeLinha      : Lista_Ident ;

  Function Valida (Var Entrada : String ;  Var Valor : Integer) : Boolean ;
  Var
    PosErro : Integer ;
    Result  : Real ;

  begin { TESTA SE UMA ENTRADA E' VALIDA, DANDO SEU RESULTADO }
    { retira espacos em branco da entrada }
    while Pos (' ',Entrada) <> 0 do
      Delete (Entrada,Pos (' ',Entrada),1) ;

    Valida := TRUE ;
    if Entrada = SimbEspecial1 then
      Valor := ValorEspecial1
    else
      if Entrada = SimbEspecial2 then
        Valor := ValorEspecial2
      else begin
        Val (Entrada,Result,PosErro) ;
        if (Entrada <> '') AND (PosErro = 0) AND
           (Result >= ValorMinimo) AND (Result <= ValorMaximo) then begin
          Valor  := Trunc (Result) ;
          if Valor = ValorEspecial1 then
            Entrada := SimbEspecial1
          else
            if Valor = ValorEspecial2 then
              Entrada := SimbEspecial2
            else
              Str (Valor,Entrada) ;
        end else
          Valida := FALSE ;
      end ;
  end ; { TESTA SE UMA ENTRADA E' VALIDA, DANDO SEU RESULTADO }

  Procedure Atualiza_Entrada ;
  begin
    GotoXY (ColCurInic,LinCurJan) ;
    Write (Entrada) ;
    ClrEoL ;
  end ;

begin { LEITURA DE VETOR }
  { separacao dos indices habilitados do vetor }
  NumLinVet := 0 ;
  for i := 1 to NumCampos do
    if i in Habilitados then begin
      NumLinVet := Succ (NumLinVet) ;
      VetorEntr [NumLinVet] := Vetor [i] ;
      NomeLinha [NumLinVet] := NomeCampo [i] ;
    end ;

  Formato_Cursor (0) ;
  { definicao do tamanho da janela de leitura }
  NumColJan := TamNomes + 7 + TamBuffer ;
  NumLinJan := MinI (NumLinVet + 3,25) ;

  { definicao da posicao da janela de leitura }
  LinInicJan := 13 - NumLinJan DIV 2 ; { posiciona na metade da tela }
  ColInicJan := 81 - NumColJan ;       { posiciona a direita da tela }
  Cria_Janela (Titulo,ColInicJan,LinInicJan,NumColJan,NumLinJan,Atrib_Forte) ;

  { define linha inicial do vetor na janela e do cursor }
  LinInicVet := 1 ;
  LinCurVet  := 1 ;
  ColCurInic := TamNomes + 5 ;

  { formatacao do simbolos especiais }
  while Length (SimbEspecial1) > TamBuffer do
    Dec (SimbEspecial1 [0]) ;
  while Length (SimbEspecial2) > TamBuffer do
    Dec (SimbEspecial2 [0]) ;

  Final  := FALSE ;
  repeat

    { escreve conteudo da janela }
    i := LinInicVet ;
    j := 2 ;
    while (i <= NumLinVet) AND (j <= NumLinJan - 2) do begin
      GotoXY (3,j) ;
      Write (NomeLinha [i]^) ;
      ClrEoL ;
      GotoXY (ColCurInic,j) ;

      if (VetorEntr [i] = ValorEspecial1) then
        Write (SimbEspecial1)
      else
        if (VetorEntr [i] = ValorEspecial2) then
          Write (SimbEspecial2)
        else
          Write (VetorEntr [i]) ;
      j := Succ (j) ;
      i := Succ (i) ;
    end ;

    { apagar o restante da tela }
    for i := j to NumLinJan - 2 do begin
      GotoXY (1,i) ;
      ClrEoL ;
    end ;

    { escreve setas de continuacao da lista }
    GotoXY (1,2) ;
    if LinInicVet > 1 then Write (ChrSobe)
                      else write (' ') ;
    GotoXY (1,NumLinJan - 2) ;
    if (LinInicVet + NumLinJan - 3) < NumLinVet then write (ChrDesce)
                                                else write (' ') ;

    ColCurEntr  := 1 ;
    MudaTela    := FALSE ;
    MudaEntrada := TRUE ;
    repeat

      LinCurJan  := LinCurVet  - LinInicVet + 2 ;
      ColCurJan  := ColCurEntr + ColCurInic - 1 ;
      LinCurTela := LinCurJan  + LinInicJan ;

      { atualiza string de entrada }
      if MudaEntrada then begin
        if VetorEntr [LinCurVet] = ValorEspecial1 then
          Entrada := SimbEspecial1
        else
          if VetorEntr [LinCurVet] = ValorEspecial2 then
            Entrada := SimbEspecial2
          else
            Str (VetorEntr [LinCurVet],Entrada) ;
        MudaEntrada := FALSE ;
      end ;

      { mostra linha selecionada }
      Modifica_Atributo (ColInicJan + 1,LinCurTela,NumColJan - 2,1,Atrib_Destaque) ;
      GotoXY (ColCurJan,LinCurJan) ;

      Formato_Cursor (2) ;
      Escolha := Tecla (Funcao) ;

      { somente apaga cursor se tecla de funcao }
      if Funcao OR (Escolha in [#13,#27]) then begin
        Formato_Cursor (0) ;
        { esconde linha selecionada }
        Modifica_Atributo (ColInicJan + 1,LinCurTela,NumColJan - 2,1,Atrib_Forte) ;
      end ;

      if Funcao then begin
        { movimento vertical do cursor }
        if Escolha in ['H','P','I','Q','G','O'] then begin
          if Valida (Entrada,VetorEntr [LinCurVet]) then begin
            Atualiza_Entrada ;
            Case Escolha of
             'H': if (LinCurVet > 1) then begin
                    LinCurVet := Pred (LinCurVet) ;
                    ColCurEntr := 1 ;
                    MudaEntrada := TRUE ;
                    if (LinCurVet < LinInicVet) then begin
                      LinInicVet := Pred (LinInicVet) ;
                      MudaTela := TRUE ;
                    end ;
                  end ;
             'P': if (LinCurVet < NumLinVet) then begin
                    LinCurVet := Succ (LinCurVet) ;
                    ColCurEntr := 1 ;
                    MudaEntrada := TRUE ;
                    if (LinCurVet - LinInicVet = NumLinJan - 3) then begin
                      LinInicVet := Succ (LinInicVet) ;
                      MudaTela := TRUE ;
                    end ;
                  end ;
             'I': if LinInicVet > 1 then begin
                    LinInicVet := MaxI (1,LinInicVet - NumLinJan + 3) ;
                    LinCurVet  := MaxI (1,LinCurVet  - NumLinJan + 3) ;
                    MudaTela := TRUE ;
                  end ;
             'Q': if LinInicVet < NumLinVet then begin
                    LinInicVet := MinI (NumLinVet,LinInicVet + NumLinJan - 3) ;
                    LinCurVet  := MinI (NumLinVet,LinCurVet  + NumLinJan - 3) ;
                    MudaTela := TRUE ;
                  end ;
             'G': if LinCurVet <> LinInicVet then begin
                    LinCurVet := LinInicVet ;
                    MudaEntrada := TRUE ;
                  end ;
             'O': if LinCurVet < LinInicVet + NumLinJan - 4 then begin
                    MudaEntrada := TRUE ;
                    LinCurVet := MinI (NumLinVet,LinInicVet + NumLinJan - 4) ;
                  end ;
            end ;
          end ;
        end else
          { movimento horizontal do cursor }
          Case Escolha of
           'K': ColCurEntr := MaxI (1,Pred (ColCurEntr)) ;
           'M': ColCurEntr := MinI (Succ (Comprimento),Succ (ColCurEntr)) ;
           'S': if (ColCurEntr in [1..Comprimento]) then begin
                  Delete (Entrada,ColCurEntr,1) ;
                  Atualiza_Entrada ;
                end ;
          end ;
      end else

        { teclas de edicao edicao }
        Case Escolha of
        #08: if (ColCurEntr > 1) then begin
               ColCurEntr := Pred (ColCurEntr) ;
               Delete (Entrada,ColCurEntr,1) ;
               Atualiza_Entrada ;
             end ;
        #13: if Valida (Entrada,VetorEntr [LinCurVet]) then
               if (LinCurVet < NumLinVet) then begin
                 LinCurVet := Succ (LinCurVet) ;
                 ColCurEntr := 1 ;
                 MudaEntrada := TRUE ;
                 if (LinCurVet - LinInicVet = NumLinJan - 3) then begin
                   LinInicVet := Succ (LinInicVet) ;
                   MudaTela := TRUE ;
                 end ;
               end else
                 Final := TRUE ;
        #27: if Valida (Entrada,VetorEntr [LinCurVet]) then
               Final := TRUE ;
        else
          if Escolha in [#32..#255] then
            if ColCurEntr > Comprimento then begin
              if (Comprimento < TamBuffer) then begin
                Entrada := Entrada + Escolha ;
                ColCurEntr := Succ (ColCurEntr) ;
                Atualiza_Entrada ;
              end ;
            end else begin
              Entrada [ColCurEntr] := Escolha ;
              ColCurEntr := Succ (ColCurEntr) ;
              Atualiza_Entrada ;
            end ;
        end ;

    Until MudaTela OR Final ;
  Until Final ;
  Apaga_Atual ;

  { devolve os valores aos indices habilitados }
  for i := NumCampos downto 1 do
    if i in Habilitados then begin
      Vetor [i] := VetorEntr [NumLinVet] ;
      NumLinVet := Pred (NumLinVet) ;
    end ;

  { devolve os valores default dos limitadores }
  TamBuffer   := TamBufferDefault ;
  ValorMinimo := MinimoRealDefault ;
  ValorMaximo := MaximoRealDefault ;
end ; { LEITURA DE VETOR }

(****************************************)

Procedure EscConj (Conjunto: Conj_Bytes ; Var Nome: Lista_Ident ; Tamanho: Byte) ;
Var
  i : Byte ;

begin { ESCREVE CONJUNTO }
  WrtS ('{') ;
  Tab_Inic (Col_Texto) ;
  if Conjunto <> [] then
    if (Conjunto = [1..Tamanho]) then
      WrtS ('all')
    else begin
      for i := 1 to Tamanho do
        if i in Conjunto then
          WrtS (Nome [i]^ + ', ') ;
      Posic (Col_Texto - 2) ;
    end ;
  WrtLnS ('}') ;
end ; { ESCREVE CONJUNTO }

(****************************************)

Procedure EscVetor (Var Vetor ;
                    Var NomeCampos     : Lista_Ident ;
                        NumCampos      : Byte ;
                        TipoCampos     : TipoVariavel ;
                        SimbEspecial1  : String ;
                        ValorEspecial1 : Integer ;
                        SimbEspecial2  : String ;
                        ValorEspecial2 : Integer) ;
Var
  VetorByte   : Vetor_Bytes    Absolute Vetor ;
  VetorInt    : Vetor_Inteiros Absolute Vetor ;
  VetorFinal  : Vetor_Inteiros ;
  Escreveu    : Boolean ;
  Elem,i      : Integer ;

begin { ESCREVE VETOR DO TIPO DADO }
  WrtS ('{') ;
  Tab_Inic (Col_Texto) ;
  Escreveu := FALSE ;

  if TipoCampos = TipoInt then
    VetorFinal := VetorInt
  else
    for i := 1 to NumCampos do
      VetorFinal [i] := VetorByte [i] ;

  i := 1 ;
  while (i <= NumCampos) AND (NomeCampos [i] <> NIL) do begin
    Elem := VetorFinal [i] ;
    if Elem <> 0 then begin
      Escreveu := TRUE ;

      { escreve o elemento }
      if Elem = ValorEspecial1 then
        WrtS (SimbEspecial1 + '* ' + NomeCampos [i]^ + ', ')
      else
        if Elem = ValorEspecial2 then
          WrtS (SimbEspecial2 + '* ' + NomeCampos [i]^ + ', ')
        else
          Case Elem of
            1: WrtS (NomeCampos [i]^ + ', ') ;
           -1: WrtS ('-' + NomeCampos [i]^ + ', ') ;
          else
            WrtS (StI (Elem) + '* ' + NomeCampos [i]^ + ', ') ;
          end ;
    end ;
    i := Succ (i) ;
  end ;

  if Escreveu then
    Posic (Col_Texto - 2) ;
  WrtLnS ('}') ;
end ; { ESCREVE VETOR DO TIPO DADO }

(****************************************)

Procedure Traco ;
begin { ESCREVE UM TRACO }
   Posic (1) ;
   WrtLnS ('*--------------------------------------------------------------------------*') ;
end ; { ESCREVE UM TRACO }

end.

(**************************************************************************)
