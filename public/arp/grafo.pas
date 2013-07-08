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

{$O+,F+} { permite a realizacao de overlay }

Unit Grafo ;

Interface
Uses Variavel ;

  { estruturas de dados para o grafo }
  Const
    Max_Marcacao = 2000 ;
    MaximoHash   = 255  ;
    W            = 255  ;

  Type
    { estrutura (topologia) do grafo }
    Ap_Arco_Grafo = ^Arco_Grafo ;
    Arco_Grafo = Record
      TMin,TMax,
      Sucessor  : Integer ;
      Transicao : Byte ;
      Proximo   : Ap_Arco_Grafo ;
    end ;

    { estrutura dos dominios de disparo }
    Ap_Dominio = ^Campo_Dominio ;
    Campo_Dominio = Record
      Transicao : Byte ;
      DEFT,DLFT : Integer ;
      Proximo   : Ap_Dominio ;
    end ;

    { estrutura das marcacoes }
    Ap_Marcacao    = ^Vetor_Bytes ;

    Lista_Marcacao = Array [0..Max_Marcacao] of Ap_Marcacao ;
    Lista_Dominio  = Array [0..Max_Marcacao] of Ap_Dominio ;
    Lista_Grafo    = Array [0..Max_Marcacao] of Ap_Arco_Grafo ;

    VetorIntLongo  = Array [0..Max_Marcacao] of Integer ;
    VetorBoolLongo = Array [0..Max_Marcacao] of Boolean ;

  Var
    SuccEst    : Lista_Grafo ;
    UltimoEst  : Integer ;
    VetorFALSE : VetorBoolLongo ;

  { gerenciamento das estruturas de dados }
  Procedure ApagaArcosGrafo (Var Atual : Ap_Arco_Grafo) ;
  Procedure ApagaListaGrafo (Var SuccEst : Lista_Grafo) ;

  Procedure ApagaArcosDominio (Var Dominio : Ap_Dominio) ;
  Procedure ApagaListaDominio (Var Dominio : Lista_Dominio) ;

  Procedure ApagaListaMarcacao (Var Marcacao : Lista_Marcacao) ;

  { primitivas de geracao do grafo }
  Procedure CalculaLimiar (Var Rede   : Tipo_Rede ;
                           Var Limiar : Vetor_Bytes) ;

  Function Sensibilizada (    Entrada  : Ap_Arco_Rede ;
                          Var Marcacao : Vetor_Bytes) : Boolean ;

  Procedure CalculaMinimoLFT (Dominio : Ap_Dominio ;  Var MinLFT : Integer) ;

  Procedure CalculaNovaMarcacao (    EntrTrans,SaidTrans : Ap_Arco_Rede ;
                                 Var MarcVelha,MarcNova  : Vetor_Bytes) ;

  Procedure CalculaNovoDominio (Var DominioNovo : Ap_Dominio ;
                                Var Marcacao    : Vetor_Bytes ;
                                Var Rede        : Tipo_Rede) ;

  Procedure AtualizaIntervalos (    DominioVelho,
                                    DominioNovo  : Ap_Dominio ;
                                Var MarcResidual : Vetor_Bytes ;
                                    TMin,TMax    : Integer ;
                                Var Rede         : Tipo_Rede) ;

  Procedure DeterminaFatorHashing (Var Rede : Tipo_Rede) ;

  Function CodigoHashing (Var Marcacao : Vetor_Bytes ;
                              Tamanho  : Byte ;
                              Dominio  : Ap_Dominio) : Byte ;

  Function MarcacoesIguais (Var Marc1,Marc2 : Vetor_Bytes ;
                                Tamanho     : Byte) : Boolean ;

  Function DominiosIguais (Dom1,Dom2 : Ap_Dominio) : Boolean ;

  Function MarcacaoMaior (Var MarcNova,MarcVelha,Limiar : Vetor_Bytes ;
                              Tamanho                   : Byte) : Boolean ;

  Procedure TestaCrescimento (Var MarcNova   : Vetor_Bytes ;
                                  DomNovo    : Ap_Dominio ;
                                  Inicio     : Integer ;
                              Var Marcacao   : Lista_Marcacao ;
                              Var Dominio    : Lista_Dominio ;
                              Var Precedente : VetorIntLongo ;
                              Var Limiar     : Vetor_Bytes ;
                              Var Rede       : Tipo_Rede) ;

  Procedure IncluiArco (    Transicao,Origem,
                            Destino,TMin,TMax : Integer ;
                        Var SuccEst           : Lista_Grafo ;
                        Var Precedente        : VetorIntLongo) ;

  { geracao do grafo e testes }
  Procedure GeraGrafo (Var Rede       : Tipo_Rede ;
                       Var MarcInic   : Vetor_Bytes ;
                       Var SuccEst    : Lista_Grafo ;
                       Var UltimoEst  : Integer ;
                       Var Marcacao   : Lista_Marcacao ;
                       Var Dominio    : Lista_Dominio ;
                       Var Precedente : VetorIntLongo ;
                       Var Erro       : Byte) ;

  Procedure TestaLimites (Var Nulos,Binarios,
                              NaoLimitados   : Conj_Bytes ;
                          Var Limitados      : Vetor_Bytes ;
                          Var Marcacao       : Lista_Marcacao ;
                              UltimoEst      : Integer ;
                          Var Rede           : Tipo_Rede) ;

  Procedure TestaVivacidade (Var Vivas,QuaseVivas : Conj_Bytes ;
                             Var SuccEst          : Lista_Grafo ;
                                 UltimoEst        : Integer ;
                             Var Precedente       : VetorIntLongo ;
                             Var Rede             : Tipo_Rede) ;

  Procedure TestaDeadLock (Var SuccEst   : Lista_Grafo ;
                               UltimoEst : Integer ;
                           Var DeadLock  : VetorBoolLongo ;
                           Var NumDeads  : Integer) ;

  Procedure TestaLiveLock (Var SuccEst   : Lista_Grafo ;
                               UltimoEst : Integer ;
                           Var LiveLock  : VetorBoolLongo ;
                           Var NumLives  : Integer) ;

  Procedure TestaReiniciacao (Var SuccEst     : Lista_Grafo ;
                                  UltimoEst   : Integer ;
                              Var Precedente  : VetorIntLongo ;
                              Var Reiniciavel : VetorBoolLongo ;
                              Var NumReinic   : Integer) ;

  Procedure TestaMultiSensib (Var MultiSensibs : Conj_Bytes ;
                              Var Marcacao     : Lista_Marcacao ;
                              Var Dominio      : Lista_Dominio ;
                                  UltimoEst    : Integer ;
                              Var Rede         : Tipo_Rede) ;

  Function TestaConservacao (Var Marcacao  : Lista_Marcacao ;
                                 UltimoEst : Integer ;
                             Var Rede      : Tipo_Rede) : Boolean ;

  { interfaces }
  Procedure EscreveGrafo (Var SuccEst   : Lista_Grafo ;
                              UltimoEst : Integer ;
                          Var Rede      : Tipo_Rede ;
                              Simbolo   : String) ;

  Procedure EscreveDominio (Var Rede: Tipo_Rede ;  Dominio: Ap_Dominio) ;

  Procedure EscreveRoteiro (    Estado     : Integer ;
                            Var SuccEst    : Lista_Grafo ;
                                UltimoEst  : Integer ;
                            Var Precedente : VetorIntLongo ;
                                Rede       : Tipo_Rede) ;

  Procedure LeituraGrafo (Var Rede       : Tipo_Rede ;
                          Var SuccEst    : Lista_Grafo ;
                          Var UltimoEst  : Integer ;
                              Permitidas : Conj_Bytes) ;

(*********************************************************************)

Implementation
Uses Janelas,Interfac,Texto ;

Var
  i            : Integer ;
  FatorHashing : Real ;

(*********************************)

  Procedure ApagaArcosGrafo (Var Atual : Ap_Arco_Grafo) ;
  begin { APAGA UMA LISTA DE ARCOS DO GRAFO }
    if Atual <> NIL then begin
      ApagaArcosGrafo (Atual^.Proximo) ;
      Dispose (Atual) ;
      Atual := NIL ;
    end ;
  end ; { APAGA UMA LISTA DE ARCOS DO GRAFO }

(*********************************)

  Procedure ApagaListaGrafo (Var SuccEst : Lista_Grafo) ;
  Var i : Integer ;
  begin { APAGA TODA A ESTRUTURA DO GRAFO }
    for i := 0 to Max_Marcacao do
      ApagaArcosGrafo (SuccEst [i]) ;
  end ; { APAGA TODA A ESTRUTURA DO GRAFO }

(*********************************)

  Procedure ApagaArcosDominio (Var Dominio : Ap_Dominio) ;
  begin { APAGA UMA LISTA DE DOMINIO }
    if Dominio <> NIL then begin
      ApagaArcosDominio (Dominio^.Proximo) ;
      Dispose (Dominio) ;
      Dominio := NIL ;
    end ;
  end ; { APAGA UMA LISTA DE DOMINIO }

(*********************************)

  Procedure ApagaListaDominio (Var Dominio : Lista_Dominio) ;
  Var i : Integer ;
  begin { APAGA TODA A LISTA DE DOMINIOS }
    for i := 0 to Max_Marcacao do
      ApagaArcosDominio (Dominio [i]) ;
  end ; { APAGA TODA A LISTA DE DOMINIOS }

(*********************************)

  Procedure ApagaListaMarcacao (Var Marcacao : Lista_Marcacao) ;
  Var i : Integer ;
  begin { APAGA A LISTA DE MARCACOES }
    for i := 0 to Max_Marcacao do
      if Marcacao [i] <> NIL then begin
        Dispose (Marcacao [i]) ;
        Marcacao [i] := NIL ;
      end ;
  end ; { APAGA UMA MARCACAO }

(*********************************************************************)

  Procedure CalculaLimiar (Var Rede   : Tipo_Rede ;
                           Var Limiar : Vetor_Bytes) ;
  Var
    Lugar : Byte ;
    Atual : Ap_Arco_Rede ;

  begin { CALCULA MARCACAO LIMIAR DOS LUGARES }
    for Lugar := 1 to Rede.Num_Lugar do begin
      Limiar [Lugar] := 0 ;
      Atual := Rede.Succ_Lugar [Lugar] ;
      while Atual <> NIL do begin
        Limiar [Lugar] := MaxI (Atual^.Peso,Limiar [Lugar]) ;
        Atual := Atual^.Par_Lugar ;
      end ;
    end ;
  end ; { CALCULA O LIMIAR DOS LUGARES DA REDE }

(*********************************)

  Function Sensibilizada (    Entrada  : Ap_Arco_Rede ;
                          Var Marcacao : Vetor_Bytes) : Boolean ;
  begin  { TESTE DE SENSIBILIZACAO DA TRANSICAO }
    while (Entrada <> NIL) AND (Marcacao [Entrada^.Lugar_Ass] >= Entrada^.Peso) do
      Entrada := Entrada^.Par_Trans ;
    Sensibilizada := (Entrada = NIL) ;
  end ;  { TESTE DE SENSIBILIZACAO DA TRANSICAO }

(*********************************)

  Procedure CalculaMinimoLFT (Dominio : Ap_Dominio ;   Var MinLFT : Integer) ;
  begin { CALCULA MINIMO LFT DO DOMINIO }
    if Dominio = NIL then
      MinLFT := 0
    else begin
      MinLFT := MaxInt ; { maximo inteiro disponivel }
      while Dominio <> NIL do begin
        MinLFT := MinI (MinLFT,Dominio^.DLFT) ;
        Dominio := Dominio^.Proximo ;
      end ;
    end ;
  end ; { CALCULA MINIMO LFT DO DOMINIO }

(*********************************)

  Procedure CalculaNovaMarcacao (    EntrTrans,SaidTrans : Ap_Arco_Rede ;
                                 Var MarcVelha,MarcNova  : Vetor_Bytes) ;
  Var
    Lugar : Byte ;

  begin { CALCULA NOVA MARCACAO }
    MarcNova := MarcVelha ;

    { atualiza lugares de entrada da transicao disparada }
    while (EntrTrans <> NIL) do begin
      Lugar := EntrTrans^.Lugar_Ass ;
      if MarcNova [Lugar] <> W then
        MarcNova [Lugar] := MarcNova [Lugar] - EntrTrans^.Peso ;
      EntrTrans := EntrTrans^.Par_Trans ;
    end ;

    { atualiza lugares de saida da transicao disparada }
    while (SaidTrans <> NIL) do begin
      Lugar := SaidTrans^.Lugar_Ass ;
      MarcNova [Lugar] := MinI (W,MarcNova [Lugar] + SaidTrans^.Peso) ;
      SaidTrans := SaidTrans^.Par_Trans ;
    end ;
  end ; { CALCULA NOVA MARCACAO }

(*********************************)

  Procedure CalculaNovoDominio (Var DominioNovo : Ap_Dominio ;
                                Var Marcacao    : Vetor_Bytes ;
                                Var Rede        : Tipo_Rede) ;
  Var
    AtualNovo : Ap_Dominio ;
    Transicao : Byte ;

  begin { GERA O NOVO DOMINIO DE DISPAROS }
    DominioNovo := NIL ;
    AtualNovo   := NIL ;
    for Transicao := 1 to Rede.Num_Trans do
      if Sensibilizada (Rede.Pred_Trans [Transicao],Marcacao) then begin
        if DominioNovo = NIL then begin
          New (DominioNovo) ;
          AtualNovo := DominioNovo ;
        end else begin
          New (AtualNovo^.Proximo) ;
          AtualNovo := AtualNovo^.Proximo ;
        end ;
        AtualNovo^.Transicao := Transicao ;
        AtualNovo^.DEFT      := Rede.SEFT [Transicao] ;
        AtualNovo^.DLFT      := Rede.SLFT [Transicao] ;
        AtualNovo^.Proximo   := NIL ;
      end ;
  end ; { CALCULA NOVO DOMINIO DE DISPARO }

(*********************************)

  Procedure AtualizaIntervalos (    DominioVelho,
                                    DominioNovo  : Ap_Dominio ;
                                Var MarcResidual : Vetor_Bytes ;
                                    TMin,TMax    : Integer ;
                                Var Rede         : Tipo_Rede) ;

  begin { ATUALIZA INTERVALOS DE ACORDO COM INSTANTE DE DISPARO }
    while (DominioNovo <> NIL) AND (DominioVelho <> NIL) do
      if (DominioVelho^.Transicao < DominioNovo^.Transicao) then
        { avanca transicao do dominio velho }
        DominioVelho := DominioVelho^.Proximo
      else
        if (DominioNovo^.Transicao < DominioVelho^.Transicao) then
          { avanca transicao do dominio novo }
          DominioNovo := DominioNovo^.Proximo
        else begin
          if Sensibilizada (Rede.Pred_Trans [DominioNovo^.Transicao],
            MarcResidual) then begin
            { corrige valores do intervalo [DEFT..DLFT] da transicao }
            DominioNovo^.DLFT := DominioVelho^.DLFT - TMin ;
            DominioNovo^.DEFT := MaxI (0,DominioVelho^.DEFT - TMax) ;
          end ;
          DominioNovo  := DominioNovo^.Proximo ;
          DominioVelho := DominioVelho^.Proximo ;
        end ;
  end ; { ATUALIZA INTERVALOS DE ACORDO COM INSTANTE DE DISPARO }

(*********************************)

  Procedure DeterminaFatorHashing (Var Rede : Tipo_Rede) ;
  Var Dimensao : Integer ;
  begin { DETERMINA FATOR UTILIZADO NA FUNCAO DE HASHING }
    {
      Calculo  do  fator  dependente  da  rede  para  o  Hashing  de
      marcacoes. A funcao de hashing abaixo definida foi determinada
      empiricamente.
    }
    Dimensao := Rede.Num_Trans + Rede.Num_Lugar ;
    FatorHashing := Exp (Ln (23417 / Dimensao) / (Dimensao - 1)) ;
  end ; { DETERMINA FATOR UTILIZADO NA FUNCAO DE HASHING }

(*********************************)

  Function CodigoHashing (Var Marcacao : Vetor_Bytes ;
                              Tamanho  : Byte ;
                              Dominio  : Ap_Dominio) : Byte ;
  Var
    i         : Integer ;
    Peso,Soma : Real ;

  begin { CALCULA CODIGO DE HASHING DA MARCACAO }
    Soma := 0 ;
    Peso := 1 ;

    { considera informacoes da marcacao }
    for i := 1 to Tamanho do begin
      Soma := Soma + Marcacao [i] * Peso ;
      Peso := Peso * FatorHashing ;
    end ;

    { considera informacoes do dominio }
    Peso := 1 ;
    while Dominio <> NIL do begin
      with Dominio^ do
        Soma := Soma + Transicao * (DEFT + FatorHashing * DLFT) * Peso ;
      Peso := Peso * FatorHashing ;
      Dominio := Dominio^.Proximo ;
    end ;

    CodigoHashing := Trunc (Soma) MOD Succ (MaximoHash) ;
  end ; { CALCULA CODIGO DE HASHING DA MARCACAO }

(*********************************)

  Function MarcacoesIguais (Var Marc1,Marc2 : Vetor_Bytes ;
                                 Tamanho     : Byte) : Boolean ;
  begin { TESTA SE DUAS MARCACOES SAO IGUAIS }
    while (Tamanho > 0) AND (Marc1 [Tamanho] = Marc2 [Tamanho]) do
      Tamanho := Pred (Tamanho) ;
    MarcacoesIguais := (Tamanho = 0) ;
  end ; { TESTA SE DUAS MARCACOES SAO IGUAIS }

(*********************************)

  Function DominiosIguais (Dom1,Dom2 : Ap_Dominio) : Boolean ;
  Var
    Iguais,Fim : Boolean ;

  begin { VERIFICA SE DOIS DOMINIOS SAO IGUAIS }
    Iguais := TRUE ;
    Fim    := FALSE ;
    while Iguais AND NOT Fim do
      if Dom1 = NIL then
        if Dom2 = NIL then Fim := TRUE
                      else Iguais := FALSE
      else
        if Dom2 = NIL then
          Iguais := FALSE
        else
          if Dom1^.Transicao = Dom2^.Transicao then
            if Dom1^.DEFT = Dom2^.DEFT then
              if Dom1^.DLFT = Dom2^.DLFT then begin
                Dom1 := Dom1^.Proximo ;
                Dom2 := Dom2^.Proximo ;
              end else
                Iguais := FALSE
            else
              Iguais := FALSE
          else
            Iguais := FALSE ;
    DominiosIguais := Iguais ;
  end ; { VERIFICA SE DOIS DOMINIOS SAO IGUAIS }

(*********************************)

  Function MarcacaoMaior (Var MarcNova,MarcVelha,Limiar : Vetor_Bytes ;
                              Tamanho                   : Byte) : Boolean ;
  Var
    Menor,Maior : Boolean ;
    Lugar       : Byte ;

  begin { VERIFICA SE A MARCACAO NOVA E' MAIOR QUE A VELHA }
    MarcacaoMaior := FALSE ;
    Maior := FALSE ;
    Menor := FALSE ;
    Lugar := 1 ;

    { detecta se houve crescimento de fichas }
    While (Lugar <= Tamanho) AND NOT Menor do
      if MarcNova [Lugar] < MarcVelha [Lugar] then
        Menor := TRUE
      else begin
        if MarcNova [Lugar] <> W then
          if MarcNova [Lugar] > MarcVelha [Lugar] then
            if MarcNova [Lugar] > Limiar [Lugar] then
              Maior := TRUE ;
        Lugar := Succ (Lugar) ;
      end ;

    { atribui W aos lugares onde houve crescimento }
    if Maior AND NOT Menor then
      for Lugar := 1 to Tamanho do
        if MarcNova [Lugar] > MarcVelha [Lugar] then
          if MarcNova [Lugar] > Limiar [Lugar] then begin
            MarcNova [Lugar] := W ;
            MarcacaoMaior := TRUE ;
          end ;
  end ; { VERIFICA SE A MARCACAO NOVA E' MAIOR QUE A VELHA }

(*********************************)

  Procedure TestaCrescimento (Var MarcNova   : Vetor_Bytes ;
                                  DomNovo    : Ap_Dominio ;
                                  Inicio     : Integer ;
                              Var Marcacao   : Lista_Marcacao ;
                              Var Dominio    : Lista_Dominio ;
                              Var Precedente : VetorIntLongo ;
                              Var Limiar     : Vetor_Bytes ;
                              Var Rede       : Tipo_Rede) ;
  begin { TESTA CRESCIMENTO DA MARCACAO DADA }
    repeat
      if DominiosIguais (DomNovo,Dominio [Inicio]) then
        if MarcacaoMaior (MarcNova,Marcacao [Inicio]^,
                          Limiar,Rede.Num_Lugar) then ;

      if Inicio = 0 then Inicio := -1
                    else Inicio := Precedente [Inicio] ;
    until (Inicio = -1) ;
  end ; { TESTA CRESCIMENTO DA MARCACAO DADA }

(*********************************)

  Procedure IncluiArco (    Transicao,Origem,
                            Destino,TMin,TMax : Integer ;
                        Var SuccEst           : Lista_Grafo ;
                        Var Precedente        : VetorIntLongo) ;
  Var
    Atual : Ap_Arco_Grafo ;
    Novo  : Boolean ;

  begin { INCLUI ARCO NA ESTRUTURA DO GRAFO }
    Novo := TRUE ;
    Atual := SuccEst [Origem] ;
    if Atual = NIL then begin
      New (SuccEst [Origem]) ;
      Atual := SuccEst [Origem] ;
    end else begin
      while (Atual^.Proximo <> NIL) AND Novo do
        if (Atual^.Transicao = Transicao) AND (Atual^.Sucessor = Destino) then
          Novo := FALSE
        else
          Atual := Atual^.Proximo ;
      if Novo then begin
        New (Atual^.Proximo) ;
        Atual := Atual^.Proximo ;
      end ;
    end ;
    if Novo then begin
      Atual^.TMin      := TMin ;
      Atual^.TMax      := TMax ;
      Atual^.Sucessor  := Destino ;
      Atual^.Transicao := Transicao ;
      Atual^.Proximo   := NIL ;

      if Precedente [Destino] = -1 then
        Precedente [Destino] := Origem ;
    end ;
  end ; { INCLUI ARCO NA ESTRUTURA DO GRAFO }

(*********************************************************************)

  Procedure GeraGrafo (Var Rede       : Tipo_Rede ;
                       Var MarcInic   : Vetor_Bytes ;
                       Var SuccEst    : Lista_Grafo ;
                       Var UltimoEst  : Integer ;
                       Var Marcacao   : Lista_Marcacao ;
                       Var Dominio    : Lista_Dominio ;
                       Var Precedente : VetorIntLongo ;
                       Var Erro       : Byte) ;
  Var
    ProximoHash : VetorIntLongo ;
    InicioHash  : Array [0..MaximoHash] of Integer ;
    Residuo,
    Limiar      : Vetor_Bytes ;
    UltimoHash,
    i,Codigo    : Integer ;
    MarcNova    : Vetor_Bytes ;
    DominioNovo : Ap_Dominio ;
    Unica       : Boolean ;

(*********************************)

    Procedure TestaEstado (Estado : Integer) ;
    Var
      Trans  : Byte ;

    begin {GERA RECURSIVAMENTE O GRAFO DE ACESSIBILIDADE }
      Write (#13,UltimoEst:5) ;
      if Pressiona_ESC then Erro := 1 ;

      Trans := 1 ;
      while (Trans <= Rede.Num_Trans) AND (Erro = 0) do begin
        if Sensibilizada (Rede.Pred_Trans [Trans],Marcacao [Estado]^) then begin

          { calcula novo estado }
          CalculaNovaMarcacao (Rede.Pred_Trans [Trans],
                               Rede.Succ_Trans [Trans],
                               Marcacao [Estado]^,MarcNova) ;

          { testa crescimento de sua marcacao }
          TestaCrescimento (MarcNova,NIL,Estado,Marcacao,
                            Dominio,Precedente,Limiar,Rede) ;

          Codigo := CodigoHashing (MarcNova,Rede.Num_Lugar,NIL) ;

          { testa duplicidade do estado }
          Unica := TRUE ;
          i := InicioHash [Codigo] ;
          UltimoHash := -1 ;
          while Unica AND (i <> -1) do
            if MarcacoesIguais (MarcNova,Marcacao [i]^,Rede.Num_Lugar) then
              Unica := FALSE
            else begin
              UltimoHash := i ;
              i := ProximoHash [i] ;
            end ;
          if Unica then
            i := Succ (UltimoEst) ;

          IncluiArco (Trans,Estado,i,0,0,SuccEst,Precedente) ;

          if Unica then
            if UltimoEst = Max_Marcacao then
              Erro := 2
            else begin
              { guarda novo estado gerado }
              UltimoEst := Succ (UltimoEst) ;
              New (Marcacao [UltimoEst]) ;
              Marcacao [UltimoEst]^ := MarcNova ;

              { organiza hashing do novo estado }
              if UltimoHash = -1 then
                InicioHash [Codigo] := UltimoEst
              else
                ProximoHash [UltimoHash] := UltimoEst ;

              { testa novo estado gerado }
              TestaEstado (UltimoEst) ;
            end ;
        end ;
        Trans := Succ (Trans) ;
      end ;
    end ; {GERA RECURSIVAMENTE O GRAFO DE ACESSIBILIDADE }

(*********************************)

    Procedure TestaEstadoTemporizado (Estado : Integer) ;
    Var
      Atual_Disp : Ap_Dominio ;
      MinLFT     : Integer ;

    begin {GERA RECURSIVAMENTE O GRAFO COM TEMPORIZACAO }
      Write (#13,UltimoEst:5) ;
      if Pressiona_ESC then Erro := 1 ;


      { calcula menor tempo maximo para disparo }
      CalculaMinimoLFT (Dominio [Estado],MinLFT) ;

      Atual_Disp := Dominio [Estado] ;
      while (Atual_Disp <> NIL) AND (Erro = 0) do begin
        { se atransicao for disparavel }
        if (Atual_Disp^.DEFT <= MinLFT) then begin

          { calcula novo estado }
          CalculaNovaMarcacao (Rede.Pred_Trans [Atual_Disp^.Transicao],
                               NIL,Marcacao [Estado]^,Residuo) ;
          CalculaNovaMarcacao (NIL,Rede.Succ_Trans [Atual_Disp^.Transicao],
                               Residuo,MarcNova) ;
          DominioNovo := NIL ;
          CalculaNovoDominio (DominioNovo,MarcNova,Rede) ;
          AtualizaIntervalos (Dominio [Estado],DominioNovo,Residuo,
                              Atual_Disp^.DEFT,MinLFT,Rede) ;

          { testa crescimento de sua marcacao }
          TestaCrescimento (MarcNova,DominioNovo,Estado,Marcacao,
                            Dominio,Precedente,Limiar,Rede) ;

          Codigo := CodigoHashing (MarcNova,Rede.Num_Lugar,DominioNovo) ;

          { testa duplicidade do estado }
          Unica := TRUE ;
          i := InicioHash [Codigo] ;
          UltimoHash := -1 ;
          while Unica AND (i <> -1) do
            if MarcacoesIguais (MarcNova,Marcacao [i]^,Rede.Num_Lugar) AND
               DominiosIguais  (DominioNovo,Dominio [i]) then
              Unica := FALSE
            else begin
              UltimoHash := i ;
              i := ProximoHash [i] ;
            end ;
          if Unica then
            i := Succ (UltimoEst) ;

          IncluiArco (Atual_Disp^.Transicao,Estado,i,Atual_Disp^.DEFT,
                      MinLFT,SuccEst,Precedente) ;

          if Unica then
            if UltimoEst = Max_Marcacao then begin
              Erro := 2 ;
              ApagaArcosDominio (DominioNovo) ;
            end else begin
              { guarda novo estado gerado }
              UltimoEst := Succ (UltimoEst) ;
              New (Marcacao [UltimoEst]) ;
              Marcacao [UltimoEst]^ := MarcNova ;
              Dominio  [UltimoEst]  := DominioNovo ;

              { organiza hashing do novo estado }
              if UltimoHash = -1 then
                InicioHash [Codigo] := UltimoEst
              else
                ProximoHash [UltimoHash] := UltimoEst ;

              { testa novo estado gerado }
              TestaEstadoTemporizado (UltimoEst) ;
            end
          else
            ApagaArcosDominio (DominioNovo) ;
        end ;
        Atual_Disp := Atual_Disp^.Proximo ;
      end ;
    end ; {GERA RECURSIVAMENTE O GRAFO COM TEMPORIZACAO }

(*********************************)

  begin { GERA O GRAFO DE ACESSIBILIDADE DA REDE }
    Aviso ('[   0] Reachable States') ;
    { iniciacao das variaveis }
    UltimoEst := 0 ;
    Erro := 0 ;
    for i := 0 to Max_Marcacao do begin
      SuccEst     [i] := NIL ;
      Marcacao    [i] := NIL ;
      Dominio     [i] := NIL ;
      Precedente  [i] := -1 ;
      ProximoHash [i] := -1 ;
    end ;
    for i := 0 to 255 do
      InicioHash [i] := -1 ;

    { calculo do limiar dos lugares da rede }
    CalculaLimiar (Rede,Limiar) ;

    DeterminaFatorHashing (Rede) ;

    { montagem da marcacao inicial do grafo }
    New (Marcacao [0]) ;
    Marcacao [0]^ := MarcInic ;
    if Rede.Temporizada then
      CalculaNovoDominio (Dominio [0],Marcacao [0]^,Rede) ;
    InicioHash [CodigoHashing (Marcacao [0]^,Rede.Num_Lugar,Dominio [0])] := 0 ;

    { gera recursivamente o grafo }
    if Rede.Temporizada then TestaEstadoTemporizado (0)
                        else TestaEstado (0) ;
    Apaga_Atual ;
  end ; { GERA O GRAFO DE ACESSIBILIDADE DA REDE }

(*********************************************************************)

  Procedure TestaLimites (Var Nulos,Binarios,
                              NaoLimitados   : Conj_Bytes ;
                          Var Limitados      : Vetor_Bytes ;
                          Var Marcacao       : Lista_Marcacao ;
                              UltimoEst      : Integer ;
                          Var Rede           : Tipo_Rede) ;
  Var
    i,j : Integer ;

  begin { TESTA O LIMITE DE CADA LUGAR }

    { identifica limite de cada lugar }
    for j := 1 to Rede.Num_Lugar do
      Limitados [j] := 0 ;
    for i := 0 to UltimoEst do
      for j := 1 to Rede.Num_Lugar do
        Limitados [j] := MaxI (Limitados [j],Marcacao [i]^[j]) ;

    { classifica os lugares por seus limites }
    Nulos := [] ;
    Binarios := [] ;
    NaoLimitados := [] ;
    for j := 1 to Rede.Num_Lugar do
      Case Limitados [j] of
        0: begin
             Nulos := Nulos + [j] ;
             Limitados [j] := 0 ;
           end ;
        1: begin
             Binarios := Binarios + [j] ;
             Limitados [j] := 0 ;
           end ;
        W: begin
             NaoLimitados := NaoLimitados + [j] ;
             Limitados [j] := 0 ;
           end ;
      end ;
  end ; { TESTA O LIMITE DE CADA LUGAR }

(*********************************)

  Procedure TestaVivacidade (Var Vivas,QuaseVivas : Conj_Bytes ;
                             Var SuccEst          : Lista_Grafo ;
                                 UltimoEst        : Integer ;
                             Var Precedente       : VetorIntLongo ;
                             Var Rede             : Tipo_Rede) ;
  Var
    i,j        : Integer ;
    Disparadas : Conj_Bytes ;
    Percorreu,
    EstadoVivo : VetorBoolLongo ;

    Procedure VerificaDisparadas (    Estado     : Integer ;
                                  Var Disparadas : Conj_Bytes) ;
    Var
      Atual : Ap_Arco_Grafo ;
    begin { VERIFICA TRANSICOES DISPARADAS PELA MARCACAO }
      if NOT Percorreu [Estado] then begin
        Percorreu [Estado] := TRUE ;
        { verifica transicoes disparadas }
        Atual := SuccEst [Estado] ;
        While Atual <> NIL do begin
          Disparadas := Disparadas + [Atual^.Transicao] ;
          Atual := Atual^.Proximo ;
        end ;
        { testa os sucessores do estado }
        Atual := SuccEst [Estado] ;
        While (Atual <> NIL) AND (Disparadas <> [1..Rede.Num_Trans]) do begin
          VerificaDisparadas (Atual^.Sucessor,Disparadas) ;
          Atual := Atual^.Proximo ;
        end ;
      end ;
    end ; { VERIFICA TRANSICOES DISPARADAS PELA MARCACAO }

  begin { TESTA A VIVACIDADE DAS TRANSICOES }
    Vivas := [1..Rede.Num_Trans] ;
    QuaseVivas := [] ;
    EstadoVivo := VetorFALSE ;
    for i := UltimoEst DownTo 0 do
      if NOT EstadoVivo [i] then begin
        Percorreu  := VetorFALSE ;
        Disparadas := [] ;
        VerificaDisparadas (i,Disparadas) ;
        Vivas := Vivas - ([1..Rede.Num_Trans] - Disparadas) ;
        QuaseVivas := QuaseVivas + Disparadas ;
        if Disparadas = [1..Rede.Num_Trans] then begin
          j := i ;
          while (j >= 0) AND (NOT EstadoVivo [j]) do begin
            EstadoVivo [j] := TRUE ;
            j := Precedente [j] ;
          end ;
        end ;
      end ;
  end ; { TESTA A VIVACIDADE DAS TRANSICOES }

(*********************************)

  Procedure TestaDeadLock (Var SuccEst   : Lista_Grafo ;
                               UltimoEst : Integer ;
                           Var DeadLock  : VetorBoolLongo ;
                           Var NumDeads  : Integer) ;
  Var i : Integer ;
  begin { TESTA A OCORRENCIA DE BLOQUEIOS MORTAIS }
    NumDeads := 0 ;
    for i := 0 to UltimoEst do begin
      DeadLock [i] := (SuccEst [i] = NIL) ;
      if DeadLock [i] then
        NumDeads := Succ (NumDeads) ;
    end ;
  end ; { TESTA A OCORRENCIA DE BLOQUEIOS MORTAIS }

(*********************************)

  Procedure TestaLiveLock (Var SuccEst   : Lista_Grafo ;
                               UltimoEst : Integer ;
                           Var LiveLock  : VetorBoolLongo ;
                           Var NumLives  : Integer) ;
  Var
    Rastro,
    Percorreu    : VetorBoolLongo ;
    i            : Integer ;
    ExisteRastro : Boolean ;

    Procedure ProcuraLiveLock (Estado : Integer) ;
    Var
      Atual : Ap_Arco_Grafo ;
      i     : Integer ;

    begin { PROCURA LIVE-LOCKS A PARTIR DO ESTADO DADO }
      if Percorreu [Estado] then begin
        if ExisteRastro then begin
          { registra live lock }
          if Rastro [Estado] then begin
            LiveLock [Estado] := TRUE ;
            NumLives := Succ (NumLives) ;
          end ;
          { limpa rastros de live-lock }
          Rastro := VetorFALSE ;
          ExisteRastro := FALSE ;
        end ;
      end else begin
        Percorreu [Estado] := TRUE ;
        if (SuccEst [Estado] <> NIL) AND (SuccEst [Estado]^.Proximo = NIL) then begin
          { marca rastro de live-lock }
          Rastro [Estado] := TRUE ;
          ExisteRastro := TRUE ;
        end else
          if ExisteRastro then begin
            { limpa rastros de live-lock }
            Rastro := VetorFALSE ;
            ExisteRastro := FALSE ;
          end ;

        { vai para os sucessores do estado que nao pertencem a live-locks }
        Atual := SuccEst [Estado] ;
        while Atual <> NIL do begin
          if NOT LiveLock [Atual^.Sucessor] then
            ProcuraLiveLock (Atual^.Sucessor) ;
          Atual := Atual^.Proximo ;
        end ;
      end ;
    end ; { PROCURA LIVE-LOCKS A PARTIR DO ESTADO DADO }

  begin { TESTA A OCORRENCIA DE BLOQUEIOS VIVOS }
    NumLives := 0 ;
    Percorreu := VetorFALSE ;
    LiveLock  := VetorFALSE ;
    Rastro    := VetorFALSE ;
    ExisteRastro := FALSE ;
    ProcuraLiveLock (0) ;
  end ; { TESTA A OCORRENCIA DE BLOQUEIOS VIVOS }

(*********************************)

  Procedure TestaReiniciacao (Var SuccEst     : Lista_Grafo ;
                                  UltimoEst   : Integer ;
                              Var Precedente  : VetorIntLongo ;
                              Var Reiniciavel : VetorBoolLongo ;
                              Var NumReinic   : Integer) ;
  Var
    Percorreu : VetorBoolLongo ;
    i,j       : Integer ;

    Function AlcancaOrigem (Estado : Integer) : Boolean ;
    Var
      Atual : Ap_Arco_Grafo ;
    begin { TESTA SE ESTADO ALCANCA A ORIGEM }
      if Reiniciavel [Estado] then
        AlcancaOrigem := TRUE
      else
        if Percorreu [Estado] then
          AlcancaOrigem := FALSE
        else begin
          Percorreu [Estado] := TRUE ;
          Atual := SuccEst [Estado] ;
          while (Atual <> NIL) AND (Atual^.Sucessor <> 0) AND
                 NOT AlcancaOrigem (Atual^.Sucessor) do
            Atual := Atual^.Proximo ;
          AlcancaOrigem := (Atual <> NIL) ;
        end ;
    end ; { TESTA SE ESTADO ALCANCA A ORIGEM }

  begin { TESTA A REINICIACAO DAS MARCACOES }
    Reiniciavel := VetorFALSE ;
    for i := UltimoEst DownTo 0 do
      if NOT Reiniciavel [i] then begin
        Percorreu := VetorFALSE ;
        if AlcancaOrigem (i) then begin
          j := i ;
          while (j >= 0) AND (NOT Reiniciavel [j]) do begin
            Reiniciavel [j] := TRUE ;
            j := Precedente [j] ;
          end ;
        end ;
      end ;

    { conta numero de reiniciaveis }
    NumReinic := 0 ;
    for i := 0 to UltimoEst do
      if Reiniciavel [i] then
        NumReinic := Succ (NumReinic) ;
  end ; { TESTA A REINICIACAO DAS MARCACOES }

(*********************************)

  Procedure TestaMultiSensib (Var MultiSensibs : Conj_Bytes ;
                              Var Marcacao     : Lista_Marcacao ;
                              Var Dominio      : Lista_Dominio ;
                                  UltimoEst    : Integer ;
                              Var Rede         : Tipo_Rede) ;
  Var
    Estado        : Integer ;
    AtualDominio  : Ap_Dominio ;
    AtualTrans    : Ap_Arco_Rede ;
    MultiSensivel : Boolean ;
    Marc          : Vetor_Bytes ;
    Lugar         : Byte ;

  begin { TESTA AS TRANSICOES MULTISENSIBILIZADAS }
    MultiSensibs := [] ;
    for Estado := 0 to UltimoEst do begin
      Marc := Marcacao [Estado]^ ;

      AtualDominio := Dominio [Estado] ;
      while AtualDominio <> NIL do begin

        with AtualDominio^ do
          if NOT (Transicao in MultiSensibs) then begin

            { testa multisensibilizacao da transicao }
            MultiSensivel := TRUE ;
            AtualTrans := Rede.Pred_Trans [Transicao] ;
            while (AtualTrans <> NIL) AND MultiSensivel do begin
              Lugar := AtualTrans^.Lugar_Ass ;
              if (Marc [Lugar] <> W) then
                if (Marc [Lugar] < 2 * AtualTrans^.Peso) then
                  MultiSensivel := FALSE ;
              AtualTrans := AtualTrans^.Par_Trans ;
            end ;

            { guarda resultado obtido }
            if MultiSensivel then
              MultiSensibs := MultiSensibs + [Transicao] ;
          end ;

        AtualDominio := AtualDominio^.Proximo ;
      end ;
    end ;
  end ; { TESTA AS TRANSICOES MULTISENSIBILIZADAS }

(*********************************)

  Function  TestaConservacao (Var Marcacao  : Lista_Marcacao ;
                                  UltimoEst : Integer ;
                              Var Rede      : Tipo_Rede) : Boolean ;
  Var
    i,Soma1,
    j,Soma2 : Integer ;
    Conserv : Boolean ;

  begin { TESTA SE A REDE E' CONSERVATIVA }
    Conserv := TRUE ;
    Soma1 := 0 ;
    for j := 1 to Rede.Num_Lugar do
      Soma1 := Soma1 + Marcacao [0]^[j] ;
    i := 1 ;
    while (i <= UltimoEst) AND Conserv do begin
      Soma2 := 0 ;
      for j := 1 to Rede.Num_Lugar do
        Soma2 := Soma2 + Marcacao [i]^[j] ;
      Conserv := (Soma2 = Soma1) ;
      i := Succ (i) ;
    end ;
    TestaConservacao := Conserv ;
  end ; { TESTA SE A REDE E' CONSERVATIVA }

(*********************************************************************)

  Procedure EscreveGrafo (Var SuccEst   : Lista_Grafo ;
                              UltimoEst : Integer ;
                          Var Rede      : Tipo_Rede ;
                              Simbolo   : String) ;
  Var
    Est   : Integer ;
    Atual : Ap_Arco_Grafo ;

  begin { ESCREVE O GRAFO NO TEXTO CORRENTE }
    for Est := 0 to UltimoEst do begin
      WrtS (Simbolo + StI (Est)) ;
      Posic (6) ;
      WrtS (':') ;
      Tab_Inic (Col_Texto) ;
      Atual := SuccEst [Est] ;
      While Atual <> NIL do begin
        with Atual^ do
          if (TMax = 0) then
            WrtS ('(' + Rede.Nome_Trans [Transicao]^ +
                  ': ' + Simbolo + StI (Sucessor) + ') ')
          else
            if TMin = TMax then
              WrtS ('(' + Rede.Nome_Trans [Transicao]^ + '[' + StI (TMax) +
                    ']: ' + Simbolo + StI (Sucessor) + ') ')
            else
              WrtS ('(' + Rede.Nome_Trans [Transicao]^ + '[' + StI (TMin) + ','
                    + StI (TMax) + ']: ' + Simbolo + StI (Sucessor) + ') ') ;
        Atual := Atual^.Proximo ;
      end ;
      Nova_Linha ;
    end ;
  end ; { ESCREVE O GRAFO NO TEXTO CORRENTE }

(*********************************)

  Procedure EscreveDominio (Var Rede: Tipo_Rede ;  Dominio: Ap_Dominio) ;
  begin { ESCREVE O DOMINIO ATUAL NO TEXTO CORRENTE }
    Wrts ('{') ;
    if Dominio <> NIL then begin
      Tab_Inic (Col_Texto) ;
      while Dominio <> NIL do begin
        with Dominio^ do
          if (DLFT = 0) then
            WrtS (Rede.Nome_Trans [Transicao]^ + ', ')
          else
            if DEFT = DLFT then
              WrtS (Rede.Nome_Trans [Transicao]^ + '[' + StI (DLFT) + '], ')
            else
              WrtS (Rede.Nome_Trans [Transicao]^ + '[' + StI (DEFT) + ','
                    + StI (DLFT) + '], ') ;
        Dominio := Dominio^.Proximo ;
      end ;
      Posic (Col_Texto - 2) ;
    end ;
    WrtLnS('}') ;
  end ; { ESCREVE O DOMINIO ATUAL NO TEXTO CORRENTE }

(*********************************)

  Procedure EscreveRoteiro (    Estado     : Integer ;
                            Var SuccEst    : Lista_Grafo ;
                                UltimoEst  : Integer ;
                            Var Precedente : VetorIntLongo ;
                                Rede       : Tipo_Rede) ;
  Var
    Pilha : VetorIntLongo ;
    Topo  : Integer ;
    Atual : Ap_Arco_Grafo ;

  begin { ESCREVE OS DISPAROS DE TRANSICAO DO ESTADO 0 AO ATUAL }
    { monta a pilha de estados a percorrer }
    Topo := 0 ;
    repeat
      Topo := Succ (Topo) ;
      Pilha [Topo] := Estado ;
      Estado := Precedente [Estado] ;
    until Pilha [Topo] = 0 ;

    { percorre a pilha escrevendo os disparos de transicoes }
    Tab_Inic (Col_Texto) ;
    while Topo > 1 do begin
      Atual := SuccEst [Pilha [Topo]] ;
      Topo := Pred (Topo) ;
      while Atual^.Sucessor <> Pilha [Topo] do
        Atual := Atual^.Proximo ;
      WrtS (Rede.Nome_Trans [Atual^.Transicao]^ + ' ') ;
    end ;
    Nova_Linha ;
  end ; { ESCREVE OS DISPAROS DE TRANSICAO DO ESTADO 0 AO ATUAL }

(*********************************)

  Procedure LeituraGrafo (Var Rede       : Tipo_Rede ;
                          Var SuccEst    : Lista_Grafo ;
                          Var UltimoEst  : Integer ;
                              Permitidas : Conj_Bytes) ;
  Var
    NovoUltimo,i,
    EstadoAtual   : Integer ;
    AtualSucessor : Ap_Arco_Grafo ;
    Precedente    : VetorIntLongo ;
    VetorSucc     : Vetor_Inteiros ;

  begin { LEITURA DE UM GRAFO DO USUARIO }
    if Permitidas <> [] then begin
      EstadoAtual := 0 ;
      NovoUltimo  := 0 ;
      for i := 0 to Max_Marcacao do
        Precedente [i] := -1 ;
      While EstadoAtual <= UltimoEst do begin

        { monta vetor de sucessores do estado atual }
        for i := 1 to Rede.Num_Trans do
          VetorSucc [i] := -1 ;
        AtualSucessor := SuccEst [EstadoAtual] ;
        While (AtualSucessor <> NIL) do begin
          if (AtualSucessor^.Transicao in Permitidas) then
            VetorSucc [AtualSucessor^.Transicao] := AtualSucessor^.Sucessor ;
          AtualSucessor := AtualSucessor^.Proximo ;
        end ;

        { expoe ao usuario o vetor de sucessores do estado atual }
        ValorMinimo := 0 ;
        ValorMaximo := Max_Marcacao ;
        TamBuffer   := 4 ;
        Leitura_Vetor (' E' + StI (EstadoAtual) + ' ',Rede.Nome_Trans,VetorSucc,
                        Permitidas,Rede.Num_Trans,Rede.Tam_Trans,'',-1,'',-1) ;

        { reconstroi a lista de sucessores do estado atual }
        ApagaArcosGrafo (SuccEst [EstadoAtual]) ;
        for i := 1 to Rede.Num_Trans do
          if (VetorSucc [i] <> -1) then begin
            UltimoEst  := MaxI (UltimoEst,VetorSucc [i]) ;
            NovoUltimo := MaxI (NovoUltimo,VetorSucc [i]) ;
            IncluiArco (i,EstadoAtual,VetorSucc [i],0,0,SuccEst,Precedente) ;
          end ;

        EstadoAtual := Succ (EstadoAtual) ;
      end ;

      { reavaliacao do numero de estados do grafo do usuario }
      UltimoEst := NovoUltimo ;
    end ;
  end ; { FAZ A LEITURA DE UM GRAFO DO USUARIO }

(*********************************)

begin
  for i := 0 to Max_Marcacao do begin
    SuccEst [i] := NIL ;
    VetorFALSE [i] := FALSE ;
  end ;
  UltimoEst := 0 ;
end.

(*********************************************************************)
