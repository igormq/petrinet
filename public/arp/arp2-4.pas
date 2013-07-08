{ Programa implementado em TURBO-PASCAL 5.0 }
{$F+}    {force far calls, for overlays}
{$R-}    {Range checking off}
{$B-}    {Boolean complete evaluation off}
{$S+}    {Stack checking on}
{$I+}    {I/O checking on}
{$N+}    {No numeric coprocessor}
{$E+}    {Uses emulation}
{$M 65500,16384,655360} {Turbo 3 default stack and heap}

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

(*****  ANALISADOR DE REDES DE PETRI ARP    Versao 2.4  *****)
(*                                                          *)
(*   Este programa realiza a analise de redes  de  Petri,   *)
(*   baseado  na tese de doutorado de Philippe Esteban na   *)
(*   Universidade  Paul  Sabatier de Toulouse - Franca, e   *)
(*   em outras publicacoes a respeito na area, principal-   *)
(*   mente Peterson (81) e Brams (83).                      *)
(*                                                          *)
(*   Autores:    Carlos Alberto Maziero     1987-1988-1989  *)
(*               Luis Adriano E. Franco          1988-1989  *)
(*   Traducao:   Paulo Valim                          1992  *)
(*                                                          *)
(*   Laboratorio de Controle e Microinformatica - LCMI      *)
(*   Universidade Federal de Santa Catarina - UFSC - Brasil *)
(*                                                          *)
(************************************************************)

(***** VERSAO 2.4 ********************************************

Escrita por Carlos Maziero e Andre Marques, 1994.

Modificacoes em relacao a versao 2.3i :

Modificaoes efetuadas :
- possibilidade de acessar drives D: ... Z: na leitura de uma
  rede, para poder usar o ARP com o Windows/WorkGroups.
- na simulacao, aviso de que o retorno a uma marcacao anterior
  nao e possivel diretamente. Este aviso eh temporario, ate' que
  seja permitido o retorno a marcacao anterior.
- Modificacao da rotina "Pergunta" do modulo interfac.pas, para
  determinar automaticamente as dimensoes da janela em funcao
  do texto a ser mostrado, considerando-se os simbolos []\|#.
- Em diretorios com mais de 119 arquivos, apenas 119 sao mos-
  trados, na tela de leitura de redes. Os 119 sao quaisquer,
  nao necessariamente os mais antigos ou alfabeticamente
  primeiros.
- Algumas variaveis do modulo janelas.pas mudaram de Integer para
  Word, pois mexiam com segmentos de memoria (de video). Isto corrige
  um erro de execucao potencial.
- Na procedure Atualiza_Valores do modulo desemp.pas estava faltando
  uma variavel local "i", para o controle de um loop local. Isto corrige
  um erro de "loop" na avaliacao de desempenho.

Restam a fazer :
- correcao na simulacao passo-a-passo : retorno a uma marcacao
  anterior deve ser permitido, com pergunta previa ao usuario.
- correcao na avaliacao de desempenho : divisao por zero em
  algumas redes.
- revisao das telas de ajuda ao usuario, com mais detalhes e
  menos erros de ingles.
- revisao dos menus e janelas, tornando mais apropriadas as
  traducoes em ingles.
- normalizacao de algumas teclas (ESC, etc) para tornar mais
  ergonomica a interface.
- mostrar TODOS os arquivos de um diretorio, possibilitando a
  navegacao no mesmo.
- Criar arquivo arp.pif e arp.icon para usar o ARP no Windows.
- O compilador deve aceitar redes em portugues ou ingles de
  modo transparente.
- Avisar o usuario de que o grafo de classes de estados gerado
  pode nao ser correto.
- Geracao correta do grafo de classes de estados em redes com
  temporizacao.

*************************************************************)

Program Analisador_de_Redes_de_Petri ;
Uses
  Overlay,     { rotinas de manipulacao de overlays  }
  Crt,         { rotinas basicas de video e teclado  }
  Janelas,     { rotinas de manipulacao de janelas   }
  Erro,        { rotina de manipulacao de erros      }
  Ajuda,       { sistema de ajuda ao usuario         }
  Texto,       { rotinas de montagem e uso de textos }
  Variavel,    { estruturas de dados globais         }
  Interfac,    { interfaces e rotinas basicas        }
  Arquivo,     { tratamento de arquivos em disco     }
  Grafo,       { rotinas de manipulacao de grafos    }
  Desemp,      { avaliacao de desempenho             }
  Edicao,      { ambiente de edicao de redes         }
  Impress,     { impressao de resultados             }
  Simular,     { novo simulador                      }
  Invarian,    { analise de invariantes              }
  Enumera,     { analise por enumeracao de estados   }
  Verifica ;   { verificacao de equiv. de linguagem  }

(**  UNITS EM OVERLAY  ******************)

  {$O Ajuda    }
  {$O Arquivo  }
  {$O Desemp   }
  {$O Edicao   }
  {$O Impress  }
  {$O Simular  }
  {$O Invarian }
  {$O Enumera  }
  {$O Verifica }

(** INICIO DO PROGRAMA PRINCIPAL ********)

begin
   { iniciacao do sistema de overlay do turbo 5 }
   OvrInit ('ARP2-4.OVR') ;
   OvrInitEMS ;

   Formato_Cursor (0) ;
   ClrScr ;

   GetDir(0,SubDir) ;

   { cria janela principal do ambiente }
   Cria_Janela (' ARP - 2.4 LCMI-EEL-UFSC ',1,1,80,7,Atrib_Forte) ;
   Msg (' Current Net :\ Directory   : \\ a[N]alisys                        ') ;
   Msg ('[S]imulation           [E]dit            [H]elp\ Pe[R]formance') ;
   Msg (' Evaluation          [V]erification         [P]rint           [Q]uit') ;

   Escolha := 'E' ;
   Funcao := FALSE ;

   repeat
      Alterou := FALSE ;
      if NOT Funcao then begin
         if (Rede.Num_Trans <> 0) then  { existe uma rede em memoria }
            Case Escolha of
              'N': begin
                     Cria_Janela (' Petri Net Analysis ',1,8,80,4,Atrib_Forte) ;
                     Msg ('\ P[L]ace Invariants          [T]ransition Invariants          State [E]numeration');
                     Escolha := Tecla (Funcao) ;
                     Case Escolha of
                      'E': Enumeracao_Estados (Rede,Texto_Grafo,
                                               Texto_Estados,Texto_Props,
                                               SuccEst,UltimoEst) ;
                      'L': Analise_de_Invariantes (Rede,Texto_Inv_Lugar,FALSE) ;
                      'T': Analise_de_Invariantes (Rede,Texto_Inv_Trans,TRUE) ;
                     end ;
                     Escolha := '*' ;
                     Apaga_Atual ;
                   end ;
              'V': Verificacao (Rede,Texto_Verif,SuccEst,UltimoEst) ;
              'S': Simulacao_Rede (Rede,Texto_Simu) ;
              'R': Avaliacao_Desempenho (Rede,Texto_Desemp) ;
            end ;
         Case Escolha of
           'P': Impressao_Saidas (Rede,Texto_Rede,Texto_Grafo,Texto_Estados,
                    Texto_Props,Texto_Inv_Trans,Texto_Inv_Lugar,Texto_Verif,
                    Texto_Desemp,Texto_Simu,Nome_Arq,Nome_Saida) ;
           'Q': if (NOT Salvo) OR (Texto_Props <> NIL) OR (Texto_Simu <> NIL)
                   OR (Texto_Inv_Trans <> NIL) OR (Texto_Inv_Lugar <> NIL)
                   OR (Texto_Verif <> NIL) OR (Texto_Desemp <> NIL) then begin
                     if Resp ('Sure to quit ARP ? ([Y]/[N])') = 'Y' then
                       Escolha := 'f'
                     else
                       Escolha := '*' ;
                end else
                   Escolha := 'f' ;
           'E': begin
                   Edicao_Redes (Rede,Nome_Arq,Texto_Rede,Alterou,Salvo) ;
                   if Alterou then begin
                      Apaga_Texto (Texto_Props) ;
                      Apaga_Texto (Texto_Grafo) ;
                      Apaga_Texto (Texto_Estados) ;
                      Apaga_Texto (Texto_Simu) ;
                      Apaga_Texto (Texto_Inv_Trans) ;
                      Apaga_Texto (Texto_Inv_Lugar) ;
                      Apaga_Texto (Texto_Verif) ;
                      Apaga_Texto (Texto_Desemp) ;

                      ApagaListaGrafo (SuccEst) ;
                      UltimoEst := 0 ;
                   end ;
                end ;
           'H': Tela_Ajuda (Principal) ;
         end ;
      end ;
      if (Escolha = 'E') then begin
         GotoXY(16,1) ;   ClrEoL ;   Write (Nome_Arq) ;
         GetDir(0,SubDir) ;
         GotoXY(16,2) ;   ClrEoL ;   Write (SubDir) ;
      end ;
      if Escolha <> 'f' then
         Escolha := Tecla (Funcao) ;
   Until Escolha = 'f' ; { f minusculo, so' setado pela alternat. Q do Case }
   Apaga_Atual ;

   Apaga_Rede (Rede) ;
   Apaga_Texto (Texto_Props) ;
   Apaga_Texto (Texto_Estados) ;
   Apaga_Texto (Texto_Grafo) ;
   Apaga_Texto (Texto_Simu) ;
   Apaga_Texto (Texto_Inv_Trans) ;
   Apaga_Texto (Texto_Inv_Lugar) ;
   Apaga_Texto (Texto_Verif) ;
   Apaga_Texto (Texto_Desemp) ;
   ApagaListaGrafo (SuccEst) ;
   GotoXY (1,25) ;
   Formato_Cursor (1) ;
end.

(** FIM DO PROGRAMA PRINCIPAL ***********)
