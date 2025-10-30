unit Main.View;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TMainView = class(TForm)
    Btn1: TButton;
    LblFMAppClassHWND: TLabel;
    LblFormHWND: TLabel;
    Lbl1: TLabel;
    Lbl2: TLabel;
    procedure Btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation
uses
  Winapi.Windows, Winapi.Messages,
  FMX.Platform.Win, FMX.TaskbarFix.Win;

{$R *.fmx}

{ TMainView }

procedure TMainView.Btn1Click(Sender: TObject);
begin
  ShowWindow(FmxHandleToHWND(Handle), SW_MINIMIZE);
//  WindowState := TWindowState.wsMinimized; // Don't use this
end;

constructor TMainView.Create(AOwner: TComponent);
begin
  inherited;
  TFMXTaskbarFix.Apply(Self);
end;

procedure TMainView.FormCreate(Sender: TObject);
var
  LWndHwnd: HWND;
begin
  LWndHwnd := FmxHandleToHWND(Handle);

  LblFMAppClassHWND.Text := IntToHex(applicationhwnd, SizeOf(applicationhwnd));
  LblFormHWND.Text := IntToHex(LWndHwnd, SizeOf(LWndHwnd));
end;

end.
