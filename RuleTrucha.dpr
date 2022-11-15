program RuleTrucha;

uses
  Forms,
  UnitLogin in 'Units\UnitLogin.pas' {fLogin},
  LO_ArbolAVL in 'LO\ArbolAVL\LO_ArbolAVL.pas',
  LO_HashAbierto in 'LO\HashAbierto\LO_HashAbierto.pas',
  ME_Jugadores in 'MEs\ME_Jugadores.pas',
  LO_ListasDobles in 'LO\ListasDobles\LO_ListasDobles.pas',
  ControladorLibrerias in 'Controller\ControladorLibrerias.pas',
  Formatos in 'Controller\Formatos.pas',
  Rutas in 'Controller\Rutas.pas',
  ME_Cuentas in 'MEs\ME_Cuentas.pas',
  LO_HashCerrado in 'LO\HashCerrado\LO_HashCerrado.pas',
  LO_ListasSimples in 'LO\ListasSimples\LO_ListasSimples.pas',
  ME_Ruleta in 'MEs\ME_Ruleta.pas',
  LO_Colas in 'LO\Colas\LO_Colas.pas',
  ME_Apuestas in 'MEs\ME_Apuestas.pas',
  ME_Ganadores in 'MEs\ME_Ganadores.pas',
  LO_ArbolTrinario in 'LO\ArbolTrinario\LO_ArbolTrinario.pas',
  UsuarioActual in 'Controller\UsuarioActual.pas',
  UnitMenu in 'Units\UnitMenu.pas' {fMenu},
  ManejadorErrores in 'Controller\ManejadorErrores.pas',
  Administrador in 'Controller\Administrador.pas',
  UnitAlta in 'Units\UnitAlta.pas' {fAlta},
  UnitMod in 'Units\UnitMod.pas' {fMod},
  UnitBaja in 'Units\UnitBaja.pas' {fBaja},
  UnitPass in 'Units\UnitPass.pas' {fPass},
  UnitMoves in 'Units\UnitMoves.pas' {fMoves},
  UnitJuego in 'Units\UnitJuego.pas' {fJuego},
  UnitAdmin in 'Units\UnitAdmin.pas' {fAdmin};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfLogin, fLogin);
  Application.CreateForm(TfMenu, fMenu);
  Application.CreateForm(TfAlta, fAlta);
  Application.CreateForm(TfMod, fMod);
  Application.CreateForm(TfBaja, fBaja);
  Application.CreateForm(TfPass, fPass);
  Application.CreateForm(TfMoves, fMoves);
  Application.CreateForm(TfJuego, fJuego);
  Application.CreateForm(TfAdmin, fAdmin);
  Application.Run;
end.
