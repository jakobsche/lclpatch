{
 /***************************************************************************
                                   dwg.pas
                                   -------


 ***************************************************************************/

 *****************************************************************************
  This file is part of the Lazarus packages by Andreas Jakobsche

  See the file COPYING.modifiedLGPL.txt, included in this distribution,
  for details about the license.
 *****************************************************************************
}
unit Dwg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, ExtCtrls;

type

  { TVector }

  TVector = class(TComponent)
  private
    FEinheitsvektor: TVector;
    FX, FY: Extended;
    FT: TDateTime;
    function GetAbs: Extended;
    function GetEinheitsvektor: TVector;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    property Abs: Extended read GetAbs;
    property Einheitsvektor: TVector read GetEinheitsvektor;
  published
    property X: Extended read FX write FX;
    property Y: Extended read FY write FY;
    property T: TDateTime read FT write FT;
  end;

  { TRectangle }

  TRectangle = class(TComponent)
  private
    FLeftBottom, FExtent, FRightTop: TVector;
    function GetExtent: TVector;
    function GetLeftBottom: TVector;
    function GetRightTop: TVector;
    procedure SetExtent(AValue: TVector);
    procedure SetLeftBottom(AValue: TVector);
    procedure SetRightTop(AValue: TVector);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  published
    property LeftBottom: TVector read GetLeftBottom write SetLeftBottom;
    property RightTop: TVector read GetRightTop write SetRightTop;
    property Extent: TVector read GetExtent write SetExtent;
  end;

  TDrawing = class;

  { TDrawingItem }

  TDrawingItem = class(TComponent)
  private
    FArea: TRectangle;
    FColor: TColor;
    FSelected: Boolean;
    FSelectedColor: TColor;
    function GetArea: TRectangle; virtual;
    function GetDrawing: TDrawing;
    procedure SetColor(AValue: TColor); virtual;
    procedure SetSelected(AValue: Boolean); virtual;
    procedure SetSelectedColor(AValue: TColor); virtual;
  protected
    {procedure LineTo(AVector: TVector); virtual;
    procedure MoveTo(AVector: TVector); virtual;}
    function GetPosition: TVector; virtual;
    procedure SetPosition(AValue: TVector); virtual;
    property Drawing: TDrawing read GetDrawing;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    function Contains(AVector: TVector): Boolean; virtual;
    procedure Draw; virtual; abstract;
    procedure Print; virtual; abstract;
    property Area: TRectangle read GetArea;
    property Selected: Boolean read FSelected write SetSelected;
  published
    property SelectedColor: TColor read FSelectedColor write SetSelectedColor;
    property Color: TColor read FColor write SetColor;
    property Position: TVector read GetPosition write SetPosition;
  end;

  { Geradenabschnitt der alles zum Zeichnen seiner selbst enthält aber auf
    externe Daten (Vektoren für Anfang und Ende) angewendet wird }

  { TStraightLineSection }

  TStraightLineSection = class(TDrawingItem)
  private
    function GetDiff: TVector;
  private
    FA, FB, FDiff: TVector;
    function GetLength: Extended;
    {function GetArea: TRectangle; override;} {kein GetArea, weil nie als TFigure.Items[i] verwendet}
    property Diff: TVector read GetDiff;
  public
    procedure Draw; override;
    procedure Print; override;
    property Length: Extended read GetLength;
  published
  { Begrenzungen }
    property A: TVector read FA write FA;
    property B: TVector read FB write FB;
  end;

{ TFigure }

  TFigure = class(TDrawingItem)
  private
    FItemList, FSelectedList: TList;
    function GetItemList: TList;
    function GetSelectedList: TList;
    procedure SetColor(AValue: TColor); override;
    procedure SetSelectedColor(AValue: TColor); override;
  private
    function GetItemCount: Integer;
    function GetItems(i: Integer): TDrawingItem;
    function GetSelectedItems(i: Integer): TDrawingItem;
    function GetSelectedCount: Integer;
    procedure ReadItems(Reader: TReader);
    procedure SetSelected(AValue: Boolean); override;
    procedure WriteItems(Writer: TWriter);
    property ItemList: TList read GetItemList;
    property SelectedList: TList read GetSelectedList;
  protected
    procedure DefineProperties(Filer: TFiler); override;
    function GetArea: TRectangle; override;
  public
    destructor Destroy; override;
    procedure Append(AnItem: TDrawingItem);
    procedure Clear;
    procedure Deselect(AnItem: TDrawingItem);
    procedure Draw; override;
    procedure Print; override;
    procedure Select(AnItem: TDrawingItem);
    procedure ToggleSelection(AnItem: TDrawingItem);
    property ItemCount: Integer read GetItemCount;
    property Items[i: Integer]: TDrawingItem read GetItems;
    property SelectedItems[i: Integer]: TDrawingItem read GetSelectedItems;
    property SelectedCount: Integer read GetSelectedCount;
  end;

  TFrameBorderIndex = (fbBottom, fbRight, fbTop, fbLeft);

  { TFrame }

  TFrame = class(TFigure) {rechteckiger Rahmen mit Seiten parallel zu den
    Koordinatenachsen}
  private
    FBorders: array[TFrameBorderIndex] of TStraightLineSection;
    FHeight: Extended;
    FWidth: Extended;
    function GetBorders(AnIndex: TFrameBorderIndex): TStraightLineSection;
    function GetLeftBottom: TVector;
    procedure SetBorders(AnIndex: TFrameBorderIndex;
      AValue: TStraightLineSection);
    procedure SetHeight(AValue: Extended);
    procedure SetLeftBottom(AValue: TVector);
    procedure SetWidth(AValue: Extended);
  public
    procedure Draw; override;
    property Borders[AnIndex: TFrameBorderIndex]: TStraightLineSection read GetBorders write SetBorders; {Seiten des Rechtecks}
  published
    property Height: Extended read FHeight write SetHeight;
    property Width: Extended read FWidth write SetWidth;
    property LeftBottom: TVector read GetLeftBottom write SetLeftBottom;
  end;

  { TTextArea }

  TTextArea = class(TDrawingItem)
  private
    {FFont: TFont;}
    FHeight: Extended;
    FText: string;
    FWidth: Extended;
    function GetArea: TRectangle; override;
    {function GetFont: TFont;}
    {function GetHeight: Extended;}
    function GetWidth: Extended;
    {procedure SetFont(AValue: TFont);
    procedure SetHeight(AValue: Extended);}
    procedure SetText(AValue: string);
    {procedure SetWidth(AValue: Extended);}
  protected
    function GetPosition: TVector; override;
    {procedure SetColor(AValue: TColor); override;}
    procedure SetPosition(AValue: TVector); override;
  public
    {destructor Destroy; override;}
    procedure Draw; override;
    procedure Print; override;
  published
    {property Font: TFont read GetFont write SetFont;}
    property Text: string read FText write SetText;
    property Height: Extended read FHeight write FHeight;
    property Width: Extended read GetWidth write FWidth;
  end;

  TDrawing = class(TFigure)
  private
    FPaintBox: TPaintBox;
    FLeftBottom, FPosition: TVector;
    FPixelsPerMillimeter: Extended;
    {FYPixelsPerMillimeter: Extended;}
    function GetLeftBottom: TVector;
    function GetPixelsPerInch: Integer;
    procedure SetLeftBottom(AValue: TVector);
    procedure SetPixelsPerInch(AValue: Integer);
    procedure SetPixelsPerMillimeter(AValue: Extended);
    {function GetPosition: TVector;
    procedure SetPosition(AValue: TVector);}
  protected
    function FindBorder(A, B: TVector): TVector;
    function IsInPaintRect(AVector: TVector): Boolean;
    function PointToVector(AVector: TVector; APoint: TPoint): TVector;
    function VectorToPoint(AVector: TVector): TPoint;
  public
    {procedure LineTo(AVector: TVector); override;
    procedure MoveTo(AVector: TVector); override;}
    procedure Draw; override;
    procedure Focus;
    function PointToVector(AVector: TVector; X, Y: Integer): TVector;
    property PaintBox: TPaintBox read FPaintBox write FPaintBox;
    {property Position: TVector read GetPosition write SetPosition;}
    property PixelsPerInch: Integer read GetPixelsPerInch write SetPixelsPerInch;
    property PixelsPerMillimeter: Extended read FPixelsPerMillimeter write SetPixelsPerMillimeter;
    {property XPixelsPerMillimeter: Extended read FXPixelsPerMillimeter write FXPixelsPerMillimeter;
    property YPixelsPerMillimeter: Extended read FYPixelsPerMillimeter write FYPixelsPerMillimeter;}
  published
    property LeftBottom: TVector read GetLeftBottom write SetLeftBottom;
  end;

  { TPolygon }

  TPolygon = class(TDrawingItem)
  private
    FAcceleration: TVector;
    FEdgeList: TList;
    FVelocity: TVector;
    function GetEdgeList: TList;
  private
    FClosed: Boolean;
    FPrecision: Extended;
    function GetAcceleration(i: Integer): TVector;
    function GetArea: TRectangle; override;
    function GetEdgeCount: Integer;
    function GetEdges(i: Integer): TVector;
    function GetVelocities(i: Integer): TVector;
    procedure ReadEdges(Reader: TReader);
    procedure WriteEdges(Writer: TWriter);
    property EdgeList: TList read GetEdgeList;
  protected
    procedure DefineProperties(Filer: TFiler); override;
  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;
    procedure Append(x, y, t: Extended);
    procedure Clear;
    procedure Draw; override;
    procedure Print; override;
    property EdgeCount: Integer read GetEdgeCount;
    property Edges[i: Integer]: TVector read GetEdges;
    property Acceleration[i: Integer]: TVector read GetAcceleration;
    property Velocities[i: Integer]: TVector read GetVelocities;
  published
    property Closed: Boolean read FClosed write FClosed;
    property Precision: Extended read FPrecision write FPrecision;
  end;

  TTrack = class(TFigure)
  public

  end;

function Difference(Ref, A, B: TVector): TVector;

function Sum(Ref, A, B: TVector): TVector;

function Product(Ref, A: TVector; B: Extended): TVector;

implementation

uses
{Nur zum Debuggen:}  Dialogs,
  Streaming2, Printers;

function Difference(Ref, A, B: TVector): TVector;
begin
  if Ref = nil then Ref := TVector.Create(nil);
  if (A <> nil) and (B <> nil) then begin
    Ref.X := A.X - B.X;
    Ref.Y := A.Y - B.Y;
    Ref.T := A.T - B.T;
  end;
  Result := Ref
end;

function Sum(Ref, A, B: TVector): TVector;
begin
  if not Assigned(Ref) then Ref := TVector.Create(nil);
  Ref.X := A.X + B.X;
  Ref.Y := A.Y + B.Y;
  Ref.T := A.T + B.T;
  Result := Ref
end;

function Product(Ref, A: TVector; B: Extended): TVector;
begin
  Ref.X := A.X * B;
  Ref.Y := A.Y * B;
  Result := Ref
end;

{ TTextArea }

function TTextArea.GetArea: TRectangle;
begin
  Result:=inherited GetArea;
  Result.Extent.Y := Height;
  Result.Extent.X := Width;
end;

{function TTextArea.GetFont: TFont;
begin
  if not Assigned(FFont) then begin
    FFont := TFont.Create;
    if Drawing <> nil then
      if Drawing.PaintBox <> nil then FFont.Assign(Drawing.PaintBox.Canvas.Font)
  end;
  Result := FFont
end;}

function TTextArea.GetWidth: Extended;
begin
  if Drawing <> nil then
    if Drawing.PaintBox <> nil then begin
      Drawing.PaintBox.Canvas.Font.Height := -Round(Height * Drawing.PixelsPerMillimeter);
      Result := Drawing.PaintBox.Canvas.TextWidth(Text) / Drawing.PixelsPerMillimeter;
      FWidth := Result;
      Exit
    end;
  Result := 0
end;

function TTextArea.GetPosition: TVector;
begin
  Result := Area.LeftBottom
end;

{procedure TTextArea.SetColor(AValue: TColor);
begin
  inherited SetColor(AValue);
  Font.Color := AValue
end;}

{procedure TTextArea.SetFont(AValue: TFont);
begin
  GetFont.Assign(AValue)
end;}

{procedure TTextArea.SetHeight(AValue: Extended);
begin
  FHeight := AValue
end;}

procedure TTextArea.SetPosition(AValue: TVector);
begin
  Area.LeftBottom.Assign(AValue);
  Area.Extent.X := Width;
  Area.Extent.Y := Height
end;

procedure TTextArea.SetText(AValue: string);
begin
  if FText=AValue then Exit;
  FText:=AValue;
  GetWidth;
end;

{procedure TTextArea.SetWidth(AValue: Extended);
begin
  FWidth := AValue
end;}

{destructor TTextArea.Destroy;
begin
  inherited Destroy;
end;}

procedure TTextArea.Draw;
var
  P: TPoint;
begin
  if Drawing = nil then Exit;
  if Drawing.PaintBox = nil then Exit;
  P := Drawing.VectorToPoint(Position);
  if Selected then Drawing.PaintBox.Canvas.Font.Color := SelectedColor
  else Drawing.PaintBox.Canvas.Font.Color := Color;
  Drawing.PaintBox.Canvas.Font.PixelsPerInch := Drawing.PixelsPerInch;
  Drawing.PaintBox.Canvas.Font.Height := -Round(Height * Drawing.PixelsPerMillimeter);
  with Drawing.PaintBox.Canvas do begin
    TextOut(P.X, P.Y - TextHeight(Text), Text)
  end;
end;

procedure TTextArea.Print;
var
  P: TPoint;
begin
  P := Drawing.VectorToPoint(Position);
  Printer.Canvas.Font.Color := Color;
  Printer.Canvas.Font.PixelsPerInch := Drawing.PixelsPerInch;
  Printer.Canvas.Font.Height := -Round(Height * Drawing.PixelsPerMillimeter);
  with Printer.Canvas do
    TextOut(P.X, P.Y - TextHeight(Text), Text)
end;

{ TFrame }

function TFrame.GetBorders(AnIndex: TFrameBorderIndex): TStraightLineSection;
begin
  if not Assigned(FBorders[AnIndex]) then
    FBorders[AnIndex] := TStraightLineSection.Create(Self);
  Result := FBorders[AnIndex];
  case AnIndex of
    fbBottom: begin
        Result.A := LeftBottom;
        Result.B := LeftBottom;
        Result.B.X := Result.B.X + Width;
      end;
    fbRight:;
    fbTop:;
    fbLeft:;
  end;
end;

function TFrame.GetLeftBottom: TVector;
begin
  Result := Area.LeftBottom
end;

procedure TFrame.SetBorders(AnIndex: TFrameBorderIndex;
  AValue: TStraightLineSection);
begin

end;

procedure TFrame.SetHeight(AValue: Extended);
begin
  if FHeight=AValue then Exit;
  FHeight:=AValue;
end;

procedure TFrame.SetLeftBottom(AValue: TVector);
begin
  Area.LeftBottom.Assign(AValue)
end;

procedure TFrame.SetWidth(AValue: Extended);
begin
  if FWidth=AValue then Exit;
  FWidth:=AValue;
end;

procedure TFrame.Draw;
begin
  inherited Draw;
end;

{ TRectangle }

function TRectangle.GetExtent: TVector;
begin
  if not Assigned(FExtent) then FExtent := TVector.Create(Self);
  Result := FExtent
end;

function TRectangle.GetLeftBottom: TVector;
begin
  if not Assigned(FLeftBottom) then FLeftBottom := TVector.Create(Self);
  Result := FLeftBottom
end;

function TRectangle.GetRightTop: TVector;
begin
  Result := Sum(FRightTop, LeftBottom, Extent)
end;

procedure TRectangle.SetExtent(AValue: TVector);
var
  LB: Extended;
begin
  if AValue.X >= 0 then GetExtent.X := AValue.X
  else begin
    LB := LeftBottom.X + AValue.X;
    GetExtent.X := - AValue.X;
    LeftBottom.X := LB
  end;
  if AValue.Y >= 0 then GetExtent.Y := AValue.Y
  else begin
    LB := LeftBottom.Y + AValue.Y;
    GetExtent.Y := -AValue.Y;
    LeftBottom.Y := LB
  end;
end;

procedure TRectangle.SetLeftBottom(AValue: TVector);
begin
  GetLeftBottom.Assign(AValue)
end;

procedure TRectangle.SetRightTop(AValue: TVector);
begin
  if LeftBottom.X > AValue.X then begin
    LeftBottom.X := AValue.X;
    Extent.X := 0
  end
  else Extent.X := AValue.X - LeftBottom.X;
  if LeftBottom.Y > AValue.Y then begin
    LeftBottom.Y := AValue.Y;
    Extent.Y := 0
  end
  else Extent.Y := AValue.Y - LeftBottom.Y
end;

procedure TRectangle.AssignTo(Dest: TPersistent);
begin
  if Dest is TRectangle then begin
    (Dest as TRectangle).LeftBottom := LeftBottom;
    (Dest as TRectangle).Extent := Extent
  end;
end;

{ TStraightLineSection }

{function TStraightLineSection.GetArea: TRectangle;
begin
  Result := inherited GetArea;
  if A.X < B.X then begin
    Result.LeftBottom.X := A.X;
    Result.RightTop.X := B.X
  end
  else begin
    Result.LeftBottom.X := B.X;
    Result.RightTop.X := A.X
  end;
  if A.Y < B.Y then begin
    Result.LeftBottom.Y := A.Y;
    Result.RightTop.Y := B.Y
  end
  else begin
    Result.LeftBottom.Y := B.Y;
    Result.RightTop.Y := A.Y
  end;
end;}

function TStraightLineSection.GetDiff: TVector;
begin
  if not Assigned(FDiff) then FDiff := TVector.Create(Self);
  if (A <> nil) and (B <> nil) then Result := Difference(FDiff, B, A)
  else Result := FDiff
end;

function TStraightLineSection.GetLength: Extended;
begin
  Result := Diff.Abs
end;

procedure TStraightLineSection.Draw;
begin
  if Drawing <> nil then
      if Drawing.PaintBox <> nil then
        if Drawing.IsInPaintRect(A) and Drawing.IsInPaintRect(B) then begin
          if Selected then Drawing.PaintBox.Canvas.Pen.Color := SelectedColor
          else Drawing.PaintBox.Canvas.Pen.Color := Color;
          with Drawing do begin
            PaintBox.Canvas.MoveTo(VectorToPoint(A));
            PaintBox.Canvas.LineTo(VectorToPoint(B))
          end;
        end;
end;

procedure TStraightLineSection.Print;
begin
  if Drawing <> nil then
    if Drawing.IsInPaintRect(A) and Drawing.IsInPaintRect(B) then begin
      if Selected then Printer.Canvas.Pen.Color := SelectedColor
      else Printer.Canvas.Pen.Color := Color;
      with Drawing do begin
        Printer.Canvas.MoveTo(VectorToPoint(A));
        Printer.Canvas.LineTo(VectorToPoint(B))
      end;
    end;
end;

{ TVector }

function TVector.GetAbs: Extended;
begin
  Result := Sqrt(Sqr(X) + Sqr(Y))
end;

function TVector.GetEinheitsvektor: TVector;
begin
  if not Assigned(FEinheitsvektor) then FEinheitsvektor := TVector.Create(Self);
  FEinheitsvektor.X := X / Abs;
  FEinheitsvektor.Y := Y / Abs;
  Result := FEinheitsvektor
end;

procedure TVector.AssignTo(Dest: TPersistent);
var
  D: TVector absolute Dest;
begin
  if Dest is TVector then begin
    D.X := X;
    D.Y := Y;
  end
  else inherited AssignTo(Dest)
end;

{ TDrawing }

{function TDrawing.GetPosition: TVector;
begin
  if not Assigned(FPosition) then FPosition := TVector.Create(Self);
  Result := FPosition
end;}

function TDrawing.GetLeftBottom: TVector;
begin
  if not Assigned(FLeftBottom) then FLeftBottom := TVector.Create(Self);
  Result := FLeftBottom
end;

function TDrawing.GetPixelsPerInch: Integer;
begin
  Result := Round(PixelsPerMillimeter * 25.4)
end;

procedure TDrawing.SetLeftBottom(AValue: TVector);
begin
  GetLeftBottom.Assign(AValue)
end;

procedure TDrawing.SetPixelsPerInch(AValue: Integer);
begin
  PixelsPerMillimeter := AValue / 25.4
end;

procedure TDrawing.SetPixelsPerMillimeter(AValue: Extended);
begin
  if FPixelsPerMillimeter=AValue then Exit;
  FPixelsPerMillimeter:=AValue;
end;

function TDrawing.FindBorder(A, B: TVector): TVector;
begin

end;

function TDrawing.IsInPaintRect(AVector: TVector): Boolean;
var
  P: TPoint;
begin
  if PaintBox <> nil then begin
    P := VectorToPoint(AVector);
    Result := (P.X >= 0) and (P.X < PaintBox.Width) and (P.Y >= 0) and (P.Y < PaintBox.Height)
  end
  else Result := False;
end;

function TDrawing.PointToVector(AVector: TVector; APoint: TPoint): TVector;
var
  x, y: Integer;
begin
  if PaintBox <> nil then begin
    if AVector = nil then AVector := TVector.Create(nil);
    AVector.X := LeftBottom.X + APoint.X / PixelsPerMillimeter;
    AVector.Y := LeftBottom.Y + (PaintBox.Height - APoint.Y) / PixelsPerMillimeter
  end;
  Result := AVector
end;

function TDrawing.PointToVector(AVector: TVector; X, Y: Integer): TVector;
begin
  Result := PointToVector(AVector, Point(X, Y))
end;

function TDrawing.VectorToPoint(AVector: TVector): TPoint;
var
  C: TVector;
begin
  if AVector = nil then Result := Point(-1, -1)
  else begin
    C := Difference(nil, AVector, LeftBottom);
    try
      Result.X := Round(C.X * PixelsPerMillimeter);
      Result.Y := PaintBox.Height - Round(C.Y * PixelsPerMillimeter);
    finally
      C.Free
    end
  end;
end;

procedure TDrawing.Draw;
begin
  if PaintBox <> nil then with PaintBox.Canvas do begin
    FillRect(PaintBox.ClientRect);

  end;
  inherited Draw;
end;

{ TDrawingItem }

procedure TDrawingItem.SetColor(AValue: TColor);
begin
  if FColor=AValue then Exit;
  FColor:=AValue;
  if not Selected then Draw
end;

procedure TDrawingItem.SetSelected(AValue: Boolean);
begin
  if FSelected=AValue then Exit;
  FSelected:=AValue;
  Draw
end;

procedure TDrawingItem.SetSelectedColor(AValue: TColor);
begin
  if FSelectedColor=AValue then Exit;
  FSelectedColor:=AValue;
  if Selected then Draw
end;

function TDrawingItem.GetPosition: TVector;
begin
  Result := Area.LeftBottom;
end;

procedure TDrawingItem.SetPosition(AValue: TVector);
begin
  Area.LeftBottom.Assign(AValue);
end;

constructor TDrawingItem.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  if AnOwner is TFigure then begin
    TFigure(AnOwner).Append(Self);
    Color := TFigure(AnOwner).Color;
    SelectedColor := TFigure(AnOwner).SelectedColor;
    if TFigure(Owner).Selected then TFigure(Owner).Select(Self)
  end;
end;

destructor TDrawingItem.Destroy;
var
  x: Integer;
  Fig: TFigure;
begin
  if Owner <> nil then
    if Owner is TFigure then begin
      TComponent(Fig) := Owner;
      if Fig.ItemCount > 0 then begin
        x := Fig.ItemList.IndexOf(Self);
        if x >= 0 then Fig.ItemList.Delete(x);
      end
    end;
  inherited Destroy
end;

function TDrawingItem.Contains(AVector: TVector): Boolean;
begin
  Result := (AVector.X >= Area.LeftBottom.X) and (AVector.X <= Area.RightTop.X)
    and (AVector.Y >= Area.LeftBottom.Y) and (AVector.Y <= Area.RightTop.Y)
end;

procedure TDrawing.Focus;
var
  x, y: Extended;
begin
    if PaintBox <> nil then begin
      LeftBottom := Area.LeftBottom;
      if Area.Extent.X > 0 then x := PaintBox.Width / Area.Extent.X
      else x := PixelsPerMillimeter;
      if Area.Extent.Y > 0 then y := PaintBox.Height / Area.Extent.Y
      else y := PixelsPerMillimeter;
      if y < x then x := y;
      PixelsPerMillimeter := x;
      Draw
    end;
end;

function TDrawingItem.GetArea: TRectangle;
begin
  if not Assigned(FArea) then FArea := TRectangle.Create(Self);
  Result := FArea;
end;

function TDrawingItem.GetDrawing: TDrawing;
var
  x: TComponent;
begin
  x := Self;
  while x <> nil do begin
    if x is TDrawing then begin
      Result := TDrawing(x);
      Exit
    end;
    x := x.Owner
  end;
  Result := nil
end;

{ TPolygon }

function TPolygon.GetEdgeList: TList;
begin
  if not Assigned(FEdgeList) then FEdgeList := TList.Create;
  Result := FEdgeList;
end;

function TPolygon.GetArea: TRectangle;
var
  i: Integer;
begin
  Result:=inherited GetArea;
  if EdgeCount > 0 then begin
    Result.LeftBottom := Edges[0];
    Result.RightTop := Edges[0];
    if EdgeCount > 1 then
      for i := 1 to EdgeCount - 1 do begin
        if Result.LeftBottom.X > Edges[i].X then Result.LeftBottom.X := Edges[i].X;
        if Result.LeftBottom.Y > Edges[i].Y then Result.LeftBottom.Y := Edges[i].Y;
        if Result.RightTop.X < Edges[i].X then Result.RightTop.X := Edges[i].X;
        if Result.RightTop.Y < Edges[i].Y then Result.RightTop.Y := Edges[i].Y
      end;
  end;
end;

function TPolygon.GetAcceleration(i: Integer): TVector;
begin
  if not Assigned(FAcceleration) then FAcceleration := TVector.Create(Self);
  Result := FAcceleration;
  if (i > 0) and (i < EdgeCount) then begin
    if Edges[i].T <> Edges[i-1].T then begin
      Result.X := (Velocities[i].X - Velocities[i-1].X) / (Edges[i].T - Edges[i-1].T);
      Result.Y := (Velocities[i].Y - Velocities[i-1].Y) / (Edges[i].T - Edges[i-1].T);
    end
    else Result := Acceleration[i-1]
  end
  else begin
    Result.X := 0;
    Result.Y := 0
  end;
end;

function TPolygon.GetEdgeCount: Integer;
begin
  if not Assigned(FEdgeList) then Result := 0
  else Result := EdgeList.Count
end;

function TPolygon.GetEdges(i: Integer): TVector;
begin
  Result := TVector(EdgeList[i])
end;

function TPolygon.GetVelocities(i: Integer): TVector;
begin
  if not Assigned(FVelocity) then FVelocity := TVector.Create(Self);
  Result := FVelocity;
  if (i > 0) and (i < EdgeCount) then
    if Edges[i].T > Edges[i-1].T then begin
      Result.X := (Edges[i].X - Edges[i-1].X) / (Edges[i].T - Edges[i-1].T);
      Result.Y := (Edges[i].Y - Edges[i-1].Y) / (Edges[i].T - Edges[i-1].T);
    end
    else Result := Velocities[i - 1]
  else begin
    Result.X := 0;
    Result.Y := 0
  end;
end;

procedure TPolygon.ReadEdges(Reader: TReader);
var
  i, n: Integer;
  x: TVector;
begin
  n := Reader.ReadInteger;
  if n > 0 then begin
    Reader.ReadListBegin;
    for i := 0 to n - 1 do begin
      x := TVector.Create(Self);
      EdgeList.Add(x);
      Reader.ReadComponent(x)
    end;
    Reader.ReadListEnd;
  end;
end;

procedure TPolygon.WriteEdges(Writer: TWriter);
var i: Integer;
begin
  Writer.WriteInteger(EdgeCount);
  if EdgeCount > 0 then begin
    Writer.WriteListBegin;
    for i := 0 to EdgeCount - 1 do Writer.WriteComponent(Edges[i]);
    Writer.WriteListEnd;
  end;
end;

procedure TPolygon.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('Edges', @ReadEdges, @WriteEdges, True)
end;

constructor TPolygon.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FPrecision := 0.1;
end;

destructor TPolygon.Destroy;
begin
  FEdgeList.Free;
  FEdgeList := nil;
  inherited Destroy;
end;

procedure TPolygon.Append(x, y, t: Extended);
var
  C, D, Edge: TVector;
begin
    Edge := TVector.Create(Self);
    Edge.X := x;
    Edge.Y := y;
    Edge.T := t;
    if EdgeCount = 0 then EdgeList.Add(Edge)
    else begin
      C := TVector.Create(Self);
      D := TVector.Create(Self);
      try
        if Difference(D, Edge, Edges[EdgeCount - 1]).Abs >= Precision then begin
          if EdgeCount <= 1 then EdgeList.Add(Edge)
          else begin
            Difference(C, Edges[EdgeCount - 2], Edges[EdgeCount - 1]);
            if C.Einheitsvektor = D.Einheitsvektor then begin
              Edges[EdgeCount - 1].Assign(Edge);
              Edge.Free
            end
            else EdgeList.Add(Edge)
          end
        end
        else
          Edge.Free
      finally
        D.Free;
        C.Free
      end
    end
end;

procedure TPolygon.Clear;
var i: Integer;
begin
  if EdgeCount > 0 then begin
    for i := 0 to EdgeCount - 1 do Edges[i].Free;
    EdgeList.Clear
  end;
end;

procedure TPolygon.Draw;
var
  i: Integer;
  LS: TStraightLineSection;
begin
  if Drawing <> nil then
    if EdgeCount >= 2 then begin
      LS := TStraightLineSection.Create(Self);
      try
        LS.Color := Color;
        for i := 0 to EdgeCount - 2 do begin
          LS.A := Edges[i];
          LS.B := Edges[i + 1];
          LS.Draw;
        end;
      finally
        LS.Free
      end;
      if EdgeCount >= 3 then
        if Closed then begin
          LS := TStraightLineSection.Create(Self);
          try
            LS.Color := Color;
            LS.A := Edges[EdgeCount - 1];
            LS.B := Edges[0];
            LS.Draw;
          finally
            LS.Free
          end;
        end;
    end;
end;

procedure TPolygon.Print;
var
  i: Integer;
  LS: TStraightLineSection;
begin
  if EdgeCount >= 2 then begin
    LS := TStraightLineSection.Create(Self);
    try
      LS.Color := Color;
      for i := 0 to EdgeCount - 2 do begin
        LS.A := Edges[i];
        LS.B := Edges[i + 1];
        LS.Print;
      end;
      if EdgeCount >= 3 then
        if Closed then begin
          LS.Color := Color;
          LS.A := Edges[EdgeCount - 1];
          LS.B := Edges[0];
          LS.Print;
        end;
    finally
      LS.Free
    end;
  end;
end;

{ TFigure }

function TFigure.GetItemList: TList;
begin
  if not Assigned(FItemList) then FItemList := TList.Create;
  Result := FItemList
end;

function TFigure.GetSelectedList: TList;
begin
  if not Assigned(FSelectedList) then FSelectedList := TList.Create;
  Result := FSelectedList
end;

procedure TFigure.SetColor(AValue: TColor);
var i: Integer;
begin
  inherited SetColor(AValue);
  for i := 0 to ItemCount - 1 do Items[i].Color := AValue
end;

procedure TFigure.SetSelectedColor(AValue: TColor);
var i: Integer;
begin
  inherited SetSelectedColor(AValue);
  for i := 0 to ItemCount - 1 do Items[i].SetSelectedColor(AValue);
end;

function TFigure.GetArea: TRectangle;
var
  i: Integer;
begin
  Result := inherited GetArea;
  if ItemCount > 0 then begin
    Assign(Items[0].Area);
    if ItemCount > 1 then
      for i := 1 to ItemCount - 1 do begin
        if Result.LeftBottom.X > Items[i].Area.LeftBottom.X then
          Result.LeftBottom.X := Items[i].Area.LeftBottom.X;
        if Result.LeftBottom.Y > Items[i].Area.LeftBottom.Y then
          Result.LeftBottom.Y := Items[i].Area.LeftBottom.Y;
        if Result.RightTop.X < Items[i].Area.RightTop.X then
          Result.RightTop.X := Items[i].Area.RightTop.X;
        if Result.RightTop.Y < Items[i].Area.RightTop.Y then
          Result.RightTop.Y := Items[i].Area.RightTop.Y
      end;
  end;
end;

function TFigure.GetItemCount: Integer;
begin
  if not Assigned(FItemList) then Result := 0
  else Result := ItemList.Count
end;

function TFigure.GetItems(i: Integer): TDrawingItem;
var
  R: TDrawingItem;
begin
  Pointer(Result) := ItemList[i];
end;

function TFigure.GetSelectedItems(i: Integer): TDrawingItem;
begin
  Pointer(Result) := SelectedList.Items[i]
end;

function TFigure.GetSelectedCount: Integer;
begin
  if not Assigned(FSelectedList) then Result := 0
  else Result := FSelectedList.Count
end;

procedure TFigure.ReadItems(Reader: TReader);
var
  i, n: Integer;
  x: TDrawingItem;
  CN: string;
begin
  n := Reader.ReadInteger;
  if n > 0 then begin
    Reader.ReadListBegin;
    for i := 0 to n - 1 do begin
      {CN := Reader.ReadString;
      if CN = 'TFigure' then x := TFigure.Create(Self)
      else x := TDrawingItem.Create(Self);}
      try
        Append(Reader.ReadComponent(nil) as TDrawingItem);
      except
        on EClassNotFound do begin
            raise
          end;
      end;
    end;
    Reader.ReadListEnd
  end;
end;

procedure TFigure.SetSelected(AValue: Boolean);
var i: Integer;
begin
  for i := 0 to ItemCount - 1 do
    if AValue then Select(Items[i])
    else Deselect(Items[i]);
  inherited SetSelected(AValue);
end;

procedure TFigure.WriteItems(Writer: TWriter);
var
  i: Integer;
begin
  Writer.WriteInteger(ItemCount);
  ShowMessage(Format('%s-Komponente mit %d Elementen', [ClassName, ItemCount]));
  if ItemCount > 0 then begin
    Writer.WriteListBegin;
    for i := 0 to ItemCount - 1 do begin
      {Writer.WriteString(Items[i].ClassName);}
      Writer.WriteComponent(Items[i]);
    end;
    Writer.WriteListEnd
  end;
end;

procedure TFigure.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('Items', @ReadItems, @WriteItems, True);
end;

destructor TFigure.Destroy;
begin
  FItemList.Free;
  FItemList := nil; {nötig, weil TDrawingItem-Komponenten beim Zerstören auf das
    Feld oder die Eigenschaft zugreifen}
  FreeAndNil(FSelectedList);
  inherited Destroy;
end;

procedure TFigure.Append(AnItem: TDrawingItem);
begin
  if AnItem <> nil then begin
    ItemList.Add(AnItem);
    if AnItem.Owner <> Self then begin
      if AnItem.Owner <> nil then AnItem.Owner.RemoveComponent(AnItem);
      InsertComponent(AnItem)
    end;
  end
end;

procedure TFigure.Clear;
var
  x: TDrawingItem;
begin
  while ItemCount > 0 do begin
    Pointer(x) := ItemList[0];
    x.Free
  end;
  FItemList.Free;
  FItemList := nil;
end;

procedure TFigure.Deselect(AnItem: TDrawingItem);
var i: Integer;
begin
  if AnItem <> nil then
    if AnItem.Selected then begin
      AnItem.Selected := False;
      with SelectedList do Delete(IndexOf(AnItem));
      if AnItem is TFigure then
        with TFigure(AnItem) do
          for i := 0 to ItemCount - 1 do Deselect(Items[i])
    end;
end;

procedure TFigure.Draw;
var
  i: Integer;
begin
  for i := 0 to ItemCount - 1 do
    Items[i].Draw;
end;

procedure TFigure.Print;
var
  i: Integer;
begin
  for i := 0 to ItemCount - 1 do Items[i].Print
end;

procedure TFigure.Select(AnItem: TDrawingItem);
var i: Integer;
begin
  if AnItem <> nil then
    if not AnItem.Selected then begin
      AnItem.Selected := True;
      SelectedList.Add(AnItem);
      if AnItem is TFigure then
        with TFigure(AnItem) do
          for i := 0 to ItemCount - 1 do Select(Items[i])
    end;
end;

procedure TFigure.ToggleSelection(AnItem: TDrawingItem);
begin
  if AnItem.Selected then Deselect(AnItem)
  else Select(AnItem)
end;

initialization

RegisterForStreaming(TTrack);
RegisterForStreaming(TPolygon)

end.

