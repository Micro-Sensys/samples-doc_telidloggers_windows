unit NativeTest_TELID3xx_Main;

//-----------------------------------------------------------------------
//--Sample code for native DLL TELID3xx----------------------------------
//--Borland Delphi 7-----------------------------------------------------
//-----------------------------------------------------------------------
//--Last mod:------------------------------------------------------------
//--V0.1-First version supporting with limited functionality-------------
//--V0.2-limited functionality-+ Read/Program parameters-----------------
//--V0.3-first official version incl. temperature data protocol----------
//-----------------------------------------------------------------------
//--V0.4- Clear Grid by button-------------------------------------------
//--V0.5- internal test routine to check for valid data------------------
//--V0.6- support for high temperature modes-----------------------------
//--V0.7- support for TELID343.02----------------------------------------
//--V0.8- support for Seconds-SampleTime for TELID343.02-----------------
//--V0.9- Separate functions for reading/programming TELID311 and--------
//------- TELID343.02----------------------------------------------------
//------- Stop time for TELID343.02 supported----------------------------
//-----------------------------------------------------------------------


interface

uses
  DateUtils,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, ComCtrls, Grids;

const DLL_NAME = 'TELID3xx_Native.dll';

type          //Array type containing TELID temperature data
  TTELID_Temperature_Record =
      record
        Time:        TDateTime;
        Temperature: Double;
        State:       Integer;
      end;
  PTELID_Temperature_Record = ^TTELID_Temperature_Record;

  // 2018-03-23. ML: V0.9
  TTELID_Pressure_Record =
    record
      Time        : TDateTime;
      State       : Integer;
      Pressure    : Double;
      Temperature : Double;
    end;
  // 2018-03-23. Ende
  // 2017-08-03. ML: V0.7
  PTELID_Pressure_Record = ^TTELID_Pressure_Record;

type
  TVersions = 1..$FF;
  TVersionSet = set of TVersions;
  PVersionSet = ^TVersionSet;
  // 2017-08-03. Ende


//------------ Reader specific functions --------------------------------
procedure Reader_OpenInterface(); stdcall; external DLL_NAME;
procedure Reader_CloseInterface();  stdcall; external DLL_NAME;
procedure Reader_GetState();  stdcall; external DLL_NAME;

//------------ TELID specific functions ---------------------------------
//-----------------------------------------------------------------------
function TELID_ReadROCode(PData:PByteArray;PTELID_ID:PInteger):Integer;  stdcall; external DLL_NAME;
function TELID_ReadRemarks(PFrom,PTo,PRemark:PByteArray):Integer;stdcall;external DLL_NAME;
function TELID_ReadParameters(
            PT_ID : Pinteger;
            PT_Min, PT_Max : PDouble;
            PT_ProductCode, PT_Version  : Pbyte;
            PT_Nr_Of_DataSets, PT_Max_Nr_Of_DataSets, PT_MemCount  : Pinteger;
            PT_Mode, PT_Mode_Advanced, PT_Status_Fail : Pbyte;
            PT_HTModeEnable, PT_HistogramEnable, PT_LimitWatchEnable, PT_OutOfLimit : Pbyte;
            PT_StartTime, PT_ProgramTime : PDateTime;
            PT_SampleTime_Min, PT_SampleTime_Sec : Pinteger;
            PT_LED1, PT_LED2, PT_LED3 : PByte):Integer;stdcall; external DLL_NAME;
function TELID_GetTemperatureData(NrOfDataSet:Integer;PData:PTELID_Temperature_record):Integer;stdcall; external DLL_NAME;
//-----------------------------------------------------------------------
function TELID_ProgramRemarks(Array1,Array2,Array3:PByteArray):Integer;stdcall; external DLL_NAME;
function TELID_ProgramParameters(
            PT_ID : PInteger;
            T_Min, T_Max : Double;
            T_ProductCode, T_Version  : PByte;
            T_Max_Nr_Of_DataSets  : integer;
            T_Mode, T_Service_Mode : byte;
            T_HTModeEnable, T_HistogramEnable, T_LimitWatchEnable : byte;
            PT_StartTime, PT_ProgramTime : PDateTime;
            T_SampleTime_Min, T_SampleTime_Sec : integer;
            T_LED1, T_LED2, T_LED3 : byte):Integer;stdcall; external DLL_NAME;
function TELID_ReadTemperatureProtocol(PNrOfReadDatasets:PInteger): Integer;stdcall;external DLL_NAME;
//added 2007-10-15, V1.7x: Get permissions for TELID handling
function TELID_GetKeys():Integer;stdcall;external DLL_NAME;
//added 2007-10-17, V1.7x: Get TELID ID, ProductCode, Version
function TELID_ReadID(
            PT_ID : Pinteger;
            PT_ProductCode, PT_Version  : Pbyte):Integer;stdcall;external DLL_NAME;

//------------ Get variables from library--------------------------------
function Get_Reader_Connected:integer;  stdcall; external DLL_NAME;
function Get_Port_Initialized:integer;  stdcall; external DLL_NAME;
function Get_Reader_Id:integer;  stdcall; external DLL_NAME;
function Reader_Read_Inteface_Id(PReaderId:PInteger;PReadArray:PByteArray):integer;stdcall; external DLL_NAME;

//------------ Set variables to library----------------------------------
procedure Set_Port_Type(Porttype_:integer);  stdcall; external DLL_NAME;
procedure Set_Port_Name(Portname_:string);  stdcall; external DLL_NAME;
procedure Set_Interface_Type(InterfaceType_:integer);  stdcall; external DLL_NAME;


// 2017-08-03. ML: V0.7
// 2018-03-23. ML: V0.9
//function TELID_ReadPressureProtocol(PNrOfReadDatasets:PInteger): Integer; stdcall; external DLL_NAME;
function TELID_ReadPressureProtocol(PNrOfReadDatasets:PInteger; PNrOfReadMeasurements:PInteger): Integer; stdcall; external DLL_NAME;
// 2018-03-23. Ende
function TELID_GetPressureData(NrOfData : Integer; DataArray : PTELID_Pressure_Record): Integer; stdcall; external DLL_NAME;
// 2017-08-03. Ende

//2018-03-14. ML: V0.9
function TELID_ProgramPressureParameters(
            PT_ID : PInteger;
            T_Min, T_Max : Double;
            T_ProductCode, T_Version  : PByte;
//            T_Max_Nr_Of_DataSets  : integer;
            T_Mode, T_Service_Mode : byte;
            T_HTModeEnable, T_HistogramEnable, T_LimitWatchEnable : byte;
            PT_StartTime, PT_StopTime, PT_ProgramTime : PDateTime;
            T_SampleTime_Min, T_SampleTime_Sec : integer;
            T_LED1, T_LED2, T_LED3 : byte):Integer;stdcall; external DLL_NAME;

function TELID_ReadPressureParameters(
            PT_ID : Pinteger;
            PT_Min, PT_Max : PDouble;
            PT_ProductCode, PT_Version  : Pbyte;
            PT_Nr_Of_DataSets, PT_MemCount  : Pinteger;
            PT_Mode, PT_Mode_Advanced, PT_Status_Fail : Pbyte;
            PT_HTModeEnable, PT_HistogramEnable, PT_LimitWatchEnable, PT_OutOfLimit : Pbyte;
            PT_StartTime, PT_StopTime, PT_ProgramTime : PDateTime;
            PT_SampleTime_Min, PT_SampleTime_Sec : Pinteger;
            PT_LED1, PT_LED2, PT_LED3 : PByte):Integer;stdcall; external DLL_NAME;
// 2018-03-14

type
  TForm_Main = class(TForm)
    Timer_CheckReader: TTimer;
    Panel_CheckReader: TPanel;
    Button_ClearMemo: TButton;
    Panel_Result: TPanel;
    Panel_Operation: TPanel;
    Button_WriteRemarks: TButton;
    Button_SearchTELID: TButton;
    Button_ReadRemarks: TButton;
    Button_ReadParameters: TButton;
    Button_ProgramParameters: TButton;
    Button_ReadTemperatureProtocol: TButton;
    BitBtn_Cancel: TBitBtn;
    PageControl_Results: TPageControl;
    TabSheet_Memo: TTabSheet;
    TabSheet_Temp: TTabSheet;
    Memo_Result: TMemo;
    StringGrid_Temperatures: TStringGrid;
    TabSheet_InternalCheck: TTabSheet;
    Memo_Check: TMemo;
    Button_ReadAndCheck: TButton;
    Button_ProgramPressureParameters: TButton;
    Button_ReadPressureParameters: TButton;
    Button_ReadAndCheck_Pressure: TButton;
    procedure FormActivate(Sender: TObject);
    procedure Timer_CheckReaderTimer(Sender: TObject);
    procedure Button_SearchTELIDClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure AddToMemo(Txt:String;Clear:boolean);
    procedure Button_ReadRemarksClick(Sender: TObject);
    procedure Button_WriteRemarksClick(Sender: TObject);
    procedure Button_ReadParametersClick(Sender: TObject);
    procedure Button_ClearMemoClick(Sender: TObject);
    procedure Button_ProgramParametersClick(Sender: TObject);
    procedure Button_ReadTemperatureProtocolClick(Sender: TObject);
    procedure BitBtn_CancelClick(Sender: TObject);
    procedure Button_ReadAndCheckClick(Sender: TObject);
    procedure AddToCheckMemo(Txt:String;Clear:boolean);
    procedure Button_ProgramPressureParametersClick(Sender: TObject);
    procedure Button_ReadPressureParametersClick(Sender: TObject);
    procedure Button_ReadAndCheck_PressureClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form_Main: TForm_Main;

implementation

var
 TELID_Data_Array                 : array[1..8192] of TTELID_Temperature_Record;  //array containing temperature data
 PTELID_Data_Array                : PTELID_Temperature_Record;    //Pointer on dataarray
 TELID_FROM,TELID_TO,TELID_REMARK : String;                 //Free definable strings 16/16/32
 TELID_ID                         : Integer;                //TELID ID-Number
 Array1, Array2, Array3           : Array[0..32] of byte;
 TELID_Min, TELID_Max             : Double;                 //lower and upper temperature limit
 TELID_ProductCode, TELID_Version : Byte;                   //TELID ProductCode and Version
 TELID_Nr_Of_DataSets             : Integer;                //actual number of collected datasets
 TELID_Nr_Of_Read_DataSets        : Integer;                //actual number of read datasets
 TELID_Max_Nr_Of_DataSets         : Integer;                //defined maximum number of datasets
 TELID_MemCount                   : Integer;                //count of memory turns in Roll Over Mode
 TELID_Mode                       : Byte;                   //TELID mode information
 TELID_Service_Mode               : Byte = 0;               //TELID service mode (internal)
 TELID_Mode_Advanced              : Byte;                   //advamced TELID mode information
 TELID_Status_Fail                : Byte;                   //TELID Fail Status
 TELID_HTModeEnable               : Byte = 0;               //enable HIGH temperature mode -> ATTENTION !
 TELID_HistogramEnable            : Byte = 0;               //TELID Histogram function enable/disable
 TELID_LimitWatchEnable           : Byte = 0;               //TELID LimitWatch function enable/disable;
 TELID_OutOfLimit                 : Byte;                   //TELID Out of Limit?
 TELID_StartTime                  : TDateTime;              //TELID Start time
 TELID_ProgramTime                : TDateTime;              //TELID Program Time
 TELID_SampleTime_Min             : Integer;                //TELID sample time (min)
 TELID_SampleTime_Sec             : Integer;                //TELID sample time (sec)
 TELID_LED1Enable                 : byte;
 TELID_LED2Enable                 : byte;
 TELID_LED3Enable                 : byte;
 //added 2007-10-15: added support for TELID HT mode
 TELID_Permissions                : word;

 //added 2018-03-13: added Stop time for TELID 343
 TELID_StopTime, TimeValue        : TDateTime;              //TELID Stop time
 Year, Month, Day, Hour, Min, Sec, MSec : Word;
 //

 cancelread : boolean;

 // 2017-08-03. ML: V0.7
 TELID_PRESSURE_PRODUCT_CODES : TVersionSet;

 // 2018-03-23. ML: V0.9
 TELID_Nr_Of_Pressure_Measurements : Integer;
 {$R *.dfm}


procedure TForm_Main.AddToCheckMemo(Txt:String;Clear:boolean);
begin
  if (clear or  (Memo_Check.Lines.Count>500)) then
    Memo_Check.Clear;
  Memo_Check.Lines.Add(Format('%3d-',[Memo_Check.Lines.Count+1])+DateTimeToStr(Now)+') '+Txt);
end;

procedure TForm_Main.AddToMemo(Txt:String;Clear:boolean);
begin
  if (clear or  (Memo_result.Lines.Count>500)) then
    Memo_result.Clear;
  Memo_Result.Lines.Add(Format('%3d-',[Memo_Result.Lines.Count+1])+DateTimeToStr(Now)+') '+Txt);
end;

procedure TForm_Main.FormActivate(Sender: TObject);
begin
{
  TimeValue := IncMinute(Now, 5);
  DecodeDate(TimeValue, Year, Month, Day);
  DecodeTime(TimeValue, Hour, Min, Sec, MSec);
  DateTimePicker_StopDate.Date := EncodeDate(Year, Month, Day);
  DateTimePicker_StopTime.Time := EncodeTime(Hour, Min, 0, 0);
 }
  AddToMemo('Started...',true);
  TELID_Permissions:=TELID_GetKeys();
  AddToMemo(Format('TELID permissions 0x%x found...',[TELID_Permissions]),false);

  //Set Port Type to library
  //Serial: PortType=0
  //BT: PortType=2
  //USB: PortType=4
  set_port_type(4);
  //Set Port Name to library-no function for USB
  set_port_name('COM26:');
  //Interface Type should be 1356
  set_interface_type(1356);
  //Establish interface communication
  Reader_OpenInterface();
  //Port Initialized ?
  if (get_port_initialized=1) then
    AddToMemo('Port initialized',false);
  //Reader detected ?
  if (get_reader_connected=1) then
    begin
      AddToMemo('Reader connected',false);
      AddToMemo(Format('Reader-ID: %d',[Get_Reader_ID]),false);
    end;
  Application.MessageBox('Sample code TELID3xx_Native.dll, V0.9 (c) MICROSENSYS 2018-03','Information',MB_OK);

  // 2017-07-18
  TELID_PRESSURE_PRODUCT_CODES := [$50];
end;


//---------------- cyclical READER check -------------------------------
procedure TForm_Main.Timer_CheckReaderTimer(Sender: TObject);
begin
  with Panel_CheckReader do
    begin
      Color:=Form_Main.Color;
      Caption:='';
      //Check Port and Reader State
      Reader_GetState();
      if (Get_Port_Initialized=0) then
        begin
          Color:=clred;
          exit;
        end;
      if (Get_Reader_Connected=0) then
        begin
          Color:=clyellow;
          exit;
        end;
      Color:=clLime;
      Caption:=Format('Reader ID %d detected...',[Get_Reader_Id]);
    end;
end;


//---------------- SCAN for TELID DATALOGGER ---------------------------
procedure TForm_Main.Button_SearchTELIDClick(Sender: TObject);
var
  wait          : double;
  i, LastResult : Integer;
  ReadArray     : Array[0..8] of byte;
  Strg          : String;

begin
AddToMemo('Searching for TELID...',false);
wait:=GetTickCount();
while (GetTickCount()<wait+2500) do
   begin
   //Search for TELID datalogger
   LastResult:=TELID_ReadRoCode(@ReadArray,@TELID_ID);
   if (LastResult=0) then
      begin
      Strg:='';
      //ReadArray[0] contains length of Array
      for i:=0 to ReadArray[0]-1 do Strg:=Strg+IntToHex(ReadArray[i+1],2)+' ';
      AddToMemo('TELID RO-Code '+Strg+' found!',false);
      AddToMemo(Format('TELID ID: %d',[TELID_ID]),false);
      MessageBeep(MB_OK);
      end;
   if (LastResult<>0) then break;
   LastResult:=TELID_ReadId(@TELID_ID,@TELID_PRODUCTCODE,@TELID_VERSION);
   if (LastResult=0) then
      begin
      Strg:='';
      //ReadArray[0] contains length of Array
      AddToMemo(Format('TELID ID: %d, ProductCode: %x, Version: %x',[TELID_ID,TELID_PRODUCTCODE,TELID_VERSION]),false);
      MessageBeep(MB_OK);
      exit;
      end;
   end;
  AddToMemo('No TELID found!',false);
  MessageBeep(MB_ICONEXCLAMATION);
end;



procedure TForm_Main.FormCloseQuery(Sender: TObject;
var
  CanClose: Boolean);

begin
  // 2017-09-08
  cancelread := true;

  if (Get_Port_Initialized<>0) then
    begin
      Reader_CloseInterface();
      Memo_Result.Lines.Add('Port closed...');
    end;
end;



procedure TForm_Main.Button_ClearMemoClick(Sender: TObject);
begin
  Memo_Result.Clear;
  with StringGrid_Temperatures do
    begin
      RowCount:=2;
      ColCount:=4;
      FixedRows:=1;
      FixedCols:=1;
      Cells[0,0]:='Nr';
      Cells[1,0]:='Time';
      Cells[2,0]:='T/°C';
      Cells[3,0]:='State';
      Cells[0,1]:='';
      Cells[1,1]:='';
      Cells[2,1]:='';
      Cells[3,1]:='';
    end;
end;


//---------------- Read Reamrks from TELID -----------------------------
procedure TForm_Main.Button_ReadRemarksClick(Sender: TObject);
var
  wait          : double;
  i, LastResult : Integer;
  ReadArray     : Array[0..8] of byte;
  Strg          : String;

begin
  AddToMemo('Searching for TELID...',false);
  wait:=GetTickCount();
  while (GetTickCount()<wait+2500) do
    begin
      //Search for TELID datalogger
      LastResult:=TELID_ReadRoCode(@ReadArray,@TELID_ID);
      if (LastResult=0) then
        begin
          Strg:='';
          //ReadArray[0] contains length of Array
          for i:=0 to ReadArray[0]-1 do
            Strg := Strg + IntToHex(ReadArray[i + 1], 2) + ' ';
          AddToMemo('TELID RO-Code '+Strg+' found!',false);
          AddToMemo(Format('TELID ID: %d',[TELID_ID]),false);
          break;
        end;
    end;

  if (LastResult<>0) then
    begin
      // 2017-08-11. ML
      AddToMemo('No TELID found!',false);
      exit;
    end;

  //Read TELID remarks
  LastResult:=TELID_ReadRemarks(@Array1,@Array2,@Array3);
  AddToMemo(Format('Result 0x%2X reading TELID Remarks.',[LastResult]),false);
  if (LastResult<>0) then
    begin
      exit;
    end;

  TELID_FROM:='';
  if Array1[0] > 0 then
    for i:=0 to Array1[0] do
      TELID_FROM:=TELID_FROM+Chr(Array1[i+1]);

  TELID_TO:='';
  if Array2[0] > 0 then
    for i:=0 to Array2[0] do
      TELID_TO:=TELID_TO+Chr(Array2[i+1]);

  TELID_REMARK:='';
  if Array3[0] > 0 then
    for i:=0 to Array3[0] do
      TELID_REMARK:=TELID_REMARK+Chr(Array3[i+1]);

  AddToMemo('TELID_FROM: '+TELID_FROM,false);
  AddToMemo('TELID_TO: '+TELID_TO,false);
  AddToMemo('TELID_REMARK: '+TELID_REMARK,false);
  MessageBeep(MB_OK);
end;


//---------------- Write Reamrks to TELID -----------------------------
procedure TForm_Main.Button_WriteRemarksClick(Sender: TObject);
var
  wait          : double;
  i, LastResult : Integer;
  ReadArray     : Array[0..8] of byte;
  Array1, Array2, Array3 : Array[0..32] of byte;
  Strg          : String;

begin
  AddToMemo('Searching for TELID...',false);
  wait:=GetTickCount();
  while (GetTickCount()<wait+2500) do
    begin
      //Search for TELID datalogger
      LastResult:=TELID_ReadRoCode(@ReadArray,@TELID_ID);
      if (LastResult=0) then
        begin
          Strg:='';
          //ReadArray[0] contains length of Array
          for i:=0 to ReadArray[0]-1 do
            Strg:=Strg+IntToHex(ReadArray[i + 1], 2) + ' ';
          AddToMemo('TELID RO-Code '+Strg+' found!',false);
          AddToMemo(Format('TELID ID: %d',[TELID_ID]),false);
          break;
        end;
    end;
  if (LastResult<>0) then
    begin
      // 2017-08-11. ML
      AddToMemo('No TELID found!',false);
      exit;
    end;

  TELID_FROM:='From...';
  Array1[0]:=length(TELID_FROM);
  if Array1[0] > 0 then
    for i:=0 to Array1[0] do
      Array1[i+1]:=byte(TELID_FROM[i+1]);

  TELID_To:='To...';
  Array2[0]:=length(TELID_To);
  if Array2[0]>0 then
    for i:=0 to Array2[0] do
      Array2[i+1]:=byte(TELID_To[i+1]);

  TELID_Remark:='Remark-'+DateTimeToStr(now);
  Array3[0]:=length(TELID_Remark);
  if Array3[0]>0 then
    for i:=0 to Array3[0] do
      Array3[i+1]:=byte(TELID_Remark[i+1]);

  //Program TELID remarks
  LastResult:=TELID_ProgramRemarks(@Array1,@Array2,@Array3);
  AddToMemo(Format('Result 0x%2X programming TELID Remarks.',[LastResult]),false);
  if (LastResult<>0) then
    exit;
  MessageBeep(MB_OK);
end;


//---------------- Read Parameters from TELID -----------------------------
procedure TForm_Main.Button_ReadParametersClick(Sender: TObject);
var
  wait          : double;
  i, LastResult : Integer;
  ReadArray     : Array[0..8] of byte;
  Strg          : String;

begin
  AddToMemo('Searching for TELID...',false);
  wait:=GetTickCount();
  while (GetTickCount()<wait+2500) do
    begin
      //Search for TELID datalogger
      LastResult:=TELID_ReadRoCode(@ReadArray,@TELID_ID);
      if (LastResult=0) then
        begin
          Strg:='';
          //ReadArray[0] contains length of Array
          for i:=0 to ReadArray[0]-1 do
            Strg:=Strg+IntToHex(ReadArray[i+1],2)+' ';
          AddToMemo('TELID RO-Code '+Strg+' found!',false);
          AddToMemo(Format('TELID ID: %d',[TELID_ID]),false);
          break;
        end;
    end;
  if (LastResult<>0) then
    begin
      // 2017-08-11
      AddToMemo('No TELID found!',false);
      exit;
    end;

  //Read TELID remarks
  LastResult:=TELID_ReadParameters(@TELID_ID,@TELID_Min,@TELID_Max,
            @TELID_ProductCode,@TELID_Version,
            @TELID_Nr_Of_DataSets,@TELID_Max_Nr_Of_DataSets,@TELID_MemCount,
            @TELID_Mode,@TELID_Mode_Advanced,@TELID_Status_Fail,
            @TELID_HTModeEnable,@TELID_HistogramEnable,@TELID_LimitWatchEnable,@TELID_OutOfLimit,
            @TELID_StartTime,@TELID_ProgramTime,@TELID_SampleTime_Min,@TELID_SampleTime_Sec,
            @TELID_LED1Enable,@TELID_LED2Enable,@TELID_LED3Enable);
  AddToMemo(Format('Result 0x%2X reading TELID Parameters.',[LastResult]),false);
  if (LastResult<>0) then
    begin
      MessageBeep(MB_ICONEXCLAMATION);
      exit;
    end;

  MessageBeep(MB_OK);
  AddToMemo('Read Parameters:',false);
  AddToMemo(Format('TELID ID: %d',[TELID_ID]),false);
  AddToMemo(Format('ProductCode : 0x%X',[TELID_ProductCode]),false);
  AddToMemo(Format('Version : 0x%X',[TELID_Version]),false);
  AddToMemo(Format('Limit MIN : %f°C',[TELID_Min]),false);
  AddToMemo(Format('Limit MAX : %f°C',[TELID_Max]),false);
  AddToMemo('Start Time: '+DateTimeToStr(TELID_StartTime),false);
  AddToMemo('Program Time: '+DateTimeToStr(TELID_ProgramTime),false);
  AddToMemo(Format('Sample Time: %d:%d min:sec',[TELID_SampleTime_Min,TELID_SampleTime_Sec]),false);
  AddToMemo(Format('Maximum Number Of Datasets: %d',[TELID_Max_Nr_Of_Datasets]),false);
  AddToMemo(Format('Number Of Datasets: %d',[TELID_Nr_Of_Datasets]),false);
  AddToMemo(Format('TELID Mode : 0x%X',[TELID_Mode]),false);
  AddToMemo(Format('TELID Mode_Advanced : 0x%X',[TELID_Mode_Advanced]),false);
  AddToMemo(Format('TELID Status_Fail : 0x%X',[TELID_Status_Fail]),false);
  AddToMemo(Format('TELID HT Mode enabled (0/1): %d',[TELID_HTModeEnable]),false);
  AddToMemo(Format('TELID Histogram enabled (0/1): %d',[TELID_HistogramEnable]),false);
  AddToMemo(Format('TELID Limit Watch enabled (0/1): %d',[TELID_LimitWatchEnable]),false);
  if bool(TELID_LimitWatchEnable) then
    AddToMemo(Format('TELID Out of Limit (0/1): %d',[TELID_OutOfLimit]),false);
end;


//-------- Program parameters to TELID -----------------------------------
procedure TForm_Main.Button_ProgramParametersClick(Sender: TObject);
var
  wait          : double;
  i, LastResult : Integer;
  ReadArray     : Array[0..8] of byte;
  Strg          : String;

begin
  AddToMemo('Searching for TELID...',false);
  wait:=GetTickCount();
  while (GetTickCount()<wait+2500) do
    begin
      //Search for TELID datalogger
      LastResult:=TELID_ReadRoCode(@ReadArray,@TELID_ID);
      if (LastResult=0) then
        begin
          Strg:='';
          //ReadArray[0] contains length of Array
          for i:=0 to ReadArray[0] - 1 do
            Strg := Strg + IntToHex(ReadArray[i + 1], 2) + ' ';
            AddToMemo('TELID RO-Code '+Strg+' found!',false);
            AddToMemo(Format('TELID ID: %d',[TELID_ID]),false);
            break;
        end;
   end;
  if (LastResult<>0) then
    begin
      AddToMemo('No TELID found!',false);
      exit;
    end;

  //Read TELID remarks

  //STOP FULL MODE
  TELID_mode:=1;
  TELID_Service_Mode:=0;
  //Sample Time 2 sec
  TELID_SampleTime_Min:=0;
  TELID_SampleTime_Sec:=2;
  //start up in 1 min
  TELID_StartTime:=Now+EnCodeTime(0,1,0,0);

  // 2017-08-08. ML: V0.7
  ////Limit MIN=15°C
  //TELID_Min:=15.0;
  ////Limit MAX=20°C
  //TELID_Max:=25.0;
  if (TELID_ProductCode in TELID_PRESSURE_PRODUCT_CODES) then
    begin
      // Keine Überprüfung
      TELID_Min := 0.0;
      TELID_Max := 0.0;
    end
  else
    begin
      //Limit MIN=15°C
      TELID_Min := 15.0;
      //Limit MAX=20°C
      TELID_Max := 25.0;
    end;

  //maximum number of datasets (multiple of 256)
  // 2017-08-03. ML: V0.7
  //TELID_Max_Nr_Of_DataSets:=1028;
  if (TELID_ProductCode in TELID_PRESSURE_PRODUCT_CODES) then
    begin
      TELID_Max_Nr_Of_DataSets := 5201;
      TELID_LimitWatchEnable := 0;
    end
  else
    begin
      TELID_Max_Nr_Of_DataSets := 1028;
      TELID_LimitWatchEnable := 1;
    end;
  // 2017-08-03. Ende

  TELID_HTModeEnable:=0;
  TELID_HistogramEnable:=0;
  //TELID_LimitWatchEnable:=1;
  LastResult:=TELID_ProgramParameters(
            @TELID_ID,
            TELID_Min, TELID_Max,
            @TELID_ProductCode, @TELID_Version,
            TELID_Max_Nr_Of_DataSets,
            TELID_Mode, TELID_Mode_Advanced,
            TELID_HTModeEnable, TELID_HistogramEnable, TELID_LimitWatchEnable,
            @TELID_StartTime, @TELID_ProgramTime,
            TELID_SampleTime_Min, TELID_SampleTime_Sec,
            TELID_LED1Enable, TELID_LED2Enable, TELID_LED3Enable);

  AddToMemo(Format('Result 0x%2X programming TELID Parameters.',[LastResult]),false);
  if (LastResult<>0) then
    begin
      exit;
    end;
  AddToMemo('Program Parameters:',false);
  AddToMemo(Format('TELID ID: %d',[TELID_ID]),false);
  AddToMemo(Format('ProductCode : 0x%X',[TELID_ProductCode]),false);
  AddToMemo(Format('Version : 0x%X',[TELID_Version]),false);
  AddToMemo(Format('Limit MIN : %f°C',[TELID_Min]),false);
  AddToMemo(Format('Limit MAX : %f°C',[TELID_Max]),false);
  AddToMemo('Start Time: '+DateTimeToStr(TELID_StartTime),false);
  AddToMemo('Program Time: '+DateTimeToStr(TELID_ProgramTime),false);
  AddToMemo(Format('Sample Time: %d:%d min:sec',[TELID_SampleTime_Min,TELID_SampleTime_Sec]),false);
  AddToMemo(Format('Maximum Number Of Datasets: %d',[TELID_Max_Nr_Of_Datasets]),false);
  AddToMemo(Format('TELID Mode : 0x%X',[TELID_Mode]),false);

  case TELID_Mode of
    0 : AddToMemo('Sleep Mode programmed...',false);        //BIT0=Sleep/Run
    1 : AddToMemo('Stop Full Mode programmed...',false);    //BIT1=0 Stop Full Mode
    3 : AddToMemo('Roll Over Mode programmed...',false);    //BIT1=1 Roll Over Mode
  end;

  AddToMemo(Format('TELID Mode_Advanced : 0x%X',[TELID_Mode_Advanced]),false);
  AddToMemo(Format('TELID Histogram enabled (0/1): %d',[TELID_HistogramEnable]),false);
  AddToMemo(Format('TELID HT Mode enabled (0/1): %d',[TELID_HTModeEnable]),false);
  AddToMemo(Format('TELID Limit Watch enabled (0/1): %d',[TELID_LimitWatchEnable]),false);
end;


procedure TForm_Main.Button_ReadTemperatureProtocolClick(Sender: TObject);
var
  i, j: integer;
  LastResult : Integer;

  // 2017-08-03. ML: V0.7
  TELID_Pressure_Data_Array : array of TTELID_Pressure_Record;
  Index: Integer;
  // 2017-08-03. Ende

  // 2017-09-08.
  TimeStamp : TDateTime;

begin
  if (TELID_Nr_Of_DataSets=0) then
    begin
      AddToMemo('No datasets found on TELID',false);
      exit;
    end;

  cancelread:=false;
  i:=0;

  // 2017-08-03. ML: V0.7
  if (TELID_ProductCode in TELID_PRESSURE_PRODUCT_CODES) then
    begin
      while (not cancelread) do
        begin
          try
            // 2018-03-23. ML: V0.9
            LastResult := TELID_ReadPressureProtocol(@TELID_Nr_Of_Read_DataSets, @TELID_Nr_Of_Pressure_Measurements);
            // 2018-03-23. Ende
            AddToMemo(Format('ReadPressureProtocol-datasets read: %d, result 0x%X', [TELID_Nr_Of_Read_DataSets, LastResult]), false);

            if (LastResult = 0) then
              begin
               // 2018-03-23. ML: V0.9
                AddToMemo(Format('ReadPressureProtocol- %d measurements read', [TELID_Nr_Of_Pressure_Measurements]), false);
                SetLength(TELID_Pressure_Data_Array, TELID_Nr_Of_Pressure_Measurements);
                // 2018-03-23. Ende
                AddToMemo('Reading pressure protocol complete !', false);
                break;
              end;
            Application.ProcessMessages;
          except
            exit;
          end;
        end;
      if (cancelread) then
        begin
          AddToMemo('Ready/Aborted...', false);
          exit;
        end;
      MessageBeep(MB_OK);

      with StringGrid_Temperatures do
        begin
          RowCount := 2;
          ColCount := 5;
          FixedRows := 1;
          FixedCols := 1;
          Cells[0, 0] := 'Nr';
          Cells[1, 0] := 'Time';
          Cells[2, 0] := 'P/bar';
          Cells[3, 0] := 'T/°C';
          Cells[4, 0] := 'State';
        end;

      Index := 1;
      for i := 1 to TELID_Nr_Of_Pressure_Measurements do
        begin
          try
            if bool(TELID_GetPressureData(i, @TELID_Pressure_Data_Array[i - 1])) then
              exit; // load pressure dataset from DLL
            with StringGrid_Temperatures do
              begin
                RowCount := RowCount + 1;
                Cells[0, Index] := Format('%d', [i]);
                TimeStamp := TELID_Pressure_Data_Array[i - 1].Time;
                Cells[1, Index] := DateTimeToStr(TimeStamp);
                Cells[2, Index] := Format('%0.3f', [TELID_Pressure_Data_Array[i - 1].Pressure]);
                Cells[3, Index] := Format('%0.2f', [TELID_Pressure_Data_Array[i - 1].Temperature]);
                Cells[4, Index] := Format('0x%.2X', [TELID_Pressure_Data_Array[i - 1].State]);
              end;
            Inc(Index);
          except
            exit
          end;
        end;

        StringGrid_Temperatures.RowCount := StringGrid_Temperatures.RowCount - 1;
        exit;
    end;
  // 2017-08-03. Ende


  while (not cancelread) do
    begin
      inc(i);
      LastResult:=TELID_ReadTemperatureProtocol(@TELID_Nr_Of_Read_DataSets);
      AddToMemo(Format('ReadTemperatureProtocol-datasets read: %d, result 0x%X',[TELID_Nr_Of_Read_DataSets,LastResult]),false);
      if (LastResult=0) then
        begin
          AddToMemo('Reading temperature protocol complete !',false);
          break;
        end;
      Application.ProcessMessages;
  end;
  if (cancelread) then
    exit;
  MessageBeep(MB_OK);
  with StringGrid_Temperatures do
    begin
      RowCount:=TELID_Nr_Of_DataSets+1;
      ColCount:=4;
      Cells[0,0]:='Nr';
      Cells[1,0]:='Time';
      Cells[2,0]:='T/°C';
      Cells[3,0]:='State';
    end;
  for i:=1 to TELID_Nr_Of_DataSets do
    begin
      PTELID_Data_Array:=@TELID_Data_Array[i];
      if bool(TELID_GetTemperatureData(i,PTELID_Data_Array)) then exit;  //load temperature dataset from DLL
      with StringGrid_Temperatures do
        begin
          Cells[0,i]:=IntToStr(i);
          Cells[1,i]:=DateTimeToStr(PTELID_Data_Array^.Time);
          // 2017-08-11. ML. Nur zwei Kommastellen
          //Cells[2,i]:=FloatToStr(PTELID_Data_Array^.Temperature);
          Cells[2, i] := Format('%0.2f', [PTELID_Data_Array^.Temperature]);
          // 2017-08-11. Ende
          Cells[3,i]:=Format('0x%.2X',[PTELID_Data_Array^.State]);
        end;
    end;
end;


procedure TForm_Main.BitBtn_CancelClick(Sender: TObject);
begin
cancelread:=true;
end;


procedure TForm_Main.Button_ReadAndCheckClick(Sender: TObject);
var
  wait          : double;
  i, counter, LastResult : Integer;
  ReadArray     : Array[0..8] of byte;
  Strg          : String;

  TELID_Pressure_DataSet_Array : array of TTELID_Pressure_Record;
  j, Index : Integer;

begin
  cancelread:=false;
  counter:=1;
  Memo_Check.Color:=clWhite;

  while (not cancelread) do
    begin
      AddToCheckMemo(Format('Durchlauf %d:',[counter]),false);
      inc(counter);
      AddToCheckMemo('Searching for TELID...',false);
      wait:=GetTickCount();
      AddToCheckMemo(Format('Reader-ID: %d',[Get_Reader_Id]),false);
      repeat
        Application.ProcessMessages
      until (GetTickCount>wait+80);

      while (GetTickCount()<wait+2500) do
        begin
          //Search for TELID datalogger
          LastResult:=TELID_ReadRoCode(@ReadArray,@TELID_ID);
          if (LastResult=0) then
            begin
              Strg:='';
              //ReadArray[0] contains length of Array
              for i:=0 to ReadArray[0]-1 do
                Strg:=Strg+IntToHex(ReadArray[i+1],2)+' ';
              AddToCheckMemo('TELID RO-Code '+Strg+' found!',false);
              AddToCheckMemo(Format('TELID ID: %d',[TELID_ID]),false);
              break;
            end
          else
            begin
            //AddToCheckMemo(Format('Error: %X',[LastResult]),false);
            end;;
        end;

      if (LastResult<>0) then
        begin
          MessageBeep(MB_ICONEXCLAMATION);
          Application.ProcessMessages;
          continue;
        end;

      //Read TELID remarks
      LastResult:=TELID_ReadParameters(@TELID_ID,@TELID_Min,@TELID_Max,
                    @TELID_ProductCode,@TELID_Version,
                    @TELID_Nr_Of_DataSets,
                    @TELID_Max_Nr_Of_DataSets,
                    @TELID_MemCount,
                    @TELID_Mode,
                    @TELID_Mode_Advanced,
                    @TELID_Status_Fail,
                    @TELID_HTModeEnable,
                    @TELID_HistogramEnable,
                    @TELID_LimitWatchEnable,
                    @TELID_OutOfLimit,
                    @TELID_StartTime,
                    @TELID_ProgramTime,
                    @TELID_SampleTime_Min,
                    @TELID_SampleTime_Sec,
                    @TELID_LED1Enable,
                    @TELID_LED2Enable,
                    @TELID_LED3Enable);

      AddToCheckMemo(Format('Result 0x%2X reading TELID Parameters.',[LastResult]),false);

      // 2018-03-26. ML: V16.0.0.0
      if (LastResult = $4F) then
        begin
          Memo_Check.Color:=clRed;
          MessageBeep(MB_ICONEXCLAMATION);
          exit;
        end;
      // 2018-03-26. Ende

      if (LastResult<>0) then
        begin
          MessageBeep(MB_ICONEXCLAMATION);
          continue;
        end;
      MessageBeep(MB_OK);
      AddToCheckMemo('Read Parameters:',false);
      AddToCheckMemo(Format('TELID ID: %d',[TELID_ID]),false);
      AddToCheckMemo(Format('ProductCode : 0x%X',[TELID_ProductCode]),false);
      AddToCheckMemo(Format('Version : 0x%X',[TELID_Version]),false);
      AddToCheckMemo('Start Time: '+DateTimeToStr(TELID_StartTime),false);
      AddToCheckMemo('Program Time: '+DateTimeToStr(TELID_ProgramTime),false);
      AddToCheckMemo(Format('Sample Time: %d:%d min:sec',[TELID_SampleTime_Min,TELID_SampleTime_Sec]),false);
      AddToCheckMemo(Format('Number Of Datasets: %d',[TELID_Nr_Of_Datasets]),false);
      AddToCheckMemo(Format('TELID Mode : 0x%X',[TELID_Mode]),false);
      AddToCheckMemo(Format('TELID Mode_Advanced : 0x%X',[TELID_Mode_Advanced]),false);
      AddToCheckMemo(Format('TELID Status_Fail : 0x%X',[TELID_Status_Fail]),false);

      //Now read temperature table
      if (TELID_Nr_Of_DataSets=0) then
        begin
          AddToCheckMemo('No datasets found on TELID',false);
          cancelread:=true;
        end;

      i:=0;
      while (not cancelread) do
        begin
          inc(i);
          LastResult:=TELID_ReadTemperatureProtocol(@TELID_Nr_Of_Read_DataSets);
          if (LastResult=$2B) then
            begin
              AddToCheckMemo(Format('ReadTemperatureProtocol-datasets read: %d, result 0x%X',[TELID_Nr_Of_Read_DataSets,LastResult]),false);
              Memo_Check.Color:=clYellow;
            end;
          if (LastResult=0) then
            begin
              // 2017-08-11. ML
              AddToCheckMemo(Format('ReadPressureProtocol-datasets read: %d, result 0x%X', [TELID_Nr_Of_Read_DataSets, LastResult]), false);
              AddToCheckMemo('Reading temperature protocol complete !',false);
              break;
            end;
          Application.ProcessMessages;
        end;

      if (cancelread) then
        exit;
      MessageBeep(MB_OK);
      with StringGrid_Temperatures do
        begin
          RowCount:=TELID_Nr_Of_DataSets+1;
          ColCount:=4;
          Cells[0,0]:='Nr';
          Cells[1,0]:='Time';
          Cells[2,0]:='T/°C';
          Cells[3,0]:='State';
        end;
      for i:=1 to TELID_Nr_Of_DataSets do
        begin
          PTELID_Data_Array:=@TELID_Data_Array[i];
          if bool(TELID_GetTemperatureData(i,PTELID_Data_Array)) then
            exit;  //load temperature dataset from DLL
          with StringGrid_Temperatures do
            begin
              Cells[0,i]:=IntToStr(i);
              Cells[1,i]:=DateTimeToStr(PTELID_Data_Array^.Time);
              // 2017-08-11. ML: Nur zwei Kommastellen
              //Cells[2,i]:=FloatToStr(PTELID_Data_Array^.Temperature);
              Cells[2, i] := Format('%0.2f', [PTELID_Data_Array^.Temperature]);
              // 2017-08-11. Ende
              Cells[3,i]:=Format('0x%X',[PTELID_Data_Array^.State]);
            end;
        end;

      //now check for VALID temperatures
      for i:=1 to TELID_Nr_Of_DataSets do
        begin
          PTELID_Data_Array:=@TELID_Data_Array[i];
          if ((PTELID_Data_Array^.Temperature < TELID_MIN) or (PTELID_Data_Array^.Temperature>TELID_Max)) then
            begin
              cancelread:=true;
              Memo_Check.Color:=clRed;
              AddToCheckMemo(Format('Error at dataset : %d',[i]),false);
            end;
          if (PTELID_Data_Array^.State<>0) then
            begin
              cancelread:=true;
              Memo_Check.Color:=clRed;
              AddToCheckMemo(Format('Error at dataset : %d',[i]),false);
            end;
        end;

      if (not cancelread) then
        AddToCheckMemo('Seems to be no error...',false);
      AddToCheckMemo('',false);
      break;
    end;
  if cancelread then
    AddToCheckMemo('Ready/Aborted...',false);
end;




procedure TForm_Main.Button_ProgramPressureParametersClick(
  Sender: TObject);
var
  wait          : double;
  i, LastResult : Integer;
  ReadArray     : Array[0..8] of byte;
  Strg          : String;
  StartTime, StopTime      : TDateTime;
  Year, Month, Day, Hour, Min, Sec, MSec  : Word;

begin
  StartTime := Now + EncodeTime(0, 1, 0, 0);

  // 2018-03-26. ML: V16.0.0.0: StartTime zum vollen Minute eingestellt
  DecodeDate(StartTime, Year, Month, Day);
  DecodeTime(StartTime, Hour, Min, Sec, MSec);
  StartTime := EncodeDateTime(Year, Month, Day, Hour, Min, 0, 0);
  // 2018-03-26. Ende

  // Messdauer zu 1 Stunde gesetzt.
  StopTime := StartTime + EncodeTime(1, 0, 0, 0);

  AddToMemo('Searching for TELID...',false);
  wait:=GetTickCount();
  while (GetTickCount()<wait+2500) do
    begin
      //Search for TELID datalogger
      LastResult:=TELID_ReadRoCode(@ReadArray,@TELID_ID);
      if (LastResult=0) then
        begin
          Strg:='';
          //ReadArray[0] contains length of Array
          for i:=0 to ReadArray[0] - 1 do
            Strg := Strg + IntToHex(ReadArray[i + 1], 2) + ' ';
            AddToMemo('TELID RO-Code '+Strg+' found!',false);
            AddToMemo(Format('TELID ID: %d',[TELID_ID]),false);
            break;
        end;
   end;
  if (LastResult<>0) then
    begin
      AddToMemo('No TELID found!',false);
      exit;
    end;

  //Read TELID remarks

 //STOP FULL MODE
  TELID_mode:=1;
  TELID_Service_Mode:=0;
  //Sample Time 2 sec
  TELID_SampleTime_Min:=0;
  TELID_SampleTime_Sec:=2;
  //start up in 1 min
  //TELID_StartTime:=Now+EnCodeTime(0,1,0,0);
  TELID_StartTime := StartTime;
  TELID_StopTime := StopTime;


  // Derzeit keine Überprüfung
  TELID_Min := 0.0;
  TELID_Max := 0.0;
  TELID_LimitWatchEnable := 0;

  // Max_Nr_of_Datasets für TELID343 nicht benutzt
  //TELID_Max_Nr_Of_DataSets := 5201;

  TELID_HTModeEnable:=0;
  TELID_HistogramEnable:=0;

  LastResult:=TELID_ProgramPressureParameters(
            @TELID_ID,
            TELID_Min, TELID_Max,
            @TELID_ProductCode, @TELID_Version,
            TELID_Mode, TELID_Mode_Advanced,
            TELID_HTModeEnable, TELID_HistogramEnable, TELID_LimitWatchEnable,
            @TELID_StartTime, @TELID_StopTime, @TELID_ProgramTime,
            TELID_SampleTime_Min, TELID_SampleTime_Sec,
            TELID_LED1Enable, TELID_LED2Enable, TELID_LED3Enable);

  AddToMemo(Format('Result 0x%2X programming TELID Parameters.',[LastResult]),false);
  if (LastResult<>0) then
    begin
      exit;
    end;
  AddToMemo('Program Parameters:',false);
  AddToMemo(Format('TELID ID: %d',[TELID_ID]),false);
  AddToMemo(Format('ProductCode : 0x%X',[TELID_ProductCode]),false);
  AddToMemo(Format('Version : 0x%X',[TELID_Version]),false);
{ // 2018-03-14. MML: Derzeit nicht benutzt
  AddToMemo(Format('Limit MIN : %f bar',[TELID_Min]),false);
  AddToMemo(Format('Limit MAX : %f bar',[TELID_Max]),false);
}
  AddToMemo('Start Time: '+DateTimeToStr(TELID_StartTime),false);
  AddToMemo('Stop Time: ' +DateTimeToStr(TELID_StopTime), false);
  AddToMemo('Program Time: '+DateTimeToStr(TELID_ProgramTime),false);
  AddToMemo(Format('Sample Time: %d:%d min:sec',[TELID_SampleTime_Min,TELID_SampleTime_Sec]),false);
//  AddToMemo(Format('Maximum Number Of Datasets: %d',[TELID_Max_Nr_Of_Datasets]),false);
  AddToMemo(Format('TELID Mode : 0x%X',[TELID_Mode]),false);

  case TELID_Mode of
    0 : AddToMemo('Sleep Mode programmed...',false);        //BIT0=Sleep/Run
    1 : AddToMemo('Stop Full Mode programmed...',false);    //BIT1=0 Stop Full Mode
    3 : AddToMemo('Roll Over Mode programmed...',false);    //BIT1=1 Roll Over Mode
  end;

{ // 2018-03-14. ML: Derzeit nicht benutzt
  AddToMemo(Format('TELID Mode_Advanced : 0x%X',[TELID_Mode_Advanced]),false);
  AddToMemo(Format('TELID Histogram enabled (0/1): %d',[TELID_HistogramEnable]),false);
  AddToMemo(Format('TELID HT Mode enabled (0/1): %d',[TELID_HTModeEnable]),false);
  AddToMemo(Format('TELID Limit Watch enabled (0/1): %d',[TELID_LimitWatchEnable]),false);
}
end;

procedure TForm_Main.Button_ReadPressureParametersClick(Sender: TObject);
var
  wait          : double;
  i, LastResult : Integer;
  ReadArray     : Array[0..8] of byte;
  Strg          : String;

begin
  AddToMemo('Searching for TELID...',false);
  wait:=GetTickCount();
  while (GetTickCount()<wait+2500) do
    begin
      //Search for TELID datalogger
      LastResult:=TELID_ReadRoCode(@ReadArray,@TELID_ID);
      if (LastResult=0) then
        begin
          Strg:='';
          //ReadArray[0] contains length of Array
          for i:=0 to ReadArray[0]-1 do
            Strg:=Strg+IntToHex(ReadArray[i+1],2)+' ';
          AddToMemo('TELID RO-Code '+Strg+' found!',false);
          AddToMemo(Format('TELID ID: %d',[TELID_ID]),false);
          break;
        end;
    end;
  if (LastResult<>0) then
    begin
      // 2017-08-11
      AddToMemo('No TELID found!',false);
      exit;
    end;

  //Read TELID remarks
  LastResult:=TELID_ReadPressureParameters(@TELID_ID,@TELID_Min,@TELID_Max,
            @TELID_ProductCode,@TELID_Version,
            @TELID_Nr_Of_DataSets,@TELID_MemCount,
            @TELID_Mode,@TELID_Mode_Advanced,@TELID_Status_Fail,
            @TELID_HTModeEnable,@TELID_HistogramEnable,@TELID_LimitWatchEnable,@TELID_OutOfLimit,
            @TELID_StartTime,@TELID_StopTime, @TELID_ProgramTime,@TELID_SampleTime_Min,@TELID_SampleTime_Sec,
            @TELID_LED1Enable,@TELID_LED2Enable,@TELID_LED3Enable);
  AddToMemo(Format('Result 0x%2X reading TELID Parameters.',[LastResult]),false);
  if (LastResult<>0) then
    begin
      MessageBeep(MB_ICONEXCLAMATION);
      exit;
    end;

  // 2018-03-23. ML: V0.9
  TELID_Nr_Of_Pressure_Measurements := 0;

  MessageBeep(MB_OK);
  AddToMemo('Read Parameters:',false);
  AddToMemo(Format('TELID ID: %d',[TELID_ID]),false);
  AddToMemo(Format('ProductCode : 0x%X',[TELID_ProductCode]),false);
  AddToMemo(Format('Version : 0x%X',[TELID_Version]),false);

{  // 2018-03-14. MML: Derzeit nicht benutzt
  AddToMemo(Format('Limit MIN : %f°C',[TELID_Min]),false);
  AddToMemo(Format('Limit MAX : %f°C',[TELID_Max]),false);
}

  AddToMemo('Start Time: '+DateTimeToStr(TELID_StartTime),false);
  AddToMemo('Stop Time: ' + DateTimeToStr(TELID_StopTime), false);
  AddToMemo('Program Time: '+DateTimeToStr(TELID_ProgramTime),false);
  AddToMemo(Format('Sample Time: %d:%d min:sec',[TELID_SampleTime_Min,TELID_SampleTime_Sec]),false);
//  AddToMemo(Format('Maximum Number Of Datasets: %d',[TELID_Max_Nr_Of_Datasets]),false);
  AddToMemo(Format('Number Of Datasets: %d',[TELID_Nr_Of_Datasets]),false);
  AddToMemo(Format('TELID Mode : 0x%X',[TELID_Mode]),false);

{ //2018-03-14. MML: Derzeit nicht benutzt
  AddToMemo(Format('TELID Mode_Advanced : 0x%X',[TELID_Mode_Advanced]),false);
}
  AddToMemo(Format('TELID Status_Fail : 0x%X',[TELID_Status_Fail]),false);
{ // 2018-03-14. MML: Derzeit nicht benutzt
  AddToMemo(Format('TELID HT Mode enabled (0/1): %d',[TELID_HTModeEnable]),false);
  AddToMemo(Format('TELID Histogram enabled (0/1): %d',[TELID_HistogramEnable]),false);
  AddToMemo(Format('TELID Limit Watch enabled (0/1): %d',[TELID_LimitWatchEnable]),false);
}
  if bool(TELID_LimitWatchEnable) then
    AddToMemo(Format('TELID Out of Limit (0/1): %d',[TELID_OutOfLimit]),false);
end;




//----------------------------------------------------------------------
// 2018-03-26. ML: V16.0.0.0
//----------------------------------------------------------------------
procedure TForm_Main.Button_ReadAndCheck_PressureClick(Sender: TObject);
var
  wait          : double;
  i, counter, LastResult : Integer;
  ReadArray     : Array[0..8] of byte;
  Strg          : String;

  TELID_Pressure_Data_Array : array of TTELID_Pressure_Record;
  PTELID_Pressure_Data : PTELID_Pressure_Record;
  Timestamp     : TDateTime;
  j, Index, RowCount : Integer;

begin
  cancelread:=false;
  counter:=1;
  Memo_Check.Color:=clWhite;

  while (not cancelread) do
    begin
      AddToCheckMemo(Format('Durchlauf %d:',[counter]),false);
      inc(counter);
      AddToCheckMemo('Searching for TELID...',false);
      wait:=GetTickCount();
      AddToCheckMemo(Format('Reader-ID: %d',[Get_Reader_Id]),false);
      repeat
        Application.ProcessMessages
      until (GetTickCount>wait+80);

      while (GetTickCount()<wait+2500) do
        begin
          //Search for TELID datalogger
          LastResult:=TELID_ReadRoCode(@ReadArray,@TELID_ID);
          if (LastResult=0) then
            begin
              Strg:='';
              //ReadArray[0] contains length of Array
              for i:=0 to ReadArray[0]-1 do
                Strg:=Strg+IntToHex(ReadArray[i+1],2)+' ';
              AddToCheckMemo('TELID RO-Code '+Strg+' found!',false);
              AddToCheckMemo(Format('TELID ID: %d',[TELID_ID]),false);
              break;
            end
          else
            begin
            //AddToCheckMemo(Format('Error: %X',[LastResult]),false);
            end;;
        end;

      if (LastResult<>0) then
        begin
          MessageBeep(MB_ICONEXCLAMATION);
          Application.ProcessMessages;
          continue;
        end;

      //Read TELID remarks
      LastResult:=TELID_ReadPressureParameters(@TELID_ID,@TELID_Min,@TELID_Max,
            @TELID_ProductCode,@TELID_Version,
            @TELID_Nr_Of_DataSets,@TELID_MemCount,
            @TELID_Mode,@TELID_Mode_Advanced,@TELID_Status_Fail,
            @TELID_HTModeEnable,@TELID_HistogramEnable,@TELID_LimitWatchEnable,@TELID_OutOfLimit,
            @TELID_StartTime,@TELID_StopTime, @TELID_ProgramTime,@TELID_SampleTime_Min,@TELID_SampleTime_Sec,
            @TELID_LED1Enable,@TELID_LED2Enable,@TELID_LED3Enable);

      AddToCheckMemo(Format('Result 0x%2X reading TELID Parameters.',[LastResult]),false);

      // 2018-03-27. ML: V16.0.0.0
      if (LastResult = $4F) then
        begin
          Memo_Check.Color:=clRed;
          MessageBeep(MB_ICONEXCLAMATION);
          exit;
        end;
      // 2018-03-27. Ende

      if (LastResult<>0) then
        begin
          MessageBeep(MB_ICONEXCLAMATION);
          continue;
        end;
      MessageBeep(MB_OK);
      AddToCheckMemo('Read Parameters:',false);
      AddToCheckMemo(Format('TELID ID: %d',[TELID_ID]),false);
      AddToCheckMemo(Format('ProductCode : 0x%X',[TELID_ProductCode]),false);
      AddToCheckMemo(Format('Version : 0x%X',[TELID_Version]),false);
      AddToCheckMemo('Start Time: '+DateTimeToStr(TELID_StartTime),false);
      AddToCheckMemo('Stop Time: ' + DateTimeToStr(TELID_StopTime), false);
      AddToCheckMemo('Program Time: '+DateTimeToStr(TELID_ProgramTime),false);
      AddToCheckMemo(Format('Sample Time: %d:%d min:sec',[TELID_SampleTime_Min,TELID_SampleTime_Sec]),false);
      AddToCheckMemo(Format('Number Of Datasets: %d',[TELID_Nr_Of_Datasets]),false);
      AddToCheckMemo(Format('TELID Mode : 0x%X',[TELID_Mode]),false);
      //AddToCheckMemo(Format('TELID Mode_Advanced : 0x%X',[TELID_Mode_Advanced]),false);
      AddToCheckMemo(Format('TELID Status_Fail : 0x%X',[TELID_Status_Fail]),false);

      //Now read temperature table
      if (TELID_Nr_Of_DataSets=0) then
        begin
          AddToCheckMemo('No datasets found on TELID',false);
          cancelread:=true;
        end;

      i := 0;
      TELID_Nr_Of_Read_Datasets := 0;
      while (not cancelread) do
        begin
          inc(i);
          LastResult := TELID_ReadPressureProtocol(@TELID_Nr_Of_Read_DataSets, @TELID_Nr_Of_Pressure_Measurements);
          if (LastResult = 1) then
            begin
              AddToCheckMemo(Format('ReadPressureProtocol-datasets read: %d, result 0x%X', [TELID_Nr_Of_Read_DataSets, LastResult]), false);
              Memo_Check.Color := clYellow;
            end
          else if (LastResult = 0) then
            begin
              Memo_Check.Color := clWhite;
              AddToCheckMemo(Format('ReadPressureProtocol-datasets read: %d, result 0x%X', [TELID_Nr_Of_Read_DataSets, LastResult]), false);
              AddToCheckMemo(Format('ReadPressureProtocol- %d measurements read', [TELID_Nr_Of_Pressure_Measurements]), false);
              SetLength(TELID_Pressure_Data_Array, TELID_Nr_Of_Pressure_Measurements);
              AddToCheckmemo('Reading pressure protocol complete !', false);
              break;
            end
          else
            begin
              Memo_Check.Color := clRed;
              AddToCheckMemo(Format('ReadPressureProtocol-datasets read: %d, result 0x%X', [TELID_Nr_Of_Read_DataSets, LastResult]), false);
            end;
          Application.ProcessMessages;
        end;

      if (cancelread) then
        exit;

      MessageBeep(MB_OK);
      with StringGrid_Temperatures do
        begin
          RowCount := 2;
          ColCount := 5;
          FixedRows := 1;
          FixedCols := 1;
          ColCount := 5;
          Cells[0, 0] := 'Nr';
          Cells[1, 0] := 'Time';
          Cells[2, 0] := 'P/bar';
          Cells[3, 0] := 'T/°C';
          Cells[4, 0] := 'State';
        end;

      Index := 1;
      for i := 1 to TELID_Nr_Of_Pressure_Measurements do
        begin
          try
            if bool(TELID_GetPressureData(i, @TELID_Pressure_Data_Array[i - 1])) then
              exit; // load pressure dataset from DLL
            with StringGrid_Temperatures do
              begin
                RowCount := RowCount + 1;
                Cells[0, Index] := Format('%d', [i]);
                TimeStamp := TELID_Pressure_Data_Array[i - 1].Time;
                Cells[1, Index] := DateTimeToStr(TimeStamp);
                Cells[2, Index] := Format('%0.3f', [TELID_Pressure_Data_Array[i - 1].Pressure]);
                Cells[3, Index] := Format('%0.2f', [TELID_Pressure_Data_Array[i - 1].Temperature]);
                Cells[4, Index] := Format('0x%.2X', [TELID_Pressure_Data_Array[i - 1].State]);
              end;
            Inc(Index);
          except
            exit
          end;
        end;

      StringGrid_Temperatures.RowCount := StringGrid_Temperatures.RowCount - 1;
      break;
    end;

  //now check for VALID temperatures
  for i:=1 to TELID_Nr_Of_DataSets do
    begin
      PTELID_Pressure_Data:=@TELID_Pressure_Data_Array[i];
      {
      if ((PTELID_Pressure_Data^.Pressure < TELID_MIN) or (PTELID_Pressure_Data^.Pressure>TELID_Max)) then
        begin
          cancelread:=true;
          Memo_Check.Color:=clRed;
          AddToCheckMemo(Format('Error at dataset : %d',[i]),false);
        end;
      }
      if (PTELID_Pressure_Data^.State<>0) then
        begin
          cancelread:=true;
          Memo_Check.Color:=clRed;
          AddToCheckMemo(Format('Error at dataset : %d',[i]),false);
        end;
    end;

  if (not cancelread) then
    begin
      AddToCheckMemo('Seems to be no error...',false);
      AddToCheckMemo('',false);
    end
  else
    AddToCheckMemo('Ready/Aborted...',false);
end;

end.
