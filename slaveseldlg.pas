unit SlaveSelDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, SlvSelFm;

type
  
  { TSlaveSelDlg }

  TSlaveSelDlg = class(TCommonDialog)
  private
    FDialogForm: TSlaveSelForm;
    function GetDialogForm: TSlaveSelForm;

  protected

  public
    constructor Create(AOwner: TComponent); override;
    function Execute: Boolean; override;
    property DialogForm: TSlaveSelForm read GetDialogForm;
  published

  end;

procedure Register;

implementation

uses FormEx;

procedure Register;
begin
  RegisterComponents('Dialogs',[TSlaveSelDlg]);
end;

{ TSlaveSelDlg }

function TSlaveSelDlg.GetDialogForm: TSlaveSelForm;
begin
  if not Assigned(FDialogForm) then begin
    FDialogForm := TSlaveSelForm.Create(Self);
  end;
  Result := FDialogForm
end;

constructor TSlaveSelDlg.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
end;

function TSlaveSelDlg.Execute: Boolean;
begin
  Result := DialogForm.ShowModal = mrOK;
  if Result then
    with DialogForm.FormListBox do
      if ItemIndex >= 0 then begin
        (Items.Objects[ItemIndex] as TForm).Show;
        FormAdjust((Items.Objects[ItemIndex] as TForm));
      end
      else Result := False;
end;

end.
