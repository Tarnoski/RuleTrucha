unit Formatos;

interface

    uses
      SysUtils;

    Function EsNumerico(str:string):boolean;
    Function EsNatural(int:integer):boolean;
    Function SoloLetras(str:string):boolean;
    Function EsAlfaNumerico(str:string):boolean;
    Function TieneChar(str:string; chr:char):boolean;
    Function StringVacio(str:string):boolean;

    Function PreEspaciosString(cantidad:integer; str:string):string;
    Function PreCerosString(cantidad:integer; str:string):string;
    Function PreCerosInteger(cantidad:integer; int:integer):string;

implementation

  Function EsNumerico(str:string):boolean;
  var
    val:Extended;

  begin
    EsNumerico:=TryStrToFloat(str,val);
  end;

{------------------------------------------------------------------------------}

  Function EsNatural(int:integer):boolean;

  begin
    EsNatural:=(int > -1);
  end;

{------------------------------------------------------------------------------}

  Function SoloLetras(str:string):boolean;
  const
    CHARS = ['a'..'z', 'A'..'Z'];
  var
    i:integer;
    Es:boolean;

  begin
    Es:=True;
    for i := 1 to Length(str)
    do if not (str[i] in CHARS)
    then Es:=False;
    SoloLetras:=Es;
  end;

{------------------------------------------------------------------------------}

  Function EsAlfaNumerico(str:string):boolean;
  const
    CHARS = ['0'..'9', 'a'..'z', 'A'..'Z'];
  var
    i:integer;
    Es:boolean;

  begin
    Es:=True;
    for i := 1 to Length(str)
    do if not (str[i] in CHARS)
    then Es:=False;
    EsAlfaNumerico:=Es;
  end;

{------------------------------------------------------------------------------}

  Function TieneChar(str:string; chr:char):boolean;
  var
    i:integer;
    Esta:boolean;

  begin
    Esta:=False;
    for i := 1 to Length(str)
    do if str[i] = chr
    then Esta:=True;
    TieneChar:=Esta;
  end;
  
{------------------------------------------------------------------------------}

  Function StringVacio(str:string):boolean;

  begin
    StringVacio:=(Length(str) = 0);
  end;

{------------------------------------------------------------------------------}

  Function PreEspaciosString(cantidad:integer; str:string):string;

  begin
    PreEspaciosString:=StringOfChar(' ', cantidad - length(str)) + str;
  end;

{------------------------------------------------------------------------------}

  Function PreCerosString(cantidad:integer; str:string):string;
  begin
    PreCerosString:=StringOfChar('0', cantidad - length(str)) + str;
  end;

{------------------------------------------------------------------------------}

  Function PreCerosInteger(cantidad:integer; int:integer):string;
  begin
    PreCerosInteger:=Format('%.*d', [cantidad, int]);
  end;

{------------------------------------------------------------------------------}
end.
 