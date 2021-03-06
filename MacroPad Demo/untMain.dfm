object frmMacroPadDemo: TfrmMacroPadDemo
  Left = 0
  Top = 0
  Caption = 'MacroPad Demo'
  ClientHeight = 447
  ClientWidth = 741
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 532
    Top = 0
    Width = 4
    Height = 447
    Align = alRight
    ExplicitLeft = 529
  end
  object ERDKeyboardLayout: TERDKeyboardLayout
    Left = 0
    Top = 0
    Width = 532
    Height = 447
    Items = <>
    Align = alClient
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 536
    Top = 0
    Width = 205
    Height = 447
    Align = alRight
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object Label1: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 4
      Width = 189
      Height = 13
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      Caption = 'COM Port:'
      ExplicitWidth = 50
    end
    object Label2: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 46
      Width = 189
      Height = 13
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      Caption = 'Baudrate:'
      ExplicitWidth = 48
    end
    object cbCOMPort: TComboBox
      AlignWithMargins = True
      Left = 8
      Top = 21
      Width = 189
      Height = 21
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      Style = csDropDownList
      TabOrder = 0
      OnSelect = cbCOMPortSelect
    end
    object cbBaudrate: TComboBox
      AlignWithMargins = True
      Left = 8
      Top = 63
      Width = 189
      Height = 21
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      Style = csDropDownList
      ItemIndex = 6
      TabOrder = 1
      Text = '115200 Kbs'
      OnSelect = cbBaudrateSelect
      Items.Strings = (
        '9600 Kbs '
        '14400 Kbs'
        '19200 Kbs'
        '38400 Kbs'
        '56000 Kbs'
        '57600 Kbs'
        '115200 Kbs'
        '128000 Kbs'
        '256000 Kbs')
    end
    object btnConnect: TButton
      AlignWithMargins = True
      Left = 8
      Top = 96
      Width = 189
      Height = 25
      Margins.Left = 8
      Margins.Top = 12
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      Caption = 'Connect'
      Enabled = False
      TabOrder = 2
      OnClick = btnConnectClick
    end
    object btnDisconnect: TButton
      AlignWithMargins = True
      Left = 8
      Top = 125
      Width = 189
      Height = 25
      Margins.Left = 8
      Margins.Top = 4
      Margins.Right = 8
      Margins.Bottom = 0
      Align = alTop
      Caption = 'Disconnect'
      Enabled = False
      TabOrder = 3
      OnClick = btnDisconnectClick
    end
  end
  object MacroPadFile: TMacroPadFile
    FileVersion = 0.100000000000000000
    OnFileLoaded = MacroPadFileFileLoaded
    Left = 32
    Top = 24
  end
  object ComPort: TComPort
    BaudRate = br9600
    Port = 'COM1'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    StoredProps = [spBasic]
    TriggersOnRxChar = True
    OnAfterOpen = ComPortAfterOpen
    OnAfterClose = ComPortAfterClose
    OnRxChar = ComPortRxChar
    OnBreak = ComPortBreak
    OnError = ComPortError
    OnException = ComPortException
    Left = 64
    Top = 24
  end
end
