unit MasterFm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, SlaveSelDlg;

type

  TMasterForm = class;

  { TSlaveFormCaptions }

  TSlaveFormCaptions = class(TStrings)
  private
    MasterForm: TMasterForm;
  protected
    procedure AssignTo(Dest: TPersistent); override;
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
  public
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
  end;

  { TMasterForm }

  TMasterForm = class(TForm)
  private
    FSlaveFormCaptions: TSlaveFormCaptions;
    FSlaveList: TFpList;
    FSlaveSelDlg: TSlaveSelDlg;
    function GetSlaveList: TFpList;
  private
    FSlaveIndex: Integer;
    function GetSlaveCount: Integer;
    function GetSlaveFormCaptions: TStrings;
    function GetSlaveForms(I: Integer): TForm;
    function GetSlaveIndex: Integer;
    function GetSlaveSelDlg: TSlaveSelDlg;
    procedure SetSlaveIndex(AValue: Integer);
    property SlaveList: TFpList read GetSlaveList;
  protected
    procedure Activate; override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    function AddSlave(ASlave: TForm): Integer;
    procedure AdjustSlaves;
    procedure CascadeSlaves;
    function CloseQuery: Boolean; override;
    procedure RemoveSlave(ASlave: TForm);
    procedure TileSlaves;
    property SlaveCount: Integer read GetSlaveCount;
    property SlaveFormCaptions: TStrings read GetSlaveFormCaptions;
    property SlaveIndex: Integer read GetSlaveIndex write SetSlaveIndex;
    property SlaveForms[I: Integer]: TForm read GetSlaveForms;
    property SlaveSelDlg: TSlaveSelDlg read GetSlaveSelDlg;
  end;

implementation

uses FormEx;

{$R *.lfm}

{ TSlaveFormCaptions }

procedure TSlaveFormCaptions.AssignTo(Dest: TPersistent);
begin
  inherited AssignTo(Dest);
end;

function TSlaveFormCaptions.Get(Index: Integer): string;
begin
  Result := (Objects[Index] as TForm).Caption;
end;

function TSlaveFormCaptions.GetCount: Integer;
begin
  Result := MasterForm.SlaveCount;
end;

function TSlaveFormCaptions.GetObject(Index: Integer): TObject;
begin
  Result := MasterForm.SlaveForms[Index]
end;

procedure TSlaveFormCaptions.Clear;
begin
  raise EInvalidOperation.CreateFmt('Clearing a %s object is not possible.', [ClassName]);
end;

procedure TSlaveFormCaptions.Delete(Index: Integer);
begin
  (Objects[Index] as TForm).Close;
end;

procedure TSlaveFormCaptions.Insert(Index: Integer; const S: string);
begin
  raise EInvalidOperation.CreateFmt('Insertion to a %s object is not possible', [ClassName]);
end;

{ TMasterForm }

function TMasterForm.GetSlaveList: TFpList;
begin
  if not Assigned(FSlaveList) then FSlaveList := TFpList.Create;
  Result := FSlaveList
end;

function TMasterForm.GetSlaveForms(I: Integer): TForm;
begin
  Pointer(Result) := SlaveList[i]
end;

function TMasterForm.GetSlaveCount: Integer;
begin
  if Assigned(FSlaveList) then Result := FSlaveList.Count
  else Result := 0
end;

function TMasterForm.GetSlaveFormCaptions: TStrings;
begin
  if not Assigned(FSlaveFormCaptions) then begin
    FSlaveFormCaptions := TSlaveFormCaptions.Create;
    FSlaveFormCaptions.MasterForm := Self
  end;
  Result := FSlaveFormCaptions
end;

function TMasterForm.GetSlaveIndex: Integer;
begin
  if FSlaveIndex >= SlaveCount then FSlaveIndex := SlaveCount - 1;
  Result := FSlaveIndex
end;

function TMasterForm.GetSlaveSelDlg: TSlaveSelDlg;
var
  i: Integer;
begin
  if not Assigned(FSlaveSelDlg) then begin
    FSlaveSelDlg := TSlaveSelDlg.Create(Self);
  end;
  with FSlaveSelDlg.DialogForm.FormListBox do begin
    Items := SlaveFormCaptions;
    if (ItemIndex < 0) or (ItemIndex >= Items.Count) then begin
      if Items.Count > 0 then ItemIndex := 0
      else ItemIndex := -1;
      for i := 0 to Items.Count - 1 do
        if (Items.Objects[i] as TForm).Active then begin
          ItemIndex := i;
          Break
        end;
    end
  end;
  Result := FSlaveSelDlg
end;

procedure TMasterForm.SetSlaveIndex(AValue: Integer);
begin
  SlaveForms[AValue].Show;
  SlaveForms[AValue].BringToFront;
  FSlaveIndex := AValue;
end;

procedure TMasterForm.Activate;
begin
  inherited Activate;
  if SlaveCount > 0 then begin
    SlaveForms[0].Show;
    SlaveForms[0].BringToFront;
    Hide;
  end;
end;

constructor TMasterForm.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  Visible := False;
  Height := 0;
  Width := 0;
  WindowState := wsMinimized
end;

destructor TMasterForm.Destroy;
begin
  if Assigned(FSlaveList) then begin
    FreeAndNil(FSlaveList);
  end;
  FSlaveFormCaptions.Free;
  inherited Destroy;
end;

function TMasterForm.AddSlave(ASlave: TForm): Integer;
begin
  if ASlave <> nil then begin
    Result := SlaveList.Add(ASlave);
    ASlave.Show;
    ASlave.BringToFront;
    SendToBack;
    Hide
  end;
end;

procedure TMasterForm.AdjustSlaves;
var
  i: Integer;
begin
  for i := 0 to SlaveCount - 1 do begin
    FormAdjust(SlaveForms[i]);
    SlaveForms[i].Show
  end;
end;

procedure TMasterForm.CascadeSlaves;
const
  dw = 24;
  dt = 24;
var
  i: Integer;
begin
  for i := 0 to SlaveCount - 1 do begin
    SlaveForms[i].Width := Screen.Width - SlaveCount * dw;
    SlaveForms[i].Height := Screen.Height - SlaveCount * dt;
    SlaveForms[i].Left := i * dw;
    SlaveForms[i].Top := i * dt;
  end;
end;

function TMasterForm.CloseQuery: Boolean;
var
  i: Integer;
begin
  for i := 0 to SlaveCount - 1 do begin
    Result := SlaveForms[i].CloseQuery;
    if not Result then Exit
  end;
  Result := inherited CloseQuery
end;

procedure TMasterForm.RemoveSlave(ASlave: TForm);
var
  i: Integer;
begin
  i := SlaveList.IndexOf(ASlave);
  if i > -1 then
    SlaveList.Delete(i);
  if (SlaveCount = 0) then Close
  else begin
    if i >= SlaveCount then i := SlaveCount - 1;
    with SlaveForms[i] do begin
      Show;
      BringToFront
    end;
  end;
end;

procedure TMasterForm.TileSlaves;
var
  A, q: Extended;
  w, h, L, T, i: Integer;
begin
  if SlaveCount > 0 then begin
    A := Screen.Width * Screen.Height / SlaveCount;
    q := Screen.Width / Screen.Height;
    w := Round(Int(Sqrt(A * q)));
    h := Round(Int(w / q));
    L := 0; T := 0;
    for i := 0 to SlaveCount - 1 do begin
      SlaveForms[i].Left := L;
      SlaveForms[i].Top := T;
      SlaveForms[i].Width := w;
      SlaveForms[i].Height := h;
      FormAdjust(SlaveForms[i]);
      L := L + w;
      if L >= Screen.Width then begin
        L := 0;
        T := T + h
      end;
    end;
  end;
end;

end.

