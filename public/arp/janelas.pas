(*********************************************************************)

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

{
   Esta UNIT e' composta por um conjunto de procedimentos para o uso e
   manipulacao  de  janelas na tela de texto em programas TURBO-PASCAL
   versao 4.0 ou  superiores, em PC-DOS (16 bits IBM-PC). Para maiores
   explicacoes sobre o uso de UNITS vide o manual do Turbo Pascal.

   Desenvolvida no Laboratorio de Controle  e Microinformatica  (LCMI)
   do depto  de Engenharia Eletrica  da  Universidade Federal de Santa
   Catarina (UFSC), em 1988, por C.A. Maziero.

   Obs: esta UNIT deve ser declarada em "Uses" ANTES de qualquer outra
        que possa utiliza-la, para que seu codigo  de  iniciacao  seja
        corretamente executado.
}
Unit Janelas ;
Interface
  Const
    { dimensoes da tela de texto }
    Max_Tela_X = 80 ;
    Max_Tela_Y = 25 ;

    { caracteres da moldura das janelas (podem ser alterados) }
    Barra_Horizontal_Inferior : Char = 'Ä' ;
    Barra_Horizontal_Superior : Char = 'Í' ;
    Barra_Vertical_Esquerda   : Char = '³' ;
    Barra_Vertical_Direita    : Char = '³' ;
    Canto_Inferior_Esquerdo   : Char = 'À' ;
    Canto_Superior_Esquerdo   : Char = 'Õ' ;
    Canto_Inferior_Direito    : Char = 'Ù' ;
    Canto_Superior_Direito    : Char = '¸' ;

  Var
    { atributos "default" para compatibilidade entre videos diversos }
    Atrib_Fraco, Atrib_Forte, Atrib_Inverso, Atrib_Destaque : Byte ;

{ ****** procedimentos de manipulacao de janelas ****** }

  Function Janela_Atual : Byte ;
  { Retorna o numero da janela atualmente ativa. }

  Function Janela_em_Uso (Numero : Byte) : Boolean ;
  { Informa se a janela "Numero" esta' sendo usada ou nao. }

  Procedure Cria_Janela (Titulo: String ;  X,Y,Col,Lin,Atributo : Byte) ;
  { Cria uma janela definida pelo usuario, guardando o trecho de tela
    sobreposto  pela  mesma. A janela e'definida  por seu Titulo, seu
    canto superior esquerdo (X,Y), suas dimensoes incluindo a moldura
    (Col,Lin) e o atributo de texto a seu usado. }

  Procedure Vai_Para_Janela (Destino : Byte) ;
  { Permite mudar de uma janela para outra, guardando todas as infor-
    macoes da janela em uso, e passando a operar na janela "Destino",
    caso a mesma exista. }

  Procedure Reposiciona_Janela (X,Y : Byte) ;
  { Reposiciona a janela atual, colocando o canto superior esquerdo em X,Y }

  Procedure Apaga_Atual ;
  { Apaga a janela ativa, recolocando na tela a parte sobreposta e
    passando a trabalhar na ultima janela anteriormente usada. }

  Procedure Salva_Janelas ;
  { Salva em outra posicao de memoria as janelas existentes, apagando-as
    do video e liberando este para outras tarefas, como por exemplo graficos }

  Procedure Restaura_Janelas ;
  { Repoe no video as janelas anteriormente salvas pelo "Salva_Janelas" }

{ ****** procedimentos diversos ****** }

  Procedure Modifica_Atributo (X1,Y1,Col,Lin,Atributo : Byte) ;
  { modifica o atributo de video de um retangulo de dimensoes "Lin" linhas
    por "Col" colunas, cujo canto superior esquerdo se situa em (X1,Y1). }

  Procedure Moldura (X1,Y1,Col,Lin : Byte ;  Titulo  : String) ;
  { Desenha na tela uma moldura com os caracteres ASCII definidos acima
    de dimensoes "Lin" linhas por "Col" colunas, e com o canto superior
    esquerdo em (X1,Y1). Poe o titulo da moldura centrado sobre a linha
    superior da mesma. }

  Procedure Seta_Cores (Atributo : Byte) ;
  { Seta as cores de frente e de fundo conforme definidas pelo atributo. }

  Procedure Formato_Cursor (Formato : Byte) ;
  { Seta o formato do cursor conforme tres padroes, definidos abaixo:
    0: invisivel      1: normal (baixo)      2: cheio (quadrado). }

  Procedure Msg (Mensagem : String) ;
  { Escreve uma mensagem na tela, usando os  seguintes  caracteres
    de controle dentro da string "MENSAGEM" :
     '[' : inicia  a escrita destacada.
     ']' : termina a escrita destacada
     '\' : desce uma linha e vai para o inicio.
     '|' : memoriza a coluna da tela onde esta' o cursor.
     '#' : desce uma linha e vai para a coluna memorizada. }

(*********************************************************************)

Implementation

{ Obs.: Abaixo esta' relacionada a dependencia das procedures e funcoes
        deste modulo em relacao ao hardware usado:

  Dependentes da organizacao da memoria de video:
    Modifica_Atributo, Moldura, Guarda, Recoloca, Seta_Cores

  Dependentes diretas do hardware:
    Formato_Cursor, codigo de iniciacao da UNIT

  Independentes do hardware ou organizacao de video:

    Atributo_Moldura, Troca_Buffer_com_Conteudo, Janela_Atual,
    Janela_Atual, Janela_Em_Uso, Primeira_Janela_Livre, Area_Comum,
    Cria_Janela, Reposiciona_Janela, Vai_Para_Janela, Apaga_Atual,
    Salva_Janelas, Restaura_Janelas, Msg
}
Uses Crt,Dos ;
Const
  { numero maximo de janelas simultaneas na tela }
  Maximo_Janelas = 25  ;

Type
  { registro com as informacoes de uma janela }
  Tipo_Janela = Record
    X_Jan,Y_Jan,                 { coordenadas do canto superior esquerdo }
    Col_Jan,Lin_Jan,             { numero de linhas e colunas da janela }
    Atribut_Jan,                 { atributo (cores) do texto da janela }
    Pos_X,Pos_Y      : Byte ;    { ultima posicao salva do cursor }
    Buffer_Jan       : Pointer ; { aponta p/ buffer da area sobreposta }
  end ;

  { matriz de armazenamento do video no padrao IBM-PC: 1a diamensao
    indica a linha, 2a indica a coluna e 3a indica o atributo usado
    para aquela linha e coluna }
  Tipo_Video = Array [1..Max_Tela_Y,1..Max_Tela_X,0..1] of Char ;

Var
  { armazenamento das janelas abertas pelo usuario }
  Vetor_Janelas     : Array [1..Maximo_Janelas] of Tipo_Janela ;

  { apontador do video fisico, iniciado pelo codigo de iniciacao da UNIT }
  Video_Fisico      : ^Tipo_Video ;

  { posicao do cursor na tela antes da abertura da 1a janela }
  Cursor_Inicial_X,
  Cursor_Inicial_Y  : Byte ;

  { valores usados na interrupcao de formato de cursor }
  Cursor_Vazio,
  Cursor_Baixo,
  Cursor_Cheio      : Integer ;

  { registro usado na iniciacao da UNIT }
  Rec               : Registers ;

  { pilha de sobreposicao (ordem de ativacao) das janelas no video }
  Pilha_Janelas     : String [Maximo_Janelas] ;

(************************************)

Procedure Modifica_Atributo (X1,Y1,Col,Lin,Atributo : Byte) ;
{ modifica o atributo de cor de um retangulo da tela, para o valor desejado }
Var
  X2,Y2,i,j : Byte ;
begin
  X2 := Pred (X1 + Col) ;
  Y2 := Pred (Y1 + Lin) ;
  for i := X1 to X2 do
    for j := Y1 to Y2 do
      Video_Fisico^[j,i,1] := Chr (Atributo) ;
end ;

(************************************)

Procedure Moldura (X1,Y1,Col,Lin : Byte ;    Titulo : String) ;
{ desenha na tela uma moldura e coloca o titulo em seu topo }
Var
  X2,Y2,Posicao,i : Byte ;
begin  { Procedure MOLDURA }
  X2 := Pred (X1 + Col) ;
  Y2 := Pred (Y1 + Lin) ;
  for i := Succ(X1) to Pred(X2) do begin
    Video_Fisico^[Y1,i,0] := Barra_Horizontal_Superior ;
    Video_Fisico^[Y2,i,0] := Barra_Horizontal_Inferior ;
  end ;
  for i := Succ(Y1) to Pred(Y2) do begin
    Video_Fisico^[i,X1,0] := Barra_Vertical_Esquerda ;
    Video_Fisico^[i,X2,0] := Barra_Vertical_Direita ;
  end ;

  Video_Fisico^[Y1,X1,0] := Canto_Superior_Esquerdo ;
  Video_Fisico^[Y1,X2,0] := Canto_Superior_Direito ;
  Video_Fisico^[Y2,X1,0] := Canto_Inferior_Esquerdo ;
  Video_Fisico^[Y2,X2,0] := Canto_Inferior_Direito ;

  Posicao := Round((X1 + X2) / 2 - Length(Titulo) / 2) ;
  for i := 1 to Length (Titulo) do
    Video_Fisico^[Y1,Posicao + Pred(i),0] := Titulo [i] ;
end ;  { Procedure MOLDURA }

(************************************)

Procedure Atributo_Moldura (X1,Y1,Col,Lin,Atributo : Byte) ;
{ Seta o atributo de uma moldura retangular na tela, conforme o valor dado }
Var  X2,Y2 : Byte ;
begin
  X2 := X1 + Pred (Col) ;
  Y2 := Y1 + Pred (Lin) ;
  Modifica_Atributo (X1,Y1,Col,1,Atributo) ; { lado superior }
  Modifica_Atributo (X2,Y1,1,Lin,Atributo) ; { lado direito  }
  Modifica_Atributo (X1,Y2,Col,1,Atributo) ; { lado inferior }
  Modifica_Atributo (X1,Y1,1,Lin,Atributo) ; { lado esquerdo }
end ;

(************************************)

Procedure Guarda (Var Buffer ;    X1,Y1,Col,Lin : Byte) ;
{ Copia  um retangulo da tela de texto de dimensoes "Col" colunas
  por  "Lin"  linhas  e  com o canto superior esquerdo em (X1,Y1)
  dentro de uma variavel  ou  trecho  de  memoria enderecado pelo
  identificador "Buffer". }
Var
  Seg_Buffer,
  Ofs_Buffer  : Word ;
  i,Passo     : Integer ;
  Contador    : Pointer ;

begin
  Seg_Buffer := Seg (Buffer) ;
  Ofs_Buffer := Ofs (Buffer) ;
  Passo := Col + Col ;
  Mem [Seg_Buffer : Ofs_Buffer       ] := Passo ;
  Mem [Seg_Buffer : Succ (Ofs_Buffer)] := Lin ;
  Contador := Ptr (Seg_Buffer,Ofs_Buffer + 2) ;
  for i := Y1 to Pred (Y1 + Lin) do begin
    Move(Video_Fisico^[i,X1,0],Contador^,Passo) ;
    Contador := Ptr (Seg_Buffer,Ofs (Contador^) + Passo) ;
  end ;
end ;

(************************************)

Procedure Recoloca (Var Buffer ;   X1,Y1 : Byte) ;
{ Recoloca  o  retangulo de tela guardado no endereco de "Buffer"
  pelo  procedimento  anterior  (GUARDA)  na  tela,  com  o canto
  superior esquerdo em (X1,Y1). }
Var
  Seg_Buffer,
  Ofs_Buffer  : Word ;
  i,Passo,Lin : Integer ;
  Contador    : Pointer ;

begin
  Seg_Buffer := Seg (Buffer) ;
  Ofs_Buffer := Ofs (Buffer) ;
  Passo := Mem [Seg_Buffer : Ofs_Buffer       ] ;
  Lin   := Mem [Seg_Buffer : Succ (Ofs_Buffer)] ;
  Contador := Ptr (Seg_Buffer,Ofs_Buffer + 2) ;
  for i := Y1 to Pred (Y1 + Lin) do begin
    Move (Contador^,Video_Fisico^[i,X1,0],Passo) ;
    Contador := Ptr (Seg_Buffer,Ofs(Contador^) + Passo) ;
  end ;
end ;

(************************************)

Procedure Troca_Buffer_com_Conteudo (Janela : Byte) ;
{ Recoloca o conteudo do buffer da janela indicada no video e
  guarda  o conteudo da janela dentro de seu buffer (ou seja,
  faz um "swap" entre a tela e o buffer da parte sobreposta. }
Var
  Buffer_Aux : Pointer ;
  Tamanho    : Integer ;

begin
  with Vetor_Janelas [Janela] do begin
    Tamanho := (Col_Jan * Lin_Jan * 2) + 3 ;
    GetMem (Buffer_Aux,Tamanho) ;
    Guarda (Buffer_Aux^,X_Jan,Y_Jan,Col_Jan,Lin_Jan) ;
    Recoloca (Buffer_Jan^,X_Jan,Y_Jan) ;
    FreeMem  (Buffer_Jan,Tamanho) ;
    Buffer_Jan := Buffer_Aux ;
  end ;
end ;

(************************************)

Procedure Seta_Cores (Atributo : Byte) ;
{ seta cor de frente e de fundo de acordo c/ valor dado }
begin
  TextColor (Atributo AND $0F) ;
  TextBackGround ((Atributo ShR 4) AND $0F) ;
end ;

(************************************)

Function Janela_Atual : Byte ;
{ indica qual janela esta' no topo da pilha de janela ativadas }
begin
  if Pilha_Janelas = '' then
    Janela_Atual := 0
  else
    Janela_Atual := Ord (Pilha_Janelas [Length (Pilha_Janelas)]) ;
end ;

(************************************)

Function Janela_em_Uso (Numero : Byte) : Boolean ;
{ indica seu uma determinada janela esta' na pilha de janelas ativadas }
begin
  Janela_em_Uso := (Pos (Chr (Numero),Pilha_Janelas) <> 0) ;
end ;

(************************************)

Function Area_Comum (Jan1,Jan2 : Byte) : Boolean ;
{ indica se duas janelas possuem alguma area em comum, mesmo de moldura }
Var x1,y1,x2,y2,
    u1,v1,u2,v2 : Byte ;
begin { VERIFICA SE DUAS JANELAS TEM UMA AREA EM COMUM }
  { determina coordenadas da primeira janela }
  with Vetor_Janelas [Jan1] do begin
    x1 := X_Jan ;
    y1 := Y_Jan ;
    x2 := Col_Jan + Pred (x1) ;
    y2 := Lin_Jan + Pred (y1) ;
  end ;

  { determina coordenadas da segunda janela }
  with Vetor_Janelas [Jan2] do begin
    u1 := X_Jan ;
    v1 := Y_Jan ;
    u2 := Col_Jan + Pred (u1) ;
    v2 := Lin_Jan + Pred (v1) ;
  end ;

  { verifica se ambas tem alguma area em comum na tela }
  Area_Comum := ([x1..x2] * [u1..u2] <> []) AND ([y1..y2] * [v1..v2] <> []) ;
end ;

(************************************)

Function Primeira_Janela_Livre : Byte ;
{ indica o numero da primeira janela que nao estiver na pilha de ativadas }
Var
  i : Byte ;
begin
  i := 1 ;
  while ( i <= Maximo_Janelas) AND Janela_em_Uso (i) do
    i := Succ (i) ;
  if i > Maximo_Janelas then
    Primeira_Janela_Livre := 0
  else
    Primeira_Janela_Livre := i ;
end ;

(************************************)

Procedure Cria_Janela (Titulo : String ;   X,Y,Col,Lin,Atributo : Byte) ;
{ Abre no video uma janela de acordo c/ os parametros dados }
Var
  Numero : Byte ;

begin
  Numero := Primeira_Janela_Livre ;
  if (Numero <> 0) then begin
    if (Janela_Atual = 0) then begin
      { salva posicao inicial do cursor }
      Cursor_Inicial_X := WhereX ;
      Cursor_Inicial_Y := WhereY ;
    end else
      With Vetor_Janelas [Janela_Atual] do begin
        { salva posicao do cursor na janela anterior }
        Pos_X := WhereX ;
        Pos_Y := WhereY ;
        { escurece moldura da janela anterior }
        Atributo_Moldura (X_Jan,Y_Jan,Col_Jan,Lin_Jan,Atrib_Fraco) ;
      end ;
    with Vetor_Janelas [Numero] do begin
      { guarda area a ser sobreposta pela nova janela }
      GetMem (Buffer_Jan,(Col * Lin * 2) + 3) ;
      Guarda (Buffer_Jan^,X,Y,Col,Lin) ;
      { guarda parametros da nova janela }
      X_Jan := X ;
      Y_Jan := Y ;
      Col_Jan := Col ;
      Lin_Jan := Lin ;
      Atribut_Jan := Atributo ;
    end ;
    { empilha nova janela criada no topo da pilha de ativadas }
    Pilha_Janelas := Pilha_Janelas + Chr (Numero) ;
    {desenha moldura da nova janela }
    Moldura (X,Y,Col,Lin,Titulo) ;
    { poe cor clara na nova moldura }
    Atributo_Moldura (X,Y,Col,Lin,Atrib_Forte) ;
    { seta cores de texto da nova janela }
    Seta_Cores (Atributo) ;
    { limita a area de atuacao no video para a nova janela }
    Window (Succ (X),Succ (Y),(X + Col - 2),(Y + Lin - 2)) ;
    { limpa o interior da nova janela }
    ClrScr ;
    GotoXY(1,1) ;
  end ;
end ;

(************************************)

Procedure Vai_Para_Janela (Destino : Byte) ;
Var
  Posicao,
  Tamanho_Pilha,
  Posicao_Destino : Byte ;
  Escondeu_Janela : Boolean ;

begin
  if Janela_em_Uso (Destino) then
    if (Destino <> 0) then begin
      if (Janela_Atual <> Destino) then begin

        With Vetor_Janelas [Janela_Atual] do begin
          { guarda posicao de cursor da janela atual }
          Pos_X := WhereX ;
          Pos_Y := WhereY ;
          { escurece moldura da janela atual }
          Atributo_Moldura (X_Jan,Y_Jan,Col_Jan,Lin_Jan,Atrib_Fraco) ;
        end ;

        { determina variaveis de conrole da pilha }
        Tamanho_Pilha := Length (Pilha_Janelas) ;
        Posicao_Destino := Pos (Chr (Destino),Pilha_Janelas) ;

        { guarda conteudo das janelas com area comum `a janela destino }
        Escondeu_Janela := FALSE ;
        for Posicao := Tamanho_Pilha DownTo Succ (Posicao_Destino) do
          if Area_Comum (Ord (Pilha_Janelas [Posicao]),Destino) then begin
            Troca_Buffer_com_Conteudo (Ord (Pilha_Janelas [Posicao])) ;
            Escondeu_Janela := TRUE ;
          end ;

        { se escondeu alguma janela entao esconde a janela destino tambem }
        if Escondeu_Janela then
          Troca_Buffer_com_Conteudo (Destino) ;

        { reposiciona janela destino na pilha de janelas }
        Delete (Pilha_Janelas,Posicao_Destino,1) ;
        Pilha_Janelas := Pilha_Janelas + Chr (Destino) ;

        { recoloca conteudo das janelas anteriormente guardadas }
        if Escondeu_Janela then
          for Posicao := Posicao_Destino to Tamanho_Pilha do
            if Area_Comum (Ord (Pilha_Janelas [Posicao]),Destino) then
              Troca_Buffer_com_Conteudo (Ord (Pilha_Janelas [Posicao])) ;
      end ;

      { restaura valores da janela destino }
      With Vetor_Janelas [Destino] do begin
        Atributo_Moldura (X_Jan,Y_Jan,Col_Jan,Lin_Jan,Atrib_Forte) ;
        Window (Succ (X_Jan),Succ (Y_Jan),(X_Jan + Col_jan - 2),(
                Y_Jan + Lin_Jan) - 2) ;
        GotoXY (Pos_X,Pos_Y) ;
        Seta_Cores (Atribut_Jan) ;
      end ;

    end ;
end ;

(************************************)

Procedure Reposiciona_Janela (X,Y : Byte) ;
begin
  with Vetor_Janelas [Janela_Atual] do begin
    { salva posicao atual do cursor }
    Pos_X := WhereX ;
    Pos_Y := WhereY ;
    { esconde a janela em seu buffer }
    Troca_Buffer_com_Conteudo (Janela_Atual) ;
    { indica novas coordenadas da janela }
    X_Jan := X ;
    Y_Jan := Y ;
    { repoe conteudo da janela na tela }
    Troca_Buffer_com_Conteudo (Janela_Atual) ;
    { limita a area no video da janela }
    Window (Succ (X_Jan),Succ (Y_Jan),(X_Jan + Col_jan - 2),
            (Y_Jan + Lin_Jan) - 2) ;
    { reposiciona o cursor }
    GotoXY (Pos_X,Pos_Y) ;
  end ;
end ;

(************************************)

Procedure Apaga_Atual ;
begin
  if (Janela_Atual <> 0) then begin
    { repoe a area sobreposta e libera o buffer do sobreposto }
    With Vetor_Janelas [Janela_Atual] do begin
      Recoloca (Buffer_Jan^,X_Jan,Y_Jan) ;
      FreeMem  (Buffer_Jan,(Col_Jan * Lin_Jan * 2) + 3) ;
    end ;
    { retira a janela do topo da pilha }
    Pilha_Janelas [0] := Pred (Pilha_Janelas [0]) ;
    if Janela_Atual <> 0 then
      Vai_Para_Janela (Janela_Atual)
    else begin
      { restaura o ambiente inical de video }
      Window (1,1,Max_Tela_X,Max_Tela_Y) ;
      Seta_Cores (Atrib_Forte) ;
      GotoXY (Cursor_Inicial_X,Cursor_Inicial_Y) ;
    end ;
  end ;
end ;

(************************************)

Procedure Salva_Janelas ;
Var
  Jan : Byte ;
begin
  { salva posicao de cursor atual }
  Vetor_Janelas [Janela_Atual].Pos_X := WhereX ;
  Vetor_Janelas [Janela_Atual].Pos_Y := WhereY ;

  { esconde cada janela dentro de seu proprio buffer de sobreposto }
  for Jan := Length (Pilha_Janelas) DownTo 1 do
    Troca_Buffer_com_Conteudo (Ord (Pilha_Janelas [Jan])) ;

  { restaura o ambiente existente antes das janelas }
  Window (1,1,Max_Tela_X,Max_Tela_Y) ;
  GotoXY (Cursor_Inicial_X,Cursor_Inicial_Y) ;
end ;

(************************************)

Procedure Restaura_Janelas ;
Var
  Jan : Byte ;
begin
  { salva posicoes de cursor }
  Cursor_Inicial_X := WhereX ;
  Cursor_Inicial_Y := WhereY ;

  { restaura cada janela escondida em seu buffer de sobreposto }
  for Jan := 1 to Length (Pilha_Janelas) do
    Troca_Buffer_com_Conteudo (Ord (Pilha_Janelas [Jan])) ;

  { restaura ambiente da janela do topo da pilha }
  with Vetor_Janelas [Janela_Atual] do begin
    Window (Succ (X_Jan),Succ (Y_Jan),(X_Jan + Col_jan - 2),
            (Y_Jan + Lin_Jan) - 2) ;
    GotoXY (Pos_X,Pos_Y) ;
  end ;
end ;

(************************************)

Procedure Msg (Mensagem : String) ;
Var
  Coluna_Inicial : Byte ;

begin
  Coluna_Inicial := WhereX ;
  Seta_Cores (Atrib_Fraco) ;
  While Mensagem <> '' do begin
    Case Mensagem [1] of
     '[' : Seta_Cores (Atrib_Forte) ;
     ']' : Seta_Cores (Atrib_Fraco) ;
     '\' : WriteLn ;
     '|' : Coluna_Inicial := WhereX ;
     '#' : GotoXY (Coluna_Inicial,Succ (WhereY)) ;
    else
      Write (Mensagem [1])
    end ;
    Delete (Mensagem,1,1) ;
  end ;
  if Janela_Atual <> 0 then
    Seta_Cores (Vetor_Janelas [Janela_Atual].Atribut_Jan)
  else
    Seta_Cores (Atrib_Fraco) ;
end ;

(************************************)

Procedure Formato_Cursor (Formato : Byte) ;
Var
   Rec : Registers ;

begin { ALTERA O FORMATO DO CURSOR }
    Rec.AX := $0100 ;
    With Rec do
    Case Formato of
       0 : CX := Cursor_Vazio ;
       1 : CX := Cursor_Baixo ;
       2 : CX := Cursor_Cheio ;
    end ;
    Intr ($10,Rec) ;
end ; { ALTERA O FORMATO DO CURSOR }

(*********************************************************************)

{ Codigo de iniciacao da UNIT Janelas: posiciona o apontador que  indica
  a posicao da memoria de video, que pode ser $B800:$0000 para as placas
  normais  ou $B000:$0000  para a placa Hercules e outras monocromaticas
  de alta resolucao. Seta variaveis conforme a placa existente. }

begin
  Rec.AX := $0F00 ;
  Intr ($10,Rec) ;
  if (Rec.AX AND $00FF) = 7 then begin
    Video_Fisico   := Ptr ($B000,$0000) ;
    Atrib_Inverso  := $70 ;
    Atrib_Destaque := $70 ;
    Cursor_Baixo   := $0C0D ;
    Cursor_Cheio   := $000D ;
  end else begin
    Video_Fisico   := Ptr ($B800,$0000) ;
    Atrib_Inverso  := $71 ;
    Atrib_Destaque := $3F ;
    Cursor_Baixo   := $0607 ;
    Cursor_Cheio   := $0007 ;
  end ;
  Cursor_Vazio := $0800 ;
  Atrib_Fraco := $13 ;
  Atrib_Forte := $1F ;
  Pilha_Janelas := '' ;
end .

(*********************************************************************)
