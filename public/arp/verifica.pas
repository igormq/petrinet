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

Unit Verifica ;

Interface
  Uses Variavel,Texto,Grafo ;

  Procedure Verificacao (Var Rede        : Tipo_Rede ;
                         Var Texto_Verif : Ap_Texto ;
                         Var SuccEst     : Lista_Grafo ;
                         Var UltimoEst   : Integer) ;

(*****************************************************************************)

Implementation
  Uses Crt,Interfac,Janelas,Ajuda ;

Procedure Verificacao (Var Rede        : Tipo_Rede ;
                       Var Texto_Verif : Ap_Texto ;
                       Var SuccEst     : Lista_Grafo ;
                       Var UltimoEst   : Integer) ;
Var
   Erro              : Byte ;
   Escolha           : Char ;
   Escrever_Caminhos,
   Mudou             : Boolean ;
   SuccEstDet,
   SuccEstUser       : Lista_Grafo ;
   UltimoEstDet,i,
   UltimoEstUser     : Integer ;
   Visiveis          : Conj_Bytes ;
   MarcInic          : Vetor_Bytes ;
   Auxiliar          : Vetor_Inteiros ;
   Marcacao          : Lista_Marcacao ;
   Dominio           : Lista_Dominio ;
   Precedente        : VetorIntLongo ;

(*****************************************************************************)

  Procedure ObtemGrafoDeterministico (Var SuccEst   : Lista_Grafo ;
                                      Var UltimoEst : Integer ;
                                      Var SuccDet   : Lista_Grafo ;
                                      Var UltimoDet : Integer ;
                                      Var Visiveis  : Conj_Bytes ;
                                      Var Erro      : Byte) ;
  Type
    { armazenamento de listas de estados geradores }
    Ap_Geradores = ^Lista_Geradores ;
    Lista_Geradores = Record
      Gerador : Integer ;
      Proximo : Ap_Geradores ;
    end ;

  Var
    Trans,
    i,NumDest,Est : Integer ;
    Geradores     : Array [0..Max_Marcacao] of Ap_Geradores ;
    Auxiliar      : VetorBoolLongo ;
    Gerador_Atual,
    Lista_Destino : Ap_Geradores ;
    Arco_Atual    : Ap_Arco_Grafo ;
    Disparou,
    ExisteDestino : Boolean ;

(***************)

    Procedure E_Closure (Estado : Integer ;   Var Vetor : VetorBoolLongo) ;
    Var
      Atual : Ap_Arco_Grafo ;

    begin { BUSCA OS ESTADOS ALCANCAVEIS POR DISPAROS INVISIVEIS }
      if NOT Vetor [Estado] then begin
        Vetor [Estado] := TRUE ;
        Atual := SuccEst [Estado] ;
        while Atual <> NIL do begin
          if NOT (Atual^.Transicao in Visiveis) then
            E_Closure (Atual^.Sucessor,Vetor) ;
          Atual := Atual^.Proximo ;
        end ;
      end ;
    end ; { BUSCA OS ESTADOS ALCANCAVEIS POR DISPAROS INVISIVEIS }

(***************)

    Procedure Converte_Vetor_Lista (Var Vetor    : VetorBoolLongo ;
                                    Var Lista    : Ap_Geradores ;
                                        Dimensao : Integer) ;
    Var
      i     : Integer ;
      Atual : Ap_Geradores ;

    begin { CONVERTE UM VETOR BOOLEANO EM UMA LISTA DE GERADORES }
      Lista := NIL ;
      for i := Dimensao downto 0 do
        if Vetor [i] then begin
          Atual := Lista ;
          New (Lista) ;
          Lista^.Gerador := i ;
          Lista^.Proximo := Atual ;
        end ;
    end ; { CONVERTE UM VETOR BOOLEANO EM UMA LISTA DE GERADORES }

(***************)

    Function ListasIguais (Ap1,Ap2 : Ap_Geradores) : Boolean ;
    begin { VERIFICA SE DUAS LISTAS DE GERADORES SAO IGUAIS }
      if (Ap1 = NIL) XOR (Ap2 = NIL) then
        ListasIguais := FALSE
      else
        if (Ap1 = NIL) AND (Ap2 = NIL) then
          ListasIguais := TRUE
        else
          if (Ap1^.Gerador) = (Ap2^.Gerador) then
            ListasIguais := ListasIguais (Ap1^.Proximo,Ap2^.Proximo)
          else
            ListasIguais := FALSE ;
    end ; { VERIFICA SE DUAS LISTAS DE GERADORES SAO IGUAIS }

(***************)

    Procedure Apaga_Lista_Geradores (Var Atual : Ap_Geradores) ;
    begin { APAGA LISTA DE GERADORES }
      if Atual <> NIL then begin
        Apaga_Lista_Geradores (Atual^.Proximo) ;
        Dispose (Atual) ;
        Atual := NIL ;
      end ;
    end ; { APAGA LISTA DE GERADORES }

(***************)

  begin { OBTEM GRAFO DETERMINISTICO SEM TRANSICOES INVISIVEIS }
    Aviso ('[   0] deterministic states') ;  {?????}

    { inicia listas de geradores }
    for i := 0 to Max_Marcacao do begin
      Geradores [i] := NIL ;
      SuccDet   [i] := NIL ;
    end ;

    { cria estado inicial do grafo deterministico }
    UltimoDet := 0 ;
    Auxiliar := VetorFALSE ;
    E_Closure (0,Auxiliar) ;
    Converte_Vetor_Lista (Auxiliar,Geradores [0],UltimoEst) ;

    Est := 0 ;
    while (Est <= UltimoDet) AND (Erro = 0) do begin
      { atualiza contador de estados processados }
      Write (#13,Est:5) ;

      Trans := 1 ;
      while (Trans <= Rede.Num_Trans) AND (Erro = 0) do begin
        if Trans in Visiveis then begin
          if Pressiona_ESC then Erro := 1 ;

          Auxiliar := VetorFALSE ;
          Disparou := FALSE ;

          { para cada estado gerador verifica o disparo de Trans }
          Gerador_Atual := Geradores [Est] ;
          while Gerador_Atual <> NIL do begin
            Arco_Atual := SuccEst [Gerador_Atual^.Gerador] ;
            while (Arco_Atual <> NIL) do
              if Arco_Atual^.Transicao < Trans then
                Arco_Atual := Arco_Atual^.Proximo
              else begin
                while (Arco_Atual <> NIL) AND
                      (Arco_Atual^.Transicao = Trans) do begin
                  { Auxiliar := Auxiliar + e_closure (est') }
                  E_Closure (Arco_Atual^.Sucessor,Auxiliar) ;
                  Disparou := TRUE ;
                  Arco_Atual := Arco_Atual^.Proximo ;
                end ;
                Arco_Atual := NIL ;
              end ;
            Gerador_Atual := Gerador_Atual^.Proximo ;
          end ;

          { se existe estado sucessor, armazena-lo }
          if Disparou then begin

            { converte auxiliar na lista de geradores do estado destino }
            Converte_Vetor_Lista (Auxiliar,Lista_Destino,UltimoEst) ;

            { verifica existencia do destino encontrado }
            ExisteDestino := FALSE ;
            NumDest := 0 ;
            while (NumDest <= UltimoDet) AND (NOT ExisteDestino) do
              if ListasIguais (Geradores [NumDest],Lista_Destino) then
                ExisteDestino := TRUE
              else
                NumDest := Succ (NumDest) ;

            { guarda nova lista de geradores }
            if ExisteDestino then
              Apaga_Lista_Geradores (Lista_Destino)
            else begin
              UltimoDet := Succ (UltimoDet) ;
              NumDest := UltimoDet ;
              Geradores [UltimoDet] := Lista_Destino ;
              Lista_Destino := NIL ;
            end ;

            { guarda estrutura do novo grafo: Est -(trans)-> NumDest }
            IncluiArco (Trans,Est,NumDest,0,0,SuccDet,Precedente) ;

          end ;
        end ;

        Trans := Succ (Trans) ;
      end ;

      Est := Succ (Est) ;
    end ;

    { apaga listas de geradores }
    for Est := 0 to UltimoDet do
      Apaga_Lista_Geradores (Geradores [Est]) ;

    Apaga_Atual ;
  end ; { OBTEM GRAFO DETERMINISTICO SEM TRANSICOES INVISIVEIS }

(*****************************************************************************)

  Procedure SeparaGruposIniciais (Var SuccEst     : Lista_Grafo ;
                                  Var UltimoEst   : Integer ;
                                  Var Grupo       : VetorIntLongo ;
                                  Var UltimoGrupo : Integer) ;
  Var
    TransSaida  : Array [0..Max_Marcacao] of ^Conj_Bytes ;
    SaidaAtual  : Conj_Bytes ;
    Atual       : Ap_Arco_Grafo ;
    i,j         : Integer ;
    ExisteGrupo : Boolean ;

  begin { SEPARA ESTADOS EM GRUPOS INICIAIS }
    { inicia variaveis }
    for i := 0 to UltimoEst do begin
      TransSaida [i] := NIL ;
      Grupo      [i] := -1 ;
    end ;
    UltimoGrupo := -1 ;

    { separa estados em grupos }
    i := 0 ;
    while (i <= UltimoEst) AND (Erro = 0) do begin
      if Pressiona_ESC then Erro := 1 ;

      { identifica transicoes de saida do estado i }
      SaidaAtual := [] ;
      Atual := SuccEst [i] ;
      While Atual <> NIL do begin
        SaidaAtual := SaidaAtual + [Atual^.Transicao] ;
        Atual := Atual^.Proximo ;
      end ;

      { procura grupo j com mesmas saidas do estado i }
      j := 0 ;
      ExisteGrupo := FALSE ;
      while (j <= UltimoGrupo) AND NOT ExisteGrupo do
        if TransSaida [j]^ = SaidaAtual then
          ExisteGrupo := TRUE
        else
          j:= Succ (j) ;

      { classifica estado conforme a pesquisa efetuada }
      if ExisteGrupo then
        Grupo [i] := j
      else begin
        { cria novo grupo }
        UltimoGrupo := Succ (UltimoGrupo) ;
        Grupo [i] := UltimoGrupo ;
        New (TransSaida [UltimoGrupo]) ;
        TransSaida [UltimoGrupo]^ := SaidaAtual ;
      end ;
      i := Succ (i) ;
    end ;

    { apaga variaveis de controle da formacao de grupos }
    for i := 0 to UltimoGrupo do
      Dispose (TransSaida [i]) ;
  end ; { SEPARA ESTADOS EM GRUPOS INICIAIS }

(***************)

  Procedure RefinaAgrupamentos (Var SuccEst     : Lista_Grafo ;
                                Var UltimoEst   : Integer ;
                                Var Grupo       : VetorIntLongo ;
                                Var UltimoGrupo : Integer) ;
  Var
    Atual        : Lista_Grafo ;
    Estado       : Vetor_Inteiros ;
    GrupoDestino,
    NumEst,i,j   : Integer ;
    Reagrupou,
    CriouGrupo   : Boolean ;

  begin { REFINA AGRUPAMENTOS DOS ESTADOS }
    repeat
      Reagrupou := FALSE ;
      i := 0 ;
      While (i <= UltimoGrupo) AND (Erro = 0) do begin
        if Pressiona_ESC then Erro := 1 ;

        { identifica e separa estados do grupo i }
        NumEst := 0 ;
        for j := 0 to UltimoEst do
          if Grupo [j] = i then begin
            NumEst := Succ (NumEst) ;
            Estado [NumEst] := j ;
            Atual [NumEst] := SuccEst [j] ;
          end ;

        { percorre listas dos estados buscando divergencias }
        CriouGrupo := FALSE ;
        while (Atual [1] <> NIL) do begin

          { compara destinos dos estados 1 e j}
          GrupoDestino := Grupo [Atual [1]^.Sucessor] ;
          for j := 2 to NumEst do
            if Grupo [Atual [j]^.Sucessor] <> GrupoDestino then begin
              { cria novo grupo }
              if NOT CriouGrupo then begin
                CriouGrupo := TRUE ;
                UltimoGrupo := Succ (UltimoGrupo) ;
              end ;
              Grupo [Estado [j]] := UltimoGrupo ;
              Reagrupou := TRUE ;
            end ;

          { proximas transicoes }
          for j := 1 to NumEst do
            Atual [j] := Atual [j]^.Proximo ;
        end ;
        i := Succ (i) ;
      end ;
    until NOT Reagrupou OR (Erro <> 0) ;
  end ; { REFINA AGRUPAMENTOS DOS ESTADOS }

(***************)

  Procedure MinimizaGrafo (Var SuccEst   : Lista_Grafo ;
                           Var UltimoEst : Integer ;
                           Var Erro      : Byte) ;
  Var
    Grupo       : VetorIntLongo ;
    Atual       : Ap_Arco_Grafo ;
    UltimoGrupo : Integer ;

    Procedure MontaGrafoMinimo (Var SuccEst     : Lista_Grafo ;
                                Var UltimoEst   : Integer ;
                                Var Grupo       : VetorIntLongo ;
                                Var UltimoGrupo : Integer) ;
    Var
      SuccAuxi : Lista_Grafo ;
      Atual    : Ap_Arco_Grafo ;
      i,j      : Integer ;

    begin { MONTA GRAFO DEFINITIVO }
      for i := 0 to UltimoGrupo do begin
        { encontra estado j pertencente ao grupo i }
        j := 0 ;
        while Grupo [j] <> i do
          j := Succ (j) ;

        { passa lista de saida do estado j para o grupo i }
        SuccAuxi [i] := SuccEst [j] ;
        SuccEst  [j] := NIL ;

        { troca estados destino pelos respectivos grupos }
        Atual := SuccAuxi [i] ;
        while Atual <> NIL do begin
          Atual^.Sucessor := Grupo [Atual^.Sucessor] ;
          Atual := Atual^.Proximo ;
        end ;
      end ;

      { limpa estrutura do grafo antigo }
      ApagaListaGrafo (SuccEst) ;

      { coloca estrutura do novo grafo }
      UltimoEst := UltimoGrupo ;
      for i := 0 to UltimoEst do
        SuccEst [i] := SuccAuxi [i] ;
    end ; { MONTA GRAFO DEFINITIVO }

  begin { OBTEM GRAFO MINIMO }
    Aviso ('Getting minimum deterministic graph') ;
    SeparaGruposIniciais (SuccEst,UltimoEst,Grupo,UltimoGrupo) ;
    RefinaAgrupamentos   (SuccEst,UltimoEst,Grupo,UltimoGrupo) ;
    MontaGrafoMinimo     (SuccEst,UltimoEst,Grupo,UltimoGrupo) ;
    Apaga_Atual ;
  end ; { OBTEM GRAFO MINIMO }

(*****************************************************************************)

  Procedure EscreveCaminhos (Var SuccEst   : Lista_Grafo ;
                             Var UltimoEst : Integer ;
                             Var Rede      : Tipo_Rede) ;
  Var
    TopoPilha,i,NumCaminhos : Integer ;
    PilhaTrans,Nivel        : VetorIntLongo ;

(***************)

    Procedure RegistraCaminho (Var PilhaTrans  : VetorIntLongo ;
                                   TopoPilha,
                                   ProfundLaco : Integer) ;
    Var
      i : Integer ;

    begin { REGISTRA UM NOVO CAMINHO DETECTADO }
      NumCaminhos := Succ (NumCaminhos) ;
      Write (#13,NumCaminhos:5) ;

      { escreve cabecalho do caminho }
      WrtS ('C' + StI (NumCaminhos)) ;          { deve ser W ? }
      Posic (6) ;
      WrtS (': ') ;
      Tab_Inic (Col_Texto) ;

      { escreve pilha de transicoes disparadas }
      for i := 1 to TopoPilha do begin
        if i = ProfundLaco then
          Wrts ('{ ') ;
        WrtS (Rede.Nome_Trans [PilhaTrans [i]]^ + ' ') ;
      end ;

      { fecha chaves indicadoras de laco }
      if ProfundLaco > 0 then WrtLnS ('}')
                         else Nova_Linha ;
    end ; { REGISTRA UM NOVO CAMINHO DETECTADO }

(***************)

    Procedure SegueCaminhosnoGrafo (Estado : Integer) ;
    Var
      Atual : Ap_Arco_Grafo ;

    begin { SEGUE CAMINHOS NO GRAFO }
      if Pressiona_ESC then Erro := 1 ;
      Atual := SuccEst [Estado] ;
      if Atual <> NIL then
        While (Atual <> NIL) AND (Erro = 0) do begin

          { empilha transicao disparada pelo estado }
          TopoPilha := Succ (TopoPilha) ;
          PilhaTrans [TopoPilha] := Atual^.Transicao ;

          if Nivel [Atual^.Sucessor] = -1 then begin

            { pesquisa recursivamente o proximo estado }
            Nivel [Atual^.Sucessor] := Succ (Nivel [Estado]) ;
            SegueCaminhosnoGrafo (Atual^.Sucessor) ;
            Nivel [Atual^.Sucessor] := -1 ;

          end else
            RegistraCaminho (PilhaTrans,TopoPilha,Succ (Nivel [Atual^.Sucessor])) ;

          { desempilha transicao disparada }
          TopoPilha := Pred (TopoPilha) ;

          Atual := Atual^.Proximo ;
        end
      else
        RegistraCaminho (PilhaTrans,TopoPilha,-1) ;
    end ; { SEGUE CAMINHOS NO GRAFO }

(***************)

  begin { ESCREVE CAMINHOS POSSIVEIS EM UM GRAFO }
    Aviso ('[   0] Walked ways at minimum graph') ;

    { inicializa variaveis }
    for i := 0 to Max_Marcacao do
      Nivel [i]      := -1 ;
    NumCaminhos := 0 ;
    TopoPilha   := 0 ;
    Nivel [0]   := 0 ;

    SegueCaminhosnoGrafo (0) ;

    Apaga_Atual ;
  end ; { ESCREVE CAMINHOS POSSIVEIS EM UM GRAFO }

(*****************************************************************************)

  Procedure ComparaAutomatos (Var SuccEstA,SuccEstB     : Lista_Grafo ;
                              Var UltimoEstA,UltimoEstB : Integer) ;
  Var
    Grupo       : VetorIntLongo ;
    UltimoEst,
    UltimoGrupo,
    i,k         : Integer ;
    Atual       : Ap_Arco_Grafo ;
    Equival,
    EstA,EstB   : Boolean ;
    Equiv       : VetorBoolLongo ;
    Escrita     : String ;

  begin { COMPARA A TOPOLOGIA DE DOIS GRAFOS ENTRE SI }
    Aviso ('Comparing created with specified "automato"') ;

    { coloca os dois grafos em uma so' estrutura de dados }
    for i := 0 to UltimoEstB do begin
      { muda indice dos sucessores }
      Atual := SuccEstB [i] ;
      while Atual <> NIL do begin
        Atual^.Sucessor := Atual^.Sucessor + UltimoEstA + 1 ;
        Atual := Atual^.Proximo ;
      end ;

      { transfere a cabeca da lista }
      SuccEstA [i + UltimoEstA + 1] := SuccEstB [i] ;
      SuccEstB [i] := NIL ;
    end ;
    UltimoEst := UltimoEstA + UltimoEstB + 1 ;

    { separa estados em grupos equivalentes }
    SeparaGruposIniciais (SuccEstA,UltimoEst,Grupo,UltimoGrupo) ;
    RefinaAgrupamentos   (SuccEstA,UltimoEst,Grupo,UltimoGrupo) ;

    { testa se cada grupo possui ao menos um estado de cada automato }
    Equival := TRUE ;
    for k := 0 to UltimoGrupo do begin
      EstA := FALSE ;
      EstB := FALSE ;
      i := 0 ;
      while (NOT (EstA AND EstB)) AND (i <= UltimoEst) do begin
        if Grupo [i] = k then
          if i <= UltimoEstA then EstA := TRUE
                             else EstB := TRUE ;
        i := Succ (i) ;
      end ;
      Equiv [k] := EstA AND EstB ;
      Equival := Equival AND Equiv [k] ;
    end ;

    { escreve resultados obtidos }
    if Equival then
      WrtLnS ('The "automato" S and the specification E are equivalents.')
    else
      WrtLnS ('The "automato" S and the specification E are not equivalents.') ;
    Nova_Linha ;

    WrtS ('Group of equivalents states : ') ;
    Tab_Inic (4) ;
    for k := 0 to UltimoGrupo do begin
      Escrita := '(' ;
      for i := 0 to UltimoEst do
        if Grupo [i] = k then
          if i > UltimoEstA then
            Escrita := Escrita + 'E' + StI (i - UltimoEstA - 1) + ' '
          else
            Escrita := Escrita + 'S' + StI (i) + ' ' ;
      Escrita [Length (Escrita)] := ')' ;
      WrtS (Escrita + ' ') ;
    end ;
    Nova_Linha ;
    Traco ;
    Tab_Inic (1) ;

    Apaga_Atual ;
  end ; { COMPARA A TOPOLOGIA DE DOIS GRAFOS ENTRE SI }

(*****************************************************************************)

begin { VERIFICACAO }
   Erro := 0 ;
   Visiveis := [] ;
   for i := 0 to Max_Marcacao do
     SuccEstUser [i] := NIL ;
   UltimoEstUser := 0 ;
   MarcInic := Rede.Mo ;
   Escrever_Caminhos := FALSE ;

   if (Texto_Verif <> NIL) then
     Escolha := Resp ('Want to lose last results ? [(Y/N)]')
   else
     Escolha := 'Y' ;
   if (Escolha <> 'Y') then
     Escolha := 'B'
   else begin

     Cria_Janela (' Petri Net Verification ',1,8,80,4,Atrib_Forte) ;
     Msg ('\ [V]isible Events   [I]nicial Mark.  [G]raph to Compare ' +
          '  [P]aths ([NOT])  [B]egin   [H]elp') ;

     { gerencia menu de verificacao }
     repeat
       Escolha := Tecla (Funcao) ;
       if Funcao then
         Escolha := '*'
       else
         Case Escolha of
          'V': With Rede do
                 Seleciona_Nodos (' Visible ',Nome_Trans,[1..Num_Trans],
                                  Visiveis,Erro,FALSE,Num_Trans,Tam_Trans) ;
          'G': LeituraGrafo (Rede,SuccEstUser,UltimoEstUser,Visiveis) ;
          'P': begin
                 Escrever_Caminhos := NOT Escrever_Caminhos ;
                 GotoXY (60,2) ;
                 if Escrever_Caminhos then write ('YES')
                                      else write ('NOT');
               end ;
          'I': with Rede do begin
                 Mudou := FALSE ;
                 for i := 1 to Num_Lugar do
                   Auxiliar [i] := MarcInic [i] ;
                 ValorMinimo := 0 ;
                 ValorMaximo := 254 ;
                 TamBuffer := 3 ;
                 Leitura_Vetor (' M0 ',Nome_Lugar,Auxiliar,[0..255],
                                Num_Lugar,Tam_Lugar,'',0,'',0) ;
                 for i := 1 to Num_Lugar do
                   if MarcInic [i] <> Auxiliar [i] then begin
                     MarcInic [i] := Auxiliar [i] ;
                     Mudou := TRUE ;
                   end;
                 if Mudou then begin
                   ApagaListaGrafo (SuccEst) ;
                   UltimoEst := 0 ;
                 end ;
               end ;
          'H': Tela_Ajuda (Verific) ;
          'B':;
         else
           Escolha := '*' ;
         end ;
     until Escolha in ['B','*'] ;

     { efetua verificacao }
     if Escolha = 'B' then begin
       Apaga_Texto (Texto_Verif) ;

       { gera grafo, se ainda nao existir }
       if (UltimoEst = 0) then begin
         ApagaListaGrafo (SuccEst) ;
         UltimoEst := 0 ;
         GeraGrafo (Rede,MarcInic,SuccEst,UltimoEst,
                    Marcacao,Dominio,Precedente,Erro) ;
         ApagaListaMarcacao (Marcacao) ;
         ApagaListaDominio (Dominio) ;
         if Erro <> 0 then begin
           ApagaListaGrafo (SuccEst) ;
           UltimoEst := 0 ;
         end ;
       end ;

       if Erro = 0 then begin
         ObtemGrafoDeterministico (SuccEst,UltimoEst,SuccEstDet,
                                   UltimoEstDet,Visiveis,Erro) ;
         if Erro = 0 then
           MinimizaGrafo (SuccEstDet,UltimoEstDet,Erro) ;

         if Erro = 0 then begin
           Aviso ('Writing exit text') ;
           Usa_Texto (Texto_Verif) ;
           WrtLnS ('Net Analysis ' + Rede.Nome + '.') ;
           Nova_Linha ;
           WrtS ('Visible Tr. : ') ;
           EscConj (Visiveis,Rede.Nome_Trans,Rede.Num_Trans) ;
           WrtS ('Invisible Tr. : ') ;
           EscConj ([1..Rede.Num_Trans] - Visiveis,Rede.Nome_Trans,Rede.Num_Trans) ;
           Nova_Linha ;
           WrtS ('Inicial Mark. : ') ;
           EscVetor (MarcInic,Rede.Nome_Lugar,Rede.Num_Lugar,TipoByte,'',0,'',0) ;
           Traco ;
           Nova_Linha ;

           WrtLnS ('Reduced graph was found :') ;
           Nova_Linha ;
           EscreveGrafo (SuccEstDet,UltimoEstDet,Rede,'S') ;
           Traco ;
           Nova_Linha ;

           Apaga_Atual ;

           if Escrever_Caminhos then begin
             WrtLnS ('Language elementaries components accepted by graph :') ;
             Traco ;
             EscreveCaminhos (SuccEstDet,UltimoEstDet,Rede) ;
             Traco ;
           end ;
         end ;

         if SuccEstUser [0] <> NIL then begin
           WrtLnS ('Specification to compare :') ;
           Nova_Linha ;
           EscreveGrafo (SuccEstUser,UltimoEstUser,Rede,'E') ;
           Nova_Linha ;
           ComparaAutomatos (SuccEstDet,SuccEstUser,UltimoEstDet,UltimoEstUser) ;
         end ;

         ApagaListaGrafo (SuccEstUser) ;
         ApagaListaGrafo (SuccEstDet) ;
       end ;
     end ;
     Apaga_Atual ;
   end ;

   if Escolha = 'B' then
     if (Erro = 0) then
       Edita_Texto (' Verification Results ',Texto_Verif,
                    1,1,8,18,FALSE,Funcao)
      else begin
        Case Erro of
          1 : Escolha := Resp ('aborted by user...') ;
          2 : Escolha := Resp ('excess of markings...') ;
        end ;
        Apaga_Texto (Texto_Verif) ;
      end ;
end ; { VERIFICACAO }

end.

(*****************************************************************************)
