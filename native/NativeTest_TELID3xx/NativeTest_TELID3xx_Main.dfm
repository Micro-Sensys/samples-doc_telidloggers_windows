object Form_Main: TForm_Main
  Left = 609
  Top = 119
  Width = 757
  Height = 480
  Caption = 'Sample code TELID3xx_Native by MICROSENSYS'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object Panel_CheckReader: TPanel
    Left = 0
    Top = 419
    Width = 749
    Height = 30
    Align = alBottom
    TabOrder = 0
    object Button_ClearMemo: TButton
      Left = 712
      Top = 4
      Width = 30
      Height = 22
      Caption = 'X'
      TabOrder = 0
      OnClick = Button_ClearMemoClick
    end
  end
  object Panel_Result: TPanel
    Left = 297
    Top = 0
    Width = 452
    Height = 419
    Align = alClient
    TabOrder = 1
    object PageControl_Results: TPageControl
      Left = 1
      Top = 1
      Width = 450
      Height = 417
      ActivePage = TabSheet_Memo
      Align = alClient
      TabOrder = 0
      object TabSheet_Memo: TTabSheet
        Caption = 'Memo'
        object Memo_Result: TMemo
          Left = 0
          Top = 0
          Width = 442
          Height = 389
          Align = alClient
          TabOrder = 0
        end
      end
      object TabSheet_Temp: TTabSheet
        Caption = 'Temperature table'
        ImageIndex = 1
        object StringGrid_Temperatures: TStringGrid
          Left = 0
          Top = 0
          Width = 434
          Height = 382
          Align = alClient
          ColCount = 4
          DefaultColWidth = 110
          DefaultRowHeight = 18
          RowCount = 2
          TabOrder = 0
        end
      end
      object TabSheet_InternalCheck: TTabSheet
        Caption = 'Internal Check functions'
        ImageIndex = 2
        object Memo_Check: TMemo
          Left = 0
          Top = 84
          Width = 442
          Height = 305
          Align = alBottom
          ScrollBars = ssBoth
          TabOrder = 0
        end
        object Button_ReadAndCheck: TButton
          Left = 0
          Top = 8
          Width = 185
          Height = 65
          Caption = 'Read TELID and check for valid data'
          TabOrder = 1
          OnClick = Button_ReadAndCheckClick
        end
        object Button_ReadAndCheck_Pressure: TButton
          Left = 192
          Top = 8
          Width = 249
          Height = 65
          Caption = 'Read PRESSURE TELID and check for valid data'
          TabOrder = 2
          OnClick = Button_ReadAndCheck_PressureClick
        end
      end
    end
  end
  object Panel_Operation: TPanel
    Left = 0
    Top = 0
    Width = 297
    Height = 419
    Align = alLeft
    TabOrder = 2
    object Button_WriteRemarks: TButton
      Left = 16
      Top = 64
      Width = 121
      Height = 65
      Caption = 'Program REMARKS to TELID'
      TabOrder = 0
      WordWrap = True
      OnClick = Button_WriteRemarksClick
    end
    object Button_SearchTELID: TButton
      Left = 16
      Top = 8
      Width = 265
      Height = 49
      Caption = 'Scan for TELID datalogger'
      TabOrder = 1
      OnClick = Button_SearchTELIDClick
    end
    object Button_ReadRemarks: TButton
      Left = 160
      Top = 64
      Width = 121
      Height = 65
      Caption = 'Read REMARKS from TELID'
      TabOrder = 2
      WordWrap = True
      OnClick = Button_ReadRemarksClick
    end
    object Button_ReadParameters: TButton
      Left = 160
      Top = 136
      Width = 121
      Height = 65
      Caption = 'Read PARAMETERS from TELID'
      TabOrder = 3
      WordWrap = True
      OnClick = Button_ReadParametersClick
    end
    object Button_ProgramParameters: TButton
      Left = 16
      Top = 136
      Width = 121
      Height = 65
      Caption = 'Program PARAMETERS to TELID'
      TabOrder = 4
      WordWrap = True
      OnClick = Button_ProgramParametersClick
    end
    object Button_ReadTemperatureProtocol: TButton
      Left = 160
      Top = 283
      Width = 121
      Height = 65
      Caption = 'Read Measurement PROTOCOL from TELID'
      TabOrder = 5
      WordWrap = True
      OnClick = Button_ReadTemperatureProtocolClick
    end
    object BitBtn_Cancel: TBitBtn
      Left = 16
      Top = 368
      Width = 265
      Height = 33
      TabOrder = 6
      OnClick = BitBtn_CancelClick
      Kind = bkCancel
    end
    object Button_ProgramPressureParameters: TButton
      Left = 16
      Top = 208
      Width = 121
      Height = 65
      Caption = 'Program PRESSURE PARAMETERS to TELID'
      TabOrder = 7
      WordWrap = True
      OnClick = Button_ProgramPressureParametersClick
    end
    object Button_ReadPressureParameters: TButton
      Left = 160
      Top = 208
      Width = 121
      Height = 65
      Caption = 'Read PRESSURE PARAMETERS from TELID'
      TabOrder = 8
      WordWrap = True
      OnClick = Button_ReadPressureParametersClick
    end
  end
  object Timer_CheckReader: TTimer
    Interval = 5000
    OnTimer = Timer_CheckReaderTimer
    Left = 648
    Top = 8
  end
end
