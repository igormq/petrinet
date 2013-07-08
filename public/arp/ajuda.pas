(***********************************************************************
 Esta UNIT e' responsavel pelo gerenciamento das telas de ajuda  ao
 usuario. Contem somente um procedimento publico, que e' chamado de
 acordo com o assunto do qual se deseja a ajuda.
************************************************************************)

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

{$O+,F+}   { permissao para overlay }

Unit Ajuda ;
Interface
  Type Tipo_Ajuda = (Principal,Edicao_Geral,Editor,Enumeracao,Impressao,
                     Invariantes,Simulacao,Desempenho,Verific) ;

  Procedure Tela_Ajuda (Opcao : Tipo_Ajuda) ;

(***********************************************************************)

Implementation
  Uses Crt,Janelas ;

(**********************************)

Procedure Ajuda_Principal ;
begin { MENU PRINCIPAL }
  Msg ('\               Laboratorio de Controle e Microinformatica - [LCMI]') ;
  Msg ('\               Departamento   de   Engenharia    Eletrica - [DEEL]') ;
  Msg ('\               Universidade  Federal  de  Santa  Catarina - [UFSC]') ;
  Msg ('\               88.049-900 Florianopolis - Santa Catarina - [Brasil]') ;
  Msg ('\\                [Petri Net Analyser  ARP  version  2.4]') ;
  Msg ('\                ======================================') ;
  Msg ('\\         This program analyses Ordinary Petri Nets, Time Petri Nets,');
  Msg ('\         and Extended Time Petri Nets. It has the following modules:') ;
  Msg ('\\         [- Editor.                      - Reachable States Enumeration.]');
  Msg ('\        [ - Compiler.                    - Equivalency Verification.]');
  Msg ('\        [ - File Management.             - Linear Invariants.]');
  Msg ('\        [ - Simulation.                  - Performance Evaluation. ]');
  Msg ('\\         The current window is the one with [highlighted frame].' ) ;
  Msg ('\         To activate a command press the corresponding [highlighted key].') ;
  Msg ('\         To leave a window use [ESC] or the [space bar].') ;
end ; { MENU PRINCIPAL }

(**********************************)

Procedure Ajuda_Edicao ;
begin { EDICAO }
  Msg ('\ [L]oad      : load text files. You must [type the file name] or') ;
  Msg ('\             [press ENTER] to select a file from the directory.') ;
  Msg ('\\ [S]ave      : save current text on disk, creating a "back-up" file.') ;
  Msg ('\\ [E]dit      : edit current text. Inside editor use [ESC] to see the') ;
  Msg ('\             commands and a Net Description Language summary.') ;
  Msg ('\\ [C]ompile   : compile current text, showing possible syntax errors.') ;
  Msg ('\\ [D]irectory : list current directory. Use [arrow keys] to move') ;
  Msg ('\             the cursor through files or sub-directories and the') ;
  Msg ('\             [ENTER] key to select one of them.') ;
end ; { EDICAO }

(**********************************)

Procedure Ajuda_Editor ;
begin { EDITOR DE TEXTOS }
  Msg (' [Petri Nets Description Language syntax :]') ;
  Msg ('\\ [NET] net_name ; { comentaries between brackets are allowed }') ;
  Msg ('\ [CONST]') ;
  Msg ('\   constant1,constant2,... = value ;') ;
  Msg ('\\ [NODES]') ;
  Msg ('\   name1,name2, ... : [TRANSITION] { [') ;
  Write ('[TMin,TMax]') ;
  Msg ('] } { [EXPON] (1000) } ;') ;
  Msg ('\   name1,name2, ... : [PLACE] { (initial number of tokens ) } ;') ;
  Msg ('\\ [STRUCTURE]      { input }                    { output }') ;
  Msg ('\   trans_name : (place,weight*place, ... ) , (place, ... ) ;') ;
  Msg ('\   ...') ;
  Msg ('\ [ENDNET.]') ;
  Msg ('\\\ [Text Editor Commands:]') ;
  Msg ('\   [') ;  Write (#24#25#26#27) ; Msg (']: Move cursor        [Ins]: Insert/overwrite      [Tab]: Tabulation') ;
  Msg ('\   [PgUp]: Page up            [Del]: Delete character     [Home]: Line beginning') ;
  Msg ('\  [PgDwn]: Page down          [Bks]: Backspace             [End]: Line end') ;
  Msg ('\  [^PgUp]: Top              [Enter]: New line              [F10]: Exit') ;
  Msg ('\ [^PgDwn]: Bottom              [^Y]: Delete line') ;
end ; { EDITOR DE TEXTOS }

(**********************************)

Procedure Ajuda_Enumeracao ;
begin { ENUMERACAO }
  Msg ('\ Properties observed in the net under analysis:') ;
  Msg ('\\ Places:  [Null]        : M(p) = 0  for any marking M.') ;
  Msg ('\          [Safe]        : M(p) <= 1 for any M.') ;
  Msg ('\          [k-Bounded]   : M(p) <= k for any M, 1 < k < W.') ;
  Msg ('\          [Unbounded]   : M(p) = W  for some M.         (Obs.: W = ì )') ;
  Msg ('\\ Net [strictly conservative] : tokens are neither created nor');
  Msg ('\                             destroyed for any M.');
  Msg ('\\ Transitions :  [live]          : it can be fired at any M.') ;
  Msg ('\                [Almost-live]   : It was fired at least once in the graph.') ;
  Msg ('\                [Non fired]     : It was never fired.') ;
  Msg ('\                [k-sensible]    : for some marking, it has enough tokens at');
  Msg ('\                                input for two or more consecutives fires.') ;
  Msg ('\\ [Free State] : there is a path that goes to M0 from it.') ;
  Msg ('\\ [Dead-Lock]  : no successor states (blocked).') ;
  Msg ('\\ [Live-lock]  : repetitive execution cycle.') ;
end ; { ENUMERACAO }

(**********************************)

Procedure Ajuda_Impressao ;
begin { IMPRESSAO }
  Msg ('\ [T]arged Archive : indicate where results should be printed. The') ;
  Msg ('\                standard device " PRN " is assumed by default.') ;
  Msg ('\                It is possible "to print" inside a file, just') ;
  Msg ('\                indicating its name. All the outputs are appended') ;
  Msg ('\                to this file, without losing of previous contents.') ;
  Msg ('\\ [C]urrent Net    : net in memory.') ;
  Msg ('\\ [E]numeration    : results from the last state enumeration.') ;
  Msg ('\\ [S]imulation     : results from the last simulation.') ;
  Msg ('\\ [I]nvariants     : results from calculation of invariants.') ;
  Msg ('\\ [V]erification   : record of the last verification.') ;
  Msg ('\\ [P]erformance    : record of the last performance evaluation.') ;
end ; { IMPRESSAO }

(**********************************)

Procedure Ajuda_Simulacao ;
begin
  Msg (' Simulation tracking simbology:') ;
  Msg ('\\        [state name    23®¹ fired transition on track') ;
  Msg ('\           ') ;       Write ('[depth]') ; Msg ('[<¿   1®¹ tr1') ;
  Msg ('\               ') ;  Write ('[2] |') ;  Msg ('[     º tr2]  <-- current state') ;
  Msg ('\                  [ À Ä Ä Ù]') ;
  Msg ('\\  [ÄÐÄ]   : block at current state        [Ä Ä Ä] : duplicity with previous state') ;
  Msg ('\  [') ; Write ('[xxx]') ; Msg ('] : state depth                   [xxx®¹] : non-fired transitions') ;
  Msg ('\\\\ - [F]ire       : fires a firable transition. If the net has timings,') ;
  Msg ('\                firing instant is asked.                                     ') ;
  Msg ('\ - [R]eturn     : allows return to the previous state.                         ') ;
  Msg ('\ - [E]dit       : changes the marking and time intervals of current state.     ') ;
  Msg ('\ - [M]emory     : memorizes state or jumps to a memorized state.               ') ;
  Msg ('\ - [S]tates     : shows old states from the current tracking.                  ') ;
  Msg ('\ - [T]race      : generates a trace text.') ;
  Msg ('\ - [P]laces     : selects which places will be displayed in the marking frame.') ;
  Msg ('\ - [Q]uit       : to finish simulation.                                     ') ;
end ;

(**********************************)

Procedure Ajuda_Avaliacao_Desempenho ;
begin { AVALIACAO DE DESEMPENHO }
  Msg ('\ [P]recision      : desired precision for results.                         ');
  Msg ('\ [M]ax. Fire.     : maximum  number of  transitions fired in  a cycle of   ');
  Msg ('\                  evaluation, if  no  targed  state, targed  event  or   ');
  Msg ('\                  inicial event are reached.                             ');
  Msg ('\ [C]onflicts      : allows  atribution  of  relative   probabilities  to   ');
  Msg ('\                  transitions on effective conflict in the net.          ');
  Msg ('\ [I]nicial Mark.  : inicial marking of performance evaluation.             ');
  Msg ('\ [T]arged  Mark.  : targed marking of  states  oriented  evaluation. They  ');
  Msg ('\                  are  the  points of  the cycle  and the  data collect  ');
  Msg ('\                  for performance evaluation.                            ');
  Msg ('\ [I]nicial Event  : event transition of  enumeration for  event  oriented  ');
  Msg ('\                  evaluation.                                            ');
  Msg ('\ [T]arged Events  : events transitions of  enumeration. When they  occur , ');
  Msg ('\                  they make the data collect for performance evaluation. ');
  Msg ('\ [R]eset          : it is to restore  the inicial marking of the net after ');
  Msg ('\                  have reached any targed event.                         ');
  Msg ('\ [B]egin          : it is to start the  performance evaluation. It ends up ');
  Msg ('\                  after  reaching  the  desired precision or for any key ');
  Msg ('\                  pressed by user.                                       ');
end ; { AVALIACAO DE DESEMPENHO }

(**********************************)

Procedure Ajuda_Calculo_Invariantes ;
begin { ANALISE DE INVARIANTES }
  Msg ('\ The invariants calculation results of linears equations  of type Cx = 0,');
  Msg ('\ where C is the incidency matrix from the petri net under analysis .     ');
  Msg ('\\ [Place Invariants]: they are the allocation of resources at net . In a ');
  Msg ('\   place invariant the  multiplicity of tokens is  constant (considering ');
  Msg ('\   the specific weights of the places).                                  ');
  Msg ('\\ [Transition Invariants ]: they are the cycle activities of the net.    ');
  Msg ('\   Firing transitions occurring to the ordered leads to the same marking ');
  Msg ('\   ( transition weight at invariant  indicates its  number of  fires  to ');
  Msg ('\   its number of fires to complete the cycle).                           ');
  Msg ('\\ [Results] :                                                            ');
  Msg ('\     [Prohibited Nodes]   : They must not be in any calculated  invariant.');
  Msg ('\     [Obligatories Nodes] : They must be in  every  calculated  invariant.');
  Msg ('\\ Obs: To select a node as a prohibited or as a obligatory node just put ');
  Msg ('\      cursor under it and press ENTER.                                   ');
end ; { ANALISE DE INVARIANTES }

(**********************************)

Procedure Ajuda_Verificacao ;
begin { VERIFICACAO }
  Msg ('\  The [verification] allows you studying the  net behaviour as a             ') ;
  Msg ('\  visible events  group. A minimum  net  graph only  having  the             ') ;
  Msg ('\  visible events is made from the reachability state  graph, and             ') ;
  Msg ('\  in it, you study the interection between these events.                     ') ;
  Msg ('\\  - [V]isible Events    : visible transitions to outside.                   ') ;
  Msg ('\  - [U]ser''s Graph      : it allows the input of a user''s graph for future ') ;
  Msg ('\                        comparison with  the  obtained  graph  from  net. For') ;
  Msg ('\                        every state the program ask you  which are the output') ;
  Msg ('\                        transitions  and  where they leads to. A white answer') ;
  Msg ('\                        means that correspondent transition does not fire  at') ;
  Msg ('\                        such state. The comparison  among  the  graphs is not') ;
  Msg ('\                        implemented yet.                                     ') ;
  Msg ('\  - [I]nicial Marking   : it allows you redefine  the inicial marking used at') ;
  Msg ('\                        graph''s creation of reachable states.               ') ;
  Msg ('\  - [P]aths             : it makes you able to research  the  possible paths ') ;
  Msg ('\                        at minimum graph.                                    ') ;
  Msg ('\  - [B]egin Verif.      : it begins the verification proccess.               ') ;
end ; { VERIFICACAO }

(**********************************)

Procedure Tela_Ajuda (Opcao : Tipo_Ajuda) ;
Var
  Ch : Char ;
begin
   Cria_Janela (' ARP 2.4 - User''s Help Screen ',1,1,80,25,Atrib_Forte) ;
   Case Opcao of
      Principal    : Ajuda_Principal ;
      Edicao_Geral : Ajuda_Edicao ;
      Editor       : Ajuda_Editor ;
      Enumeracao   : Ajuda_Enumeracao ;
      Impressao    : Ajuda_Impressao ;
      Simulacao    : Ajuda_Simulacao ;
      Desempenho   : Ajuda_Avaliacao_Desempenho ;
      Invariantes  : Ajuda_Calculo_Invariantes ;
      Verific      : Ajuda_Verificacao ;
   end ;
   repeat
     Ch := ReadKey ;
   until NOT KeyPressed ;
   Apaga_Atual ;
end ;

end.

(***********************************************************************)
