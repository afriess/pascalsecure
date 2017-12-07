program GUITest_Common;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, TestSecurityManagerSchema,
  TestBasicUserManagement, TestControlsManager, MockSecureControl,
  security.manager.schema, security.manager.controls_manager;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

