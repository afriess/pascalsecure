program LoginLvlBased;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, frmmainlvl, ubuildschemalvl, security.manager.basic_user_management,
  security.manager.controls_manager, security.manager.schema
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TFormAuthBased, FormAuthBased);
  Application.Run;
end.

