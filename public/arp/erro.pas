(*******************************************************************)

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

{$F+}  { chamadas do tipo FAR, para nao causar erros }

Unit Erro ;

Interface

(*******************************************************************)

Implementation

  Uses Crt,Janelas ;

  Var
    InicioMemoria,ExitSave : Pointer ;

  Procedure ManipulaErro ;
  begin
    ExitProc := ExitSave ;
    if ErrorAddr <> NIL then begin
      Release (InicioMemoria) ;
      Window (1,1,80,25) ;
      Seta_Cores ($03) ;
      GotoXY (1,24) ;
      ClrEOL ;
      GotoXY (1,25) ;
      ClrEOL ;
      Write ('Error: ') ;
      Case ExitCode of
         2: Write ('File not found') ;
         3: Write ('Path not found') ;
         4: Write ('Too many open files') ;
         5: Write ('Files acess denied') ;
         6: Write ('Invalid file handle') ;
        12: Write ('Invalid file acess code') ;
        15: Write ('Invalid drive number') ;
        16: Write ('Cannot remove current directory') ;
        17: Write ('Cannot rename across drives') ;
       100: Write ('Disk read error') ;
       101: Write ('Disk write error') ;
       102: Write ('File not assigned') ;
       103: Write ('File not open') ;
       104: Write ('File not open for input') ;
       105: Write ('File not open for output') ;
       106: Write ('Invalid numeric format') ;
       150: Write ('Disk is write-protected') ;
       151: Write ('Unknown unit') ;
       152: Write ('Drive not ready') ;
       153: Write ('Unknown command') ;
       154: Write ('CRC error in data') ;
       155: Write ('Bad drive request structure length') ;
       156: Write ('Disk seek error') ;
       157: Write ('Unknown media type') ;
       158: Write ('Sector not found') ;
       159: Write ('Printer out of paper') ;
       160: Write ('Device write fault') ;
       161: Write ('Device read fault') ;
       162: Write ('Hardware failure') ;
       200: Write ('Division by zero') ;
       201: Write ('Range check error') ;
       202: Write ('Stack overflow') ;
       203: Write ('Heap overflow') ;
       204: Write ('Invalid pointer operation') ;
       205: Write ('Floating point overflow') ;
       206: Write ('Floating point underflow') ;
       207: Write ('Invalid floating point operation') ;
       208: Write ('Overlay manager not installed') ;
       209: Write ('Overlay file read error') ;
      end ;
      Write (', detected at ',Seg (ErrorAddr),':',Ofs (ErrorAddr)) ;
      Formato_Cursor (1) ;
    end ;
    ErrorAddr := NIL ;
  end ;

(*******************************************************************)

begin
  { iniciacao das variaveis de controle de memoria e erro }
  Mark (InicioMemoria) ;
  ExitSave := ExitProc ;
  ExitProc := Addr (ManipulaErro) ;
end.

(*******************************************************************)
