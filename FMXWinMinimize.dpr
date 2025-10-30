program FMXWinMinimize;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main.View in 'Main.View.pas' {MainView},
  FMX.TaskbarFix.Win in 'FMX.TaskbarFix.Win.pas';

{$R *.res}

var
  MainView: TMainView;
begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.CreateForm(TMainView, MainView);
  Application.Run;
end.
