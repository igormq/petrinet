The ARP tool

ARP stands for Analisador de Redes de Petri, the portuguese translation 
for Petri Net Analyser. It's a software tool for Petri net analysis and 
simulation developed during my MSc work in the LCMI lab at the Federal 
University of Santa Catarina - Brazil, between 1988 and 1990. It's 
written in Turbo Pascal 6 and run in MS-DOS/Windows machines.  The ARP 
program has been used for teaching and research by several universities 
in Brazil and outside. Now, I'm leading the ASPeN projet, to provide a 
graphical version of the ARP tool, entirely written in Java, but this 
new tool is not ready yet. 

The ARP tool accepts the following Petri net models: 

   - Place/transition nets, with numeric markings and no time 
     information. 
   - Timed nets, in which firing intervals [tmin, tmax] are associated 
     to each transition (Merlin's approach). 
   - Extended timed nets, in which a probability function is associated 
     to each transition's firing interval. 

It offers the following analysis modules: 

   - Accessibility analysis: all the net's states (or state classes, in 
     Time nets) are found, and the reachability graph is built. Also, 
     some important properties are verified on the graph, like the 
     presence of deadlocks or livelocks, maximal markings on the places, 
     transitions' firability, and so on. 
   - Invariant analysis: provides the place or transition invariant 
     basis and all the minimum positive invariants. Some constraints 
     can be applied in the invariant calculation. 
   - Equivalence analysis: verification of the equivalence between the 
     state graph and a user given automata, considering some transitions 
     firings as invisible (internal state changes). 
   - Performance evaluation: intensive model simulation, giving several 
     statistical results like average marking of places, average firing 
     delay of transitions, average time to reach a given state, etc. 
   - Manual simulation: enables the user to "debug" the Petri net model,
     firing transitions step-by-step and modifying place markings 
     on-the-fly.

The program contains also some file facilities (simple editor, directory
browser, etc). In the ARP tool the Petri net models are described using 
a very simple language, similar to Pascal.

The ARP tool is freely distributed under the GPL - GNU Public License. 
It's no more maintained, i.e. I would appreciate to receive informations 
about nasty bugs, but I cannot insure they will be solved quickly. But, 
as it's algorithms are being used in the ASPeN Project, any bug 
information on them is very welcome. 

You can download the 2.4 (final) version of the ARP tool at 
http://www.ppgia.pucpr.br/~maziero/

Last, but not least, if you find this tool useful and effectively use 
it, please send me an e-mail (and don't forget to cite it on your 
publications !). You know, parents always like to know what their 
children are doing ;-) 

Carlos Maziero
maziero@ppgia.pucpr.br
http://www.ppgia.pucpr.br/~maziero
Curitiba - Paraná - Brazil
March 2000.
