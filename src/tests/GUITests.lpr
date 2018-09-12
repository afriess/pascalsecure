program GUITests;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, testpseccontrolsmanager, psecsecuremanager,
  TestPSECSecureManager, psecsecurelevelmanager, psecsecureauthmanager,
  psecuserschema, TestPSECAuthSecureManager, testpsecauthuserschema,
  MockSecureControl, TestPSECUserAuthComplete, PSECAuthUserManager;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

