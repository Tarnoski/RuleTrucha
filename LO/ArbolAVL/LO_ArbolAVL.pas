unit LO_ArbolAVL;

interface

uses
  SysUtils;

const
  _POSNULA = -1;
  _CLAVENULA = '';

type
  TipoPos = LongInt;
  TipoClave = string[8];
  TipoBalance = Integer;
  TipoAVLDatos =  record
                    Clave:TipoClave;
                    Padre:TipoPos;
                    HijoIzq:TipoPos;
                    HijoDer:TipoPos;
                    Balance:TipoBalance;
                    InfoPos:TipoPos;
                  end;

  TipoAVLArchD = File of TipoAVLDatos;
  TipoAVLControl =  record
                      Raiz:TipoPos;
                      Borrados:TipoPos;
                    end;
  TipoAVLArchC = File of TipoAVLControl;
  TipoAVL = record
                D:TipoAVLArchD;
                C:TipoAVLArchC;
              end;
    Procedure CrearAVL(var ME:TipoAVL; Nombre,Ruta:string);
    Procedure DestruirAVL(var ME:TipoAVL);
    Procedure AbrirAVL(var ME:TipoAVL);
    Procedure CerrarAVL(var ME:TipoAVL);

    Function  PrimeroAVL(var ME:TipoAVL):TipoPos;
    Function  UltimoAVL(var ME:TipoAVL):TipoPos;
    Function  AnteriorAVL(var ME:TipoAVL; pos:TipoPos):TipoPos;
    Function  ProximoAVL(var ME:TipoAVL; pos:TipoPos):TipoPos;

    Function  BuscarAVL(var ME:TipoAVL; Clave:TipoClave; var pos:TipoPos):boolean;
    Procedure InsertarAVL(var ME:TipoAVL; Reg:TipoAVLDatos; pos:TipoPos);
    Procedure EliminarAVL(var ME:TipoAVL; pos:TipoPos);
    Procedure CapturarAVL(var ME:TipoAVL; pos:TipoPos; var Reg:TipoAVLDatos);
    Procedure ModificarAVL(var ME:TipoAVL; pos:TipoPos; Reg:TipoAVLDatos);

    Function  RaizAVL(var ME:TipoAVL):TipoPos;
    Function  PadreAVL(var ME:TipoAVL; pos:TipoPos):TipoPos;
    Function  HijoIzquierdoAVL(var ME:TipoAVL; pos:TipoPos):TipoPos;
    Function  HijoDerechoAVL(var ME:TipoAVL; pos:TipoPos):TipoPos;

    Function PosicionNulaAVL(var ME:TipoAVL):TipoPos;
    Function ClaveNulaAVL(var ME:TipoAVL):TipoClave;
    Function ArbolAVLVacio(var ME:TipoAVL):boolean;

implementation


  Procedure CrearAVL(var ME:TipoAVL; Nombre,Ruta:string);
  var
    RC:TipoAVLControl;
    bControlOK,bControlDatos:boolean;

  begin
    Assign(Me.C,Ruta + Nombre + '.con');
    Assign(ME.D,Ruta + Nombre + '.dat');
    {$I-} {Directiva de Compilacion: debilita el control de errores de delphi
    En caso de error, no cierra la aplicacion}
    Reset(ME.C);
    bControlOK := (IOResult = 0);
    Reset(ME.D);
    bControlDatos := (IOResult = 0);
    if (not(bControlOK)) and (not(bControlDatos))
    then begin
      Rewrite(ME.C);
      RC.Raiz:=_POSNULA;
      RC.Borrados:=_POSNULA;
      seek(ME.C,0);
      Write(ME.C,RC);
      Rewrite(ME.D);
      Close(ME.C);
      Close(ME.D);
    end;
  end;

{------------------------------------------------------------------------------}

  Procedure DestruirAVL(var ME:TipoAVL);
  begin
    Erase(ME.C);
    Erase(ME.D);
  end;

{------------------------------------------------------------------------------}

  Procedure AbrirAVL(var ME:TipoAVL);
  begin
    Reset(ME.C);
    Reset(ME.D);
  end;

{------------------------------------------------------------------------------}

  Procedure CerrarAVL(var ME:TipoAVL);
  begin
    Close(ME.C);
    Close(ME.D);
  end;

{------------------------------------------------------------------------------}

  Procedure RotacionDerecha(var ME:TipoAVL; pos:TipoPos);
  var
    posP:TipoPos;
    RC:TipoAVLControl;
    Reg,RegP,RegAb,RegAux:TipoAVLDatos;

  begin
    seek(ME.C,0);
    read(ME.C,RC);

    seek(ME.D,pos);
    read(ME.D,RegP); //Padre: Balance -1 o 0.

    seek(ME.D,RegP.HijoIzq);
    read(ME.D,Reg); //Registro insertado.

    seek(ME.D,RegP.Padre);
    read(ME.D,RegAb); //Abuelo: Balance -2.
    posP:=RegAb.Padre; //Se almacena la posicion del bisabuelo, si lo hubiese.

    if RegP.Padre = RC.Raiz //Si el abuelo es la raiz del arbol, este puesto sera sedido al padre.
    then begin
      RC.Raiz:=pos;
      seek(ME.C,0);
      write(ME.C,RC);
    end
    //Sino, el bisabuelo recibira como hijo al padre.
    else begin
      seek(ME.D,posP);
      read(ME.D,RegAux);
      if RegAux.HijoIzq = RegP.Padre //¿Cual hijo del bisabuelo es el abuelo?
      then RegAux.HijoIzq:=pos    //Si el abuelo es el hijo izquierdo.
      else RegAux.HijoDer:=pos;   //Si el abuelo es el hijo derecho.
      seek(ME.D,posP);
      write(ME.D,RegAux);
    end;

    if RegP.HijoDer <> _POSNULA
    {Si el padre tiene descendencia izquierda,
    esta pasara a ser descendencia derecha del abuelo.}
    then begin
      seek(ME.D,RegP.HijoDer);
      read(ME.D,RegAux);
      RegAux.Padre:=RegP.Padre;
      seek(ME.D,RegP.HijoDer);
      write(ME.D,RegAux);
    end;
    RegAb.HijoIzq:=RegP.HijoDer;

    RegP.HijoDer:=RegP.Padre; //El abuelo pasa a ser el hijo derecho del padre.
    RegP.Padre:=RegAb.Padre; //El padre recibe al padre del ex-abuelo, su ahora hijo derecho.
    RegAb.Padre:=Reg.Padre; //El padre del ex-abuelo sera el mismo que del registro.

    Reg.Balance:=0;
    RegP.Balance:=0;
    RegAb.Balance:=0;

    seek(ME.D,Pos);
    write(ME.D,Reg);
    seek(ME.D,Reg.Padre);
    write(ME.D,RegP);
    seek(ME.D,RegP.HijoDer);
    write(ME.D,RegAb);
  end;

{------------------------------------------------------------------------------}

  Procedure RotacionIzquierda(var ME:TipoAVL; pos:TipoPos);
  var
    posP:TipoPos;
    RC:TipoAVLControl;
    Reg,RegP,RegAb,RegAux:TipoAVLDatos;

  begin
    seek(ME.C,0);
    read(ME.C,RC);

    seek(ME.D,pos);
    read(ME.D,RegP); //Padre: Balance 1 o 0.

    seek(ME.D,RegP.HijoDer);
    read(ME.D,Reg); //Registro

    seek(ME.D,RegP.Padre);
    read(ME.D,RegAb); //Abuelo: Balance 2.
    posP:=RegAb.Padre; //Se almacena la posicion del bisabuelo, si lo hubiese.

    if RegP.Padre = RC.Raiz //Si el abuelo es la raiz del arbol, este puesto sera sedido al padre.
    then begin
      RC.Raiz:=pos;
      seek(ME.C,0);
      write(ME.C,RC);
    end
    //Sino, el bisabuelo recibira como hijo al padre.
    else begin
      seek(ME.D,posP);
      read(ME.D,RegAux);
      if RegAux.HijoIzq = RegP.Padre //¿Cual hijo del bisabuelo es el abuelo?
      then RegAux.HijoIzq:=pos    //Si el abuelo es el hijo izquierdo.
      else RegAux.HijoDer:=pos;   //Si el abuelo es el hijo derecho.
      seek(ME.D,posP);
      write(ME.D,RegAux);
    end;

    if RegP.HijoIzq <> _POSNULA
    {Si el padre tiene descendencia izquierda,
    esta pasara a ser descendencia derecha del abuelo.}
    then begin
      seek(ME.D,RegP.HijoIzq);
      read(ME.D,RegAux);
      RegAux.Padre:=RegP.Padre;
      seek(ME.D,RegP.HijoIzq);
      write(ME.D,RegAux);
    end;
    RegAb.HijoDer:=RegP.HijoIzq;

    RegP.HijoIzq:=RegP.Padre; //El abuelo pasa a ser el hijo izquierdo del padre.
    RegP.Padre:=RegAb.Padre; //El padre recibe al padre del ex-abuelo, su ahora hijo izquierdo.
    RegAb.Padre:=Reg.Padre; //El padre del ex-abuelo sera el mismo que del registro.

    Reg.Balance:=0;
    RegP.Balance:=0;
    RegAb.Balance:=0;

    seek(ME.D,Pos);
    write(ME.D,Reg);
    seek(ME.D,Reg.Padre);
    write(ME.D,RegP);
    seek(ME.D,RegP.HijoIzq);
    write(ME.D,RegAb);
  end;

{------------------------------------------------------------------------------}

  Procedure RotacionDerechaIzquierda(var ME:TipoAVL; pos:TipoPos);
  var
    RC:TipoAVLControl;
    posP,posAux:TipoPos;
    Reg,RegP,RegAb,RegAux:TipoAVLDatos;

  begin
    seek(ME.C,0);
    read(ME.C,RC);

    seek(ME.D,pos);
    read(ME.D,RegP); //Padre: Balance -1.

    seek(ME.D,RegP.HijoIzq);
    read(ME.D,Reg); //Registro.
    posAux:=RegP.HijoIzq; //Se almacena la posicion del registro.

    seek(ME.D,RegP.Padre);
    read(ME.D,RegAb); //Abuelo: Balance 2.
    posP:=RegAb.Padre; //Se almacena la posicion del bisabuelo, si lo hubiese.

    if RegP.Padre = RC.Raiz
    //Si el abuelo es la raiz del arbol, este puesto sera sedido al registro.
    then begin
      RC.Raiz:=posAux;
      seek(ME.C,0);
      write(ME.C,RC);
    end
    //Sino, el bisabuelo recibira como hijo al registro.
    else begin
      seek(ME.D,posP);
      read(ME.D,RegAux);
      if RegAux.HijoIzq = RegP.Padre //¿Cual hijo del bisabuelo es el abuelo?
      then RegAux.HijoIzq:=posAux    //Si el abuelo es el hijo izquierdo.
      else RegAux.HijoDer:=posAux;   //Si el abuelo es el hijo derecho.
      seek(ME.D,posP);
      write(ME.D,RegAux);
    end;

    if Reg.HijoIzq <> _POSNULA
    {Si el registro tiene descendencia izquierda,
    esta pasara a ser descendencia derecha del abuelo.}
    then begin
      seek(ME.D,Reg.HijoIzq);
      read(ME.D,RegAux);
      RegAux.Padre:=RegP.Padre;
      seek(ME.D,Reg.HijoIzq);
      write(ME.D,RegAux);
    end;
    RegAb.HijoDer:=Reg.HijoIzq;

    if Reg.HijoDer <> _POSNULA
    {Si el registro tiene descendencia derecha,
    esta pasara a ser descendencia izquierda del padre.}
    then begin
      seek(ME.D,Reg.HijoDer);
      read(ME.D,RegAux);
      RegAux.Padre:=pos;
      seek(ME.D,Reg.HijoDer);
      write(ME.D,RegAux);
    end;
    RegP.HijoIzq:=Reg.HijoDer;

    //El registro toma a su abuelo como su hijo izquierdo.
    Reg.HijoIzq:=RegP.Padre;
    RegAb.Padre:=posAux;

    //El tegistro toma a su padre como su hijo derecho.
    Reg.HijoDer:=pos;
    RegP.Padre:=posAux;

    Reg.Padre:=posP; //El registro recibe al bisabuelo como su padre.

    Reg.Balance:=0;
    RegP.Balance:=0;
    RegAb.Balance:=0;

    seek(ME.D,posAux);
    write(ME.D,Reg);
    seek(ME.D,Reg.HijoDer);
    write(ME.D,RegP);
    seek(ME.D,Reg.HijoIzq);
    write(ME.D,RegAb);
  end;

{------------------------------------------------------------------------------}

  Procedure RotacionIzquierdaDerecha(var ME:TipoAVL; pos:TipoPos);
  var
    RC:TipoAVLControl;
    posP,posAux:TipoPos;
    Reg,RegP,RegAb,RegAux:TipoAVLDatos;

  begin
    seek(ME.C,0);
    read(ME.C,RC);

    seek(ME.D,pos);
    read(ME.D,RegP); //Padre: Balance 1.

    seek(ME.D,RegP.HijoDer);
    read(ME.D,Reg); //Registro
    posAux:=RegP.HijoDer; //Se almacena la posicion del registro.

    seek(ME.D,RegP.Padre);
    read(ME.D,RegAb); //Abuelo: Balance -2.
    posP:=RegAb.Padre;; //Se almacena la posicion del bisabuelo, si lo hubiese.

    if RegP.Padre = RC.Raiz
    //Si el abuelo es la raiz del arbol, este puesto sera sedido al registro.
    then begin
      RC.Raiz:=posAux;
      seek(ME.C,0);
      write(ME.C,RC);
    end
    //Sino, el bisabuelo recibira como hijo al registro.
    else begin
      seek(ME.D,posP);
      read(ME.D,RegAux);
      if RegAux.HijoIzq = RegP.Padre //¿Cual hijo del bisabuelo es el abuelo?
      then RegAux.HijoIzq:=posAux    //Si el abuelo es el hijo izquierdo.
      else RegAux.HijoDer:=posAux;   //Si el abuelo es el hijo derecho.
      seek(ME.D,posp);
      write(ME.D,RegAux);
    end;

    if Reg.HijoDer <> _POSNULA
    {Si el registro tiene descendencia derecha,
    esta pasara a ser descendencia izquierda del abuelo.}
    then begin
      seek(ME.D,Reg.HijoDer);
      read(ME.D,RegAux);
      RegAux.Padre:=RegP.Padre;
      seek(ME.D,Reg.HijoDer);
      write(ME.D,RegAux);
    end;
    RegAb.HijoIzq:=Reg.HijoDer;

    if Reg.HijoIzq <> _POSNULA
    {Si el registro tiene descendencia izquierda,
    esta pasara a ser descendencia derecha del padre.}
    then begin
      seek(ME.D,Reg.HijoIzq);
      read(ME.D,RegAux);
      RegAux.Padre:=pos;
      seek(ME.D,Reg.HijoIzq);
      write(ME.D,RegAux);
    end;
    RegP.HijoDer:=Reg.HijoIzq;

    //El registro toma a su abuelo como su hijo derecho.
    Reg.HijoDer:=RegP.Padre;
    RegAb.Padre:=posAux;

    //El registro toma a su padre como su hijo izquierdo.
    Reg.HijoIzq:=pos;
    RegP.Padre:=posAux;

    Reg.Padre:=posP; //El registro recibe al bisabuelo como su padre.

    Reg.Balance:=0;
    RegP.Balance:=0;
    RegAb.Balance:=0;

    seek(ME.D,posAux);
    write(ME.D,Reg);
    seek(ME.D,Reg.HijoIzq);
    write(ME.D,RegP);
    seek(ME.D,Reg.HijoDer);
    write(ME.D,RegAb);
  end;

{------------------------------------------------------------------------------}

  Procedure NuevoBalance(var ME:TipoAVL; var pos:TipoPos; Balance:TipoBalance);
  //Balance es un valor que puede ser 1 o -1.
  var
    Reg,RegPadre:TipoAVLDatos;

  begin
    seek(ME.D,pos);
    read(ME.D,Reg);
    if (Reg.Padre <> _POSNULA) {Se actualizan los balances de cada ancestro:
    si se llega a la raiz, entonces no fue necesario rotar.}
    then begin
      seek(ME.D,Reg.Padre);
      read(ME.D,RegPadre);
        {En caso necesario, se modificara el signo del balance: esto puede llegar
         a suceder ante una ondulacion o 'zigzag' durante el ascenso por el arbol,
         de padre a padre, desde el registro insertado hasta llegar a la raiz.}

        {En el caso de un alta los casos donde se debe invertir el signo seran:
          *Reg es hijo izquierdo y Balance = 1.
          *Reg es hijo derecho y Balance = -1.}
      if ((RegPadre.HijoIzq = pos) and (Balance = 1))
      or ((RegPadre.HijoDer = pos) and (Balance = -1))
      then Balance:= -Balance;
      RegPadre.Balance:= RegPadre.Balance + Balance;

      seek(ME.D,Reg.Padre);
      write(ME.D,RegPadre);
      case RegPadre.Balance of {Si hay un balance de +/-2 de RegPadre
        entonces se debera rotar conforme al balance de Reg}
        2:if Reg.Balance > -1
          then RotacionIzquierda(ME,pos) //Balance: RegPadre 2, Reg 1 o 0.
          else RotacionDerechaIzquierda(ME,pos); //Balance: RegPadre 2, Reg -1.
       -2:if Reg.Balance < 1
          then RotacionDerecha(ME,pos) //Balance: RegPadre -2, Reg -1 o 0.
          else RotacionIzquierdaDerecha(ME,pos); //Balance: RegPadre -2, Reg 1.
        else NuevoBalance(ME,Reg.Padre,Balance); //Se pasa al siguiente padre.
      end;
    end;
  end;

{------------------------------------------------------------------------------}

  Function PrimeroAVL(var ME:TipoAVL):TipoPos;
  var
    Reg:TipoAVLDatos;
    RC:TipoAVLControl;
    Pos:TipoPos;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    Pos:=RC.Raiz;
    repeat
      seek(ME.D,Pos);
      read(ME.D,Reg);
      if Reg.HijoIzq <> _POSNULA
      then Pos:=Reg.HijoIzq;
    until Reg.HijoIzq = _POSNULA;
    PrimeroAVL:=Pos;
  end;

{------------------------------------------------------------------------------}

  Function UltimoAVL(var ME:TipoAVL):TipoPos;
  var
    Reg:TipoAVLDatos;
    RC:TipoAVLControl;
    Pos:TipoPos;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    Pos:=RC.Raiz;
    repeat
      seek(ME.D,Pos);
      read(ME.D,Reg);
      if Reg.HijoDer <> _POSNULA
      then Pos:=Reg.HijoDer;
    until Reg.HijoDer = _POSNULA;
    UltimoAVL:=Pos;
  end;

{------------------------------------------------------------------------------}

  Function AnteriorAVL(var ME:TipoAVL; Pos:TipoPos):TipoPos;
  var
    Reg,Raux:TipoAVLDatos;

  begin
    seek(ME.D,Pos);
    read(ME.D,Reg);
    Pos:=_POSNULA; //Valor por defecto

    if Reg.HijoIzq <> _POSNULA //Caso 1: Reg tiene un hijo izquierdo
    then begin

      //Obtengo al hijo izquierdo de Reg, Raux
      Pos:=Reg.HijoIzq;
      seek(ME.D,Pos);
      read(ME.D,Raux);

      if Raux.HijoDer <> _POSNULA {Si Raux tiene un hijo derecho, entonces se
      buscara (siempre por la derecha) al registro que no tenga un hijo derecho.
      Este sera el anterior inmediato de Reg}
      then repeat
        seek(ME.D,Pos);
        read(ME.D,Raux);
        if Raux.HijoDer <> _POSNULA
        then Pos:=Raux.HijoDer;
      until Raux.HijoDer = _POSNULA;

    end
    else if Reg.Padre <> _POSNULA //Caso 2: Reg no tiene hijo izquierdo, pero si padre
    then begin

      Pos:=Reg.Padre;
      repeat
        seek(ME.D,Pos);
        read(ME.D,Raux);
        if Reg.Clave < Raux.Clave //Si la clave del padre es mayor que la de Reg
        then Pos:=Raux.Padre;
      until (Reg.Clave > Raux.Clave) or (Pos = _POSNULA);
      //Si Pos = Posnula, entonces alcanze la Raiz del arbol: Reg es el primer registro

    end; {Caso 3: si Reg no tiene descendencia izquierda o un padre menor que el,
    entonces es el primer registro del arbol}
    AnteriorAVL:=Pos;
  end;

{------------------------------------------------------------------------------}

  Function ProximoAVL(var ME:TipoAVL; Pos:TipoPos):TipoPos;
  var
    Reg,Raux:TipoAVLDatos;

  begin
    seek(ME.D,Pos);
    read(ME.D,Reg);
    Pos:=_POSNULA; //Valor por defecto

    if Reg.HijoDer <> _POSNULA //Caso 1: Reg tiene un hijo derecho
    then begin

      //Obtengo al hijo derecho de Reg, Raux
      Pos:=Reg.HijoDer;
      seek(ME.D,Pos);
      read(ME.D,Raux);

      if Raux.HijoIzq <> _POSNULA {Si Raux tiene un hijo izquierdo, entonces se
      buscara (siempre por la izquierda) al registro que no tenga un hijo izquierdo.
      Este sera el proximo inmediato de Reg}
      then repeat
        seek(ME.D,Pos);
        read(ME.D,Raux);
        if Raux.HijoIzq <> _POSNULA
        then Pos:=Raux.HijoIzq;
      until Raux.HijoIzq = _POSNULA;

    end
    else if Reg.Padre <> _POSNULA //Caso 2: Reg no tiene hijo izquierdo, pero si padre
    then begin

      Pos:=Reg.Padre;
      repeat
        seek(ME.D,Pos);
        read(ME.D,Raux);
        if Reg.Clave > Raux.Clave //Si la clave del padre es menor que la de Reg
        then Pos:=Raux.Padre;
      until (Reg.Clave < Raux.Clave) or (Pos = _POSNULA);
      //Si Pos = Posnula, entonces alcanze la Raiz del arbol: Reg es el ultimo registro

    end; {Caso 3: si Reg no tiene descendencia derecha o un padre mayor que el,
    entonces es el ultimo registro del arbol}
    ProximoAVL:=Pos;
  end;

{------------------------------------------------------------------------------}

  Function BuscarAVL(var ME:TipoAVL; Clave:TipoClave; var pos:TipoPos):boolean;
  var
    Encont:boolean;
    RC:TipoAVLControl;
    Reg:TipoAVLDatos;
    posP:TipoPos;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    Encont:=False;
    pos:=RC.Raiz;
    posP:=_POSNULA;
    While (Encont = False) and (pos <> _POSNULA)
    do begin
      seek(Me.D,pos);
      read(Me.D,Reg);
      if Reg.Clave = Clave
      then Encont:=True
      else
        if Clave < Reg.Clave
        then begin
          posP:=pos;
          pos:=Reg.HijoIzq;
        end
        else begin
          posP:=pos;
          pos:=Reg.HijoDer;
        end;
    end;
    if not(Encont)
    then pos:=posP;
    BuscarAVL:=Encont;
  end;

{------------------------------------------------------------------------------}

  Procedure CapturarAVL(var ME:TipoAVL; pos:TipoPos; var Reg:TipoAVLDatos);
  begin
    seek(ME.D,pos);
    read(ME.D,Reg);
  end;

{------------------------------------------------------------------------------}

  Procedure InsertarAVL(var ME:TipoAVL; Reg:TipoAVLDatos; pos:TipoPos);
  var
    RC:TipoAVLControl;
    RegP:TipoAVLDatos;
    posNueva:TipoPos;
    Balance:TipoBalance;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    posNueva:=FileSize(ME.D);
    Reg.Padre:= _POSNULA;
    Reg.HijoIzq:= _POSNULA;
    Reg.HijoDer:= _POSNULA;
    Reg.Balance:=0;
    if RC.Raiz = _POSNULA //El nuevo nodo sera la raiz del arbol
    then begin
      RC.Raiz:=posNueva;
      seek(ME.C,0);
      write(ME.C,RC);
      seek(ME.D,posNueva);
      write(ME.D,Reg);
    end
    else begin //El nuevo nodo no sera la raiz, tendra un padre
      seek(ME.D,pos);
      read(ME.D,RegP);
      if RegP.Clave < Reg.Clave
      then begin //Reg sera el hijo derecho
        Balance:= 1;
        RegP.HijoDer:=posNueva;
      end
      else begin //Reg sera el hijo izquierdo
        Balance:= -1;
        RegP.HijoIzq:=posNueva;
      end;
      Reg.Padre:=pos;
      Reg.Balance:= 0;
      RegP.Balance:=RegP.Balance + Balance;
      seek(ME.D,pos);
      write(ME.D,RegP);
      seek(ME.D,posNueva);
      write(ME.D,Reg);
      NuevoBalance(ME,pos,Balance);{NuevoBalance actualiza el balance de todos
      los ancestros de RegP, a la vez que realiza las rotaciones necesarias.}
    end;
  end;

{------------------------------------------------------------------------------}

  Procedure ModificarAVL(var ME:TipoAVL; pos:TipoPos; Reg:TipoAVLDatos);

  begin
    seek(ME.D,pos);
    write(ME.D,Reg);
  end;

{------------------------------------------------------------------------------}
  Procedure Eliminar_Balance(var ME:TipoAVL; var pos,posPadre:TipoPos;
  Balance:TipoBalance; var E3:boolean);
  var
    Reg,RegPadre,RegAux:TipoAVLDatos;

  begin
    seek(ME.D,pos);
    read(ME.D,Reg);
    if (posPadre <> _POSNULA) {Se actualizan los balances de cada ancestro:
    si se llega a la raiz, entonces no fue necesario rotar.}
    then begin
      seek(ME.D,posPadre);
      read(ME.D,RegPadre);

      {Debido a las particularidades de la Eliminacion_3, en la primera iteracion recursiva
       nos encontramos con un defecto que puede llevar a dos escenarios distintos de
       falla en la ejecucion de la libreria, siendo estos:

        *Reg era el hijo derecho y la variable Balance es -1, pero su clave es menor que la de su padre.
        *Reg era el hijo izquierdo y la variable Balance es 1, pero su clave es mayor que la de su padre.

       Este escenario conlleva a una inversion erronea de la variable Balance, lo que
       puede conllevar a una actualizacion erronea del balance del padre actual de Reg.
       Debido a que el padre ya no contenie informacion de Reg como su hijo, los registros
       no pueden ofrecer la informacion necesaria para corregir este error.
       En su lugar, se usara la variable booleana E3 para poder realizar un unico salto en la
       inversion de la variable Balance, ya que el error solo se presenta en Reg,
       el registro eliminado.}
      if E3
      then E3:=False
      else
        {En el caso de una baja los casos donde se invertira el signo seran:
        *Reg es hijo derecho y el balanace es 1.
        *Reg es hijo izquierdo y el balance es -1.}
        if ((RegPadre.Clave < Reg.Clave) and (Balance = 1))
        or ((RegPadre.Clave > Reg.Clave) and (Balance = -1))
        then Balance:= -Balance;

      RegPadre.Balance:= RegPadre.Balance + Balance;
      seek(ME.D,posPadre);
      write(ME.D,RegPadre);

      //Si fuese necesario balancear, requeririamos tener los datos del hermano de Reg.
      if Balance = -1
      then begin //Reg es el hijo Derecho y su hermano el Izquierdo de RegPadre.
        seek(ME.D,RegPadre.HijoIzq);
        read(ME.D,RegAux);
      end
      else begin //Reg es el hijo Izquierdo y su hermano el Derecho de RegPadre.
        seek(ME.D,RegPadre.HijoDer);
        read(ME.D,RegAux);
      end;

      {Si se da el caso de necesitar un balanceo entonces, por ser una baja,
       el desequilibrio se encuentra en la descendencia opuesta de RegPadre.
       Se llamara a los procedimientos rotativos en base al balance de RegPadre y
       se dara la posicion del hermano de Reg.}
      case RegPadre.Balance of {Si hay un balance de +/-2 de RegPadre
      entonces se debera rotar conforme al valor de Reg.}
        2:if RegAux.Balance > -1
          then RotacionIzquierda(ME,RegPadre.HijoDer) //Balance: RegPadre 2, Hermano 1 o 0.
          else RotacionDerechaIzquierda(ME,RegPadre.HijoDer); //Balance: RegPadre 2, Hermano -1.
        -2:if RegAux.Balance < 1
          then RotacionDerecha(ME,RegPadre.HijoIzq) //Balance: RegPadre -2, Hermano -1 o 0.
          else RotacionIzquierdaDerecha(ME,RegPadre.HijoIzq); //Balance: RegPadre -2, Hermano 1.
        else Eliminar_Balance(ME,Reg.Padre,RegPadre.Padre,Balance,E3); //Se pasa al siguiente padre.
      end;
    end;
  end;

{------------------------------------------------------------------------------}

  Procedure Eliminar_1(var ME:TipoAVL; var pos:TipoPos; E3:boolean);
  {Eliminacion simple (Reg sin hijos): RegPadre dejara de tener la posicion de Reg,
  reemplazamndo su valor por _POSNULA.}
  var
    Reg,RegPadre:TipoAVLDatos;
    RC:TipoAVLControl;
    Balance:TipoBalance;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    seek(ME.D,pos);
    read(ME.D,Reg);
    if pos=RC.Raiz
    //Si Reg es la raiz, entonces es el unico registro en el arbol.
    then begin
      RC.Raiz:=_POSNULA;
      seek(ME.C,0);
      write(ME.C,RC);
      //El arbol queda vacio
    end
    //Sino, Reg es hijo de otro registro.
    else begin
      seek(ME.D,Reg.Padre);
      read(ME.D,RegPadre);
      //Se reemplaza la posicion de Reg guardada en su padre por _POSNULA.
      if RegPadre.HijoDer = pos
      then begin
       RegPadre.HijoDer:=_POSNULA;
       Balance:=-1;
      end
      else begin
       RegPadre.HijoIzq:=_POSNULA;
       Balance:=1;
      end;
      seek(ME.D,Reg.Padre);
      write(ME.D,RegPadre);
      Eliminar_Balance(ME,pos,Reg.Padre,Balance,E3);
    end;
  end;

{------------------------------------------------------------------------------}

  Procedure Eliminar_2(var ME:TipoAVL; var pos:TipoPos; E3:boolean);
  {Eliminacion con transicion (Reg y un hijo): RegPadre dejara de tener la posicion de Reg,
  reemplazamndo su valor por el unico hijo de Reg, el cual tambien tomara como padre a RegPadre.}
  var
    RegHijo,Reg,RegPadre:TipoAVLDatos;
    RC:TipoAVLControl;
    posHijo:TipoPos;
    Balance:TipoBalance;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    seek(ME.D,pos);
    read(ME.D,Reg);
    Balance:=0;
    if Reg.HijoIzq = _POSNULA
    then posHijo:=Reg.HijoDer //RegHijo es el hijo derecho.
    else posHijo:=Reg.HijoDer; //RegHijo es el hijo izquierdo.
    seek(ME.D,posHijo);
    read(ME.D,RegHijo);
    if pos = RC.Raiz
    //Si Reg es la raiz, entonces su hijo pasa a serlo.
    then begin
      RC.Raiz:=posHijo;
      seek(ME.C,0);
      write(ME.C,RC);
    end
    else begin
      seek(ME.D,Reg.Padre);
      read(ME.D,RegPadre);
      if RegPadre.HijoIzq = pos
      then begin //RegHijo sera el nuevo hijo izquierdo de RegPadre.
        RegPadre.HijoIzq:=posHijo;
        Balance:=1;
      end
      else begin //RegHijo sera el nuevo hijo derecho de RegPadre.
        RegPadre.HijoDer:=posHijo;
        Balance:=-1;
      end;
      seek(ME.D,Reg.Padre);
      write(ME.D,RegPadre);
    end;
    RegHijo.Padre:=Reg.Padre;
    seek(ME.D,posHijo);
    write(ME.D,RegHijo);
    Eliminar_Balance(ME,pos,Reg.Padre,Balance,E3);
  end;

{------------------------------------------------------------------------------}

  Procedure Eliminar_3(var ME:TipoAVL; pos:TipoPos);
  {Eliminacion por sustitucion (Reg y dos hijos): El objetivo sera obtener
  los descendientes izquierdo y derecho con el valor mas, cercano a Reg.
  Una vez encontrados los dos cadidatos, se usaran los siguientes criterios
  para decidir el mejor caso (observados en el orden presentados,
  de mayor a menor relevancia):
    1:Altura de sub arbol, con respecto a Reg (el que tenga mas, es el elegido).
    2:Si tienen o no un hijo (si ambos poseen la misma altura, se buscara reducir los niveles del arbol).
    3:En caso de que ambos tengan la misma altura y la misma cantidad de hijos,
      se elegira al descendiente derecho, tomando en cuenta que los numeros naturales
      (de 0 a infinito positivo) suele ser la dispocision elegida por la mayoria
      de las personas.}
  var
    RC:TipoAVLControl;
    Reg,RegSusIzq,RegSusDer,RegAux:TipoAVLDatos;
    posSusIzq,posSusDer,posAux:TipoPos;
    AlturaIzq,AlturaDer:integer;
    EsIzquierdo,TieneHijo:boolean;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    seek(ME.D,pos);
    read(ME.D,Reg);



    //Fase 1: ubicar a los descendientes candidatos por la izquierda y la derecha.

    {El primer candidato a sustituir a Reg por la Derecha sera su hijo derecho, luego se
    verificara si este tiene o no un hijo izquierdo: si no lo tiene la variable contadora
    AlturaDer tendra valor 1, y el hijo derecho sera el candidato derecho final.

    Caso contrario, se pasara a este hijo izquierdo, se incrementara AlturaDer en 1
    y se observara si este nodo tiene un hijo izquierdo,  repitiendo este proceso
    hasta encontrar a aquel nodo que no tenga hijo izquierdo.

    Este ultimo nodo seria el candidato derecho final.}
    posSusDer:=Reg.HijoDer;
    seek(ME.D,Reg.HijoDer);
    read(ME.D,RegSusDer);
    AlturaDer:=1;
    While RegSusDer.HijoIzq <> _POSNULA
    do begin
      posSusDer:=RegSusDer.HijoIzq;
      AlturaDer:=AlturaDer + 1;
      seek(ME.D,posSusDer);
      read(ME.D,RegSusDer);
    end;

    {El candidato izquierdo seguira reglas similares al derecho, solo que al reves:
     comienza por el hijo izquierdo de Reg, y luego se verifica si este y todos
     los siguientes tienen nodos tienen hijos derechos. Asi hasta encontrar al
     candidato izquierdo final.}
    posSusIzq:=Reg.HijoIzq;
    seek(ME.D,Reg.HijoIzq);
    read(ME.D,RegSusIzq);
    AlturaIzq:=1;
    While RegSusIzq.HijoDer <> _POSNULA
    do begin
      posSusIzq:=RegSusIzq.HijoDer;
      AlturaIzq:= AlturaIzq + 1;
      seek(ME.D,posSusIzq);
      read(ME.D,RegSusIzq);
    end;

    //Fase 2: seleccionarar al elegido para reemplazar a la Reg.

    if AlturaIzq <> AlturaDer then
      //Caso 1: uno de los candidatos tiene mas altura que el otro.
      if AlturaDer > AlturaIzq
      then EsIzquierdo:=False //El candidato derecho tiene mas altura, sera el elegido.
      else EsIzquierdo:=True //El candidato izquierdo tiene mas altura, sera el elegido.
    else
      {Caso 2: ambos candidatos tienen la misma altura, revisar si los candidatos
       tienen igual cantidad de hijos.}
      if (RegSusIzq.HijoIzq <> _POSNULA) and (RegSusDer.HijoDer = _POSNULA)
      then EsIzquierdo:=True //El candidato izquierdo tiene un hijo y el derecho no.
      else EsIzquierdo:=False; //En cualquier otro caso el derecho sera el elegido.

      {Caso 3: si ambos tienen la misma cantidad de hijos y estan a la misma altura
      se dara preferencia, tomando en cuenta la disposicion de
      los numeros naturales, al candidato derecho}

    //Fase 3: invertir las posiciones de Reg y el elegido.

    TieneHijo:=False;

    if EsIzquierdo

    then begin  //El elegido es el descendiente por la izquierda.

      //Paso 1: Se actualizan los datos del padre de Reg, si es que tiene
      if pos = RC.Raiz //Paso 1.1: Reg es la raiz, el elegido pasa a serlo.
      then begin
        RC.Raiz:=posSusIzq;
        seek(ME.C,0);
        write(ME.C,RC);
      end
      else begin //Paso 1.2: Reg no es la raiz, tiene un nodo padre.
        seek(ME.D,Reg.Padre);
        read(ME.D,RegAux);
        if RegAux.HijoIzq = pos
        then RegAux.HijoIzq:=posSusIzq  //El elegido sera el nuevo hijo izquierdo de RegPadre.
        else RegAux.HijoDer:=posSusIzq; //El elegido sera el nuevo hijo derecho de RegPadre.
        seek(ME.D,Reg.Padre);
        write(ME.D,RegAux);
      end;

       //Paso 2: se actualiza el hijo derecho de Reg.
      seek(ME.D,Reg.HijoDer);
      read(ME.D,RegAux);
      RegAux.Padre:=posSusIzq;
      seek(ME.D,Reg.HijoDer);
      write(ME.D,RegAux);

      //Paso 3: se actualiza el hijo izquierdo del elegido, si tiene
      if RegSusIzq.HijoIzq <> _POSNULA
      then begin
        seek(ME.D,RegSusIzq.HijoIzq);
        read(ME.D,RegAux);
        RegAux.Padre:=pos;
        seek(ME.D,RegSusIzq.HijoIzq);
        write(ME.D,RegAux);
        TieneHijo:=True;
      end;

      //Paso 4: se da el intercambio entre el elegido y Reg.

      if Reg.HijoIzq = posSusIzq
      then begin //Paso 4.1: el elegido es el propio hijo izquierdo de Reg

        seek(ME.D,Reg.HijoIzq);
        read(ME.D,RegAux);

        //Paso 4.1.1: el elegido toma los datos de Reg
        RegAux.Padre:=Reg.Padre; //El padre del Reg pasa a ser el padre de elegido.
        RegAux.HijoIzq:=pos;  //El elegido toma como su hijo izquierdo a Reg.
        RegAux.HijoDer:=Reg.HijoDer; //El hijo derecho de Reg lo sera ahora para el elegido.
        RegAux.Balance:=Reg.Balance; //El balance se transfiere sin cambios.

        //Paso 4.1.2: Reg toma los datos del elegido
        Reg.Padre:=Reg.HijoIzq; //El padre de Reg sera su propio hijo izquierdo, el elegido.
        Reg.HijoIzq:=RegSusIzq.HijoIzq;  //Reg toma como su hijo izquierdo al del elegido.
        Reg.HijoDer:=_POSNULA; //Reg no tendra un hijo derecho.
        Reg.Balance:=RegSusIzq.Balance; //El balance se transfiere sin cambios.

      end
      else begin //Paso 4.2: el elegido no es el hijo izquierdo de Reg.

        //Paso 4.2.1: se actualizan los datos del padre del elegido.
        seek(ME.D,RegSusIzq.Padre);
        read(ME.D,RegAux);
        RegAux.HijoDer:=pos;
        seek(ME.D,RegSusIzq.Padre);
        write(ME.D,RegAux);

        //Paso 4.2.2: Se actualizan los datos del hijo izquierdo de Reg.
        seek(ME.D,Reg.HijoIzq);
        read(ME.D,RegAux);
        RegAux.Padre:=posSusIzq;
        seek(ME.D,Reg.HijoIzq);
        write(ME.D,RegAux);

        //Paso 4.2.3: se intercambian sus datos Reg y RegSusIzq.
        seek(ME.D,posSusIzq);
        read(ME.D,RegAux);

        RegAux.Padre:=Reg.Padre; //El padre del Reg pasa a ser el padre de elegido.
        RegAux.HijoIzq:=Reg.HijoIzq;  //El elegido toma como su hijo izquierdo al de Reg.
        RegAux.HijoDer:=Reg.HijoDer; //El hijo derecho de Reg lo sera ahora para el elegido.
        RegAux.Balance:=Reg.Balance; //El balance se transfiere sin cambios.

        Reg.Padre:=RegSusIzq.Padre; //El padre de Reg sera el padre elegido.
        Reg.HijoIzq:=RegSusIzq.HijoIzq;  //El elegido toma como su hijo izquierdo a Reg.
        Reg.HijoDer:=_POSNULA; //Reg no tendra el hijo derecho.
        Reg.Balance:=RegSusIzq.Balance; //El balance se transfiere sin cambios.

      end;

      seek(ME.D,posSusIzq);
      write(ME.D,RegAux);
      seek(ME.D,pos);
      write(ME.D,Reg);
    end

    else begin //El elegido es el descendiente por la derecha.

      //Paso 1: Se actualizan los datos del padre de Reg, si es que tiene
      if pos = RC.Raiz //Paso 1.1: Reg es la raiz, el elegido pasa a serlo.
      then begin
        RC.Raiz:=posSusDer;
        seek(ME.C,0);
        write(ME.C,RC);
      end
      else begin //Paso 1.2: Reg no es la raiz, entonces tiene un nodo padre.
        seek(ME.D,Reg.Padre);
        read(ME.D,RegAux);
        if RegAux.HijoIzq = pos
        then RegAux.HijoIzq:=posSusDer  //El sustituto sera el nuevo hijo izquierdo de RegPadre.
        else RegAux.HijoDer:=posSusDer; //El sustituto sera el nuevo hijo derecho de RegPadre.
        seek(ME.D,Reg.Padre);
        write(ME.D,RegAux);
      end;

      //Paso 2: se actualiza el hijo izquierdo de Reg.
      seek(ME.D,Reg.HijoIzq);
      read(ME.D,RegAux);
      RegAux.Padre:=posSusDer;
      seek(ME.D,Reg.HijoIzq);
      write(ME.D,RegAux);

      //Paso 3: se actualiza el hijo derecho del elegido, si tiene
      if RegSusDer.HijoDer <> _POSNULA
      then begin
        //Se actualizan los datos del hijo derecho de RegSusDer.
        seek(ME.D,RegSusDer.HijoDer);
        read(ME.D,RegAux);
        RegAux.Padre:=pos;
        seek(ME.D,RegSusDer.HijoDer);
        write(ME.D,RegAux);
        TieneHijo:=True;
      end;

      //Paso 4: se da el intercambio entre el elegido y Reg.

      if Reg.HijoDer = posSusDer
      then begin //Paso 4.1: el elegido es el propio hijo derecho de Reg.

        //Se intercambian los datos Reg y RegSusIzq.

        seek(ME.D,Reg.HijoDer);
        read(ME.D,RegAux);

        //Paso 4.1.1: el elegido toma los datos de Reg
        RegAux.Padre:=Reg.Padre; //El padre del Reg pasa a ser el padre de elegido.
        RegAux.HijoDer:=pos;  //El elegido toma como su hijo derecho a Reg.
        RegAux.HijoIzq:=Reg.HijoIzq; //El hijo izquierdo de Reg lo sera ahora para el elegido.
        RegAux.Balance:=Reg.Balance; //El balance se transfiere sin cambios

        //Paso 4.1.2: Reg toma los datos del elegido
        Reg.Padre:=Reg.HijoDer; //El padre de Reg sera su propio hijo derecho, el elegido.
        Reg.HijoDer:=RegSusDer.HijoDer;  //Reg toma como su hijo derecho al del elegido.
        Reg.HijoIzq:=_POSNULA; //Reg no tendra un hijo izquierdo.
        Reg.Balance:=RegSusDer.Balance; //El balance se transfiere sin cambios

      end
      else begin //Paso 4.2: el elegido no es el hijo derecho de Reg

        //Paso 4.2.1: se actualizan los datos del padre del elegido
        seek(ME.D,RegSusDer.Padre);
        read(ME.D,RegAux);
        RegAux.HijoIzq:=pos;
        seek(ME.D,RegSusDer.Padre);
        write(ME.D,RegAux);

        //Paso 4.2.2: se actualizan los datos del hijo derecho de Reg.
        seek(ME.D,Reg.HijoDer);
        read(ME.D,RegAux);
        RegAux.Padre:=posSusDer;
        seek(ME.D,Reg.HijoDer);
        write(ME.D,RegAux);

        //Paso 4.2.3: se intercambian sus datos Reg y RegSusIzq.
        seek(ME.D,posSusDer);
        read(ME.D,RegAux);

        RegAux.Padre:=Reg.Padre; //El padre del Reg pasa a ser el padre de elegido.
        RegAux.HijoIzq:=Reg.HijoIzq;  //El elegido toma como su hijo izquierdo al de Reg.
        RegAux.HijoDer:=Reg.HijoDer; //El hijo derecho de Reg lo sera ahora para el elegido.
        RegAux.Balance:=Reg.Balance; //El balance se transfiere sin cambios.

        Reg.Padre:=RegSusDer.Padre; //El padre de Reg sera el padre elegido.
        Reg.HijoDer:=RegSusDer.HijoDer;  //El elegido toma como su hijo derecho a Reg.
        Reg.HijoIzq:=_POSNULA; //Reg no tendra un hijo izquierdo.
        Reg.Balance:=RegSusDer.Balance; //El balance se transfiere sin cambios.

      end;

      seek(ME.D,posSusDer);
      write(ME.D,RegAux);
      seek(ME.D,pos);
      write(ME.D,Reg);
    end;

    {Dependiendo de la existencia o no de hijos, se invocara al
     procedimiento correspondiente}
    if TieneHijo
    then Eliminar_2(ME,pos,True) //Reg no tiene hijos.
    else Eliminar_1(ME,pos,True) //Reg tiene un hijo.
  end;

{------------------------------------------------------------------------------}

  Procedure EliminarAVL(var ME:TipoAVL; pos:TipoPos);
  var
    RC:TipoAVLControl;
    Reg,RegAux:TipoAVLDatos;
    posAux:TipoPos;

  begin
    {EliminarAVL tiene la funcion de elegir un tipo de eliminacion a un dato clave:
     la existencia de hijos.
    En cuyos casos:
      *Si no tiene hijos, se invocara a Eliminar_1.
      *Si tiene 2 hijos, se invocara a Eliminar_3.
      *Si tiene 1 hijo, se invocara a Eliminar_2.
    Nota: la razon por la que Eliminar_3 se invoca en un caso previo a Eliminar_2
     es, ademas de la comodidad condicional del codigo, porque Eliminar_3 no lleva
     a cabo una eliminacion en si: sustituye a Reg por un registro descendiente
     suyo reemplazandolo en su posicion (figurativa) en el arbol, por lo que
     el registro "eliminado" seria este mismo sustituto, removido de su posicion previa.
    Debido a esto, a partir de la ubicacion previa del sustituto se invocara a:
      *Eliminar_1 si no tiene hijos.
      *Eliminar_2 si tiene 1 hijo.}
    seek(ME.C,0);
    read(ME.C,RC);
    seek(ME.D,pos);
    read(ME.D,Reg);
    if (Reg.HijoIzq = _POSNULA) and (Reg.HijoDer = _POSNULA)
    {Caso 1: si el registro no tiene hijos, se invocara a Eliminar_1.}
    then Eliminar_1(ME,pos,False)
    else
      if (Reg.HijoIzq <> _POSNULA) and (Reg.HijoDer <> _POSNULA)
      //Caso 2: si el registro tiene dos hijos, se hara uso del procedeimiento Eliminar_3.
      then Eliminar_3(ME,pos)
      //Caso 3: si el registro tiene un solo hijo, se llamara al procedimiento Eliminar_2.
      else Eliminar_2(ME,pos,False);

    seek(ME.D,pos);
    read(ME.D,Reg);
    if RC.Borrados = _POSNULA
    //Si no hay registros borrados.
    then begin
     RC.Borrados:=pos;
     Reg.Padre:=_POSNULA;
     seek(ME.C,0);
     write(ME.C,RC);
    end
     //Si ya hay registros borrados.
    else begin
      posAux:=RC.Borrados;
      while RegAux.HijoDer <> _POSNULA
      do begin
        seek(ME.D,posAux);
        read(ME.D,RegAux);
        if RegAux.HijoDer <> _POSNULA
        then posAux:=RegAux.HijoDer;
      end;
      {Los borrados se apilaran por orden de entrada, usando a los Hijos Derechos
      para este fin: cada registro tendra como padre al registro borrado anterior
      y como hijo derecho al primer registro borrado despues de si mismo.}
      RegAux.HijoDer:=pos;
      Reg.Padre:=posAux;
      Reg.Balance:=0;
      Reg.HijoDer:=_POSNULA;
      Reg.HijoIzq:=_POSNULA;
      seek(ME.D,pos);
      write(ME.D,Reg);
      seek(ME.D,posAux);
      write(ME.D,RegAux);
    end;
  end;

{------------------------------------------------------------------------------}

  Function ArbolVacioAVL(var ME:TipoAVL):boolean;
  var
    RC:TipoAVLControl;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    ArbolVacioAVL:=(RC.Raiz = _POSNULA)
  end;

{------------------------------------------------------------------------------}

  Function RaizAVL(var ME:TipoAVL):TipoPos;
  var
    RC:TipoAVLControl;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    RaizAVL:=RC.Raiz;
  end;

{------------------------------------------------------------------------------}

  Function PadreAVL(var ME:TipoAVL; pos:TipoPos):TipoPos;
  var
    Reg:TipoAVLDatos;

  begin
    seek(ME.D,pos);
    read(ME.D,Reg);
    PadreAVL:=Reg.Padre;
  end;

{------------------------------------------------------------------------------}

  Function HijoIzquierdoAVL(var ME:TipoAVL; pos:TipoPos):TipoPos;
  var
    Reg:TipoAVLDatos;

  begin
    seek(ME.D,pos);
    read(ME.D,Reg);
    HijoIzquierdoAVL:=Reg.HijoIzq;
  end;

{------------------------------------------------------------------------------}

  Function HijoDerechoAVL(var ME:TipoAVL; pos:TipoPos):TipoPos;
  var
    Reg:TipoAVLDatos;

  begin
    seek(ME.D,pos);
    read(ME.D,Reg);
    HijoDerechoAVL:=Reg.HijoDer
  end;

{------------------------------------------------------------------------------}

  Function PosicionNulaAVL(var ME:TipoAVL):TipoPos;
  begin
    PosicionNulaAVL:=_POSNULA;
  end;

{------------------------------------------------------------------------------}

  Function ClaveNulaAVL(var ME:TipoAVL):TipoClave;
  begin
    ClaveNulaAVL:=_CLAVENULA;
  end;

{------------------------------------------------------------------------------}

  Function ArbolAVLVacio(var ME:TipoAVL):boolean;
  var
    RC:TipoAVLControl;

  begin
    seek(ME.C,0);
    read(ME.C,RC);
    ArbolAVLVacio:=RC.Raiz = _POSNULA;
  end;
{------------------------------------------------------------------------------}

end.

