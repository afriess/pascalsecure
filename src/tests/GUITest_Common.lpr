program GUITest_Common;

{$I PSECinclude.inc}

uses
  Interfaces, Forms, GuiTestRunner,  pascalsecure
  ,TestSecurityManagerSchema
  //,TestPSECcontrolsmanager  { TODO -oAndi : I have to Backport this }
  ,TestControlsManager
  ;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

