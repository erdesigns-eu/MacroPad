unit untERDScriptEditor;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Controls, Vcl.Graphics,
  Winapi.Messages, System.Types, Vcl.Menus, GDIPlus;

type
  TERDScriptStep = class;

  TERDScriptStepEdit   = procedure(const Step: TERDScriptStep; const Index: Integer) of object;
  TERDScriptStepSelect = procedure(const Step: TERDScriptStep; const Index: Integer) of object;

  TERDScriptStepType = (sssEmpty, sssComment, sssVariable);

  TERDScriptStep = class(TCollectionItem)
  private
    FLines    : Integer;
    FSelected : Boolean;
    FEnabled  : Boolean;

    FRect     : TRect;
    FMRect    : TRect;
    FERect    : TRect;
    
    FMarker      : Boolean;
    FMarkerColor : TColor;

    FText     : TStrings;
    FVariable : string;
    FStepType : TERDScriptStepType;

    procedure SetLines(const I: Integer);
    procedure SetSelected(const B: Boolean);
    procedure SetEnabled(const B: Boolean);
    
    procedure SetMarker(const B: Boolean);
    procedure SetMarkerColor(const C: TColor);

    procedure SetText(const S: TStrings);
    procedure SetVariable(const S: string);

    procedure SetStepType(const T: TERDScriptStepType);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(AOWner: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    property ItemRect   : TRect read FRect  write FRect;
    property MarkerRect : TRect read FMRect write FMRect;
    property EditorRect : TRect read FERect write FERect;
  published
    property Lines    : Integer read FLines    write SetLines    default 1;
    property Selected : Boolean read FSelected write SetSelected default false; 
    property Enabled  : Boolean read FEnabled   write FEnabled   default True;

    property Marker      : Boolean read FMarker      write SetMarker      default False;
    property MarkerColor : TColor  read FMarkerColor write SetMarkerColor default clHighlight;

    property Text     : TStrings read FText     write SetText;
    property Variable : string   read FVariable write SetVariable;

    property StepType : TERDScriptStepType read FStepType write SetStepType default sssEmpty;
  end;

  TERDScriptSteps = class(TOwnedCollection)
  private
    FOnChange : TNotifyEvent;

    procedure ItemChanged(Sender: TObject);

    function GetItem(Index: Integer): TERDScriptStep;
    procedure SetItem(Index: Integer; const Value: TERDScriptStep);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TERDScriptStep;
    procedure Assign(Source: TPersistent); override;

    property Items[Index: Integer]: TERDScriptStep read GetItem write SetItem;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TERDScriptEditor = class(TCustomControl)
  private
    { Private declarations }
    FLineHeight : Integer;

    { Buffer - Avoid flickering }
    FBuffer     : TBitmap;
    FUpdateRect : TRect;

    { Scroll Positions and Max }
    FScrollPosY : Integer;
    FScrollMaxY : Integer;
    FOldScrollY : Integer;

    { Editor Band }
    FBandColor : TColor;
    FBandFont  : TFont;
    FBandWidth : Integer;

    { Script Steps }
    FItems : TERDScriptSteps;

    { Comment }
    FCommentPrefix : string;
    FCommentSuffix : string;
    FCommentBold   : Boolean;

    { Variable }
    FVariablePrefix : string;
    FVariableSuffix : string;
    FVariableBold   : Boolean;

    { Editor }
    FEditorCursor   : TCursor;
    FEditorAColor   : TColor;
    FEditorIcon     : TPicture;
    FEditorHover    : Integer;
    
    { Colors }
    FCommentColor   : TColor;
    FVariableColor  : TColor;
    FEditorColor    : TColor;

    { Popup menu's }
    FMarkerPopup : TPopupMenu;
    FStepPopup   : TPopupMenu;

    { Events }
    FOnStepEdit   : TERDScriptStepEdit;
    FOnStepSelect : TERDScriptStepSelect;

    procedure SetLineHeight(const I: Integer);

    procedure SetBandColor(const C: TColor);
    procedure SetBandFont(const F: TFont);
    procedure SetBandWidth(const I: Integer);

    procedure SetCommentColor(const C: TColor);
    procedure SetVariableColor(const C: TColor);

    procedure SetCommentPrefix(const S: string);
    procedure SetCommentSuffix(const S: string);
    procedure SetCommentBold(const B: Boolean);

    procedure SetVariablePrefix(const S: string);
    procedure SetVariableSuffix(const S: string);
    procedure SetVariableBold(const B: Boolean);

    procedure SetEditorColor(const C: TColor);
    procedure SetEditorCursor(const C: TCursor);
    procedure SetEditorAColor(const C: TColor);
    procedure SetEditorIcon(const P: TPicture);
    
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;

    procedure SetScrollPosY(const I: Integer);

    procedure SetItems(I: TERDScriptSteps);
  protected
    { Protected declarations }
    procedure SettingsChanged(Sender: TObject);
    procedure ClearStepSelection;

    procedure Paint; override;
    procedure Resize; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;

    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property UpdateRect: TRect read FUpdateRect write FUpdateRect;
  published
    { Published declarations }
    property Items: TERDScriptSteps read FItems write SetItems;

    property LineHeight : Integer read FLineHeight write SetLineHeight default 20;

    property BandColor : TColor  read FBandColor write SetBandColor default clBtnFace;
    property BandFont  : TFont   read FBandFont  write SetBandFont;
    property BandWidth : Integer read FBandWidth write SetBandWidth default 32;

    property PopupMarker : TPopupMenu read FMarkerPopup write FMarkerPopup;
    property PopupStep   : TPopupMenu read FStepPopup   write FStepPopup;
  
    property CommentColor   : TColor read FCommentColor   write SetCommentColor   default $00FF8000;
    property CommentPrefix : string  read FCommentPrefix write SetCommentPrefix;
    property CommentSuffix : string  read FCommentSuffix write SetCommentSuffix; 
    property CommentBold   : Boolean read FCommentBold   write SetCommentBold default False;

    property VariableColor  : TColor  read FVariableColor  write SetVariableColor  default $0061A761;
    property VariablePrefix : string  read FVariablePrefix write SetVariablePrefix;
    property VariableSuffix : string  read FVariableSuffix write SetVariableSuffix; 
    property VariableBold   : Boolean read FVariableBold   write SetVariableBold default False;

    property EditorColor       : TColor   read FEditorColor  write SetEditorColor  default clBtnFace;
    property EditorCursor      : TCursor  read FEditorCursor write SetEditorCursor default crHandpoint;
    property EditorActiveColor : TColor   read FEditorAColor write SetEditorAColor default clHighlight;
    property EditorIcon        : TPicture read FEditorIcon   write SetEditorIcon;

    property OnStepEdit   : TERDScriptStepEdit   read FOnStepEdit   write FOnStepEdit;
    property OnStepSelect : TERDScriptStepSelect read FOnStepSelect write FOnStepSelect;

    property Align;
    property Anchors;
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
  ClipboarFormatIdentifier = 'ERDesigns Script Editor';
var
  CF_ESE : Word;

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
(*  Script Step (TERDScriptStep)
(*
(******************************************************************************)
constructor TERDScriptStep.Create(AOWner: TCollection);
begin
  inherited Create(AOwner);
  FEnabled := True;
  FLines   := 1;

  FMarker      := False;
  FMarkerColor := clHighlight;

  FSTepType := sssEmpty;

  FText := TStringList.Create;
end;

destructor TERDScriptStep.Destroy;
begin
  { Free Strings }
  FText.Free;
  
  inherited Destroy;
end;

function TERDScriptStep.GetDisplayName : string;
const
  S : Array [TERDScriptStepType] of string = ('Empty', 'Comment', 'Variable');
begin
  Result := S[StepType];
end;

procedure TERDScriptStep.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TERDScriptStep then
  begin
    Lines   := TERDScriptStep(Source).Lines;
    Enabled := TERDScriptStep(Source).Enabled;

    Changed(False);
  end else Inherited;
end;

procedure TERDScriptStep.SetLines(const I: Integer);
begin
  if I <> Lines then
  begin
    if I > 0 then FLines := I else FLines := 1;
    Changed(False);
  end;
end;

procedure TERDScriptStep.SetSelected(const B: Boolean);
begin
  if B <> Selected then
  begin
    FSelected := B;
    Changed(False);
  end;
end;

procedure TERDScriptStep.SetEnabled(const B: Boolean);
begin
  if B <> Enabled then
  begin
    FEnabled := B;
    Changed(False);
  end;
end;

procedure TERDScriptStep.SetMarker(const B: Boolean);
begin
  if B <> Marker then
  begin
    FMarker := B;
    Changed(False);
  end;
end;

procedure TERDScriptStep.SetMarkerColor(const C: TColor);
begin
  if C <> MarkerColor then
  begin
    FMarkerColor := C;
    Changed(False);
  end;
end;

procedure TERDScriptStep.SetText(const S: TStrings);
begin
  if FText <> S then
  begin
    FText.Assign(S);
    if FText.Count <> Lines then FLines := FText.Count;
    Changed(False);
  end;
end;

procedure TERDScriptStep.SetVariable(const S: string);
begin
  if Variable <> S then
  begin
    FVariable := S;
    Changed(False);
  end;
end;

procedure TERDScriptStep.SetStepType(const T: TERDScriptStepType);
begin
  if T <> StepType then
  begin
    FStepType := T;
    if T = sssEmpty    then Lines := 1;
    if T = sssComment  then Lines := Text.Count;
    if T = sssVariable then Lines := 1;
    
    Changed(False);
  end;
end;


(******************************************************************************)
(*
(*  Script Step Collection (TERDScriptSteps)
(*
(******************************************************************************)
constructor TERDScriptSteps.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TERDScriptStep);
end;

procedure TERDScriptSteps.ItemChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TERDScriptSteps.SetItem(Index: Integer; const Value: TERDScriptStep);
begin
  inherited SetItem(Index, Value);
  ItemChanged(Self);
end;

procedure TERDScriptSteps.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TERDScriptSteps.GetItem(Index: Integer) : TERDScriptStep;
begin
  Result := inherited GetItem(Index) as TERDScriptStep;
end;

function TERDScriptSteps.Add : TERDScriptStep;
begin
  Result := TERDScriptStep(inherited Add);
end;

procedure TERDScriptSteps.Assign(Source: TPersistent);
var
  LI   : TERDScriptSteps;
  Loop : Integer;
begin
  if (Source is TERDScriptSteps)  then
  begin
    LI := TERDScriptSteps(Source);
    Clear;
    for Loop := 0 to LI.Count - 1 do
        Add.Assign(LI.Items[Loop]);
  end else inherited;
end;

(******************************************************************************)
(*
(*  Script Editor (TERDScriptEditor)
(*
(******************************************************************************)

constructor TERDScriptEditor.Create(AOwner: TComponent);
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

  { Create Buffer }
  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;

  { Script Steps - Items }
  FItems := TERDScriptSteps.Create(Self);
  FItems.OnChange := SettingsChanged;

  { Defaults }
  FCommentColor   := $00FF8000;
  FVariableColor  := $0061A761;

  FCommentPrefix := '#';
  FCommentSuffix := '';
  FCommentBold   := False;

  FVariablePrefix := 'Variable [ ';
  FVariableSuffix := ' ]';
  FVariableBold   := False;

  FEditorColor  := clBtnFace;
  FEditorCursor := crHandpoint;
  FEditorAColor := clHighlight;
  FEditorIcon   := TPicture.Create;

  { Band }
  FBandColor := clBtnFace;
  FBandFont  := TFont.Create;
  FBandFont.Color    := clGray;
  FBandFont.OnChange := SettingsChanged;
  FBandWidth := 32;

  { Line Height }
  FLineHeight := 20;

  { Register Clipboard Format }
  CF_ESE := RegisterClipboardFormat(ClipboarFormatIdentifier);

  { Width / Height }
  Width  := 400;
  Height := 267;
end;

destructor TERDScriptEditor.Destroy;
begin
  { Free Buffers }
  FBuffer.Free;

  { Band }
  FBandFont.Free;

  { Editor Icon }
  FEditorIcon.Free;

  inherited Destroy;
end;

procedure TERDScriptEditor.SettingsChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TERDScriptEditor.ClearStepSelection;
var
  I : Integer;
begin
  for I := 0 to Items.Count -1 do
  Items.Items[I].FSelected := False;
  Invalidate;
end;

procedure TERDScriptEditor.SetLineHeight(const I: Integer);
begin
  if LineHeight <> I then
  begin
    if I >= FBandFont.Size then FLineHeight := I else FLineHeight := FBandFont.Size;
    Invalidate;
  end;
end;

procedure TERDScriptEditor.SetBandColor(const C: TColor);
begin
  if BandColor <> C then
  begin
    FBandColor := C;
    Invalidate;
  end;
end;

procedure TERDScriptEditor.SetBandFont(const F: TFont);
begin
  FBandFont.Assign(F);
  Invalidate;
end;

procedure TERDScriptEditor.SetBandWidth(const I: Integer);
begin
  if BandWidth <> I then
  begin
    if I > 10 then FBandWidth := I else FBandWidth := 10;
    Invalidate;
  end;
end;

procedure TERDScriptEditor.SetCommentColor(const C: TColor);
begin
  if CommentColor <> C then
  begin
    FCommentColor := C;
    Invalidate;
  end;
end;

procedure TERDScriptEditor.SetVariableColor(const C: TColor);
begin
  if VariableColor <> C then
  begin
    FVariableColor := C;
    Invalidate;
  end;
end;

procedure TERDScriptEditor.SetCommentPrefix(const S: string);
begin
  FCommentPrefix := S;
  Invalidate;
end;

procedure TERDScriptEditor.SetCommentSuffix(const S: string);
begin
  FCommentSuffix := S;
  Invalidate;
end;

procedure TERDScriptEditor.SetCommentBold(const B: Boolean);
begin
  FCommentBold := B;
  Invalidate;
end;

procedure TERDScriptEditor.SetVariablePrefix(const S: string);
begin
  FVariablePrefix := S;
  Invalidate;
end;

procedure TERDScriptEditor.SetVariableSuffix(const S: string);
begin
  FVariableSuffix := S;
  Invalidate;
end;

procedure TERDScriptEditor.SetVariableBold(const B: Boolean);
begin
  FVariableBold := B;
  Invalidate;
end;

procedure TERDScriptEditor.SetEditorColor(const C: TColor);
begin
  FEditorColor := C;
  Invalidate;
end;

procedure TERDScriptEditor.SetEditorCursor(const C: TCursor);
begin
  FEditorCursor := C;
  Invalidate;
end;

procedure TERDScriptEditor.SetEditorAColor(const C: TColor);
begin
  FEditorAColor := C;
  Invalidate;
end;

procedure TERDScriptEditor.SetEditorIcon(const P: TPicture);
begin
  FEditorIcon.Assign(P);
  Invalidate;
end;

procedure TERDScriptEditor.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TERDScriptEditor.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  { Draw Buffer to the Control }
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := -1;
end;

procedure TERDScriptEditor.SetScrollPosY(const I: Integer);
begin
  FScrollPosY := I;
  FScrollPosY := EnsureRange(FScrollPosY, 0, FScrollMaxY);
  if FOldScrollY <> FScrollPosY then Invalidate;
  FOldScrollY := FScrollPosY;
end;

procedure TERDScriptEditor.SetItems(I: TERDScriptSteps);
begin
  FItems.Assign(I);
  Invalidate;
end;

procedure TERDScriptEditor.Paint;

  procedure DrawBackground;
  var
    LDetails : TThemedElementDetails;
  begin
    with FBuffer.Canvas do
    begin
      Brush.Color := StyleServices.GetStyleColor(scComboBox);
      LDetails := StyleServices.GetElementDetails(tcBorderNormal);
      StyleServices.DrawElement(FBuffer.Canvas.Handle, LDetails, ClientRect);
    end;
  end;

  function MarkerPath(Rect: TRect) : IGPGraphicsPath;
  var
    Path : IGPGraphicsPath;
  begin
    Path := TGPGraphicsPath.Create;
    Path.AddPolygon([
      TGPPoint.Create(Rect.Left + 2, Rect.Top + 2),
      TGPPoint.Create(Round((Rect.Right - 2) - (LineHeight / 3)), Rect.Top + 2),
      TGPPoint.Create((Rect.Right - 2), Rect.Top + Round(LineHeight / 2)),
      TGPPoint.Create(Round((Rect.Right - 2) - (LineHeight / 3)), Rect.Bottom - 2),
      TGPPoint.Create(Rect.Left + 2, Rect.Bottom - 2)
    ]);
    Path.CloseFigure;
    Result := Path;
  end;

  procedure DrawBand;
  var
    FGraphics  : IGPGraphics;
    FFontBrush : IGPSolidBrush;
    FMarkBrush : IGPSolidBrush;
    FMFBrush   : IGPSolidBrush;
    FFont      : TGPFont;
    FFormat    : IGPStringFormat;
    FBandRect  : TGPRectF;
    I, T, Y    : Integer;
    Number     : string;
  begin
    T := 0;

    { Band background }
    with FBuffer.Canvas do
    begin
      Brush.Color := BandColor;
      FillRect(Rect(1, 1, BandWidth - 2, Height - 2));
      Font := BandFont;
    end;
    
    { GDI+ }
    FGraphics := TGPGraphics.Create(FBuffer.Canvas.Handle);
    FGraphics.SmoothingMode     := SmoothingModeAntiAlias;
    FGraphics.InterpolationMode := InterpolationModeHighQualityBicubic;

    FFontBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(BandFont.Color));
    FMFBrush   := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(Color));
    FFont      := TGPFont.Create(BandFont.Name, BandFont.Size, [{FontStyleBold}]);

    FFormat    := TGPStringFormat.Create;
    FFormat.Alignment     := StringAlignmentFar;
    FFormat.LineAlignment := StringAlignmentCenter;
    
    { Draw numbering }
    for I := 0 to Items.Count -1 do
    begin
      { Marker Rect }
      Items.Items[I].MarkerRect := Rect(
         0,
         (T * LineHeight) - FScrollPosY,
         BandWidth,
         ((T + 1) * LineHeight) - FScrollPosY
      );
    
      { Marker }
      if Items.Items[I].Marker then
      begin
        FMarkBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(Items.Items[I].MarkerColor));
        FGraphics.FillPath(FMarkBrush, MarkerPath(Items.Items[I].MarkerRect));
      end;
      
      { Loop over every line }
      for Y := 0 to Items.Items[I].Lines -1 do
      begin
        Number := IntToStr(T + Y + 1);
        if (Items.Items[I].Marker) and (Y = 0) then
          FGraphics.DrawString(Number, FFont, TGPRectF.Create(
            0,
            ((T + Y) * LineHeight) - FScrollPosY,
            BandWidth - 4,
            LineHeight
          ), FFormat, FMFBrush)
        else
          FGraphics.DrawString(Number, FFont, TGPRectF.Create(
            0,
            ((T + Y) * LineHeight) - FScrollPosY,
            BandWidth - 4,
            LineHeight
          ), FFormat, FFontBrush);
      end;
      
      { Increase top }
      T := T + Items.Items[I].Lines;
    end;
  end;

  procedure DrawStep(const Index: Integer; const Y: Integer);

    procedure DrawCommentLine(const Line: Integer; const Text: string);
    var
      FGraphics  : IGPGraphics;
      FFontBrush : IGPSolidBrush;
      FFont      : TGPFont;
      FFormat    : IGPStringFormat;
    begin
      { GDI+ }
      FGraphics := TGPGraphics.Create(FBuffer.Canvas.Handle);
      FGraphics.SmoothingMode     := SmoothingModeAntiAlias;
      FGraphics.InterpolationMode := InterpolationModeHighQualityBicubic;

      if Items.Items[Index].Selected then
        FFontBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(clHighlightText))
      else
        FFontBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(CommentColor));
      if CommentBold then
        FFont := TGPFont.Create(Font.Name, Font.Size, [FontStyleBold])
      else
        FFont := TGPFont.Create(Font.Name, Font.Size, []);
      FFormat    := TGPStringFormat.Create;
      FFormat.Alignment     := StringAlignmentNear;
      FFormat.LineAlignment := StringAlignmentCenter;
      FFormat.Trimming      := StringTrimmingEllipsisCharacter;
      FFormat.FormatFlags   := [StringFormatFlagsNoWrap];
    
      FGraphics.DrawString(CommentPrefix + Text + CommentSuffix, FFont, TGPRectF.Create(
        BandWidth,
        ((Y + Line) * LineHeight) - FScrollPosY,
        (ClientWidth - 8) - (BandWidth + LineHeight),
        LineHeight
      ), FFormat, FFontBrush);      
    end;

    procedure DrawVariableLine(const Variable: string; const Text: string);
    var
      FGraphics  : IGPGraphics;
      FFontBrush : IGPSolidBrush;
      FFont      : TGPFont;
      FFormat    : IGPStringFormat;
    begin
      { GDI+ }
      FGraphics := TGPGraphics.Create(FBuffer.Canvas.Handle);
      FGraphics.SmoothingMode     := SmoothingModeAntiAlias;
      FGraphics.InterpolationMode := InterpolationModeHighQualityBicubic;

      if Items.Items[Index].Selected then
        FFontBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(clHighlightText))
      else
        FFontBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(VariableColor));
      if VariableBold then
        FFont := TGPFont.Create(Font.Name, Font.Size, [FontStyleBold])
      else
        FFont := TGPFont.Create(Font.Name, Font.Size, []);
      FFormat    := TGPStringFormat.Create;
      FFormat.Alignment     := StringAlignmentNear;
      FFormat.LineAlignment := StringAlignmentCenter;
      FFormat.Trimming      := StringTrimmingEllipsisCharacter;
      FFormat.FormatFlags   := [StringFormatFlagsNoWrap];
    
      FGraphics.DrawString(Format('%s %s = %s %s', [VariablePrefix, Trim(Variable), Trim(Text), VariableSuffix]), FFont, TGPRectF.Create(
        BandWidth,
        (Y * LineHeight) - FScrollPosY,
        (ClientWidth - 8) - (BandWidth + LineHeight),
        LineHeight
      ), FFormat, FFontBrush);      
    end;

    procedure DrawEditorButton(const Hover: Boolean);
    var
      FGraphics    : IGPGraphics;
      FButtonBrush : IGPSolidBrush;
    begin
      { GDI+ }
      FGraphics := TGPGraphics.Create(FBuffer.Canvas.Handle);
      FGraphics.SmoothingMode     := SmoothingModeAntiAlias;
      FGraphics.InterpolationMode := InterpolationModeHighQualityBicubic;

      if Hover then
        FButtonBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(EditorActiveColor))
      else
        FButtonBrush := TGPSolidBrush.Create(TGPColor.CreateFromColorRef(EditorColor));
      
      FGraphics.FillEllipse(FButtonBrush, TGPRectF.Create(
        ClientWidth - LineHeight,
        ((Y * LineHeight) + 1) - FScrollPosY,
        LineHeight - 3,
        LineHeight - 3
      ));

      { Editor Button rect }
      Items.Items[Index].EditorRect := Rect(
        ClientWidth - LineHeight,
        ((Y * LineHeight) + 1) - FScrollPosY,
        ClientWidth - 1,
        (((Y * LineHeight) + 1) - FScrollPosY) + LineHeight
      );

      FBuffer.Canvas.Draw(
        Round(((ClientWidth -1) - LineHeight) + ((LineHeight / 2) - (EditorIcon.Width / 2))),
        Round(((Y * LineHeight) - FScrollPosY) + ((LineHeight / 2) - (EditorIcon.Height / 2))),
        EditorIcon.Graphic
      );
    end;

  var
    I : Integer;
  begin
    { Step Item rect }
    Items.Items[Index].ItemRect := Rect(
      BandWidth - 2,
      IfThen(Y = 0, 1, (Y * LineHeight) - FScrollPosY),
      ClientWidth -1,
      ((Y + Items.Items[Index].Lines) * LineHeight) - FScrollPosY
    );

    { Selected ? }
    if Items.Items[Index].Selected then
    begin
      StyleServices.DrawElement(FBuffer.Canvas.Handle, StyleServices.GetElementDetails(tgCellSelected), Items.Items[Index].ItemRect);
      DrawEditorButton(Index = FEditorHover);
    end;

    { Draw step }
    case Items.Items[Index].StepType of
      sssEmpty    : Exit;
      sssComment  : begin
                      for I := 0 to Items.Items[Index].Text.Count -1 do
                      DrawCommentLine(I, Items.Items[Index].Text[I]);
                    end;
      sssVariable : DrawVariableLine(Items.Items[Index].Variable, Items.Items[Index].Text.Text);
    end;
  end;

  function ScrollHeight : Integer;
  var
    I : Integer;
  begin
    Result := 0;
    if Items.Count = 0 then Exit;
    for I := 0 to Items.Count -1 do
    if Items.Items[I].ItemRect.Bottom > Result then 
    Result := Items.Items[I].ItemRect.Bottom; 
  end;

var
  X, Y, W, H, I : Integer;
  SI            : TScrollInfo;
begin
  { Set Max Scrollbar }
  FScrollMaxY := ScrollHeight;

  { Set Buffer size }
  FBuffer.SetSize(ClientWidth, ClientHeight);
  FBuffer.Canvas.Font := Font;

  { Background }
  DrawBackground;

  { Band }
  DrawBand;

  { Draw steps }
  Y := 0;
  for I := 0 to Items.Count -1 do
  begin
    DrawStep(I, Y);
    Y := Y + Items.Items[I].Lines;
  end;

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
end;

procedure TERDScriptEditor.Resize;
begin
  //
end;

procedure TERDScriptEditor.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    Style := Style or WS_VSCROLL and not (CS_HREDRAW or CS_VREDRAW)
end;

procedure TERDScriptEditor.WndProc(var Message: TMessage);
var
  SI : TScrollInfo;
begin
  inherited;
  case Message.Msg of
    // Capture Keystrokes
    WM_GETDLGCODE:
      Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTALLKEYS;

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
        FEditorHover := -1;
        ClearStepSelection;
      end;

    { Focus is lost }
    WM_KILLFOCUS:
      begin
        FEditorHover := -1;
        Invalidate;
        //ClearStepSelection;
      end;

    WM_SETFOCUS:
      begin
        { Focus returned so redraw - if we use graying out of keys }
      end;

  end;
end;

function TERDScriptEditor.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  { During designtime there is no need for these events }
  if (csDesigning in ComponentState) then Exit;
  { Ignore when the component is disabled }
  if not Enabled then Exit;
  if (FScrollPosY - (WheelDelta div 10)) > FScrollMaxY then
    FScrollPosY := FScrollMaxY
  else
    SetScrollPosY(FScrollPosY - (WheelDelta div 10));
  Result := True;
  inherited;
end;

procedure TERDScriptEditor.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);

  function MouseEditorIndex : Integer;
  var
    I : Integer;
  begin
    Result := -1;
    for I := 0 to Items.Count -1 do
    if PtInRect(Items.Items[I].EditorRect, Point(X, Y)) then
    begin
      Result := I;
    end;
  end;

var
  I, O : Integer;
begin
  if not Enabled then Exit;
  I := MouseEditorIndex;
  if (I > -1) and Items.Items[I].Selected then
  begin
    if Cursor <> EditorCursor then Cursor := EditorCursor;
    O := FEditorHover;
    FEditorHover := I;
    if O <> I then Invalidate;
  end else
  begin
    if Cursor <> crDefault then Cursor := crDefault;
    O := FEditorHover;
    FEditorHover := -1;
    if O <> -1 then Invalidate;
  end;
  inherited;
end;

procedure TERDScriptEditor.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

  function MouseMarkerIndex : Integer;
  var
    I : Integer;
  begin
    Result := -1;
    for I := 0 to Items.Count -1 do
    if PtInRect(Items.Items[I].MarkerRect, Point(X, Y)) then
    begin
      Result := I;
    end;
  end;

  function MouseStepIndex : Integer;
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

  function MouseEditorIndex : Integer;
  var
    I : Integer;
  begin
    Result := -1;
    for I := 0 to Items.Count -1 do
    if PtInRect(Items.Items[I].EditorRect, Point(X, Y)) then
    begin
      Result := I;
    end;
  end;

var
  I, J, H : Integer;
  P       : TPoint;
begin
  if not Enabled then Exit;
  if (not Focused) and CanFocus then SetFocus;
  if Button = mbLeft then
  begin
    { Editor }
    I := MouseEditorIndex;
    if (I > -1) and Items.Items[I].Selected then
    begin
      if Assigned(FOnStepEdit) then FOnStepEdit(Items.Items[I], I);
      Exit;
    end;

    { Marker }
    I := MouseMarkerIndex;
    if I > -1 then
    Items.Items[I].Marker := not Items.Items[I].Marker;

    { Script step }
    I := MouseStepIndex;
    if (I > -1) then
    begin
      if (not (ssShift in Shift)) and (not (ssCtrl in Shift)) then ClearStepSelection;
      if (ssShift in Shift) then
      begin
        for J := 0 to Items.Count -1 do
        if Items.Items[J].Selected then
        begin
          // First selection is > mouse selection
          if J > I then
          begin
            for H := J downto I do
            Items.Items[H].FSelected := True;
          end else
          // First selection is < mouse selection
          begin
            for H := J to I do
            Items.Items[H].FSelected := True;
          end;
          Invalidate;
          Break;
        end;
      end else
      if (ssCtrl in Shift) then
      begin
        Items.Items[I].Selected := not Items.Items[I].Selected;
        if Assigned(OnStepSelect) then OnStepSelect(Items.Items[I], I);
      end else
      begin
        Items.Items[I].Selected := True;
        if Assigned(OnStepSelect) then OnStepSelect(Items.Items[I], I);
      end;
    end;
  end;

  if Button = mbRight then
  begin
    { Marker }
    I := MouseMarkerIndex;
    if (I > -1) and Assigned(PopupMarker) and Items.Items[I].Marker then
    begin
      P := CLientToScreen(Point(Items.Items[I].MarkerRect.Right, Items.Items[I].MarkerRect.Top));
      PopupMarker.Popup(P.X, P.Y);
    end;

    { Script step }
    I := MouseStepIndex;
    if (I > -1) and Assigned(PopupStep) then
    begin
      ClearStepSelection;
      Items.Items[I].Selected := True;
      P := ClientToScreen(Point(X, Y));
      PopupStep.Popup(P.X, P.Y);
    end;
  end;
  inherited;
end;

procedure TERDScriptEditor.KeyDown(var Key: Word; Shift: TShiftState);

  function FirstSelected : Integer;
  var
    I : Integer;
  begin
    Result := -1;
    for I := 0 to Items.Count -1 do
    if Items.Items[I].Selected then Exit(I);
  end;

  procedure MoveSelectedDown;
  var
    I : Integer;
  begin
    for I := Items.Count -1 downto 0 do
    if Items.Items[I].Selected and (I < Items.Count -1) then
    Items.Items[I].Index := Items.Items[I].Index +1;
  end;

  procedure MoveSelectedUp;
  var
    I : Integer;
  begin
    for I := 0 to Items.Count -1 do
    if Items.Items[I].Selected and (I > 0) then
    Items.Items[I].Index := Items.Items[I].Index -1;
  end;

var
  I, O : Integer;
begin
  { During designtime there is no need for these events }
  if (csDesigning in ComponentState) then Exit;
  { Ignore when the component is disabled }
  if (not Enabled) then Exit;

  case Key of
    VK_UP    : begin
                 if (not (ssShift in Shift)) and (not (ssCtrl in Shift)) then
                 begin
                   I := FirstSelected;
                   if (I > 0) then
                   begin
                     ClearStepSelection;
                     Items.Items[I -1].Selected := True;
                     if Items.Items[I -1].ItemRect.Top < 0 then
                     FScrollPosY := 0;
                     if Assigned(OnStepSelect) then OnStepSelect(Items.Items[I -1], I-1);
                   end;
                 end else
                 if (ssCtrl in Shift) then
                 begin
                   MoveSelectedUp;
                 end;
               end;
    VK_DOWN  : begin
                 if (not (ssShift in Shift)) and (not (ssCtrl in Shift)) then
                 begin
                   I := FirstSelected;
                   if (I < Items.Count -1) then
                   begin
                     ClearStepSelection;
                     Items.Items[I +1].Selected := True;
                     if Items.Items[I +1].ItemRect.Top > ClientHeight then
                     FScrollPosY := Items.Items[I +1].ItemRect.Top;
                     if Assigned(OnStepSelect) then OnStepSelect(Items.Items[I +1], I+1);
                   end;
                 end else
                 if (ssCtrl in Shift) then
                 begin
                   MoveSelectedDown;
                 end;
               end;

    { Return - Add empty line }
    VK_RETURN: begin
                 I := FirstSelected;
                 Items.Insert(I +1);
                 ClearStepSelection;
                 Items.Items[I +1].Selected := True;
                 if Assigned(OnStepSelect) then OnStepSelect(Items.Items[I +1], I+1);
               end;

    { Delete - Delete selected }
    VK_DELETE: begin
                 for I := Items.Count -1 downto 0 do
                 if Items.Items[I].Selected then
                 begin
                   Items.Delete(I);
                   O := I;
                 end;
                 if ((O >= 0) and (Items.Count > 0)) and ((O <= Items.Count -1) and (Items.Count > 0)) then
                 begin
                   Items.Items[O].Selected := True;
                   if Assigned(OnStepSelect) then OnStepSelect(Items.Items[O], O);
                 end;
               end;

    { Backspace - Delete selected and move selection a row up }
    VK_BACK  : begin
                 I := FirstSelected;
                 if (I > -1) then Items.Delete(I);
                 if ((I -1 >= 0) and (Items.Count > 0)) and ((I -1 <= Items.Count -1) and (Items.Count > 0)) then
                 begin
                   Items.Items[I -1].Selected := True;
                   if Assigned(OnStepSelect) then OnStepSelect(Items.Items[I -1], I-1);
                 end;
               end;
  end;

  inherited;
end;

procedure Register;
begin
  RegisterComponents('ERDesigns', [TERDScriptEditor]);
end;

end.
