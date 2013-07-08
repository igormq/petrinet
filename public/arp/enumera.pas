(*****************************************************************************)

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

Unit Enumera ;

Interface
  Uses Variavel,Texto,Grafo ;

  Procedure Enumeracao_Estados (Var Rede         : Tipo_Rede ;
                                Var Texto_Grafo,
                                    Texto_Estados,
                                    Texto_Props  : Ap_Texto ;
                                Var SuccEst      : Lista_Grafo ;
                                Var UltimoEst    : Integer) ;

(*****************************************************************************)

Implementation

  Uses Crt,Interfac,Janelas,Ajuda ;

  Procedure Enumeracao_Estados (Var Rede         : Tipo_Rede ;
                                Var Texto_Grafo,
                                    Texto_Estados,
                                    Texto_Props  : Ap_Texto ;
                                Var SuccEst      : Lista_Grafo ;
                                Var UltimoEst    : Integer) ;
Const
  Limite_Result = 150 ; { para a pergunta sobre a escrita dos resultados }

Var
  Erro              : Byte ;
  Escolha,Simbolo   : Char ;
  Cresceu           : Boolean ;
  Marcacao          : Lista_Marcacao ;
  Dominio           : Lista_Dominio ;
  Precedente        : VetorIntLongo ;
  MarcAuxi          : Vetor_Inteiros ;
  MarcInic          : Vetor_Bytes ;
  Vivas,QuaseVivas,
  Nulos,Binarios,
  MultiSensibs,
  Nao_Limitados     : Conj_Bytes ;
  Limitados         : Vetor_Bytes ;
  Auxiliar          : VetorBoolLongo ;
  i,j,NumElem       : Integer ;

(*****************************************************************************)

begin { ANALISE ENUMERACAO }
  Erro := 0 ;
  if (Texto_Props <> NIL) then
    Escolha := Resp ('Want to lose last analysis ? [(Y/N)]')
  else
    Escolha := 'Y' ;

  if (Escolha = 'Y') then begin

    Apaga_Texto (Texto_Grafo) ;
    Apaga_Texto (Texto_Estados) ;
    Apaga_Texto (Texto_Props) ;

    ApagaListaGrafo (SuccEst) ;

    { edicao da marcacao inicial da rede }
    for i := 1 to Rede.Num_Lugar do
      MarcAuxi [i] := Rede.Mo [i] ;
    ValorMinimo := 0 ;
    ValorMaximo := 254 ;
    TamBuffer := 3 ;
    Leitura_Vetor (' M0 ',Rede.Nome_Lugar,MarcAuxi,[1..255],
                   Rede.Num_Lugar,Rede.Tam_Lugar,'',0,'W',255) ;
    for i := 1 to Rede.Num_Lugar do
      MarcInic [i] := MarcAuxi [i] ;

    GeraGrafo (Rede,MarcInic,SuccEst,UltimoEst,
               Marcacao,Dominio,Precedente,Erro) ;

    if Erro in [0,1] then begin
      if Rede.Temporizada then Simbolo := 'C'
                          else Simbolo := 'M' ;

      { escrita das marcacoes }
      if (UltimoEst < Limite_Result) OR (Resp
         ('Want to write the [state] text ? ([Y/N])') = 'Y') then begin
        Aviso ('Writing the state text...') ;
        Usa_Texto (Texto_Estados) ;
        WrtLnS ('State Enumeration  : net ' + Rede.Nome + '.') ;
        if Erro = 1 then
          WrtLnS ('Obs.: results are not complete, because analysis was aborted.') ;
        if Rede.Temporizada then
          WrtLnS ('Omitted intervals mean [0,0].') ;
        Nova_Linha ;
        WrtLnS ('Reachable states for this net :') ;
        Traco ;
        for i := 0 to UltimoEst do begin
          WrtS (Simbolo + StI (i)) ;
          Posic (6) ;  WrtS (':') ;
          EscVetor (Marcacao [i]^,Rede.Nome_Lugar,Rede.Num_Lugar,TipoByte,'W',255,'',0) ;
          if Rede.Temporizada then begin
            Posic (5) ; WrtS ('D:') ;
            EscreveDominio (Rede,Dominio [i]) ;
          end ;
        end ;
        Traco ;
        Apaga_Atual ;
      end ;

      { escrita do texto do grafo }
      if (UltimoEst < Limite_Result) OR (Resp
        ('Want to write the [graph] text ? ([Y/N])') = 'Y') then begin
        Aviso ('Writing the graph text...') ;
        Usa_Texto (Texto_Grafo) ;
        WrtLnS ('States Enumeration : net ' + Rede.Nome + '.') ;
        if Erro = 1 then
          WrtLnS ('Obs.: results are not complete, because analysis was aborted.') ;
        if Rede.Temporizada then
          WrtLnS ('Omitted intervals mean [0,0].') ;
        Nova_Linha ;
        WrtLnS ('Reachability graph for this net:') ;
        Traco ;
        if Rede.Temporizada then
          EscreveGrafo (SuccEst,UltimoEst,Rede,'C')
        else
          EscreveGrafo (SuccEst,UltimoEst,Rede,'M') ;
        Traco ;
        Apaga_Atual ;
      end ;

      { escrita do texto das propriedades da rede }
      Aviso ('Writing the text of properties') ;
      Usa_Texto (Texto_Props) ;
      WrtS ('State Enumeration : net ' + Rede.Nome + ' (') ;
      WrtN (Succ (UltimoEst)) ;
      WrtLnS (' reachable states).') ;
      if Erro = 1 then
        WrtLnS ('Obs.: results are not complete, because analysis was aborted.') ;
      Nova_Linha ;
      WrtLnS ('Verified properties:') ;
      Traco ;

      { testa limitacao dos lugares da rede }
      TestaLimites (Nulos,Binarios,Nao_Limitados,
                    Limitados,Marcacao,UltimoEst,Rede) ;
      if (Nulos + Binarios = [1..Rede.Num_Lugar]) then
        WrtLnS ('Net under analysis is binary.')
      else
        if Nao_Limitados = [] then
          WrtLnS ('Net under analysis is limited.')
        else
          WrtLnS ('Net under analysis is not limited.') ;
      WrtS ('  Null places (M = 0): ') ;
      EscConj (Nulos,Rede.Nome_Lugar,Rede.Num_Lugar) ;
      WrtS ('  Binary places      : ') ;
      EscConj (Binarios,Rede.Nome_Lugar,Rede.Num_Lugar) ;
      WrtS ('  k-Bounded places   : ') ;
      EscVetor (Limitados,Rede.Nome_Lugar,Rede.Num_Lugar,TipoByte,'W',255,'',0) ;
      WrtS ('  Unbounded places   : ') ;
      EscConj (Nao_Limitados,Rede.Nome_Lugar,Rede.Num_Lugar) ;
      Nova_Linha ;

      { mostra caminhos que levam a crescimento de marcacao }
      if (Nao_Limitados <> []) then begin
        WrtLnS ('Fire sequencies that leads to a growing of tokens:') ;
        for i := 0 to UltimoEst do
          if Nao_Limitados <> [] then begin
            Cresceu := FALSE ;
            for j := 1 to Rede.Num_Lugar do
              if (j in Nao_Limitados) AND (Marcacao [i]^[j] = W) then begin
                Nao_Limitados := Nao_Limitados - [j] ;
                Cresceu := TRUE ;
              end ;
            if Cresceu then begin
              WrtS ('  ' + Simbolo + StI (i)) ;
              Posic (8) ; WrtS (':') ;
              EscreveRoteiro (i,SuccEst,UltimoEst,Precedente,Rede) ;
            end ;
          end ;
        Nova_Linha ;
      end ;

      { testa a conservacao das fichas na rede }
      if TestaConservacao (Marcacao,UltimoEst,Rede) then
        WrtLnS ('Net under analysis is strictly conservative.')
      else
        WrtLnS ('Net under analysis is not strictly conservative.') ;
      Nova_Linha ;

      { testa a multisensibilizacao das transicoes }
      if Rede.Temporizada then begin
        TestaMultiSensib (MultiSensibs,Marcacao,Dominio,UltimoEst,Rede) ;
        WrtS ('Multi-enabled Tr.: ') ;
        EscConj (MultiSensibs,Rede.Nome_Trans,Rede.Num_Trans) ;
        Nova_Linha ;
      end ;

      { testa a vivacidade da rede }
      TestaVivacidade (Vivas,QuaseVivas,SuccEst,UltimoEst,Precedente,Rede) ;
      if (Vivas = [1..Rede.Num_Trans]) then
        WrtLnS ('Net under analysis is live.')
      else
        WrtLnS ('Net under analysis is not live.') ;
      WrtS ('  Live Tr.         : ') ;
      EscConj (Vivas,Rede.Nome_Trans,Rede.Num_Trans) ;
      WrtS ('  "Almost-live" Tr.: ') ;
      EscConj (QuaseVivas,Rede.Nome_Trans,Rede.Num_Trans) ;
      WrtS ('  Non-fired Tr.    : ') ;
      EscConj ([1..Rede.Num_Trans] - QuaseVivas,Rede.Nome_Trans,Rede.Num_Trans) ;
      Nova_Linha ;

      { teste de reiniciacao da rede }
      TestaReiniciacao (SuccEst,UltimoEst,Precedente,Auxiliar,NumElem) ;
      if NumElem = Succ (UltimoEst) then
        WrtLnS ('Net can always go back to M0.')
      else
        if NumElem = 0 then
          WrtLnS ('Net never can go back to M0.')
        else begin
          WrtS ('States from which the net cannot go back to M0: ') ;
          Tab_Inic (10) ;
          for i := 0 to UltimoEst do
            if NOT Auxiliar [i] then
              WrtS (Simbolo + StI (i) + ' ') ;
          Nova_Linha ;
        end ;
      Nova_Linha ;

      { teste de live-locks }
      TestaLiveLock (SuccEst,UltimoEst,Auxiliar,NumElem) ;
      if NumElem = 0 then
        WrtLnS ('No live-locks detected. ')
      else begin
        WrtS ('States that start live-locks: ') ;
        Tab_Inic (10) ;
        for i := 0 to UltimoEst do
          if Auxiliar [i] then
            WrtS (Simbolo + StI (i) + ' ') ;
        Nova_Linha ;
      end ;
      Nova_Linha ;

      { teste de dead-locks }
      TestaDeadLock (SuccEst,UltimoEst,Auxiliar,NumElem) ;
      if NumElem = 0 then
        WrtLnS ('No deadlocks detected.')
      else begin
        WrtLnS ('States (and fire sequencies) in deadlock: ') ;
        Tab_Inic (10) ;
        for i := 0 to UltimoEst do
          if Auxiliar [i] then begin
            WrtS ('  ' + Simbolo + StI (i)) ;
            Posic (8) ; WrtS (':') ;
            EscreveRoteiro (i,SuccEst,UltimoEst,Precedente,Rede) ;
          end ;
      end ;

      Traco ;
      Apaga_Atual ;
    end ;

    ApagaListaDominio (Dominio) ;
    ApagaListaMarcacao (Marcacao) ;
    if (Erro <> 0) then
      ApagaListaGrafo (SuccEst) ;

  end ;

  if (Erro in [0,1]) then begin
    Cria_Janela (' Analysis by States Enumeration ',1,12,80,4,Atrib_Fraco) ;
    Msg ('\ Reachability [G]raph        Reachable [S]tates ' +
         '       [P]roperties        [H]elp') ;
    Edita_Texto (' Observed Properties ',Texto_Props,1,1,8,18,FALSE,Funcao) ;
    repeat
      Escolha := Tecla (Funcao) ;
      Case Escolha of
        'G' : Edita_Texto (' Reachability Graph ',Texto_Grafo,
                           1,1,8,18,FALSE,Funcao) ;
        'S' : Edita_Texto (' Reachable States ',Texto_Estados,
                           1,1,8,18,FALSE,Funcao) ;
        'P' : Edita_Texto (' Observed Properties ',Texto_Props,
                           1,1,8,18,FALSE,Funcao) ;
        'H' : Tela_Ajuda (Enumeracao) ;
      else
        Escolha := '*' ;
      end ;
    until (Escolha = '*') ;
    Apaga_Atual ;
  end else begin
    Apaga_Texto (Texto_Grafo) ;
    Apaga_Texto (Texto_Estados) ;
    Apaga_Texto (Texto_Props) ;
  end ;
end ; { ANALISE ENUMERACAO }

end.

(*****************************************************************************)
