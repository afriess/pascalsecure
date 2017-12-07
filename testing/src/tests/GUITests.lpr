program GUITests;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, testpseccontrolsmanager;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

