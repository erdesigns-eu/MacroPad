unit untMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, untERDKeyboard,
  untERDKeyboardFile, CPort, Vcl.StdCtrls, untUSB;

type
  TMacroPadKeyState = (ksUnknown, ksPressed, ksHold, ksReleased);

  TfrmMacroPadDemo = class(TForm)
    ERDKeyboardLayout: TERDKeyboardLayout;
    Panel1: TPanel;
    Splitter1: TSplitter;
    MacroPadFile: TMacroPadFile;
    cbCOMPort: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    cbBaudrate: TComboBox;
    btnConnect: TButton;
    btnDisconnect: TButton;
    ComPort: TComPort;
    procedure FormCreate(Sender: TObject);
    procedure MacroPadFileFileLoaded(Sender: TObject);
    procedure ComPortAfterClose(Sender: TObject);
    procedure ComPortBreak(Sender: TObject);
    procedure ComPortError(Sender: TObject; Errors: TComErrors);
    procedure ComPortException(Sender: TObject; TComException: TComExceptions;
      ComportMessage: string; WinError: Int64; WinMessage: string);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    procedure ComPortAfterOpen(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure cbBaudrateSelect(Sender: TObject);
    procedure cbCOMPortSelect(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    USB : TComponentUSB; // Add untUSB.pas to uses clause.
    COMBuffer : string;

    procedure OnUSBChange(Sender: TObject);
    procedure HandleMacroPadInput(const S: string);
    procedure WriteToCOMPort(const Str: string);
  public
    { Public declarations }
  end;

var
  frmMacroPadDemo: TfrmMacroPadDemo;

implementation

{$R *.dfm}

//  On USB Change
procedure TfrmMacroPadDemo.OnUSBChange(Sender: TObject);
begin
  EnumComPorts(cbCOMPort.Items);
  cbCOMPort.Enabled  := cbCOMPort.Items.Count > 0;
  btnConnect.Enabled := cbCOMPort.Enabled;
end;

procedure TfrmMacroPadDemo.HandleMacroPadInput(const S: string);

  function ExtractKeyCode : Integer;
  begin
    Result := StrToIntDef(Copy(S, 1, Pos(' ', S) -1), -1);
  end;

  function ExtractKeyState : TMacroPadKeyState;
  begin
    Result := TMacroPadKeyState(StrToIntDef(Copy(S, Pos(' ', S) +1, Length(S)), 0));
  end;

  function IndexOfKeyCode(const C: Integer) : Integer;
  var
    I : Integer;
  begin
    Result := -1;
    for I := 0 to ERDKeyboardLayout.Items.Count -1 do
    if ERDKeyboardLayout.Items.Items[I].KeyCode = C then
    begin
      Result := I;
      Break;
    end;
  end;

var
  I : Integer;
begin
  I := IndexOfKeyCode(ExtractKeyCode);
  if (I >= 0) then
  case ExtractKeyState of
    ksUnknown  : ERDKeyboardLayout.Items.Items[I].Selected := False;
    ksPressed  : ERDKeyboardLayout.Items.Items[I].Selected := True;
    ksHold     : ERDKeyboardLayout.Items.Items[I].Selected := True;
    ksReleased : ERDKeyboardLayout.Items.Items[I].Selected := False;
  end;
end;

// Write to COM Port
procedure TfrmMacroPadDemo.WriteToCOMPort(const Str: string);
begin
  if (not COMPort.Connected) then Exit;
  COMPort.WriteStr(Str + #13);
end;

procedure TfrmMacroPadDemo.FormCreate(Sender: TObject);
var
  F : string;
begin
  // USB Listener
  USB := TComponentUSB.Create(Self);
  USB.OnUSBArrival := OnUSBChange;
  USB.OnUSBRemove  := OnUSBChange;
  // Demo MacroPad
  F := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + 'demo.erdmp';
  if FileExists(F) then
  begin
    // Load demo file
    MacroPadFile.LoadFromFile(F);
    // Load com ports
    OnUSBChange(Self);
    // Set Baudrate
    cbBaudrateSelect(Self);
  end else
  begin
    // Demo file not found!
    Application.MessageBox('Could not find demo.erdmp!', PChar(Caption), mb_iconwarning);
    cbCOMPort.Enabled  := False;
    cbBaudrate.Enabled := False;
    btnConnect.Enabled := False;
  end;
end;

procedure TfrmMacroPadDemo.FormDestroy(Sender: TObject);
begin
  USB.Destroy;
end;

procedure TfrmMacroPadDemo.MacroPadFileFileLoaded(Sender: TObject);
var
  I : Integer;
begin
  // Clear items in keyboard layout
  ERDKeyboardLayout.Items.Clear;
  // Load items in keyboard layout
  for I := 0 to MacroPadFile.Items.Count -1 do
  with ERDKeyboardLayout.Items.Add do
  begin
    KeyCode  := MacroPadFile.Items[I].KeyCode;
    Reserved := MacroPadFile.Items[I].Reserved;
    Width  := MacroPadFile.Items[I].Width;
    Height := MacroPadFile.Items[I].Height;
    Y      := MacroPadFile.Items[I].Top;
    X      := MacroPadFile.Items[I].Left;
    Color  := MacroPadFile.Items[I].Color;
    LegendCaption := MacroPadFile.Items[I].Legend;
    LegendPicture.Assign(MacroPadFile.Items[I].LegendImage);
  end;
end;

procedure TfrmMacroPadDemo.ComPortAfterClose(Sender: TObject);
begin
  COMBuffer := '';
  btnDisconnect.Enabled := False;
  btnConnect.Enabled    := True;
end;

procedure TfrmMacroPadDemo.ComPortAfterOpen(Sender: TObject);
begin
  COMBuffer := '';
  btnDisconnect.Enabled := True;
  btnConnect.Enabled    := False;
end;

procedure TfrmMacroPadDemo.ComPortBreak(Sender: TObject);
begin
  // Ignore
end;

procedure TfrmMacroPadDemo.ComPortError(Sender: TObject; Errors: TComErrors);
begin
  if COMPort.Connected then COMPort.Close;
end;

procedure TfrmMacroPadDemo.ComPortException(Sender: TObject;
  TComException: TComExceptions; ComportMessage: string; WinError: Int64;
  WinMessage: string);
begin
  if COMPort.Connected then COMPort.Close;
end;

procedure TfrmMacroPadDemo.ComPortRxChar(Sender: TObject; Count: Integer);
var
  S : string;
begin
  // Read characters from comport
  COMPort.ReadStr(S, Count);
  // If there is a "newline" or "carriage return"..
  if (S[Length(S)] = #13) or (S[Length(S)] = #10) then
  begin
    S := COMBuffer + S;
    S := Trim(StringReplace(S, #13, '', [rfReplaceAll]));
    S := Trim(StringReplace(S, #10, '', [rfReplaceAll]));
    HandleMacroPadInput(S);
    COMBuffer   := '';
  end else
  // Concat the read characters to the COMBuffer
  begin
    COMBuffer := COMBuffer + S;
    Exit;
  end;
end;

procedure TfrmMacroPadDemo.btnConnectClick(Sender: TObject);
begin
  COMPort.Open;
  COMPort.ClearBuffer(True, True);
  if COMPort.Connected then WriteToCOMPort('START');
end;

procedure TfrmMacroPadDemo.btnDisconnectClick(Sender: TObject);
begin
  if COMPort.Connected then
  begin
    WriteToCOMPort('STOP');
    COMPort.Close;
  end;
end;

procedure TfrmMacroPadDemo.cbBaudrateSelect(Sender: TObject);
const
  BR : Array [0..8] of TBaudRate = (br9600, br14400, br19200, br38400, br56000, br57600, br115200, br128000, br256000);
begin
  COMPort.BaudRate := BR[cbBaudRate.ItemIndex];
end;

procedure TfrmMacroPadDemo.cbCOMPortSelect(Sender: TObject);
begin
  COMPort.Port := cbCOMPort.Text;
end;

procedure TfrmMacroPadDemo.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  btnDisconnectClick(nil);
end;

end.
