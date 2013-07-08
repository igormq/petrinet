(********************************************************************)

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

Unit Simular ;

Interface
  Uses Variavel,Texto ;

  Procedure Simulacao_Rede (Var Rede       : Tipo_Rede ;
                            Var Texto_Simu : Ap_Texto) ;

(********************************************************************)

Implementation
  Uses Crt,Interfac,Janelas,Ajuda,Grafo ;

Procedure Simulacao_Rede (Var Rede       : Tipo_Rede ;
                          Var Texto_Simu : Ap_Texto) ;
Const
  ComprMaxTrilha = 21 ;

Type
  { estrutura geral dos estados armazenados }
  Ap_Estado       = ^Registro_Estado ;
  Registro_Estado = Record
    Proximo,
    Anterior     : Ap_Estado ;
    Marcacao     : Vetor_Bytes ;
    Dominio      : Ap_Dominio ;
    Pos_Memoria,
    Trans_Disp,
    Hashing      : Byte ;
    Disparadas   : Conj_Bytes ;
    Profundidade,
    Inst_Disparo : Integer ;
  end ;

  { gerencia dos estados memorizados }
  Memoria_Estados = Record
    Nome    : Lista_Ident ;
    Estado  : Array [1..Max_Trans_Lugar] of Ap_Estado ;
    TamNome,
    Numero  : Byte ;
  end ;

Var
  { controle da geracao do registro de evolucao }
  Registrar : Boolean ;

  { gerencia da memoria de estados }
  Memoria : Memoria_Estados ;

  Escolha,Ch  : Char ;
  Estado      : Ap_Estado ;
  Limiar      : Vetor_Bytes ;
  Jan_Menu,
  Jan_Trilha,
  Jan_Lugares,
  TamCampo,
  LugsLinha,
  MaxLinDisp  : Byte ;
  Disponiveis : Conj_Bytes ;

(********************************************************************)

  Procedure ApagaListaEstados (Var Estado : Ap_Estado) ;
  begin { APAGA LISTA DE ESTADOS }
    if Estado <> NIL then begin
      ApagaListaEstados (Estado^.Proximo) ;
      ApagaArcosDominio (Estado^.Dominio) ;
      Dispose (Estado) ;
      Estado := NIL ;
    end ;
  end ; { APAGA LISTA DE ESTADOS }

(**************************************)

  Procedure CopiaEstado (Var Estado,Copia : Ap_Estado) ;
  Var DomEst,DomCop : Ap_Dominio ;
  begin { GERA UMA COPIA DO ESTADO INIDICADO }
    { copia do estado como um todo }
    New (Copia) ;
    Copia^ := Estado^ ;
    Copia^.Dominio  := NIL ;
    Copia^.Anterior := NIL ;
    Copia^.Proximo  := NIL ;

    { copia da lista de dominio do estado }
    DomEst := Estado^.Dominio ;
    DomCop := Copia^.Dominio ;
    while DomEst <> NIL do begin
      if DomCop = NIL then begin
        New (DomCop) ;
        Copia^.Dominio := DomCop ;
      end else begin
        New (DomCop^.Proximo) ;
        DomCop := DomCop^.Proximo ;
      end ;
      DomCop^.Transicao := DomEst^.Transicao ;
      DomCop^.DEFT      := DomEst^.DEFT ;
      DomCop^.DLFT      := DomEst^.DLFT ;
      DomCop^.Proximo   := NIL ;
      DomEst := DomEst^.Proximo ;
    end ;
  end ; { GERA UMA COPIA DO ESTADO INIDICADO }

(********************************************************************)

  Procedure Atualiza_Diagrama_Disparos (Estado  : Ap_Estado ;
                                        Profund : Integer ;
                                        Indicar : Boolean) ;
  Var
    Abreviar       : Boolean ;
    ProfundInic,
    FimAbrevia,j,
    Posicao,Linha,
    Compr,NaoDisp  : Integer ;
    Dominio        : Ap_Dominio ;

  begin { ATUALIZA INDICADOR DE SEQUENCIA DE DISPAROS }
    { determina primeiro estado e comprimento da fila }
    Compr := 1 ;
    while (Estado^.Anterior <> NIL) do begin
      Estado := Estado^.Anterior ;
      Compr := Succ (Compr) ;
    end ;

    if Indicar then
      Compr := Succ (Compr) ;
    ProfundInic := Estado^.Profundidade ;

    { determina se deve haver ou nao abreviacao na lista }
    if Compr > ComprMaxTrilha then begin
      Abreviar := TRUE ;
      FimAbrevia := Compr - ComprMaxTrilha + 3 ;
    end else
      Abreviar := FALSE ;

    Vai_Para_Janela (Jan_Trilha) ;
    GotoXY (1,3) ;
    Posicao := 1 ;
    while (Estado <> NIL) do
      if Abreviar AND (Posicao > 1) then begin
        { escreve caractere de abreviacao }

        if Indicar then
          if (Profund = ProfundInic) then
            Write (' ':Car_Max_Ident,' |')
          else
            if (Profund < ProfundInic + FimAbrevia -1) then
              Write (('[' + Sti (Profund) + ']'):Car_Max_Ident,#17,'¿')
            else
              Write (' ':Car_Max_Ident,'  ')
        else
          Write (' ':Car_Max_Ident,'  ') ;

        Write ('     :') ;
        ClrEoL ;

        { avanca estado e contador ate' sair da abreviacao }
        for Linha := Posicao to Pred (FimAbrevia) do
          Estado := Estado^.Proximo ;
        Posicao := 3 ;
        Abreviar := FALSE ;

      end else begin
        { escreve nome do estado ou profundidade }
        GotoXY (1,Posicao + 2) ;
        if (Estado^.Pos_Memoria <> 0) then
          Write (Memoria.Nome [Estado^.Pos_Memoria]^:Car_Max_Ident)
        else
          Write (('[' + Sti (Estado^.Profundidade) + ']'):Car_Max_Ident) ;

        { escreve indicador de duplicidade }
        if Indicar then
          if (Profund = Estado^.Profundidade) then
            Write (#17,'¿ ')
          else
            if (Profund < Estado^.Profundidade) then Write (' | ')
                                                else Write ('   ')
        else
          Write ('   ') ;

        { escreve o balanco de transicoes sensibilizadas }
        NaoDisp := 0 ;
        Dominio := Estado^.Dominio ;
        while Dominio <> NIL do begin
          if NOT (Dominio^.Transicao in Estado^.Disparadas) then
            NaoDisp := Succ (NaoDisp) ;
          Dominio := Dominio^.Proximo ;
        end ;
        if NaoDisp = 0 then
          if Estado^.Disparadas = [] then write ('   ÄÐÄ')
                                     else write ('    º ')
        else
          write (NaoDisp:3,'®¹ ') ;

        { escreve transicao disparada }
        if Estado^.Trans_Disp <> 0 then
          Write (Rede.Nome_Trans [Estado^.Trans_Disp]^) ;
        ClrEoL ;

        if Posicao < ComprMaxTrilha then
          WriteLn ;
        Estado := Estado^.Proximo ;
        Posicao := Succ (Posicao) ;
      end ;

    { escreve indicador de duplicidade }
    if Indicar then begin
      Write (' ':Car_Max_Ident,' À Ä Ä Ù') ;
      ClrEOL ;
      Posicao := Succ (Posicao) ;
    end ;

    { limpa restante da tela }
    for Linha := Posicao to ComprMaxTrilha do begin
      GotoXY (1,Linha + 2) ;
      ClrEoL ;
    end ;
    Vai_Para_Janela (Jan_Menu) ;
  end ; { ATUALIZA INDICADOR DE SEQUENCIA DE DISPAROS }

(**************************************)

  Procedure Atualiza_Marcacao (Var Marcacao    : Vetor_Bytes ;
                               Var Disponiveis : Conj_Bytes ;
                               Var Rede        : Tipo_Rede) ;
  Var i,Cont,Linha : Byte ;
  begin { ATUALIZA JANELA DE LUGARES }
    Vai_Para_Janela (Jan_Lugares) ;
    Linha := 0 ;
    Cont  := 0 ;
    for i := 1 to Rede.Num_Lugar do
      if (i in Disponiveis) then begin
        { coloca nova linha ou espacos }
        if (Cont MOD LugsLinha = 0) then begin
          Linha := Succ (Linha) ;
          GotoXY (1,Linha) ;
        end else
          write (' ':2) ;

        { escreve valor do lugar desejado }
        Cont := Succ (Cont) ;
        Write (Rede.Nome_Lugar [i]^:Rede.Tam_Lugar,':') ;
        Case Marcacao [i] of
          0: write (' ':3) ;
          W: write ('W':3) ;
        else
          Write (Marcacao [i]:3) ;
        end ;

      end ;

    ClrEoL ;
    for i := Succ (Linha) to MaxLinDisp do begin
      GotoXY (1,i) ;
      ClrEoL ;
    end ;
    Vai_Para_Janela (Jan_Menu) ;
  end ; { ATUALIZA JANELA DE LUGARES }

(**************************************)

  Procedure Definir_Lugares_Display (Var Disponiveis : Conj_Bytes ;
                                     Var Marcacao    : Vetor_Bytes ;
                                     Var Rede        : Tipo_Rede) ;
  Var
    i,Cont : Byte ;

  begin { DEFINIR LUGARES MOSTRADOS NO DISPLAY }
    { leitura do conjunto de lugares disponiveis }
{lugares}   Seleciona_Nodos (' Places ',Rede.Nome_Lugar,[1..255],Disponiveis,
                     i,FALSE,Rede.Num_Lugar,Rede.Tam_Lugar) ;

    { retira lugares em excesso }
    Cont := 0 ;
    for i := 1 to Rede.Num_Lugar do
      if i in Disponiveis then
        if Cont = (LugsLinha * MaxLinDisp) then
          Disponiveis := Disponiveis - [i..Rede.Num_Lugar]
        else
          Cont := Succ (Cont) ;

    Atualiza_Marcacao (Marcacao,Disponiveis,Rede) ;
  end ; { DEFINIR LUGARES MOSTRADOS NO DISPLAY }

(**************************************)

  Procedure Escreve_Estado (Estado : Ap_Estado) ;
  begin { ESCREVE UM TEXTO SOBRE O ESTADO }
    WrtS ('Depth  : '+ StI (Estado^.Profundidade)) ;
    if Estado^.Pos_Memoria <> 0 then
      WrtS   ('  (Memorized as ' + Memoria.Nome [Estado^.Pos_Memoria]^ + ')') ;
    WrtLnS ('.') ;
    WrtS ('Marking: ') ;
    EscVetor (Estado^.Marcacao,Rede.Nome_Lugar,Rede.Num_Lugar,TipoByte,
              'W',255,'',0) ;
    WrtS ('Bounds : ') ;
    EscreveDominio (Rede,Estado^.Dominio) ;
    if Estado^.Disparadas <> [] then begin
      WrtS ('Fired  : ') ;
      EscConj (Estado^.Disparadas,Rede.Nome_Trans,Rede.Num_Trans) ;
    end ;
    Nova_Linha ;
  end ; { ESCREVE UM TEXTO SOBRE O ESTADO }

(**************************************)

  Procedure Escreve_Sequencia (Estado : Ap_Estado) ;
  Var
    Est_Inicio : Ap_Estado ;

  begin { ESCREVE SEQUENCIA QUE CULMINA NO ESTADO DADO }
    { escreve sequencia de disparos atual }
    Est_Inicio := Estado ;
    while (Est_Inicio^.Anterior <> NIL) do
      Est_Inicio := Est_Inicio^.Anterior ;

    WrtS ('Fire sequence beginning at ') ;
    if Est_Inicio^.Pos_Memoria <> 0 then
      WrtS (Memoria.Nome [Est_Inicio^.Pos_Memoria]^) ;
    WrtS   (' (depth ') ;
    WrtN   (Est_Inicio^.Profundidade) ;
    WrtLnS (')') ;

    WrtS ('             and ending at ') ;
    if Estado^.Pos_Memoria <> 0 then
      WrtS (Memoria.Nome [Estado^.Pos_Memoria]^) ;
    WrtS   (' (depth ') ;
    WrtN   (Estado^.Profundidade) ;
    WrtLnS (') ') ;

    WrtS ('-> ') ;
    Tab_Inic (Col_Texto) ;
    while Est_Inicio <> Estado do begin
      if (Est_Inicio^.Inst_Disparo <> 0) then
        WrtS (Rede.Nome_Trans [Est_Inicio^.Trans_Disp]^ +
              ' [' + StI (Est_Inicio^.Inst_Disparo) + ']  ')
      else
        WrtS (Rede.Nome_Trans [Est_Inicio^.Trans_Disp]^ + '  ') ;
      Est_Inicio := Est_Inicio^.Proximo ;
    end ;
    Nova_Linha ;
    Nova_Linha ;
  end ; { ESCREVE SEQUENCIA QUE CULMINA NO ESTADO DADO }

(**************************************)

  Procedure Visualizar_Estado (Estado    : Ap_Estado ;
                               Sequencia : Boolean) ;
  Var
    TextoEst : Ap_Texto ;

  begin { VISUALIZAR CONTEUDO DE UM ESTADO }
    TextoEst := NIL ;
    Usa_Texto (TextoEst) ;
    Escreve_Estado (Estado) ;
    if Sequencia then
      Escreve_Sequencia (Estado) ;
    Traco ;
    Edita_Texto (' State Visualization ',TextoEst,1,1,8,18,FALSE,Funcao) ;
    Apaga_Texto (TextoEst) ;
    Usa_Texto (Texto_Simu) ;
  end ; { VISUALIZAR CONTEUDO DE UM ESTADO }

(********************************************************************)

  Procedure Testa_Duplicidade_Memoria (Var Estado  : Ap_Estado ;
                                       Var Memoria : Memoria_Estados) ;
  Var
    Estado_Mem : Integer ;
    Duplicata  : Boolean ;

  begin { VERIFICA SE UM DADO ESTADO ESTA' NA MEMORIA }
    Estado_Mem := 1 ;
    Duplicata := FALSE ;
    while (Estado_Mem <= Memoria.Numero) AND NOT Duplicata do begin
      if Estado^.Hashing = Memoria.Estado [Estado_Mem]^.Hashing then
        if MarcacoesIguais (Estado^.Marcacao,Memoria.Estado
                            [Estado_Mem]^.Marcacao,Rede.Num_Lugar) then
          if DominiosIguais (Estado^.Dominio,Memoria.Estado
                             [Estado_Mem]^.Dominio) then begin
            Estado^.Pos_Memoria := Estado_Mem ;
            Duplicata := TRUE ;
          end ;
      Estado_Mem := Succ (Estado_Mem) ;
    end ;
  end ; { VERIFICA SE UM DADO ESTADO ESTA' NA MEMORIA }

(**************************************)

  Procedure Pular_Novo_Estado (Var Estado,Novo_Est : Ap_Estado) ;
  begin { PULA PARA UM NOVO ESTADO }
    { coloca o estado atual no comeco da lista de retorno a apagar }
    while (Estado^.Anterior <> NIL) do
      Estado := Estado^.Anterior ;
    { apaga lista de retorno velha }
    ApagaListaEstados (Estado) ;
    { passa a operar no novo estado }
    CopiaEstado (Novo_Est,Estado) ;
  end ; { PULA PARA UM NOVO ESTADO }

(**************************************)

  Procedure Memoriza_Estado (Var Estado  : Ap_Estado ;
                                 Nome    : Tipo_Ident ;
                             Var Memoria : Memoria_Estados) ;

  Var
    i     : Byte ;
    Igual : Boolean ;

  begin { MEMORIZA ESTADO INDICADO, COM NOME }
    if Estado^.Pos_Memoria <> 0 then
      Ch := Resp ('State already memorized as [' +
              Memoria.Nome [Estado^.Pos_Memoria]^ + ']')
    else begin

      { determina nome do estado memorizado }
      while (Nome = '') do begin
        { leitura do nome }
        TamBuffer := Car_Max_Ident ;
        Pergunta ('State name : ',Nome,TipoStr) ;

        { retira espacos em branco excessivos do nome }
        while (Pos ('  ',Nome) <> 0) do
          Delete (Nome,Pos ('  ',Nome),1) ;
        if (Nome [1] = ' ') then
          Delete (Nome,1,1) ;
        if (Nome [Length (Nome)] = ' ') then
          Delete (Nome,Length (Nome),1) ;

        { verifica se o nome ja' existe ou nao }
        i := 1 ;
        Igual := FALSE ;
        while (i <= Memoria.Numero) AND NOT Igual do
          if (UpString (Nome) = UpString (Memoria.Nome [i]^)) then
            Igual := TRUE
          else
            i := Succ (i) ;
        if Igual then
          Nome := '' ;
      end ;

      { memoriza o estado }
      Memoria.Numero := Succ (Memoria.Numero) ;
      Estado^.Pos_Memoria := Memoria.Numero ;
      CopiaEstado (Estado,Memoria.Estado [Memoria.Numero]) ;
      New (Memoria.Nome [Memoria.Numero]) ;
      Memoria.Nome [Memoria.Numero]^ := Nome ;
      Memoria.TamNome := MaxI (Memoria.TamNome,Length (Nome)) ;
    end ;
  end ; { MEMORIZA ESTADO INDICADO, COM NOME }

(**************************************)

  Procedure Gerenciar_Memoria (Var Memoria : Memoria_Estados ;
                               Var Estado  : Ap_Estado ;
                               Var Rede    : Tipo_Rede) ;
  Var
    Escolhido : Byte ;
    Auxiliar  : Conj_Bytes ;

  begin { GERENCIA MEMORIA DE ESTADOS }
    Escolha := Resp ('[M]emorize state  [J]ump to memorized state  [S]ee memorized states') ;
    Case Escolha of
     'M': begin
            Memoriza_Estado (Estado,'',Memoria) ;
            if Registrar then begin
              WrtLnS ('Current state memorized as ' +
                      Memoria.Nome [Estado^.Pos_Memoria]^ + '.') ;
              Nova_Linha ;
            end ;
            Atualiza_Diagrama_Disparos (Estado,0,FALSE) ;
          end ;
     'J': begin
            { determina estado destino }
            Auxiliar := [] ;
            Seleciona_Nodos (' Memorized ',Memoria.Nome,[1..Memoria.Numero],
                             Auxiliar,Escolhido,TRUE,Memoria.Numero,
                             Memoria.TamNome) ;
            if (Escolhido <> 0) then begin
              Pular_Novo_Estado (Estado,Memoria.Estado [Escolhido]) ;
              if Registrar then begin
                WrtLnS ('Jump to memorized state :') ;
                Escreve_Estado (Estado) ;
              end ;
              Atualiza_Diagrama_Disparos (Estado,0,FALSE) ;
              Atualiza_Marcacao (Estado^.Marcacao,Disponiveis,Rede) ;
            end ;
          end ;
     'S': begin
            { determina estado a visualizar }
            Auxiliar := [] ;
            Seleciona_Nodos (' Memorized ',Memoria.Nome,[1..Memoria.Numero],
                             Auxiliar,Escolhido,TRUE,Memoria.Numero,
                             Memoria.TamNome) ;
            if Escolhido <> 0 then
              Visualizar_Estado (Memoria.Estado [Escolhido],FALSE) ;
          end ;
    end ;
  end ; { GERENCIA MEMORIA DE ESTADOS }

(********************************************************************)

  Procedure Disparar_Transicoes (Var Estado  : Ap_Estado ;
                                 Var Memoria : Memoria_Estados ;
                                 Var Limiar  : Vetor_Bytes ;
                                 Var Rede    : Tipo_Rede) ;
  Var
    Codigo,
    Transicao   : Byte ;
    Cresceu,
    LiveLock,
    Duplicata   : Boolean ;
    TMin,
    MinDLFT,i   : Integer ;
    Auxiliar,
    Disparaveis : Conj_Bytes ;
    Duplic      : Ap_Estado ;
    DomNovo     : Ap_Dominio ;
    MarcNova,
    Residual    : Vetor_Bytes ;

  begin { REALIZAR DISPAROS DE TRANSICOES }
    repeat
      { calcula minimo DLFT do dominio }
      CalculaMinimoLFT (Estado^.Dominio,MinDLFT) ;

      { determina o conjunto de transicoes disparaveis }
      Disparaveis := [] ;
      DomNovo := Estado^.Dominio ;
      while DomNovo <> NIL do begin
        if DomNovo^.DEFT <= MinDLFT then
          Disparaveis := Disparaveis + [DomNovo^.Transicao] ;
        DomNovo := DomNovo^.Proximo ;
      end ;

      { seleciona transicao a disparar, dentre as disparaveis }
      if Disparaveis = [] then
        Transicao := 0
      else begin
        Auxiliar := [1..255] - Estado^.Disparadas ;
        Seleciona_Nodos (' Firable ',Rede.Nome_Trans,Disparaveis,
                         Auxiliar,Transicao,TRUE,Rede.Num_Trans,
                         Rede.Tam_Trans) ;
      end ;

      { dispara a transicao selecionada }
      if Transicao <> 0 then begin

        { testa se a transicao ja' foi disparada anteriormente }
        if Transicao in Estado^.Disparadas then
          Ch := Resp ('Warning: transition already fired in this state') ;
        Estado^.Disparadas := Estado^.Disparadas + [Transicao] ;

        { calcula o novo estado gerado }
        with Estado^ do begin
          { determinacao do instante de disparo da transicao }
          TMin := -1 ;
          DomNovo := Estado^.Dominio ;
          while TMin = -1 do
            if DomNovo^.Transicao = Transicao then
              TMin := DomNovo^.DEFT
            else
              DomNovo := DomNovo^.Proximo ;
          if TMin = MinDLFT then
            Inst_Disparo := TMin
          else begin
            ValorMinimo  := TMin ;
            ValorMaximo  := MinDLFT ;
            ValorDefault := StI (TMin) ;
            TamBuffer    := 5 ;
            Pergunta ('Firing time [(' + StI (TMin) + '..' +
                      StI (MinDLFT) + ')]: ',Inst_Disparo,TipoInt) ;
          end ;

          Trans_Disp := Transicao ;

          if Registrar then begin
            WrtS ('-> ' + Rede.Nome_Trans [Transicao]^ + ' fire ');
            if Rede.Temporizada then
              WrtS (' at t = ' + StI (Inst_Disparo) + '.') ;
            Nova_Linha ;
          end ;

          CalculaNovaMarcacao (Rede.Pred_Trans [Transicao],NIL,Marcacao,Residual) ;
          CalculaNovaMarcacao (NIL,Rede.Succ_Trans [Transicao],Residual,MarcNova) ;

          { testa crescimento da marcacao no caminho }
          Duplic := Estado ;
          Cresceu := FALSE ;
          while Duplic <> NIL do begin
            if MarcacaoMaior (MarcNova,Duplic^.Marcacao,
                              Limiar,Rede.Num_Lugar) then
              Cresceu := TRUE ;
            Duplic := Duplic^.Anterior ;
          end ;
          if Cresceu then begin
            Ch := Resp ('Warning: tokens growing detected in this state') ;
            if Registrar then
              WrtLnS ('Tokens Growing detected in this state.') ;
          end ;

          CalculaNovoDominio (DomNovo,MarcNova,Rede) ;
          AtualizaIntervalos (Dominio,DomNovo,Residual,
                              Inst_Disparo,Inst_Disparo,Rede) ;
                   
          if DomNovo = NIL then begin
            Ch := Resp ('Warning: deadlock detected in this state') ;
            if Registrar then 
              WrtLnS ('Deadlock detected in this state.') ;
          end ;

          Codigo := CodigoHashing (MarcNova,Rede.Num_Lugar,DomNovo) ;
        end ;

        { testa duplicidade do novo estado com estados do caminho }
        Duplicata := FALSE ;
        Duplic := Estado ;
        while (Duplic <> NIL) AND NOT Duplicata do
          if (Codigo = Duplic^.Hashing) AND MarcacoesIguais
             (MarcNova,Duplic^.Marcacao,Rede.Num_Lugar) AND
             DominiosIguais (DomNovo,Duplic^.Dominio) then
            Duplicata := TRUE
          else
            Duplic := Duplic^.Anterior ;

        if Duplicata then begin
          Ch := Resp ('[Warning]: firing this transition [would] put the net'
                    + '\  back to a previous state, as shown in the firing'
                    + '\  diagram. [The net remains in the current state].'
                    + '\  Going back directly to the indicated state will'
                    + '\  be allowed in a future version... Sorry !') ;
          { apaga lista de dominio do novo estado }
          ApagaArcosDominio (DomNovo)
        end else begin
          { passa a operar no novo estado }
          New (Estado^.Proximo) ;
          Estado^.Proximo^.Anterior := Estado ;
          Estado := Estado^.Proximo ;

          Estado^.Proximo      := NIL ;
          Estado^.Marcacao     := MarcNova ;
          Estado^.Dominio      := DomNovo ;
          Estado^.Pos_Memoria  := 0 ;
          Estado^.Trans_Disp   := 0 ;
          Estado^.Inst_Disparo := 0 ;
          Estado^.Hashing      := Codigo ;
          Estado^.Disparadas   := [] ;
          Estado^.Profundidade := 1 + Estado^.Anterior^.Profundidade ;

          { testa duplicidade com estados memorizados }
          Testa_Duplicidade_Memoria (Estado,Memoria) ;
        end ;

        Atualiza_Diagrama_Disparos (Estado,Duplic^.Profundidade,Duplicata) ;
        Atualiza_Marcacao (Estado^.Marcacao,Disponiveis,Rede) ;

        if Registrar then
          if Duplicata then
            WrtLnS ('New state and state at depth '
                    + StI (Duplic^.Profundidade) + ' are the same.')
          else
            Escreve_Estado (Estado) ;

        { testa possibilidade de live-lock }
        if Duplicata then begin
          LiveLock := TRUE ;
          while (Duplic <> NIL) AND LiveLock do
            if Duplic^.Dominio^.Proximo <> NIL then
              LiveLock := FALSE
            else
              Duplic := Duplic^.Proximo ;
          if LiveLock then begin
            Ch := Resp ('Warning : live-lock detected at this state.') ;
            if Registrar then
              WrtLnS ('Live-lock detected at thsi state.') ;
          end ;
        end ;
      end ;
    until (Transicao = 0) OR Duplicata ;
  end ; { REALIZAR DISPAROS DE TRANSICOES }

(********************************************************************)

  Procedure Gerenciar_Retorno (Var Estado  : Ap_Estado ;
                               Var Memoria : Memoria_Estados ;
                               Var Rede    : Tipo_Rede) ;
  Var
    Sensibs,
    Auxiliar    : Conj_Bytes ;
    Duplicata   : Boolean ;
    Transicao   : Byte ;
    Estado_Novo : Ap_estado ;

  begin { GERENCIAR RETORNO E DISPARO REVERSO }
    if Estado^.Anterior <> NIL then begin
      Estado := Estado^.Anterior ;
      ApagaListaEstados (Estado^.Proximo) ;
      if Registrar then begin
        WrtLnS ('-> Returned firing from ' + Rede.Nome_Trans
                [Estado^.Trans_Disp]^ + '.') ;
        Nova_Linha ;
      end ;
    end else
      if Rede.Temporizada then
        Ch := Resp ('Impossible to return in this state')
      else begin

        { verifica as transicoes sensibilizadas em reverso }
        Sensibs := [] ;
        for Transicao := 1 to Rede.Num_Trans do
          if Sensibilizada (Rede.Succ_Trans [Transicao],Estado^.Marcacao) then
            Sensibs := Sensibs + [Transicao] ;

        if Sensibs = [] then
          Ch := Resp ('No sensibilized transition in review')
        else begin
          { escolhe uma para disparar ao contrario }
          Auxiliar := [] ;
          Seleciona_Nodos (' firable ',Rede.Nome_Trans,Sensibs,Auxiliar,
                           Transicao,TRUE,Rede.Num_Trans,Rede.Tam_Trans) ;

          if Transicao <> 0 then begin
            New (Estado_Novo) ;

            { calcula valores do novo estado }
            CalculaNovaMarcacao (Rede.Succ_Trans [Transicao],
                                 Rede.Pred_Trans [Transicao],
                                 Estado^.Marcacao,
                                 Estado_Novo^.Marcacao) ;
            CalculaNovoDominio (Estado_Novo^.Dominio,
                                Estado_Novo^.Marcacao,Rede) ;
            Estado_Novo^.Hashing := CodigoHashing (Estado_Novo^.Marcacao,
                                     Rede.Num_Lugar,Estado_Novo^.Dominio) ;

            { seta ponteiros e atributos do novo estado }
            Estado_Novo^.Disparadas   := [Transicao] ;
            Estado_Novo^.Trans_Disp   := Transicao ;
            Estado_Novo^.Inst_Disparo := 0 ;
            Estado_Novo^.Anterior     := NIL ;
            Estado_Novo^.Proximo      := NIL ;
            Estado_Novo^.Pos_Memoria  := 0 ;
            Estado_Novo^.Profundidade := Pred (Estado^.Profundidade) ;

            { testa duplicidade com estados memorizados }
            Testa_Duplicidade_Memoria (Estado_Novo,Memoria) ;

            { apaga o estado posterior e passa a operar no novo estado }
            ApagaListaEstados (Estado) ;
            Estado := Estado_Novo ;

            if Registrar then begin
              WrtLnS ('-> Fired on review ' +
                      Rede.Nome_Trans [Transicao]^ + '.') ;
              Nova_Linha ;
              Escreve_Estado (Estado) ;
            end ;
          end ;
        end ;
      end ;
    Atualiza_Diagrama_Disparos (Estado,0,FALSE) ;
    Atualiza_Marcacao (Estado^.Marcacao,Disponiveis,Rede) ;
  end ; { GERENCIAR RETORNO E DISPARO REVERSO }

(********************************************************************)

  Procedure Gerenciar_Registro (Var Estado : Ap_Estado) ;
  Var Escolha : Char ;
      Opcao   : String [3] ;
  begin { GERENCIAR FUNCOES DE REGISTRO DE EVOLUCAO }
    if Registrar then Opcao := 'YES' else Opcao := 'NOT' ;
{E}{V}  Escolha := Resp ('[W]rite ([' + Opcao + '])     [S]ee text') ;

    Case Escolha of
     'W': begin
            Registrar := NOT Registrar ;
            if Registrar then begin
              WrtLnS ('----> Trace on.') ;
              Escreve_Estado (Estado) ;
            end else
              WrtLnS ('----> Trace off.') ;
          end ;
     'S': Edita_Texto (' Simulation Tracing ',
                       Texto_Simu,1,Lin_Texto,8,18,FALSE,Funcao) ;
    end ;
  end ; { GERENCIAR FUNCOES DE REGISTRO DE EVOLUCAO }

(********************************************************************)

  Procedure Visualizar_Estados_da_Lista (Final : Ap_Estado) ;
  Var
    Inicial : Ap_Estado ;
    Profund : Integer ;

  begin { VISUALIZA QUALQUER ESTADO DA LISTA }
    { determina estado inicial }
    Inicial := Final ;
    while (Inicial^.Anterior <> NIL) do
      Inicial := Inicial^.Anterior ;

    { seta parametros da leitura formatada }
    if Inicial = Final then
      Profund := Inicial^.Profundidade
    else begin
      ValorMinimo  := Inicial^.Profundidade ;
      ValorMaximo  := Final^.Profundidade ;
      ValorDefault := StI (Final^.Profundidade) ;
      TamBuffer   := 5 ;
      Profund := Final^.Profundidade ;
      Pergunta ('State depth to see  [('+ StI (Inicial^.Profundidade) +
                '..' + StI (Final^.Profundidade) + ')]: ',Profund,TipoInt) ;
    end ;

    { procura o estado indicado pelo usuario }
    while Final^.Profundidade <> Profund do
      Final := Final^.Anterior ;
    Visualizar_Estado (Final,TRUE) ;
  end ; { VISUALIZA QUALQUER ESTADO DA LISTA }

(********************************************************************)

  Procedure Edita_Estado_Atual (Var Estado : Ap_Estado) ;
  Const
    MsgBloqueio = 'No transition was sensibilized' ;

  Var
    Escolha   : Char ;
    VetTemp   : Vetor_Inteiros ;
    i         : Integer ;
    Atual     : Ap_Dominio ;
    Inicial   : Ap_Estado ;
    Sensibs   : Conj_Bytes ;
    MudouTemp,
    MudouMarc : Boolean ;
    Titulo    : String ;

  begin { EDITA VALORES DO ESTADO ATUAL }
    if Rede.Temporizada then
      Escolha := Resp ('Edit :     [M]arking     D[E]FT     D[L]FT')
    else
      Escolha := 'M' ;

    MudouTemp := FALSE ;
    MudouMarc := FALSE ;
    Case Escolha of
     'M': begin
            ValorMinimo := 0 ;
            ValorMaximo := 254 ;
            TamBuffer   := 3 ;
            for i := 1 to Rede.Num_Lugar do
              VetTemp [i] := Estado^.Marcacao [i] ;
            Leitura_Vetor (' Marking ',Rede.Nome_Lugar,VetTemp,
                           [1..Rede.Num_Lugar],Rede.Num_Lugar,
                           Rede.Tam_Lugar,'W',255,'',0) ;
            for i := 1 to Rede.Num_Lugar do
              if VetTemp [i] <> Estado^.Marcacao [i] then begin
                MudouMarc := TRUE ;
                Estado^.Marcacao [i] := VetTemp [i] ;
              end ;
          end ;

  'E','L': begin
            { verifica transicoes sensibilizadas }
            Atual := Estado^.Dominio ;
            Sensibs := [] ;
            while Atual <> NIL do begin
              Sensibs := Sensibs + [Atual^.Transicao] ;
              if Escolha = 'E' then VetTemp [Atual^.Transicao] := Atual^.DEFT
                               else VetTemp [Atual^.Transicao] := Atual^.DLFT ;
              Atual := Atual^.Proximo ;
            end ;

            if Sensibs = [] then
              Ch := Resp (MsgBloqueio)
            else begin
              ValorMinimo := 0 ;
              ValorMaximo := Tempo_Max ;
              TamBuffer   := 5 ;
              if Escolha = 'E' then Titulo := ' DEFT '
                               else Titulo := ' DLFT ' ;
              Leitura_Vetor (Titulo,Rede.Nome_Trans,VetTemp,Sensibs,
                             Rede.Num_Trans,Rede.Tam_Trans,'',0,'',0) ;

              { transfere valores de volta `a lista dominio }
              Atual   := Estado^.Dominio ;
              while Atual <> NIL do begin
                if Escolha = 'E' then begin
                  if (Atual^.DEFT <> VetTemp [Atual^.Transicao]) then begin
                    Atual^.DEFT := MinI (VetTemp [Atual^.Transicao],Atual^.DLFT) ;
                    MudouTemp := TRUE ;
                  end ;
                end else
                  if (Atual^.DLFT <> VetTemp [Atual^.Transicao]) then begin
                    Atual^.DLFT := MaxI (VetTemp [Atual^.Transicao],Atual^.DEFT) ;
                    MudouTemp := TRUE ;
                  end ;
                Atual := Atual^.Proximo ;
              end ;
            end ;
          end ;
    end ;

    { se modificou atualiza estado }
    if MudouMarc OR MudouTemp then begin

      if Estado^.Anterior <> NIL then begin
        { determina estado inicial da lista de retorno }
        Inicial := Estado ;
        while Inicial^.Anterior <> NIL do
          Inicial := Inicial^.Anterior ;

        { desliga estado atual da lista }
        Estado^.Anterior^.Proximo := NIL ;
        Estado^.Anterior := NIL ;

        ApagaListaEstados (Inicial) ;
      end ;

      { seta valores do estado modificado }
      if MudouMarc then
        CalculaNovoDominio (Estado^.Dominio,Estado^.Marcacao,Rede) ;

      Estado^.Hashing := CodigoHashing (Estado^.Marcacao,
                                        Rede.Num_Lugar,
                                        Estado^.Dominio) ;
      Estado^.Trans_Disp  := 0 ;
      Estado^.Anterior    := NIL;
      Estado^.Proximo     := NIL ;
      Estado^.Pos_Memoria := 0 ;

      Testa_Duplicidade_Memoria (Estado,Memoria) ;
      Atualiza_Diagrama_Disparos (Estado,0,FALSE) ;
      if MudouMarc then
        Atualiza_Marcacao (Estado^.Marcacao,Disponiveis,Rede) ;

      { registra mudanca de estado no texto }
      if Registrar then begin
        WrtS ('Current state after changes in ') ;
        if MudouTemp then WrtLnS ('Timings :')
                     else WrtLnS ('Marking :') ;
        Escreve_Estado (Estado) ;
      end ;

    end ;
  end ; { EDITA VALORES DO ESTADO ATUAL }

(********************************************************************)

begin { SIMULACAO DE REDES NORMAIS E COM TEMPORIZACAO }
  if (Texto_Simu <> NIL) then
    Escolha := Resp ('Want to lose last results ? [(Y/N)]')
  else
    Escolha := 'Y' ;

  if Escolha = 'Y' then begin
    { escreve janelas e menu de simulacao }
    Cria_Janela (' Simulation ',1,1,28,6,Atrib_Forte) ;
    Jan_Menu := Janela_Atual ;
    Msg (' [F]ire       [S]tate');
    Msg ('\ [R]eturn     [T]race');
    Msg ('\ [E]dit       [M]emory');
    Msg ('\ [P]laces     [H]elp     [Q]uit') ;
    Cria_Janela (' Current Track of Simulation ',29,1,52,25,Atrib_Forte) ;
    Jan_Trilha := Janela_Atual ;
    Msg ('     [Reached State           Fired Transition]') ;
    Cria_Janela (' Marking ',1,7,28,19,Atrib_Forte) ;
    Jan_Lugares := Janela_Atual ;
    Vai_Para_Janela (Jan_Menu) ;

    { inicia valores de contagem da memoria de estados }
    Memoria.Numero  := 0 ;
    Memoria.TamNome := 0 ;

    { inicia lugares disponiveis no display }
    MaxLinDisp  := 17 ;
    TamCampo    := Rede.Tam_lugar + 4 ;
    LugsLinha   := 25 DIV TamCampo ;
    while 25 - (LugsLinha * TamCampo) < 2 * (LugsLinha - 1) do
      LugsLinha := Pred (LugsLinha) ;
    Disponiveis := [1.. MinI (Rede.Num_Lugar,LugsLinha * MaxLinDisp)] ;

    { calcula marcacao limiar dos lugares }
    CalculaLimiar (Rede,Limiar) ;

    { determina fator de hashing para a rede em simulacao }
    DeterminaFatorHashing (Rede) ;

    { cria e preenche estado inicial da rede }
    New (Estado) ;
    with Estado^ do begin
      Proximo  := NIL ;
      Anterior := NIL ;
      Marcacao := Rede.Mo ;
      Dominio  := NIL ;
      CalculaNovoDominio (Dominio,Marcacao,Rede) ;
      Pos_Memoria  := 0 ;
      Profundidade := 0 ;
      Trans_Disp   := 0 ;
      Inst_Disparo := 0 ;
      Hashing      := 0 ;
      Disparadas   := [] ;
    end ;
    Estado^.Hashing := CodigoHashing (Estado^.Marcacao,Rede.Num_Lugar,
                                      Estado^.Dominio) ;
    { memoriza estado inicial da rede }
    Memoriza_Estado (Estado,'Inicial State',Memoria) ;

    { inicia valores do registro de evolucao }
    Registrar      := FALSE ;
    Apaga_Texto (Texto_Simu) ;
    Usa_Texto (Texto_Simu) ;
    WrtLnS ('Simulation tracing for net ' + Rede.Nome + '.') ;
    Nova_Linha ;

    Atualiza_Diagrama_Disparos (Estado,0,FALSE) ;
    Atualiza_Marcacao (Estado^.Marcacao,Disponiveis,Rede) ;

    { realiza a simulacao da rede }
    repeat
      Escolha := Tecla (Funcao) ;
      if NOT Funcao then
        Case Escolha of
{??} #13,'F': Disparar_Transicoes (Estado,Memoria,Limiar,Rede) ;
     #08,'R': Gerenciar_Retorno (Estado,Memoria,Rede) ;
         'T': Gerenciar_Registro (Estado) ;
         'M': Gerenciar_Memoria (Memoria,Estado,Rede) ;
         'E': Edita_Estado_Atual (Estado) ;
         'S': Visualizar_Estados_da_Lista (Estado) ;
         'P': Definir_Lugares_Display (Disponiveis,Estado^.Marcacao,Rede) ;
         'H': Tela_Ajuda (Simulacao) ;
         'Q': Traco { fim de simulacao } ;
        else
          Escolha := '*' ;
        end ;
    until (Escolha = 'Q') AND NOT Funcao ;

    { apaga o caminho atual }
    while Estado^.Anterior <> NIL do
      Estado := Estado^.Anterior ;
    ApagaListaEstados (Estado) ;

    { apaga estados memorizados }
    with Memoria do
      while Numero > 0 do begin
        Estado [Numero]^.Pos_Memoria := 0 ;
        ApagaListaEstados (Estado [Numero]) ;
        Dispose (Nome [Numero]) ;
        Numero := Pred (Numero) ;
      end ;

    Apaga_Atual ;
    Apaga_Atual ;
    Apaga_Atual ;
  end ;

  Edita_Texto (' Simulation tracing ',
               Texto_Simu,1,1,8,18,FALSE,Funcao) ;
end ; { SIMULACAO DE REDES NORMAIS E COM TEMPORIZACAO }

end.

(********************************************************************)
