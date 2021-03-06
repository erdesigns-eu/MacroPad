unit untERDKeyboardFile;

interface

uses
  Windows, System.SysUtils, System.Classes, Graphics, System.RTLConsts,
  System.Contnrs, PNGImage;

type
  AFileIdentifier = Array [0..4] of AnsiChar;
  AEndOfFileID    = Array [0..1] of AnsiChar;

const
  MPFileIdentifier : AFileIdentifier = ('E', 'R', 'D', 'M', 'P');
  MPFileVersion    : Double          = 0.1;
  MPEndOfFileID    : AEndOfFileID    = ('@', 'E');

const
  RLSalt = 'erdesigns.eu';

ResourceString
  RLInvalidFile    = 'This is not a valid ERDesigns MacroPad file!';
  RLInvalidVersion = 'This version of ERDesigns MacroPad is not supported!';

type
  TMacroPadPersistent = class(TPersistent)
  protected
    { Protected declarations }
    FOnChange : TNotifyEvent;

    procedure FileWriteString(AStream: TStream; const Value: string);
    procedure FileWriteInteger(AStream: TStream; const Value: Integer);
    procedure FileWriteBool(AStream: TStream; const Value: Boolean);
    procedure FileWriteExtended(AStream: TStream; const Value: Extended);
    procedure FileWriteSingle(AStream: TStream; const Value: Single);
    procedure FileWriteColor(AStream: TStream; const Value: TColor);
    procedure FileWriteClassName(AStream: TStream; const Value: String);
    procedure FileWritePNG(AStream: TStream; const Value: TPNGImage);

    function FileReadString(AStream: TStream) : string;
    function FileReadInteger(AStream: TStream) : Integer;
    function FileReadBool(AStream: TStream) : Boolean;
    function FileReadExtended(AStream: TStream) : Extended;
    function FileReadSingle(AStream: TStream) : Single;
    function FileReadColor(AStream: TStream) : TColor;
    function FileReadClassName(AStream: TStream) : string;
    function FileReadPNG(AStream: TStream; var PNG: TPNGImage) : Boolean;
  public
    { Public declarations }
    procedure LoadFromStream(AStream: TStream); dynamic;
    procedure SaveToStream(AStream: TStream); dynamic;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TMacroPadAuthor = class(TMacroPadPersistent)
  private
    { Private declarations }
    FName    : string;
    FPhone   : string;
    FEmail   : string;
    FTitle   : string;
    FWebsite : string;
    FComment : string;
  public
    { Public declarations }
    procedure LoadFromStream(AStream: TStream); override;
    procedure SaveToStream(AStream: TStream); override;
  published
    { Published declarations }
    property Name: string read FName write FName;
    property Phone: string read FPhone write FPhone;
    property Email: string read FEmail write FEmail;
    property Title: string read FTitle write FTitle;
    property Website: string read FWebsite write FWebsite;
    property Comment: string read FComment write FComment;
  end;

  TMacroPadKey = class(TMacroPadPersistent)
  private
    { Private declarations }
    FKeyCode  : Integer;
    FReserved : Integer;

    FWidth    : Single;
    FHeight   : Single;
    FTop      : Single;
    FLeft     : Single;

    FColor         : TColor;
    FLegend        : string;
    FLegendPicture : TPicture;
  public
    { Public declarations }
    constructor Create; virtual;
    destructor Destroy; override;

    constructor CreateFromStream(AStream: TStream); virtual;

    procedure LoadFromStream(AStream: TStream); override;
    procedure SaveToStream(AStream: TStream); override;
  published
    { Published declarations }
    property KeyCode  : Integer read FKeyCode  write FKeyCode;
    property Reserved : Integer read FReserved write FReserved;

    property Width  : Single read FWidth  write FWidth;
    property Height : Single read FHeight write FHeight;
    property Top    : Single read FTop    write FTop;
    property Left   : Single read FLeft   write FLeft;

    property Color       : TColor   read FColor         write FColor;
    property Legend      : string   read FLegend        write FLegend;
    property LegendImage : TPicture read FLegendPicture write FLegendPicture;
  end;

  TMacroPadKeyList = class
  private
    FItems: TObjectList;

    function GetCount: Integer;
    function GetObjects(Index: Integer): TMacroPadKey;
  protected
    function ReadInteger(AStream: TStream): Integer;
    procedure WriteInteger(AStream: TStream; const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(Item: TMacroPadKey);
    procedure Delete(Index: Integer);
    procedure Clear;

    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);

    property Items[Index: Integer]: TMacroPadKey read GetObjects; default;
    property Count: Integer read GetCount;
  end;

  TMacroPadFile = class(TComponent)
  private
    { Private declarations }
    FOnFileLoaded : TNotifyEvent;
    FOnFileSaved  : TNotifyEvent;
    FOnFileClosed : TNotifyEvent;
    FOnUpdateFile : TNotifyEvent;

    FItems   : TMacroPadKeyList;
    FPreview : TPicture;
    FAuthor  : TMacroPadAuthor;

    FDocumentTitle : string;
    FComment       : string;
    FLastModified  : TDateTime;

    FFileVersion   : Double;

    FFilename : string;
    FSaved    : Boolean;
    FModified : Boolean;

    procedure SetPreview(P: TPicture);
    procedure SetFileVersion(D: Double);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdateFile;
    function LoadFromFile(FileName: TFilename; IsTemplate: Boolean = false) : Boolean;
    function SaveToFile(FileName: TFilename) : Boolean;
    procedure CloseFile;

    property Items: TMacroPadKeyList read FItems;
  published
    { Published declarations }
    property Preview : TPicture read FPreview write SetPreview;
    property Author  : TMacroPadAuthor read FAuthor;

    property DocumentTitle: string read FDocumentTitle write FDocumentTitle;
    property Comment: string read FComment write FComment;
    property LastModified: TDateTime read FLastModified;

    property FileVersion: Double read FFileVersion write SetFileVersion;

    property Filename : string  read FFilename;
    property Saved    : Boolean read FSaved;
    property Modified : Boolean read FModified;

    property OnFileLoaded : TNotifyEvent read FOnFileLoaded write FOnFileLoaded;
    property OnFileSaved  : TNotifyEvent read FOnFileSaved  write FOnFileSaved;
    property OnFileClosed : TNotifyEvent read FOnFileClosed write FOnFileClosed;
    property OnUpdateFile : TNotifyEvent read FOnUpdateFile write FOnUpdateFile;
  end;

procedure Register;

implementation

procedure TMacroPadPersistent.FileWriteString(AStream: TStream; const Value: string);
var
  ASize   : Integer;
  AString : UTF8String;
begin
  AString := Value;
  ASize := Length(AString);
  AStream.WriteBuffer(ASize, SizeOf(Integer));
  if ASize > 0 then
  AStream.WriteBuffer(AString[1], ASize);
end;

procedure TMacroPadPersistent.FileWriteInteger(AStream: TStream; const Value: Integer);
begin
  AStream.WriteBuffer(Value, SizeOf(Integer));
end;

procedure TMacroPadPersistent.FileWriteBool(AStream: TStream; const Value: Boolean);
begin
  AStream.WriteBuffer(Value, SizeOf(Boolean));
end;

procedure TMacroPadPersistent.FileWriteExtended(AStream: TStream; const Value: Extended);
begin
  AStream.WriteBuffer(Value, SizeOf(Extended));
end;

procedure TMacroPadPersistent.FileWriteSingle(AStream: TStream; const Value: Single);
begin
  AStream.WriteBuffer(Value, SizeOf(Single));
end;

procedure TMacroPadPersistent.FileWriteColor(AStream: TStream; const Value: TColor);
begin
  AStream.WriteBuffer(Value, SizeOf(TColor));
end;

procedure TMacroPadPersistent.FileWriteClassName(AStream: TStream; const Value: string);
begin
  FileWriteString(AStream, Value);
end;

procedure TMacroPadPersistent.FileWritePNG(AStream: TStream; const Value: TPNGImage);
var
  MS    : TMemoryStream;
  ASize : Longint;
begin
  MS := TMemoryStream.Create;
  try
    Value.SaveToStream(MS);
    ASize := MS.Size;
    MS.Position := 0;
    AStream.Write(ASize, SizeOf(Longint));
    if ASize > 0 then
    AStream.CopyFrom(MS, ASize);
  finally
    MS.Free;
  end;
end;

function TMacroPadPersistent.FileReadString(AStream: TStream) : string;
var
  ASize   : Integer;
  AString : UTF8String;
begin
  Result := '';
  AStream.ReadBuffer(ASize, SizeOf(Integer));
  if ASize > 0 then
  begin
    SetLength(AString, ASize);
    AStream.ReadBuffer(AString[1], ASize);
    Result := WideString(AString);
  end;
end;

function TMacroPadPersistent.FileReadInteger(AStream: TStream) : Integer;
var
  AValue: Integer;
begin
  AStream.ReadBuffer(AValue, SizeOf(Integer));
  Result := AValue;
end;

function TMacroPadPersistent.FileReadBool(AStream: TStream) : Boolean;
var
  AValue: Boolean;
begin
  AStream.ReadBuffer(AValue, SizeOf(Integer));
  Result := AValue;
end;

function TMacroPadPersistent.FileReadExtended(AStream: TStream) : Extended;
var
  AValue: Extended;
begin
  AStream.ReadBuffer(AValue, SizeOf(Extended));
  Result := AValue;
end;

function TMacroPadPersistent.FileReadSingle(AStream: TStream) : Single;
var
  AValue: Single;
begin
  AStream.ReadBuffer(AValue, SizeOf(Single));
  Result := AValue;
end;

function TMacroPadPersistent.FileReadColor(AStream: TStream) : TColor;
var
  AValue: TColor;
begin
  AStream.ReadBuffer(AValue, SizeOf(TColor));
  Result := AValue;
end;

function TMacroPadPersistent.FileReadClassName(AStream: TStream) : string;
begin
  Result := FileReadString(AStream);
end;

function TMacroPadPersistent.FileReadPNG(AStream: TStream; var PNG: TPNGImage) : Boolean;
var
  MS    : TMemoryStream;
  ASize : Longint;
begin
  Result := False;
  AStream.Read(ASize, SizeOf(Longint));
  if ASize > 0 then
  begin
    MS := TMemoryStream.Create;
    try
      MS.CopyFrom(AStream, ASize);
      if ASize > 8 then
      begin
        MS.Position := 0;
        PNG.LoadFromStream(MS);
        Result := True;
      end;
    finally
      MS.Free;
    end;
  end;
end;

procedure TMacroPadPersistent.LoadFromStream(AStream: TStream);
begin
end;

procedure TMacroPadPersistent.SaveToStream(AStream: TStream);
begin
end;

procedure TMacroPadAuthor.LoadFromStream(AStream: TStream);
begin
  FName    := FileReadString(AStream);
  FPhone   := FileReadString(AStream);
  FEmail   := FileReadString(AStream);
  FTitle   := FileReadString(AStream);
  FWebsite := FileReadString(AStream);
  FComment := FileReadString(AStream);
end;

procedure TMacroPadAuthor.SaveToStream(AStream: TStream);
begin
  FileWriteString(AStream, FName);
  FileWriteString(AStream, FPhone);
  FileWriteString(AStream, FEmail);
  FileWriteString(AStream, FTitle);
  FileWriteString(AStream, FWebsite);
  FileWriteString(AStream, FComment);
end;

constructor TMacroPadKey.Create;
begin
  inherited Create;
  FLegendPicture := TPicture.Create;
end;

destructor TMacroPadKey.Destroy;
begin
  FLegendPicture.Free;
  inherited Destroy;
end;

constructor TMacroPadKey.CreateFromStream(AStream: TStream);
begin
  inherited Create;
  FLegendPicture := TPicture.Create;
  LoadFromStream(AStream);
end;

procedure TMacroPadKey.LoadFromStream(AStream: TStream);
var
  PNG : TPNGImage;
begin
  FKeyCode  := FileReadInteger(AStream);
  FReserved := FileReadInteger(AStream);

  FWidth  := FileReadSingle(AStream);
  FHeight := FileReadSingle(AStream);
  FTop    := FileReadSingle(AStream);
  FLeft   := FileReadSingle(AStream);

  FColor  := FileReadColor(AStream);
  FLegend := FileReadString(AStream);

  PNG := TPNGImage.Create;
  try
    if FileReadPNG(AStream, PNG) then
    FLegendPicture.Assign(PNG);
  finally
    PNG.Free;
  end;
end;

procedure TMacroPadKey.SaveToStream(AStream: TStream);
var
  PNG : TPNGImage;
begin
  FileWriteInteger(AStream, FKeyCode);
  FileWriteInteger(AStream, FReserved);

  FileWriteSingle(AStream, FWidth);
  FileWriteSingle(AStream, FHeight);
  FileWriteSingle(AStream, FTop);
  FileWriteSingle(AStream, FLeft);

  FileWriteColor(AStream, FColor);
  FileWriteString(AStream, FLegend);

  PNG := TPNGImage.Create;
  PNG.Assign(FLegendPicture.Graphic);
  try
    FileWritePNG(AStream, PNG);
  finally
    PNG.Free;
  end;
end;

constructor TMacroPadKeyList.Create;
begin
  inherited Create;
  FItems := TObjectList.Create(True);
end;

destructor TMacroPadKeyList.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

function TMacroPadKeyList.GetCount : Integer;
begin
  Result := FItems.Count;
end;

function TMacroPadKeyList.GetObjects(Index: Integer) : TMacroPadKey;
begin
  Result := FItems[Index] as TMacroPadKey;
end;

function TMacroPadKeyList.ReadInteger(AStream: TStream) : Integer;
var
  AInteger : Integer;
begin
  AStream.ReadBuffer(AInteger, SizeOf(Integer));
  Result := AInteger;
end;

procedure TMacroPadKeyList.WriteInteger(AStream: TStream; const Value: Integer);
begin
  AStream.WriteBuffer(Value, SizeOf(Integer));
end;

procedure TMacroPadKeyList.Add(Item: TMacroPadKey);
begin
  FItems.Add(Item);
end;

procedure TMacroPadKeyList.Delete(Index: Integer);
begin
  FItems.Delete(Index);
end;

procedure TMacroPadKeyList.Clear;
begin
  FItems.Clear;
end;

procedure TMacroPadKeyList.LoadFromStream(AStream: TStream);
var
  C : Integer;
  I : Integer;
begin
  C := ReadInteger(AStream);
  for I := 0 to C - 1 do
  begin
    Add(TMacroPadKey.CreateFromStream(AStream));
  end;
end;

procedure TMacroPadKeyList.SaveToStream(AStream: TStream);
var
  I : Integer;
begin
  WriteInteger(AStream, Count);
  for I := 0 to Count - 1 do
  begin
    Items[I].SaveToStream(AStream);
  end;
end;

constructor TMacroPadFile.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems   := TMacroPadKeyList.Create;
  FPreview := TPicture.Create;
  FAuthor  := TMacroPadAuthor.Create;

  FDocumentTitle := '';
  FComment       := '';
  FLastModified  := Now;
  FFileVersion   := MPFileVersion;
end;

destructor TMacroPadFile.Destroy;
begin
  FItems.Free;
  FPreview.Free;
  FAuthor.Free;
  inherited Destroy;
end;

procedure TMacroPadFile.SetPreview(P: TPicture);
begin
  FPreview.Assign(P);
end;

procedure TMacroPadFile.SetFileVersion(D: Double);
begin
  if D <> FFileVersion then
  begin
    if (D > 0.1) then
      FFileVersion := D
    else
      FFileVersion := 0.1;
  end;
end;

procedure TMacroPadFile.UpdateFile;
begin
  FLastModified := Now;
  FModified     := True;
  if Assigned(FOnUpdateFile) then FOnUpdateFile(Self);
end;

function TMacroPadFile.LoadFromFile(FileName: TFileName; IsTemplate: Boolean = false) : Boolean;

  function ReadString(AStream: TFileStream) : String;
  var
    ASize   : Integer;
    AString : UTF8String;
  begin
    Result := '';
    AStream.ReadBuffer(ASize, SizeOf(Integer));
    if ASize > 0 then
    begin
      SetLength(AString, ASize);
      AStream.ReadBuffer(AString[1], ASize);
      Result := WideString(AString);
    end;
  end;

  function ReadInteger(AStream: TStream) : Integer;
  var
    AValue: Integer;
  begin
    AStream.ReadBuffer(AValue, SizeOf(Integer));
    Result := AValue;
  end;

  function ReadBool(AStream: TStream) : Boolean;
  var
    AValue: Boolean;
  begin
    AStream.ReadBuffer(AValue, SizeOf(Boolean));
    Result := AValue;
  end;

  function ReadDateTime(AStream: TStream) : TDateTime;
  var
    AValue: TDateTime;
  begin
    AStream.ReadBuffer(AValue, SizeOf(TDateTime));
    Result := AValue;
  end;

  procedure ReadPreview(AStream: TFileStream);
  var
    MS    : TMemoryStream;
    ASize : Longint;
  begin
    Result := False;
    AStream.Read(ASize, SizeOf(Longint));
    if ASize > 0 then
    begin
      MS := TMemoryStream.Create;
      try
        MS.CopyFrom(AStream, ASize);
        if ASize > 8 then
        begin
          MS.Position := 0;
          FPreview.LoadFromStream(MS);
          Result := True;
        end;
      finally
        MS.Free;
      end;
    end;
  end;

  procedure ReadFileHeader(AStream: TFileStream;
    var AFileID: AFileIdentifier;
    var AFileVersion: Double);
  begin
    AStream.ReadBuffer(AFileID, SizeOf(AFileID));
    AStream.Read(AFileVersion, SizeOf(Double));
  end;

var
  MPStream     : TFileStream;
  AFileID      : AFileIdentifier;
  AFileVersion : Double;
  AEndOfFile   : AEndOfFileID;
begin
  Result := False;
  FItems.Clear;
  try
    try
      MPStream := TFileStream.Create(FileName, fmOpenReadWrite);
    except
      MPStream := TFileStream.Create(FileName, fmOpenRead);
    end;
    if MPStream = nil then Exit;
    // Read File header and file version
    ReadFileHeader(MPStream, AFileID, AFileVersion);
    if AFileID <> MPFileIdentifier then
      raise Exception.Create(RLInvalidFile);
    // Set document file version
    FFileVersion := AFileVersion;
    // Read Preview
    ReadPreview(MPStream);
    // Author
    FAuthor.LoadFromStream(MPStream);
    // Document
    FDocumentTitle := ReadString(MPStream);
    FComment       := ReadString(MPStream);
    FLastModified  := ReadDateTime(MPStream);
    // Items
    FItems.LoadFromStream(MPStream);
    // Read End of File ID
    MPStream.ReadBuffer(AEndOfFile, SizeOf(AEndOfFileID));
    if AEndOfFile = MPEndOfFileID then Result := True;
    if Result then
    begin
      if not IsTemplate then
        FFilename := Filename
      else
        FFilename := '';
      FSaved    := False;
      FModified := True;
    end;
  finally
    MPStream.Free;
  end;
  if Assigned(FOnFileLoaded) then FOnFileLoaded(Self);
end;

function TMacroPadFile.SaveToFile(FileName: TFileName) : Boolean;

  procedure WriteString(AStream: TStream; Value: String);
  var
    ASize   : Integer;
    AString : UTF8String;
  begin
    AString := UTF8String(Value);
    ASize := Length(AString);
    AStream.WriteBuffer(ASize, SizeOf(Integer));
    if ASize > 0 then
    AStream.WriteBuffer(AString[1], ASize);
  end;

  procedure WriteBool(AStream: TStream; const Value: Boolean);
  begin
    AStream.WriteBuffer(Value, SizeOf(Boolean));
  end;

  procedure WriteInteger(AStream: TStream; const Value: Integer);
  begin
    AStream.WriteBuffer(Value, SizeOf(Integer));
  end;

  procedure WriteDateTime(AStream: TStream; const Value: TDateTime);
  begin
    AStream.WriteBuffer(Value, SizeOf(TDateTime));
  end;

  procedure WritePreview(AStream: TFileStream);
  var
    MS    : TMemoryStream;
    ASize : Longint;
  begin
    MS := TMemoryStream.Create;
    try
      FPreview.SaveToStream(MS);
      ASize := MS.Size;
      MS.Position := 0;
      AStream.Write(ASize, SizeOf(Longint));
      if ASize > 0 then
      AStream.CopyFrom(MS, ASize);
    finally
      MS.Free;
    end;
  end;

  procedure WriteFileHeader(AStream: TFileStream);
  begin
    AStream.WriteBuffer(MPFileIdentifier, SizeOf(MPFileIdentifier));
    AStream.Write(MPFileVersion, SizeOf(Double));
  end;

var
  MPStream : TFileStream;
begin
  try
    try // Create filestream
      MPStream := TFileStream.Create(FileName, fmCreate);
    except
      MPStream := TFileStream.Create(Filename, fmOpenReadWrite);
    end;
    if MPStream = nil then Exit;
    // Write Fileheader and file version
    WriteFileHeader(MPStream);
    // Write File Preview
    WritePreview(MPStream);
    // Author
    FAuthor.SaveToStream(MPStream);
    // Write Printer/Page Settings
    WriteString(MPStream, FDocumentTitle);
    WriteString(MPStream, FComment);
    WriteDateTime(MPStream, FLastModified);
    // Write Objects
    FItems.SaveToStream(MPStream);
    // Write end of file identifier
    MPStream.WriteBuffer(MPEndOfFileID, SizeOf(MPEndOfFileID));
    FFilename := Filename;
    FSaved    := True;
    FModified := False;
  finally
    MPStream.Free;
    Result := True;
    if Assigned(FOnFileSaved) then FOnFileSaved(Self);
  end;
end;

procedure TMacroPadFile.CloseFile;
begin
  FItems.Clear;
  FPreview.Graphic := nil;
  FDocumentTitle   := '';
  FComment         := '';
  FFileVersion     := 0.1;
  with FAuthor do
  begin
    FName    := '';
    FPhone   := '';
    FEmail   := '';
    FTitle   := '';
    FWebsite := '';
    FComment := '';
  end;
  FFilename := '';
  FSaved    := False;
  FModified := False;
  FLastModified := Now;
  if Assigned(FOnFileClosed) then FOnFileClosed(Self);
end;

procedure Register;
begin
  RegisterComponents('ERDesigns', [TMacroPadFile]);
end;

end.
