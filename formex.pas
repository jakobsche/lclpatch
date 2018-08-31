{
 /***************************************************************************
                                   formex.pas
                                   ----------


 ***************************************************************************/

 *****************************************************************************
  This file is part of the Lazarus packages by Andreas Jakobsche

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit FormEx;

{$mode objfpc}{$H+}

interface

uses Controls, Forms;

procedure ControlAdjust(Control: TControl);
{ adjusts the size and position of a control within its parent so that it is
  completely visible }

procedure FormAdjust(Form: TForm);
{ adjusts the size and position of a form if necessary to show it completely
  within the screen, to call for example in the form's OnShow or OnCreate event
  handler or after an user action which places the form outside of the
  screen, can be called on a system not supporting TForm.Position := poDefault.
  Example of a form to watch:

  procedure TForm1.FormShow(Sender: TObject);
  begin
    FormAdjust(Sender as TForm);
  end; }

implementation

procedure ControlAdjust(Control: TControl);
begin
  if Control = nil then Exit;
  with Control do begin
    if Parent = nil then Exit;
    if Width > Parent.Width then Width := Parent.Width;
    if Height > Parent.Height then Height := Parent.Height;
    if (Left < 0) then Left := 0;
    if (Left + Width > Parent.Width) then Left := Parent.Width - Width;
    if Top < 0 then Top := 0;
    if Top + Height > Parent.Height then Top := Parent.Height - Height
  end;
end;

procedure FormAdjust(Form: TForm);
begin
  if Form = nil then Exit;
  if Screen = nil then Exit;
  with Form do begin
    if Width > Screen.Width then Width := Screen.Width;
    if Height > Screen.Height then Height := Screen.Height;
    if (Left < 0) then Left := 0;
    if (Left + Width > Screen.Width) then Left := Screen.Width - Width;
    if Top < 0 then Top := 0;
    if Top + Height > Screen.Height then Top := Screen.Height - Height
  end;
end;

end.

