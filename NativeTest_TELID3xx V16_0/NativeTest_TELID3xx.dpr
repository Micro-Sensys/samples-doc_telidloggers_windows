program NativeTest_TELID3xx;

uses
  // 2018-03-23. ML: V0.9 : Übertragung dynamischer Arrays zur Bibliothek entfernt;
  // Der Anruf zu ShareMem ist deswegen nicht mehr erforderlich
  //ShareMem,
  
  Forms,
  NativeTest_TELID3xx_Main in 'NativeTest_TELID3xx_Main.pas' {Form_Main};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm_Main, Form_Main);
  Application.Run;
end.
