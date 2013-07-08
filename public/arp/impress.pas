(***************************************************************************)

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

Unit Impress ;

Interface
  Uses Variavel,Texto ;

  Procedure Impressao_Saidas (Var Rede                : Tipo_Rede ;
                              Var Texto_Rede,
                                  Texto_Grafo,
                                  Texto_Estados,
                                  Texto_Props,
                                  Texto_Inv_Trans,
                                  Texto_Inv_Lugar,
                                  Texto_Verif,
                                  Texto_Desemp,
                                  Texto_Simu          : Ap_Texto ;
                              Var Nome_Arq,Nome_Saida : String) ;

(***************************************************************************)

Implementation
  Uses Crt,Janelas,Interfac,Ajuda,Arquivo ;

Procedure Impressao_Saidas (Var Rede                : Tipo_Rede ;
                            Var Texto_Rede,
                                Texto_Grafo,
                                Texto_Estados,
                                Texto_Props,
                                Texto_Inv_Trans,
                                Texto_Inv_Lugar,
                                Texto_Verif,
                                Texto_Desemp,
                                Texto_Simu          : Ap_Texto ;
                            Var Nome_Arq,Nome_Saida : String) ;

Const
   Mens_Impr = 'Printing text ...' ;
   Mens_Erro = 'No data for desired printing.' ;

Var
   Escolha : Char ;

(******************************)

   Procedure Avisa_Erro ;
   Var
      Ch : Char ;

   begin { AVISA ERRO }
      Ch := Resp (Mens_Erro) ;
   end ; { AVISA ERRO }

(******************************)

   Procedure Muda_Arquivo_Saida ;
   var
      Existe : Boolean ;

   begin { MUDA ARQUIVO DE SAIDA }
      Formato_Cursor (2) ;
      repeat
         GotoXY (19,1) ;
         repeat until KeyPressed ;
         ClrEoL ;
         TamBuffer := 60 ;
         ReadF (Nome_Saida,TipoStr) ;
      until Nome_Valido (Nome_Saida,Existe) ;
      Formato_Cursor (0) ;
      Nome_Saida := UpString (Nome_Saida) ;
      Completa_Nome (Nome_Saida,'LST') ;
      GotoXY (19,1) ;
      ClrEOL ;
      Write (Nome_Saida) ;
   end ; { MUDA ARQUIVO DE SAIDA }

(******************************)

   Procedure Imprime_Texto (Var Texto   : Ap_Texto ;
                                Arquivo : String) ;
   begin { IMPRIME TEXTO }
      if Texto = NIL then Avisa_Erro
                     else Grava_Texto (Texto,Arquivo,TRUE) ;
   end ; { IMPRIME TEXTO }

(******************************)

   Procedure Imprime_Enumeracao ;
   Var
     Escolha : Char ;

   begin { IMPRIME ENUMERACAO DE MARCACOES }
     Cria_Janela (' Reachable States Enumeration Printing',
                  1,16,80,4,Atrib_Fraco) ;
     Msg ('\ Reachability [G]raph      Reachable [S]tates' +
          '      Observed [P]roperties') ;
     repeat
       Escolha := Tecla (Funcao) ;
       Case Escolha of
        'G': Imprime_Texto (Texto_Grafo,Nome_Saida) ;
        'S': Imprime_Texto (Texto_Estados,Nome_Saida) ;
        'P': Imprime_Texto (Texto_Props,Nome_Saida) ;
       else
         Escolha := '*'
       end ;
     until Escolha = '*' ;
     Apaga_Atual ;
   end ; { IMPRIME ENUMERACAO DE MARCACOES }

(******************************)

   Procedure Imprime_Invariantes ;
   Var Escolha : Char ;
   begin { IMPRIME INVARIANTES DE LUGAR E TRANSICAO }
      Cria_Janela (' Linear Invariants Printing ',1,16,80,4,Atrib_Fraco) ;
      Msg ('\ [T]ransition Linear Invariants         ') ;
      Msg (' P[L]ace Linear Invariants') ;
      repeat
         Escolha := Tecla (Funcao) ;
         Case Escolha of
           'L' : Imprime_Texto (Texto_Inv_Lugar,Nome_Saida) ;
           'T' : Imprime_Texto (Texto_Inv_Trans,Nome_Saida) ;
         else
            Escolha := '*'
         end ;
      until Escolha = '*' ;
      Apaga_Atual ;
   end ; { IMPRIME INVARIANTES DE LUGAR E TRANSICAO }

(******************************)

begin { IMPRIME RESULTADOS }
   Cria_Janela (' Analysis Results Printing ',1,20,80,6,Atrib_Forte) ;
   Msg (' [T]arged Archive : \\ [C]urrent Net                      State ') ;
   Msg ('[E]numeration            [I]nvariants\ [H]elp           [S]imulation') ;
   Msg ('        [P]erformance Evaluation       [V]erification') ;

   GotoXY (19,1) ;
   Write (Nome_Saida) ;
   repeat
      Escolha := Tecla (Funcao) ;
      case escolha of
         'E' : Imprime_Enumeracao ;
         'I' : Imprime_Invariantes ;
         'P' : Imprime_Texto (Texto_Desemp,Nome_Saida) ;
         'V' : Imprime_Texto (Texto_Verif,Nome_Saida) ;
         'C' : Imprime_Texto (Texto_Rede,Nome_Saida) ;
         'S' : Imprime_Texto (Texto_Simu,Nome_Saida) ;
         'T' : Muda_Arquivo_Saida ;
         'H' : Tela_Ajuda (Impressao) ;
      else
         Escolha := '*' ;
      end ;
   until Escolha = '*' ;
   Apaga_Atual ;
end ; { IMPRIME RESULTADOS }

end.

(***************************************************************************)
