unit FMX.TaskbarFix.Win;

interface

uses
  System.UITypes,
  System.SysUtils,
  Winapi.Windows,
  FMX.Forms,
  FMX.Platform.Win;

type
  TFMXTaskbarFix = class
  class var
    fOldWndProc: TFNWndProc;

    class function TaskbarWndProc(aHwnd: HWND; aUMsg: UINT;
      aWParam: WPARAM; aLParam: LPARAM): LRESULT; stdcall; static;
  public
    class procedure Apply(const aForm: TForm); static;// inline;
  end;

implementation
uses
  Winapi.Messages;

class function TFMXTaskbarFix.TaskbarWndProc(
  aHwnd: HWND;
  aUMsg: UINT;
  aWParam: WPARAM;
  aLParam: LPARAM): LRESULT; stdcall;
var
  LForm: TForm;
begin
  Result := 0;
  LForm := nil;

  if Assigned(Application.MainForm) then
    LForm := TForm(Application.MainForm);

  case aUMsg of
    WM_SYSCOMMAND:
      case aWParam and $FFF0 of
        SC_MINIMIZE:
          begin
            if Assigned(LForm) then
            begin
              ShowWindow(FmxHandleToHWND(LForm.Handle), SW_MINIMIZE);
              LForm.WindowState := TWindowState.wsMinimized;
            end;
            Exit;
          end;

        SC_RESTORE:
          begin
            if Assigned(LForm) then
            begin
              ShowWindow(FmxHandleToHWND(LForm.Handle), SW_RESTORE);
              LForm.WindowState := TWindowState.wsNormal;
              SetForegroundWindow(FmxHandleToHWND(LForm.Handle));
            end;
            Exit;
          end;
      end;
  end;

  if Assigned(fOldWndProc) then
    Result := CallWindowProc(fOldWndProc, aHWnd, aUMsg, aWParam, aLParam)
  else
    Result := DefWindowProc(aHWnd, aUMsg, aWParam, aLParam);
end;

procedure SetFMAppClass_WndMessageOnly(aHwnd: HWND);
begin
  if aHwnd <> 0 then
    SetParent(aHwnd, HWND_MESSAGE);
end;

class procedure TFMXTaskbarFix.Apply(const aForm: TForm);
var
  LAppWnd, LFormWnd: HWND;
  ExStyle: Cardinal;
begin
  LAppWnd := ApplicationHWND;               // hidden FMX host window
  LFormWnd := FmxHandleToHWND(AForm.Handle); // visible form window

  if (LAppWnd = 0) or (LFormWnd = 0) then Exit;

  SetFMAppClass_WndMessageOnly(LAppWnd);

  // 1)️Hide the hidden app host from shell/taskbar
  ExStyle := GetWindowLong(LAppWnd, GWL_EXSTYLE);
  ExStyle := (ExStyle or WS_EX_TOOLWINDOW) and not WS_EX_APPWINDOW;
  SetWindowLong(LAppWnd, GWL_EXSTYLE, ExStyle);
  SetWindowPos(LAppWnd, 0, 0, 0, 0, 0,
    SWP_FRAMECHANGED or SWP_NOMOVE or SWP_NOZORDER or
    SWP_NOSIZE or SWP_NOACTIVATE);

  // 2) Make the visible form the true app window
  ExStyle := GetWindowLong(LFormWnd, GWL_EXSTYLE);
  ExStyle := (ExStyle or WS_EX_APPWINDOW) and not WS_EX_TOOLWINDOW;
  SetWindowLong(LFormWnd, GWL_EXSTYLE, ExStyle);

  // Normal overlapped style for DWM animation
  SetWindowLong(LFormWnd, GWL_STYLE,
    GetWindowLong(LFormWnd, GWL_STYLE) or WS_OVERLAPPEDWINDOW);

  // 3) Fix ownership & focus
  SetWindowLongPtr(LFormWnd, GWLP_HWNDPARENT, 0);
  SetWindowLongPtr(LAppWnd, GWLP_HWNDPARENT, LFormWnd);

  // 4) Apply & refresh
  SetWindowPos(LFormWnd, HWND_TOP, 0, 0, 0, 0,
    SWP_FRAMECHANGED or SWP_NOMOVE or SWP_NOSIZE or
    SWP_NOZORDER or SWP_SHOWWINDOW);

  PostMessage(LFormWnd, WM_SETFOCUS, 0, 0);

  // Hook the window proc
  if Assigned(fOldWndProc) then Exit;
  fOldWndProc := TFNWndProc(SetWindowLongPtr(LFormWnd, GWLP_WNDPROC, LONG_PTR(@TaskbarWndProc)));
end;

end.
