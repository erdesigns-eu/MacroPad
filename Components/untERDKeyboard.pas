unit untERDKeyboard;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Controls, Vcl.Graphics,
  Winapi.Messages, System.Types, Vcl.Menus, GDIPlus, PNGImage;

type
  TERDKeyboardKey = class;
  TERDKeyboardKeySelect = procedure(const Key: TERDKeyboardKey; const Index: Integer) of object;

  TERDKeyboardKeySelectionStyle = (ssOutline, ssFilled);

  TERDKeyboardKey = class(TCollectionItem)
  private
    FKeyCode  : Integer;
    FReserved : Integer;

    FWidth    : Single;
    FHeight   : Single;
    FTop      : Single;
    FLeft     : Single;

    FColor    : TColor;
    FRect     : TRect;

    FLegendColor   : TColor;
    FLegendCaption : TCaption;
    FLegendPicture : TPicture;

    FSelected : Boolean;

    procedure SetKeyCode(const I: Integer);
    procedure SetReserved(const I: Integer);

    procedure SetWidth(const S: Single);
    procedure SetHeight(const S: Single);
    procedure SetTop(const S: Single);
    procedure SetLeft(const S: Single);

    procedure SetColor(const C: TColor);

    procedure SetLegendColor(const C: TColor);
    procedure SetLegendCaption(const C: TCaption);
    procedure SetLegendPicture(const P: TPicture);

    procedure SetSelected(const B: Boolean);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(AOWner: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    property ItemRect: TRect read FRect write FRect;
  published
    property KeyCode  : Integer read FKeyCode  write SetKeyCode  default 0;
    property Reserved : Integer read FReserved write SetReserved default 0;

    property Width  : Single read FWidth  write SetWidth;
    property Height : Single read FHeight write SetHeight;
    property Y      : Single read FTop    write SetTop;
    property X      : Single read FLeft   write SetLeft;

    property Color  : TColor read FColor  write SetColor  default $00cccccc;

    property LegendColor   : TColor   read FLegendColor   write SetLegendColor default clBlack;
    property LegendCaption : TCaption read FLegendCaption write SetLegendCaption;
    property LegendPicture : TPicture read FLegendPicture write SetLegendPicture;

    property Selected : Boolean read FSelected write SetSelected default false;
  end;

  TERDKeyboardKeys = class(TOwnedCollection)
  private
    FOnChange : TNotifyEvent;

    procedure ItemChanged(Sender: TObject);

    function GetItem(Index: Integer): TERDKeyboardKey;
    procedure SetItem(Index: Integer; const Value: TERDKeyboardKey);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TERDKeyboardKey;
    procedure Assign(Source: TPersistent); override;

    property Items[Index: Integer]: TERDKeyboardKey read GetItem write SetItem;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TERDKeyboardLayout = class(TCustomControl)
  private
    { Private declarations }

    { Buffer - Avoid flickering }
    FBuffer     : TBitmap;
    FUpdateRect : TRect;

    { Scroll Positions and Max }
    FScrollPosX : Integer;
    FScrollPosY : Integer;
    FScrollMaxX : Integer;
    FScrollMaxY : Integer;
    FOldScrollX : Integer;
    FOldScrollY : Integer;

    { Keys }
    FItems : TERDKeyboardKeys;

    { Settings }
    FKeyWidth  : Integer;
    FKeyHeight : Integer;
    FKeyCorner : Integer;

    FMarginX : Integer;
    FMarginY : Integer;

    FSelectionColor : TColor;
    FSelectionStyle : TERDKeyboardKeySelectionStyle;

    FZoom         : Integer;
    FEditorActive : Boolean;
    FBorder       : Boolean;
    FKeyPopup     : TPopupMenu;

    FOnSelect : TERDKeyboardKeySelect;
    FOnChange : TNotifyEvent;

    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;

    procedure SetScrollPosX(const I: Integer);
    procedure SetScrollPosY(const I: Integer);

    procedure SetItems(I: TERDKeyboardKeys);

    procedure SetKeyWidth(const I: Integer);
    procedure SetKeyHeight(const I: Integer);
    procedure SetKeyCorner(const I: Integer);

    procedure SetMarginX(const I: Integer);
    procedure SetMarginY(const I: Integer);

    procedure SetSelectionColor(const C: TColor);
    procedure SetSelectionStyle(const S: TERDKeyboardKeySelectionStyle);

    procedure SetZoom(const I : Integer);
    procedure SetBorder(const B: Boolean);
  protected
    { Protected declarations }
    procedure SettingsChanged(Sender: TObject);

    procedure Paint; override;
    procedure Resize; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;

    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    { Public declarations }
    procedure ClearSelection;
    function GetSelectionCount : Integer;
    procedure Preview(var PNG: TPNGImage);
    procedure DeleteSelected;
    procedure InsertNewKey;
    function SelCount : Integer;
    procedure SelectAll;
    procedure DuplicateSelected;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property UpdateRect: TRect read FUpdateRect write FUpdateRect;
  published
    { Published declarations }
    property Items: TERDKeyboardKeys read FItems write SetItems;

    property KeyWidth  : Integer read FKeyWidth  write SetKeyWidth  default 54;
    property KeyHeight : Integer read FKeyHeight write SetKeyHeight default 54;
    property KeyCorner : Integer read FKeyCorner write SetKeyCorner default 12;

    property MarginX : Integer read FMarginX write SetMarginX default 8;
    property MarginY : Integer read FMarginY write SetMarginY default 8;

    property SelectionColor : TColor read FSelectionColor write SetSelectionColor default $006C6CFF;
    property SelectionStyle : TERDKeyboardKeySelectionStyle read FSelectionStyle write SetSelectionStyle default ssFilled;

    property Zoom         : Integer    read FZoom         write SetZoom       default 100;
    property EditorActive : Boolean    read FEditorActive write FEditorActive default false;
    property Border       : Boolean    read FBorder       write SetBorder     default True;
    property KeyPopupMenu : TPopupMenu read FKeyPopup     write FKeyPopup;

    property OnSelect : TERDKeyboardKeySelect read FOnSelect write FOnSelect;
    property OnChange : TNotifyEvent          read FOnChange write FOnChange;

    property Align;
    property Anchors;
    property Color default clWindow;
    property Enabled;
    property Font;
    property TabOrder;
    property Visible;
  end;

procedure Register;

implementation

uses
  System.Math, VCL.Themes;

{ Clipboard Format }
const
  ClipboarFormatIdentifier = 'ERDesigns Keyboard Layout Editor';
var
  CF_EKLE : Word;

function DarkenColor(C: TColor; P: Byte) : TColor;
var
  R, G, B: Byte;
begin
  C := ColorToRGB(C);
  R := GetRValue(C);
  G := GetGValue(C);
  B := GetBValue(C);
  R := R - MulDiv(R, P, 100);
  G := G - MulDiv(G, P, 100);
  B := B - MulDiv(B, P, 100);
  Result := RGB(R, G, B);
end;

function LightenColor(C: TColor; P: Byte) : TColor;
var
  R, G, B: Byte;
begin
  C := ColorToRGB(C);
  R := GetRValue(C);
  G := GetGValue(C);
  B := GetBValue(C);
  R := R + MulDiv(255 - R, P, 100);
  G := G + MulDiv(255 - G, P, 100);
  B := B + MulDiv(255 - B, P, 100);
  Result := RGB(R, G, B);
end;

(******************************************************************************)
(*
(*  Keyboard Key (TERDKeyboardKey)
(*
(******************************************************************************)
constructor TERDKeyboardKey.Create(AOWner: TCollection);
begin
  inherited Create(AOwner);

  FKeyCode  := 0;
  FReserved := 0;

  Width  := 1;
  Height := 1;
  Y      := 0;
  X      := 0;

  FColor := $00cccccc;

  FLegendColor   := clBlack;
  FLegendCaption := '';
  FLegendPicture := TPicture.Create;
end;

destructor TERDKeyboardKey.Destroy;
begin
  FLegendPicture.Free;
  inherited Destroy;
end;

function TERDKeyboardKey.GetDisplayName : string;
begin
  if (FLegendCaption <> '') then
    Result := FLegendCaption
  else
    Result := Format('KeyCode %d', [KeyCode]);
end;

procedure TERDKeyboardKey.Assign(Source: TPersistent);
begin
  if Source is TERDKeyboardKey then
  begin
    FKeyCode  := TERDKeyboardKey(Source).KeyCode;
    FReserved := TERDKeyboardKey(Source).Reserved;

    FWidth  := TERDKeyboardKey(Source).Width;
    FHeight := TERDKeyboardKey(Source).Height;
    FTop    := TERDKeyboardKey(Source).Y;
    FLeft   := TERDKeyboardKey(Source).X;

    FColor  := TERDKeyboardKey(Source).Color;

    FLegendColor   := TERDKeyboardKey(Source).LegendColor;
    FLegendCaption := TERDKeyboardKey(Source).LegendCaption;
    FLegendPicture.Assign(TERDKeyboardKey(Source).LegendPicture);

    Changed(False);
  end else Inherited;
end;

procedure TERDKeyboardKey.SetKeyCode(const I: Integer);
begin
  if I <> KeyCode then
  begin
    FKeyCode := I;
    Changed(False);
  end;
end;

procedure TERDKeyboardKey.SetReserved(const I: Integer);
begin
  if I <> Reserved then
  begin
    FReserved := I;
    Changed(False);
  end;
end;

procedure TERDKeyboardKey.SetWidth(const S: Single);
begin
  if S <> Width then
  begin
    FWidth := S;
    Changed(False);
  end;
end;

procedure TERDKeyboardKey.SetHeight(const S: Single);
begin
  if S <> Height then
  begin
    FHeight := S;
    Changed(False);
  end;
end;

procedure TERDKeyboardKey.SetTop(const S: Single);
begin
  if S <> Y then
  begin
    if S >= 0 then FTop := S else FTop := 0;
    Changed(False);
  end;
end;

procedure TERDKeyboardKey.SetLeft(const S: Single);
begin
  if S <> X then
  begin
    if S >= 0 then FLeft := S else FLeft := 0;
    Changed(False);
  end;
end;

procedure TERDKeyboardKey.SetColor(const C: TColor);
begin
  if C <> Color then
  begin
    FColor := C;
    Changed(False);
  end;
end;

procedure TERDKeyboardKey.SetLegendColor(const C: TColor);
begin
  if C <> LegendColor then
  begin
    FLegendColor := C;
    Changed(False);
  end;
end;

procedure TERDKeyboardKey.SetLegendCaption(const C: TCaption);
begin
  if C <> LegendCaption then
  begin
    FLegendCaption := C;
    Changed(False);
  end;
end;

procedure TERDKeyboardKey.SetLegendPicture(const P: TPicture);
begin
  FLegendPicture.Assign(P);
  Changed(False);
end;

procedure TERDKeyboardKey.SetSelected(const B: Boolean);
begin
  if B <> Selected then
  begin
    FSelected := B;
    Changed(False);
  end;
end;

(******************************************************************************)
(*
(*  Keyboard Key Collection (TERDKeyboardKeys)
(*
(******************************************************************************)
constructor TERDKeyboardKeys.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TERDKeyboardKey);
end;

procedure TERDKeyboardKeys.ItemChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TERDKeyboardKeys.SetItem(Index: Integer; const Value: TERDKeyboardKey);
begin
  inherited SetItem(Index, Value);
  ItemChanged(Self);
end;

procedure TERDKeyboardKeys.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TERDKeyboardKeys.GetItem(Index: Integer) : TERDKeyboardKey;
begin
  Result := inherited GetItem(Index) as TERDKeyboardKey;
end;

function TERDKeyboardKeys.Add : TERDKeyboardKey;
begin
  Result := TERDKeyboardKey(inherited Add);
end;

procedure TERDKeyboardKeys.Assign(Source: TPersistent);
var
  LI   : TERDKeyboardKeys;
  Loop : Integer;
begin
  if (Source is TERDKeyboardKeys)  then
  begin
    LI := TERDKeyboardKeys(Source);
    Clear;
    for Loop := 0 to LI.Count - 1 do
        Add.Assign(LI.Items[Loop]);
  end else inherited;
end;

(******************************************************************************)
(*
(*  Keyboard Layout Editor (TERDKeyboardLayout)
(*
(******************************************************************************)

constructor TERDKeyboardLayout.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  { If the ControlStyle property includes csOpaque, the control paints itself
    directly. We dont want the control to accept controls - but this might
    change in the future so we leave it here commented out. offcourse we
    like to get click, double click and mouse events. }
  ControlStyle := ControlStyle + [csOpaque{, csAcceptsControls},
    csCaptureMouse, csClickEvents, csDoubleClicks];

  { We want to get focus }
  TabStop := True;

  { Keys - Items }
  FItems := TERDKeyboardKeys.Create(Self);
  FItems.OnChange := SettingsChanged;

  { Create Buffer }
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  FKeyWidth  := 54;
  FKeyHeight := 54;
  FKeyCorner := 12;

  FMarginX := 8;
  FMarginY := 8;

  SelectionStyle := ssFilled;
  SelectionColor := $006C6CFF;

  { Zoomfactor }
  FZoom := 100;
  { Can keys be moved by keyboard }
  FEditorActive := False;
  { Border }
  FBorder := True;

  { Register Clipboard Format }
  CF_EKLE := RegisterClipboardFormat(ClipboarFormatIdentifier);

  { Width / Height }
  Width  := 400;
  Height := 400;

  { Default color }
  Color := clWindow;
end;

destructor TERDKeyboardLayout.Destroy;
begin
  { Free Buffers }
  FBuffer.Free;

  { Free Items }
  FItems.Free;

  inherited Destroy;
end;

procedure TERDKeyboardLayout.SetScrollPosX(const I: Integer);
begin
  FScrollPosX := I;
  FScrollPosX := EnsureRange(FScrollPosX, 0, FScrollMaxX);
  if FOldScrollX <> FScrollPosX then Invalidate;
  FOldScrollX := FScrollPosX;
end;

procedure TERDKeyboardLayout.SetScrollPosY(const I: Integer);
begin
  FScrollPosY := I;
  FScrollPosY := EnsureRange(FScrollPosY, 0, FScrollMaxY);
  if FOldScrollY <> FScrollPosY then Invalidate;
  FOldScrollY := FScrollPosY;
end;

procedure TERDKeyboardLayout.SetItems(I: TERDKeyboardKeys);
begin
  FItems.Assign(I);
  Invalidate;
end;

procedure TERDKeyboardLayout.SetKeyWidth(const I: Integer);
begin
  if KeyWidth <> I then
  begin
    FKeyWidth := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDKeyboardLayout.SetKeyHeight(const I: Integer);
begin
  if KeyHeight <> I then
  begin
    FKeyHeight := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDKeyboardLayout.SetKeyCorner(const I: Integer);
begin
  if KeyCorner <> I then
  begin
    FKeyCorner := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDKeyboardLayout.SetMarginX(const I: Integer);
begin
  if MarginX <> I then
  begin
    FMarginX := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDKeyboardLayout.SetMarginY(const I: Integer);
begin
  if MarginY <> I then
  begin
    FMarginY := I;
    SettingsChanged(Self);
  end;
end;

procedure TERDKeyboardLayout.SetSelectionColor(const C: TColor);
begin
  if SelectionColor <> C then
  begin
    FSelectionColor := C;
    SettingsChanged(Self);
  end;
end;

procedure TERDKeyboardLayout.SetSelectionStyle(const S: TERDKeyboardKeySelectionStyle);
begin
  if SelectionStyle <> S then
  begin
    FSelectionStyle := S;
    SettingsChanged(Self);
  end;
end;

procedure TERDKeyboardLayout.SetZoom(const I: Integer);
begin
  if Zoom <> I then
  begin
    if (I >= 50) then FZoom := I else FZoom := 50;
    SettingsChanged(Self);
  end;
end;

procedure TERDKeyboardLayout.SetBorder(const B: Boolean);
begin
  if Border <> B then
  begin
    FBorder := B;
    Invalidate;
  end;
end;

procedure TERDKeyboardLayout.ClearSelection;
var
  I : Integer;
begin
  for I := 0 to Items.Count -1 do
  Items.Items[I].FSelected := False;
  Invalidate;
end;

function TERDKeyboardLayout.GetSelectionCount : Integer;
var
  I : Integer;
begin
  Result := 0;
  for I := 0 to Items.Count -1 do
  if Items.Items[I].Selected then Result := Result +1;
end;

procedure TERDKeyboardLayout.Preview(var PNG: TPNGImage);

  function RoundRect(Rect: TGPRectF; Corner: Single) : IGPGraphicsPath;
  var
    RoundRectPath : IGPGraphicsPath;
    I             : Single;
  begin
    RoundRectPath := TGPGraphicsPath.Create;
    if Corner <> 0 then I := Corner else I := 10;
    RoundRectPath.AddArc(Rect.Left, Rect.Top, I, I, 180, 90);
    RoundRectPath.AddArc(Rect.Right - I, Rect.Top, I, I, 270, 90);
    RoundRectPath.AddArc(Rect.Right - I, Rect.Bottom - I, I, I, 0, 90);
    RoundRectPath.AddArc(Rect.Left, Rect.Bottom - I, I, I, 90, 90);
    RoundRectPath.CloseFigure;
    Result := RoundRectPath;
  end;

  function PreviewWidth : Integer;
  var
    I, M : Integer;
  begin
    if Items.Count = 0 then Exit(0);
    M := 0;
    for I := 0 to Items.Count -1 do
    if Items.Items[I].ItemRect.Right > M then M := Items.Items[I].ItemRect.Right;
    Result := M + MarginX;
  end;

  function PreviewHeight : Integer;
  var
    I, M : Integer;
  begin
    if Items.Count = 0 then Exit(0);
    M := 0;
    for I := 0 to Items.Count -1 do
    if Items.Items[I].ItemRect.Bottom > M then M := Items.Items[I].ItemRect.Bottom;
    Result := M + MarginY;
  end;

  function KeyX(const Key: TERDKeyboardKey) : Single;
  begin
    Result := MarginX + (Key.X * KeyWidth);
  end;

  function KeyY(const Key: TERDKeyboardKey) : Single;
  begin
    Result := MarginY + (Key.Y * KeyHeight);
  end;

  procedure DrawKey(const Key: TERDKeyboardKey);
  var
    FGraphics      : IGPGraphics;

    FFontBrush     : IGPSolidBrush;
    FKeyOuterBrush : IGPSolidBrush;
    FKeyInnerBrush : IGPSolidBrush;

    FKeyOuterPen   : IGPPen;
    FKeyInnerPen   : IGPPen;
    FSelectionPen  : IGPPen;

    FFont          : TGPFont;
    FKeyRect       : TGPRectF;

    FOuterPath     : IGPGraphicsPath;
    FInnerPath     : IGPGraphicsPath;

    TextW, TextH   : Integer;
  begin
    FGraphics := TGPGraphics.Create(PNG.Canvas.Handle);
    FGraphics.SmoothingMode     := SmoothingModeAntiAlias;
    FGraphics.InterpolationMode := InterpolationModeHighQualityBicubic;

    FFontBrush    := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(Font.Color));
    FFont         := TGPFont.Create(Font.Name, Font.Size, [{FontStyleBold}]);

    // Filled selection
    if Key.Selected and (SelectionStyle = ssFilled) then
    begin
      FKeyOuterBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(SelectionColor));
      FKeyInnerBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(TColor(LightenColor(ColorToRGB(SelectionColor), 50))));
      FKeyOuterPen := TGPPen.Create(TGPColor.CreateFromColorRef(TColor(DarkenColor(ColorToRGB(SelectionColor), 20))));
      FKeyInnerPen := TGPPen.Create(TGPColor.CreateFromColorRef(TColor(DarkenColor(ColorToRGB(SelectionColor), 5))));
    end else
    // Filled normal
    begin
      FKeyOuterBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(Key.Color));
      FKeyInnerBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(TColor(LightenColor(ColorToRGB(Key.Color), 50))));
      FKeyOuterPen   := TGPPen.Create(TGPColor.CreateFromColorRef(TColor(DarkenColor(ColorToRGB(Key.Color), 20))));
      FKeyInnerPen   := TGPPen.Create(TGPColor.CreateFromColorRef(TColor(DarkenColor(ColorToRGB(Key.Color), 5))));
      FSelectionPen  := TGPPen.Create(TGPColor.CreateFromColorRef(SelectionColor));
    end;

    // Key Rect
    FKeyRect := TGPRectF.Create(
      KeyX(Key) +1,
      KeyY(Key) +1,
      (Key.Width * KeyWidth) -1,
      (Key.Height * KeyHeight) -1
    );
    Key.ItemRect := Rect(
       Floor(FKeyRect.X),
       Floor(FKeyRect.Y),
       Floor(FKeyRect.X) + Round(FKeyRect.Width),
       Floor(FKeyRect.Y) + Round(FKeyRect.Height)
    );

    // Pen sizes
    FKeyInnerPen.Width  := 1;
    FKeyInnerPen.Alignment := PenAlignmentInset;
    FKeyOuterPen.Width  := 1;
    FKeyOuterPen.Alignment := PenAlignmentInset;

    // Draw the key outer part
    FOuterPath := RoundRect(FKeyRect, KeyCorner);
    FGraphics.FillPath(FKeyOuterBrush, FOuterPath);
    FGraphics.DrawPath(FKeyOuterPen, FOuterPath);
    // Recalculate the rect for the inner part
    FKeyRect.X      := FKeyRect.X + 7;
    FKeyRect.Y      := FKeyRect.Y + 7;
    FKeyRect.Width  := FKeyRect.Width - 14;
    FKeyRect.Height := FKeyRect.Height - 14;
    // Draw the key inner part
    FInnerPath := RoundRect(FKeyRect, KeyCorner);
    FGraphics.FillPath(FKeyInnerBrush, FInnerPath);
    FGraphics.DrawPath(FKeyInnerPen, FInnerPath);

    // Draw the image
    if Assigned(Key.LegendPicture.Graphic) then
    begin
      PNG.Canvas.StretchDraw(Rect(
        Round(FKeyRect.Left),
        Round(FKeyRect.Top),
        Round(FKeyRect.Right),
        Round(FKeyRect.Bottom)
      ), Key.LegendPicture.Graphic);
    end;

    // Draw the caption
    if Trim(Key.LegendCaption) <> '' then
    begin
      with PNG.Canvas do
      begin
        Font := Font;
        Font.Size := Font.Size;
        TextW := TextWidth(Key.LegendCaption) + 5;
        TextH := TextHeight(Key.LegendCaption) + 5;
      end;
      FGraphics.DrawString(Key.LegendCaption, FFont, TGPPointF.Create(
        (FKeyRect.X + (FKeyRect.Width / 2)) - (TextW / 2),
        (FKeyRect.Y + (FKeyRect.Height / 2)) - (TextH / 2)
      ), nil, FFontBrush);
    end;
  end;

var
  I, W, H : Integer;
begin
  { Set the size of the Preview }
  W := PreviewWidth;
  H := PreviewHeight;
  if (W > 0) and (H > 0) and (Items.Count > 0) then
  PNG.SetSize(W, H);
  { Set a white background }
  with PNG.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(Rect(0, 0, W, H));
  end;
  { Draw the keys }
  for I := 0 to Items.Count -1 do DrawKey(Items.Items[I]);
end;

procedure TERDKeyboardLayout.DeleteSelected;
var
  I : Integer;
begin
  for I := Items.Count -1 downto 0 do
  if Items.Items[I].Selected then Items.Delete(I);
  if Assigned(OnSelect) then OnSelect(nil, -1);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TERDKeyboardLayout.InsertNewKey;
var
  Key : TERDKeyboardKey;
begin
  ClearSelection;
  Key := Items.Add;
  with Key do
  begin
    LegendCaption := 'New';
    Selected := True;
  end;
  if Assigned(OnSelect) then OnSelect(Key, Key.Index);
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TERDKeyboardLayout.SelCount : Integer;
var
  I : Integer;
begin
  Result := 0;
  for I := 0 to Items.Count -1 do
  if Items.Items[I].Selected then Inc(Result);
end;

procedure TERDKeyboardLayout.SelectAll;
var
  I : Integer;
begin
  for I := 0 to Items.Count -1 do
  Items.Items[I].FSelected := True;
  Invalidate;
  if Assigned(FOnSelect) then FOnSelect(nil, -1);
end;

procedure TERDKeyboardLayout.DuplicateSelected;
var
  I : Integer;
  F : Integer;
begin
  F := Items.Count;
  { Duplicate }
  for I := 0 to Items.Count -1 do
  if Items.Items[I].Selected then
  Items.Add.Assign(Items.Items[I]);
  { Select duplicates }
  ClearSelection;
  for I := F to Items.Count -1 do
  Items.Items[I].Selected := True;
end;

procedure TERDKeyboardLayout.SettingsChanged(Sender: TObject);
begin
  Invalidate;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TERDKeyboardLayout.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDKeyboardLayout.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDKeyboardLayout.Paint;

  procedure DrawBackground;
  var
    LDetails : TThemedElementDetails;
  begin
    with FBuffer.Canvas do
    begin
      if (Border = True) then
      begin
        LDetails := StyleServices.GetElementDetails(tcBackground);
        StyleServices.DrawElement(FBuffer.Canvas.Handle, LDetails, ClientRect);
      end else
      begin
        Brush.Color := Color;
        FillRect(ClientRect);
      end;
    end;
  end;

  function RoundRect(Rect: TGPRectF; Corner: Single) : IGPGraphicsPath;
  var
    RoundRectPath : IGPGraphicsPath;
    I             : Single;
  begin
    RoundRectPath := TGPGraphicsPath.Create;
    if Corner <> 0 then I := Corner else I := 10;
    RoundRectPath.AddArc(Rect.Left, Rect.Top, I, I, 180, 90);
    RoundRectPath.AddArc(Rect.Right - I, Rect.Top, I, I, 270, 90);
    RoundRectPath.AddArc(Rect.Right - I, Rect.Bottom - I, I, I, 0, 90);
    RoundRectPath.AddArc(Rect.Left, Rect.Bottom - I, I, I, 90, 90);
    RoundRectPath.CloseFigure;
    Result := RoundRectPath;
  end;

  function ScrollWidth : Integer;
  var
    I, M : Integer;
  begin
    if Items.Count = 0 then Exit(0);
    M := 0;
    for I := 0 to Items.Count -1 do
    if Items.Items[I].ItemRect.Right > M then M := Items.Items[I].ItemRect.Right;
    Result := M + Ceil((MarginX / 100) * Zoom);
    Result := IfThen((M + FScrollPosX > ClientWidth), Result, 0);
  end;

  function ScrollHeight : Integer;
  var
    I, M : Integer;
  begin
    if Items.Count = 0 then Exit(0);
    M := 0;
    for I := 0 to Items.Count -1 do
    if Items.Items[I].ItemRect.Bottom > M then M := Items.Items[I].ItemRect.Bottom;
    Result := M + Ceil((MarginY / 100) * Zoom);
    Result := IfThen((M + FScrollPosY > ClientHeight), Result, 0);
  end;

  function KeyX(const Key: TERDKeyboardKey) : Single;
  var
    M : Single;
    W : Single;
  begin
    M := (MarginX / 100) * Zoom;
    W := (KeyWidth / 100) * Zoom;
    Result := (M + (Key.X * W)) - FScrollPosX;
  end;

  function KeyY(const Key: TERDKeyboardKey) : Single;
  var
    M : Single;
    H : Single;
  begin
    M := (MarginY / 100) * Zoom;
    H := (KeyHeight / 100) * Zoom;
    Result := (M + (Key.Y * H)) - FScrollPosY;
  end;

  function KeyW(const Key: TERDKeyboardKey) : Single;
  var
    W : Single;
  begin
    W := (KeyWidth / 100) * Zoom;
    Result := Key.Width * W;
  end;

  function KeyH(const Key: TERDKeyboardKey) : Single;
  var
    H : Single;
  begin
    H := (KeyHeight / 100) * Zoom;
    Result := Key.Height * H;
  end;

  function KeyF(const Key: TERDKeyboardKey) : Single;
  begin
    Result := (Font.Size / 100) * Zoom;
  end;

  function KeyI : Single;
  begin
    Result := (7 / 100) * Zoom;
  end;

  procedure DrawKey(const Key: TERDKeyboardKey);
  var
    FGraphics      : IGPGraphics;

    FFontBrush     : IGPSolidBrush;
    FKeyOuterBrush : IGPSolidBrush;
    FKeyInnerBrush : IGPSolidBrush;

    FKeyOuterPen   : IGPPen;
    FKeyInnerPen   : IGPPen;
    FSelectionPen  : IGPPen;
    
    FFont          : TGPFont;
    FKeyRect       : TGPRectF;

    FOuterPath     : IGPGraphicsPath;
    FInnerPath     : IGPGraphicsPath;

    TextW, TextH   : Integer;
  begin
    FGraphics := TGPGraphics.Create(FBuffer.Canvas.Handle);
    FGraphics.SmoothingMode     := SmoothingModeAntiAlias;
    FGraphics.InterpolationMode := InterpolationModeHighQualityBicubic;

    FFontBrush    := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(Font.Color));
    FFont         := TGPFont.Create(Font.Name, KeyF(Key), [{FontStyleBold}]);

    // Filled selection
    if Key.Selected and (SelectionStyle = ssFilled) then
    begin
      FKeyOuterBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(SelectionColor));
      FKeyInnerBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(TColor(LightenColor(ColorToRGB(SelectionColor), 50))));
      FKeyOuterPen := TGPPen.Create(TGPColor.CreateFromColorRef(TColor(DarkenColor(ColorToRGB(SelectionColor), 20))));
      FKeyInnerPen := TGPPen.Create(TGPColor.CreateFromColorRef(TColor(DarkenColor(ColorToRGB(SelectionColor), 5))));
    end else
    // Filled normal
    begin
      FKeyOuterBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(Key.Color));
      FKeyInnerBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(TColor(LightenColor(ColorToRGB(Key.Color), 50))));
      FKeyOuterPen   := TGPPen.Create(TGPColor.CreateFromColorRef(TColor(DarkenColor(ColorToRGB(Key.Color), 20))));
      FKeyInnerPen   := TGPPen.Create(TGPColor.CreateFromColorRef(TColor(DarkenColor(ColorToRGB(Key.Color), 5))));
      FSelectionPen  := TGPPen.Create(TGPColor.CreateFromColorRef(SelectionColor));
    end;

    // Key Rect
    FKeyRect := TGPRectF.Create(
      KeyX(Key) +1,
      KeyY(Key) +1,
      KeyW(Key) -1,
      KeyH(Key) -1
    );
    Key.ItemRect := Rect(
       Floor(FKeyRect.X),
       Floor(FKeyRect.Y),
       Floor(FKeyRect.X) + Round(FKeyRect.Width),
       Floor(FKeyRect.Y) + Round(FKeyRect.Height)
    );
    
    // Pen sizes
    FKeyInnerPen.Width  := (1 / 100) * Zoom;
    FKeyInnerPen.Alignment := PenAlignmentInset;
    FKeyOuterPen.Width  := (1 / 100) * Zoom;
    FKeyOuterPen.Alignment := PenAlignmentInset;

    // Draw the key outer part
    FOuterPath := RoundRect(FKeyRect, (KeyCorner / 100) * Zoom);
    FGraphics.FillPath(FKeyOuterBrush, FOuterPath);
    FGraphics.DrawPath(FKeyOuterPen, FOuterPath);
    // Recalculate the rect for the inner part
    FKeyRect.X      := FKeyRect.X + KeyI;
    FKeyRect.Y      := FKeyRect.Y + KeyI;
    FKeyRect.Width  := FKeyRect.Width - (KeyI * 2);
    FKeyRect.Height := FKeyRect.Height - (KeyI * 2);
    // Draw the key inner part
    FInnerPath := RoundRect(FKeyRect, (KeyCorner / 100) * Zoom);
    FGraphics.FillPath(FKeyInnerBrush, FInnerPath);
    FGraphics.DrawPath(FKeyInnerPen, FInnerPath);

    // Draw the image
    if Assigned(Key.LegendPicture.Graphic) then
    begin
      FBuffer.Canvas.StretchDraw(Rect(
        Round(FKeyRect.Left),
        Round(FKeyRect.Top),
        Round(FKeyRect.Right),
        Round(FKeyRect.Bottom)
      ), Key.LegendPicture.Graphic);
    end;

    // Draw the caption
    if Trim(Key.LegendCaption) <> '' then
    begin
      with FBuffer.Canvas do
      begin
        Font := Font;
        Font.Size := Ceil(KeyF(Key));
        TextW := TextWidth(Key.LegendCaption) + Round((5 / 100) * Zoom);
        TextH := TextHeight(Key.LegendCaption) + Round((2 / 100) * Zoom);
      end;
      FGraphics.DrawString(Key.LegendCaption, FFont, TGPPointF.Create(
        (FKeyRect.X + (FKeyRect.Width / 2)) - (TextW / 2),
        (FKeyRect.Y + (FKeyRect.Height / 2)) - (TextH / 2)
      ), nil, FFontBrush);
    end;

    // Draw selection ?
    if Key.Selected and (SelectionStyle = ssOutline) then
    begin
      FSelectionPen.Width := (1 / 100) * Zoom;
      FGraphics.DrawPath(FSelectionPen, FOuterPath);
    end;
  end;

var
  X, Y, W, H, I : Integer;
  SI            : TScrollInfo;
begin

  { Set Max Scrollbar }
  FScrollMaxX := ScrollWidth;
  FScrollMaxY := ScrollHeight;

  { Set Buffer size }
  FBuffer.SetSize(ClientWidth, ClientHeight);

  { Background }
  DrawBackground;

  { Draw the keys }
  for I := 0 to Items.Count -1 do DrawKey(Items.Items[I]);
  
  { Now draw the Buffer to the components surface }
  X := UpdateRect.Left;
  Y := UpdateRect.Top;
  W := UpdateRect.Right - UpdateRect.Left;
  H := UpdateRect.Bottom - UpdateRect.Top;
  if (W <> 0) and (H <> 0) then
    { Only update part - invalidated }
    BitBlt(Canvas.Handle, X, Y, W, H, FBuffer.Canvas.Handle, X,  Y, SRCCOPY)
  else
    { Repaint the whole buffer to the surface }
    BitBlt(Canvas.Handle, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, X,  Y, SRCCOPY);

  { Vertical Scrollbar }
  SI.cbSize := Sizeof(SI);
  SI.fMask  := SIF_ALL;
  SI.nMin   := 0;
  SI.nMax   := FScrollMaxY;
  SI.nPage  := 100;
  SI.nPos   := FScrollPosY;
  SI.nTrackPos := SI.nPos;
  SetScrollInfo(Handle, SB_VERT, SI, True);

  { Horizontal Scrollbar }
  SI.cbSize := Sizeof(SI);
  SI.fMask  := SIF_ALL;
  SI.nMin   := 0;
  SI.nMax   := FScrollMaxX;
  SI.nPage  := 100;
  SI.nPos   := FScrollPosX;
  SI.nTrackPos := SI.nPos;
  SetScrollInfo(Handle, SB_HORZ, SI, True);
end;

procedure TERDKeyboardLayout.Resize;
begin
  //
end;

procedure TERDKeyboardLayout.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style or WS_HSCROLL or WS_VSCROLL and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TERDKeyboardLayout.WndProc(var Message: TMessage);
var
  SI : TScrollInfo;
begin
  inherited;
  case Message.Msg of
    // Capture Keystrokes
    WM_GETDLGCODE:
      Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTALLKEYS;

    // Horizontal Scrollbar
    WM_HSCROLL:
      begin
        if FScrollMaxX > 0 then
        case Message.WParamLo of
          SB_LEFT      : SetScrollPosX(0);
          SB_RIGHT     : SetScrollPosX(FScrollMaxX);
          SB_LINELEFT  : SetScrollPosX(FScrollPosX - 10);
          SB_LINERIGHT : SetScrollPosX(FScrollPosX + 10);
          SB_PAGELEFT  : SetScrollPosX(FScrollPosX - ClientWidth);
          SB_PAGERIGHT : SetScrollPosX(FScrollPosX + ClientWidth);
          SB_THUMBTRACK:
            begin
              ZeroMemory(@SI, SizeOf(SI));
              SI.cbSize := Sizeof(SI);
              SI.fMask := SIF_TRACKPOS;
              if GetScrollInfo(Handle, SB_HORZ, SI) then
              if SI.nTrackPos < FScrollMaxX then
                SetScrollPosX(SI.nTrackPos)
              else
                SetScrollPosX(FScrollMaxX);
            end;
        end;
        Message.Result := 0;
      end;

    // Vertical Scrollbar
    WM_VSCROLL:
      begin
        if FScrollMaxY > 0 then
        case Message.WParamLo of
          SB_TOP      : SetScrollPosY(0);
          SB_BOTTOM   : SetScrollPosY(FScrollMaxY);
          SB_LINEUP   : SetScrollPosY(FScrollPosY - 10);
          SB_LINEDOWN : SetScrollPosY(FScrollPosY + 10);
          SB_PAGEUP   : SetScrollPosY(FScrollPosY - ClientHeight);
          SB_PAGEDOWN : SetScrollPosY(FScrollPosY + ClientHeight);
          SB_THUMBTRACK:
            begin
              ZeroMemory(@SI, SizeOf(SI));
              SI.cbSize := Sizeof(SI);
              SI.fMask := SIF_TRACKPOS;
              if GetScrollInfo(Handle, SB_VERT, SI) then
              if SI.nTrackPos < FScrollMaxY then
                SetScrollPosY(SI.nTrackPos)
              else
                SetScrollPosY(FScrollMaxY);
            end;
        end;
        Message.Result := 0;
      end;

    { Enabled/Disabled - Redraw }
    CM_ENABLEDCHANGED:
      begin
        // ToDo: Clear key(s) selection
        Invalidate;
      end;

    { Focus is lost }
    WM_KILLFOCUS:
      begin
        { Maybe gray out the selected keys }
      end;

    WM_SETFOCUS:
      begin
        { Focus returned so redraw - if we use graying out of keys }
      end;

  end;
end;

function TERDKeyboardLayout.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  { During designtime there is no need for these events }
  if (csDesigning in ComponentState) then Exit;
  { Ignore when the component is disabled }
  if not Enabled then Exit;
  if (ssCtrl in Shift) then Zoom := Zoom + (WheelDelta div 10)
  else
  begin
    if (ssShift in Shift) then
      SetScrollPosX(FScrollPosX - (WheelDelta div 10))
    else
      SetScrollPosY(FScrollPosY - (WheelDelta div 10));
  end;
  Result := True;
  inherited;
end;

procedure TERDKeyboardLayout.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

  function MouseKeyIndex : Integer;
  var
    I : Integer;
  begin
    Result := -1;
    for I := 0 to Items.Count -1 do
    if PtInRect(Items.Items[I].ItemRect, Point(X, Y)) then
    begin
      Result := I;
    end;
  end;

var
  I : Integer;
  P : TPoint;
begin
  if (not Focused) and CanFocus then SetFocus;
  if (not Enabled) or (not EditorActive) then Exit;
  if Button = mbLeft then
  begin
    I := MouseKeyIndex;
    if (not (ssShift in Shift)) and (not (ssCtrl in Shift)) then ClearSelection;
    if (I > -1) then
    begin
      Items.Items[I].Selected := not Items.Items[I].Selected;
      if Assigned(FOnSelect) then
      begin
        if (GetSelectionCount = 1) then
          FOnSelect(Items.Items[I], I)
        else
          FOnSelect(nil, -1);
      end;
    end;
    if (GetSelectionCount <> 1) and Assigned(FOnSelect) then FOnSelect(nil, -1);
  end;
  if Button = mbRight then
  begin
    I := MouseKeyIndex;
    if (I > -1) and Assigned(KeyPopupMenu) then
    begin
      P := ClientToScreen(Point(Items.Items[I].ItemRect.Left, Items.Items[I].ItemRect.Bottom));
      KeyPopupMenu.Popup(P.X, P.Y);
    end;
  end;
  inherited;
end;

procedure TERDKeyboardLayout.KeyDown(var Key: Word; Shift: TShiftState);

  procedure MoveSelectedX(const X: Single);
  var
    I : Integer;
  begin
    for I := 0 to Items.Count -1 do
    if Items.Items[I].Selected then
    Items.Items[I].X := Items.Items[I].X + X;
    if Assigned(FOnChange) then FOnChange(Self);
  end;

  procedure MoveSelectedY(const Y: Single);
  var
    I : Integer;
  begin
    for I := 0 to Items.Count -1 do
    if Items.Items[I].Selected then
    Items.Items[I].Y := Items.Items[I].Y + Y;
    if Assigned(FOnChange) then FOnChange(Self);
  end;

begin
  { During designtime there is no need for these events }
  if (csDesigning in ComponentState) then Exit;
  { Ignore when the component is disabled }
  if (not Enabled) or (not EditorActive) then Exit;

  if not (ssCtrl in Shift) then
  case Key of
    VK_LEFT   : MoveSelectedX(-0.25);
    VK_UP     : MoveSelectedY(-0.25);
    VK_RIGHT  : MoveSelectedX(0.25);
    VK_DOWN   : MoveSelectedY(0.25);
    VK_DELETE,
    VK_BACK   : DeleteSelected;
    VK_INSERT : InsertNewKey;
  end;

  if (Key = Ord('A')) and (ssCtrl in Shift) then SelectAll;
  if (Key = Ord('D')) and (ssCtrl in Shift) then DuplicateSelected;

  inherited;
end;

procedure Register;
begin
  RegisterComponents('ERDesigns', [TERDKeyboardLayout]);
end;

end.
