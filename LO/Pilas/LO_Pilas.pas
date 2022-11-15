unit LO_Pilas;

interface
  {Pilas:
  Abstraccion de la libreria ListasSimples. Ejecutando los metodos de esta, con
  ciertos valores prefijados para los parametros Pos, se le dara una funcionalidad
  FIFO (First In/First Out): solo se leera/insertara/eliminara el primer registro
  de la lista.
  }
  uses
    LO_ListasSimples;

  const
    _POSNULA = LO_ListasSimples._POSNULA;
    _CLAVENULA = LO_ListasSimples._CLAVENULA;

  Type

    TipoClave = LO_ListasSimples.TipoClave;
    TipoRegPila = TipoDatosSimple;
    TipoPila = TipoListaSimple;

    Procedure CrearPila(var ME:TipoPila; Nombre,Ruta:string);
    Procedure DestruirPila(var ME:TipoPila);
    Procedure AbrirPila(var ME:TipoPila);
    Procedure CerrarPila(var ME:TipoPila);

    Procedure Tope(var ME:TipoPila; var Reg:TipoRegPila);
    Procedure Apilar(var ME:TipoPila; Reg:TipoRegPila);
    Procedure Retirar(var ME:TipoPila);

    Function PilaVacia(var ME:TipoPila):Boolean;

implementation

  Procedure CrearPila(var ME:TipoPila; Nombre,Ruta:string);
  begin
    CrearListaSimple(ME,Nombre,Ruta);
  end;

  Procedure DestruirPila(var ME:TipoPila);
  begin
    DestruirListaSimple(ME);
  end;

  Procedure AbrirPila(var ME:TipoPila);
  begin
    AbrirListaSimple(ME);
  end;

  Procedure CerrarPila(var ME:TipoPila);
  begin
    CerrarListaSimple(ME);
  end;

  Procedure Tope(var ME:TipoPila; var Reg:TipoRegPila);
  begin
    //Capturo el primer registro de la lista
    CapturarListaSimple(ME,_POSNULA,Reg);;
  end;

  Procedure Apilar(var ME:TipoPila; Reg:TipoRegPila);
  begin
    //Inserto el registro al principio de la lista
    AgregarListaSimple(ME,Reg,_POSNULA);
  end;

  Procedure Retirar(var ME:TipoPila);
  begin
    //Elimino el primer registro de la lista
    EliminarListaSimple(ME,_POSNULA);
  end;

  Function PilaVacia(var ME:TipoPila):Boolean;
  begin
    PilaVacia:=ListaSimpleVacia(ME);
  end;

end.
