program fpcunitautoman;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, TestCaseUtils, Utils, Stock;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

