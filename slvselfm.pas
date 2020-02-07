unit SlvSelFm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TSlaveSelForm }

  TSlaveSelForm = class(TForm)
    OKBtn: TBitBtn;
    AbortBtn: TBitBtn;
    HelpBtn: TBitBtn;
    FormListBox: TListBox;
  private

  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  SlaveSelForm: TSlaveSelForm;

implementation

{$R *.lfm}

{ TSlaveSelForm }

constructor TSlaveSelForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Visible := False
end;

end.

