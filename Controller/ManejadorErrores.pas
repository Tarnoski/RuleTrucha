unit ManejadorErrores;

interface

Function Error(cod:integer):string;

implementation
  Function Error(cod:integer):string;
  var
    mensaje:string;

  begin
    mensaje:='Error - ';
    case cod of
      0:mensaje:='Operacion Exitosa';

      //serie 100: introduccion de texto
      101:mensaje:=mensaje + ' Ingrese todos los datos';
      102:mensaje:=mensaje + ' Datos  incorrectos';
      103:mensaje:=mensaje + ' El jugador no esta disponible';
      104:mensaje:=mensaje + ' Texto vacio';
      105:mensaje:=mensaje + ' Los campos no coinciden';
      106:mensaje:=mensaje + ' Operacion fallida';

      //serie 200: alfanumerico
      201:mensaje:=mensaje + ' Caracter no valido';
      202:mensaje:=mensaje + ' Solo caracteres alfanumericos';
      203:mensaje:=mensaje + ' Solo letras';
      204:mensaje:=mensaje + ' Solo numeros';

      //serie 300: jugador
      301:mensaje:=mensaje + ' El nick ya esta en uso';
      302:mensaje:=mensaje + ' La clave ya esta en uso';
      303:mensaje:=mensaje + ' El nick puede tener hasta 6 caracteres';
      304:mensaje:=mensaje + ' La clave debe tener entre 6 y 12 caracteres';
      305:mensaje:=mensaje + ' Nombre puede tener hasta 100 caracteres';
      306:mensaje:=mensaje + ' Apellido puede tener hasta 100 caracteres';
      307:mensaje:=mensaje + ' Clave incorrecta';

      //serie 400: cuentas
      401:mensaje:=mensaje + ' El monto es inferior al minimo necesario para abrir la cuenta';
      402:mensaje:=mensaje + ' El monto es menor a 0';
      403:mensaje:=mensaje + ' El monto es menor al saldo total';
    end;
    Error:=mensaje;
  end;
end.
 