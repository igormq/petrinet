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

Unit Variavel ;
Interface
  Uses Texto ;

(** CONSTANTES DO SISTEMA ***************)

Const
   Max_Trans_Lugar  = 150   ; { num. max. de transicoes ou lugares na rede  }
   Car_Max_Ident    = 20    ; { num. max. de caracteres em um identificador }
   Tempo_Max        = 32000 ; {maximo tempo aceito nos intervalos das trans.}

(** TIPOS USADOS PELA REDE **************)

Type
   Ap_Arco_Rede   = ^Tipo_Arco_Rede ;

   Tipo_Arco_Rede = Record
      Lugar_Ass,Trans_Ass,
      Peso                 : Byte ;
      Par_Trans,Par_Lugar  : Ap_Arco_Rede ;
   end ;

   Tipo_Ident     = String [Car_Max_Ident] ;
   Aponta_Ident   = ^Tipo_Ident ;
   Lista_Ident    = Array [1..Max_Trans_Lugar] of Aponta_Ident ;

   Vetor_Bytes    = Array [1..Max_Trans_Lugar] of Byte ;
   Vetor_Inteiros = Array [1..Max_Trans_Lugar] of Integer ;
   Vetor_Reais    = Array [1..Max_Trans_Lugar] of Real ;

   Lista_Rede     = Array [1..Max_Trans_Lugar] of Ap_Arco_Rede ;
   Conj_Bytes     = Set of 1..Max_Trans_Lugar ;

   Tipo_Distrib   = (Unif,Expon,Norm) ;
   Vetor_Distrib  = Array [1..Max_Trans_Lugar] of Tipo_Distrib ;

   Tipo_Rede = Record
      Pred_Trans,Succ_Trans,
      Pred_Lugar,Succ_Lugar : Lista_Rede ;     { listas de arcos da rede     }
      Num_Trans,Num_Lugar   : Byte ;           { dimensoes da rede           }
      Mo                    : Vetor_Bytes ;    { Marcacao inicial            }
      Nome                  : Tipo_Ident ;     { nome da rede                }
      Nome_Trans,Nome_Lugar : Lista_Ident ;    { nome dos nodos da rede      }
      Tam_Trans,Tam_Lugar   : Byte ;           { tamanho do maior nome       }
      Temporizada           : Boolean ;        { rede com temporizacao       }
      SEFT,                                    { Static Earliest Firing Time }
      SLFT                  : Vetor_Inteiros ; { Static Latest   Firing Time }
      Coef                  : Vetor_Reais ;    { coef distrib de probabs     }
      Distrib               : Vetor_Distrib ;  { tipo de distrib das transic.}
   end ;

(** VARIAVEIS USADAS PELA REDE **********)

Var
   Rede        : Tipo_Rede ;
   Texto_Rede  : Ap_Texto ;

(** VARIAVEIS USADAS PELAS ENUMERACOES **)

   Texto_Grafo,
   Texto_Props,
   Texto_Estados : Ap_Texto ;

(** VARIAVEIS USADAS PELA SIMULACAO *****)

   Texto_Simu  : Ap_Texto ;

(** VARS. USADAS PELA AVALIACAO DESEMP **)

   Texto_Desemp       : Ap_Texto ;

(** VARIAVEIS USADAS PELOS INVARIANTES **)

   Texto_Inv_Trans,
   Texto_Inv_Lugar  : Ap_Texto ;

(** VARIAVEIS USADAS PELA VERIFICACAO ***)

   Texto_Verif : Ap_Texto ;

(** VARIAVEIS DE USO GERAL E CONTROLE ***)

   Alterou,
   Salvo,Funcao   : Boolean ;
   SubDir,
   Nome_Saida,
   Nome_Arq       : String ;
   Escolha        : Char ;

(***************************************************************************)

Implementation
  Var i : Integer ;

(***************************************************************************)

begin
   { inicializa as variaveis da rede }
   with Rede do begin
      Nome := '' ;
      Num_Trans := 0 ;
      Num_Lugar := 0 ;
      Tam_Trans := 0 ;
      Tam_Lugar := 0 ;
      Temporizada := FALSE ;
      for i := 1 to Max_Trans_Lugar do begin
         Pred_Trans [i] := NIL ;
         Succ_Trans [i] := NIL ;
         Pred_Lugar [i] := NIL ;
         Succ_Lugar [i] := NIL ;
         Nome_Trans [i] := NIL ;
         Nome_Lugar [i] := NIL ;
         Mo   [i] := 0 ;
         SEFT [i] := 0 ;
         SLFT [i] := 0 ;
      end ;
   end ;

   Nome_Arq := '' ;
   Nome_Saida := 'PRN.' ;

   Texto_Rede        := NIL ;
   Texto_Grafo       := NIL ;
   Texto_Estados     := NIL ;
   Texto_Props       := NIL ;
   Texto_Simu        := NIL ;
   Texto_Inv_Trans   := NIL ;
   Texto_Inv_Lugar   := NIL ;
   Texto_Verif       := NIL ;
   Texto_Desemp      := NIL ;
   Salvo             := TRUE ;
end.

(***************************************************************************)
