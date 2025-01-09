unit UfmMain;

{$mode objfpc}{$H+}


interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Stock;

type

  { TFormMain }

  TFormMain = class(TForm)
    AddTradeButton: TButton;
    DebugEdit: TEdit;
    procedure AddTradeButtonClick(Sender: TObject);
  private

  public

  end;

var
  FormMain: TFormMain;

implementation


{$R *.lfm}

{ TFormMain }

uses Math, Utils;

procedure TFormMain.AddTradeButtonClick(Sender: TObject);
begin

end;

end.
