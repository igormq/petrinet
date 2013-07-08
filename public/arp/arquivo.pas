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

{$O+,F+}    { permissao para realizar overlay }
{$V-}       { nao checar tipos de strings     }

Unit Arquivo ;

{ esta unit deve se preocupar com as funcoes
  de gerenciamento de arquivos,  unicamente. }

Interface
  Uses Texto ;

  Function Nome_valido (Nome : String ;  Var Existe : Boolean) : Boolean ;

  Procedure Completa_Nome (Var Nome_Arquivo : String ;  Extensao : String) ;

  Procedure Leitura_Texto (Var Texto : Ap_Texto ;   Nome  : String) ;

  Procedure Grava_Texto (Var Texto       : Ap_Texto ;
                             NomeArquivo : String ;
                             Concatenar  : Boolean) ;

  Procedure Lista_Diretorio (VAR Nome_Escolhido : String ;
                                 Pegar_Nome     : Boolean) ;

(***********************************************************************)

Implementation
  Uses Crt,Dos,Janelas,Interfac ;

  Function Nome_valido (Nome : String ;  Var Existe : Boolean) : Boolean ;
  Var
    Arq  : file ;
    i    : Byte ;

  begin  { NOME VALIDO PARA ARQUIVO }
    Nome_Valido := TRUE ;
    Existe := FALSE ;
    Assign (Arq,Nome) ;
    {$I-}
    Reset (Arq) ;
    {$I+}
    if (IOResult = 0) then begin
      Existe := TRUE ;
      Close (Arq) ;
    end else begin
      {$I-}
      Rewrite (Arq) ;
      {$I+}
      if (IOResult = 0) then begin
        Close (Arq) ;
        Erase (Arq) ;
      end else
        Nome_valido := FALSE ;
    end ;
    For i := 1 to Length (Nome) do
      Nome [i] := UpCase (Nome [i]) ;
  end ; { NOME VALIDO PARA ARQUIVO }

(***********************************************************************)

  Procedure Completa_Nome (Var Nome_Arquivo : String ;  Extensao : String) ;
  begin { COMPLETA NOME }
    if Pos ('.',Nome_Arquivo) = 0 then
      Nome_Arquivo := Nome_Arquivo + '.' + Extensao ;
    Nome_Arquivo := FExpand (Nome_Arquivo) ;
  end ; { COMPLETA NOME }

(***********************************************************************)

  Procedure Leitura_Texto (Var Texto : Ap_Texto ;   Nome  : String) ;
  Var
    i     : Integer ;
    Arq   : Text ;
    St    : Linha_Texto ;
    Lin   : String ;
    Atual : Ap_Texto ;

  begin { LE UM ARQUIVO ASCII DO DISCO }
    Aviso ('Loading file...') ;
    Assign (Arq,Nome) ;
    Reset (Arq) ;
    Atual := NIL ;
    Texto := NIL ;
    While NOT EOF (Arq) do begin
      ReadLn (Arq,Lin) ;
      { retira caracteres de controle indesejaveis }
      for i := 1 to Length (Lin) do
        if Lin [i] in [#0..#31] then
          Lin [i] := ' ' ;
      repeat
        if (Atual = NIL) then begin
          New (Atual) ;
          Texto := Atual ;
          Atual^.Ant := NIL ;
        end else begin
          New (Atual^.Prox) ;
          Atual^.Prox^.Ant := Atual ;
          Atual := Atual^.Prox ;
        end ;
        Atual^.Prox := NIL ;
        Atual^.Cont := Copy (Lin,1,Tam_Linha_Texto) ;
        Delete (Lin,1,Tam_Linha_Texto) ;
      until (Lin = '') ;
    end ;
    Close (Arq) ;
    Apaga_Atual ;
  end ; { LE UM ARQUIVO ASCII DO DISCO }

(***********************************************************************)

  Procedure Grava_Texto (Var Texto       : Ap_Texto ;
                             NomeArquivo : String ;
                             Concatenar  : Boolean) ;
  Var
    Atual     : Ap_Texto ;
    Arq       : Text ;
    i         : Integer ;
    Diretorio,
    NomeBack,
    Extensao  : String ;

  begin { GRAVA TEXTO NO ARQUIVO DESEJADO, GERANDO BACKUP }
    Aviso ('Saving file...') ;

    if Concatenar then begin
      Assign (Arq,NomeArquivo) ;
      {$I-}
      Reset (Arq) ;
      {$I+}
      if (IOResult = 0) then Append (Arq)
                        else Rewrite (Arq) ;
    end else begin
      { determinacao do nome do arquivo backup }
      FSplit (NomeArquivo,Diretorio,NomeBack,Extensao) ;
      NomeBack := Diretorio + NomeBack + '.BAK' ;

      { transformacao do arquivo anterior em backup }
      {$I-}
      Assign (Arq,NomeBack) ;
      Erase (Arq) ;
      i := IOResult ;
      Assign (Arq,NomeArquivo) ;
      Rename (Arq,NomeBack) ;
      i := IOResult ;
      {$I+}

      { abertura do novo arquivo }
      Assign (Arq,NomeArquivo) ;
      Rewrite (Arq) ;
    end ;

    { escrita do texto }
    Atual := Texto ;
    While (Atual <> NIL) do begin
      WriteLn (Arq,Atual^.Cont) ;
      Atual := Atual^.Prox ;
    end ;

    Close (Arq) ;
    Apaga_Atual ;
  end ; { GRAVA TEXTO NO ARQUIVO DESEJADO, GERANDO BACKUP }

(***********************************************************************)

  Procedure Lista_Diretorio (VAR Nome_Escolhido : String ;
                                 Pegar_Nome     : Boolean) ;
  Const
    Max_Arquivos = 120 ;

  Type
    Tipo_Nome  = Record
      Nome : String [12] ;
      Tipo : Byte ;
    end ;

    Vetor_Nome = Array [1..Max_Arquivos] of Tipo_Nome ;

  Var
    i,PosX,PosY,Posicao,Num_Arq : Integer ;
    Funcao,Mudou_Dir,Terminou   : Boolean ;
    Pilha_Dir,Dir_Atual         : String ;
    Escolha                     : Char ;
    Entrada                     : Vetor_Nome ;

(****************************************************)

    Procedure Busca_Entradas_Dir_Atual (VAR Entrada : Vetor_Nome ;
                                        VAR Num_Arq : Integer) ;
    Const
      Mask : String = '*.*' ;

    Var
      Terminou  : Boolean ;
      Arquivo   : SearchRec ;   { turbo 5.0 }
      Nome      : String ;
      Letra     : Char ;
      i,j       : Integer ;
      Auxiliar  : Tipo_Nome ;

    begin { BUSCA ENTRADAS DO DIRETORIO }
      Num_Arq := 0 ;
      FindFirst (Mask,ReadOnly + Archive + Directory,Arquivo) ;
      while (DosError = 0) AND (Num_Arq <= Max_Arquivos - 1) do begin
        if Arquivo.Name <> '.' then begin
          Num_Arq := Succ (Num_Arq) ;
          Entrada [Num_Arq].Nome := Arquivo.Name ;
          Entrada [Num_Arq].Tipo := Arquivo.Attr ;
          if (Arquivo.Attr <> Directory) then
            Entrada [Num_Arq].Tipo := Archive ;
        end ;
        FindNext (Arquivo) ;
      end ;

      for j := Pred (Num_Arq) DownTo 1 do
        for i := 1 to j do
          if (Entrada [i].Nome > Entrada [Succ (i)].Nome) then begin
            Auxiliar := Entrada [i] ;
            Entrada [i] := Entrada [Succ (i)] ;
            Entrada [Succ (i)] := Auxiliar ;
          end ;

      for j := Pred (Num_Arq) DownTo 1 do
        for i := 1 to j do
          if (Entrada [i].Tipo = Archive) then
            if (Entrada [Succ (i)].Tipo = Directory) then begin
              Auxiliar := Entrada [i] ;
              Entrada [i] := Entrada [Succ (i)] ;
              Entrada [Succ (i)] := Auxiliar ;
            end ;

    end ; { BUSCA ENTRADAS DO DIRETORIO }

(****************************************************)

  begin { LISTA DIRETORIO }
    Cria_Janela ('',1,1,79,25,Atrib_Forte) ;
    GotoXY (1,23) ;
    Msg ('    Change Drive: [A ... Z]               Select: ') ;
    Msg ('[ENTER   ]    Exit:  [SPACE]') ;
    Window (2,2,78,23) ;
    Terminou := FALSE ;
    Nome_Escolhido := '' ;
    Pilha_Dir := '' ;
    Posicao := 1 ;
    repeat
      Mudou_Dir := FALSE ;
      GetDir (0,Dir_Atual) ;
      Busca_Entradas_Dir_Atual (Entrada,Num_Arq) ;
      if (Length (Dir_Atual) > 3) then
        if (Entrada [1].Nome <> '..') OR (Num_Arq = 0) then begin
          Num_Arq := Succ (Num_Arq) ;
          for i := Num_Arq DownTo 2 do
            Entrada [i] := Entrada [Pred (i)] ;
          Entrada [1].Nome := '..' ;
          Entrada [1].Tipo := Directory ;
        end ;
      ClrScr ;
      Moldura (1,1,79,25,' Dir. from ' + Dir_Atual + ' ') ;
      for i := 1 to Num_Arq do
        With Entrada [i] do begin
          TextColor (Atrib_Forte AND $0F) ;
          if Entrada [i].Tipo = Directory then
            TextColor (Atrib_Fraco AND $0F) ;
          GotoXY (Succ (Pred (i) mod 6 * 13),Succ (Pred (i) div 6)) ;
          Write (Nome) ;
        end ;
      TextColor (Atrib_Forte AND $0F) ;
      if WhereX > 1 then
        WriteLn ;
      WriteLn ;
      Write (Num_Arq,' Files , ',DiskFree (0),' free bytes on disk , ',
             MemAvail,' free bytes in memory.') ;
      repeat
        repeat
          PosX := (Pred (Posicao) mod 6) * 13 + 2 ;
          PosY := (Pred (Posicao) div 6) + 2 ;
          Modifica_Atributo (PosX,PosY,12,1,Atrib_Inverso) ;
          Escolha := Tecla (Funcao) ;
          if Entrada [Posicao].Tipo = Directory then
            Modifica_Atributo (PosX,PosY,12,1,Atrib_Fraco)
          else
            Modifica_Atributo (PosX,PosY,12,1,Atrib_Forte) ;
          if Funcao then
            Case Escolha of
            'M' : Posicao := MinI (Succ (Posicao),Num_Arq) ;
            'K' : Posicao := MaxI (Pred (Posicao),1) ;
            'H' : Posicao := MaxI (1,Posicao - 6) ;
            'P' : Posicao := MinI (Num_Arq,Posicao + 6) ;
            'G' : Posicao := 1 ;
            'O' : Posicao := Num_Arq ;
            end ;
        until NOT Funcao OR NOT (Escolha in ['M','K','H','P','G','O']) ;
        if NOT Funcao AND (Escolha in ['A'..'Z']) then begin
          {$I-}
          ChDir (Escolha + ':') ;
          {$I+}
          if IOResult = 0 then begin          
            Mudou_Dir := TRUE ;
            Posicao := 1 ;
          end ;
        end else
          if Escolha = #13 then begin
            if (Entrada [Posicao].Tipo = Archive) then begin
              if Dir_Atual [Length (Dir_Atual)] <> '\' then
                Dir_Atual := Dir_Atual + '\' ;
              Nome_Escolhido := Dir_Atual + Entrada [Posicao].Nome ;
              if Pegar_Nome then
                Terminou := TRUE ;
            end else begin
              ChDir (Entrada [Posicao].Nome) ;
              Mudou_Dir := TRUE ;
              if (Entrada [Posicao].Nome = '..') then
                if (Pilha_Dir <> '') then begin
                  Posicao := Ord (Pilha_Dir [1]) ;
                  Delete (Pilha_Dir,1,1) ;
                end else
                  Posicao := 1
              else begin
                Pilha_Dir := Chr (Posicao) + Pilha_Dir ;
                Posicao := 1 ;
              end ;
            end ;
          end else
            Terminou := TRUE ;
      until Mudou_Dir OR Terminou ;
    until Terminou ;
    Apaga_Atual ;
  end ; { LISTA DIRETORIO }

end.

(***********************************************************************)
