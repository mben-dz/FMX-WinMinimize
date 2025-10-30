# 🧩 FMX Taskbar Fix (Windows)

Fixes the long-standing **FireMonkey (FMX)** issue where:
- Two taskbar icons appear (`TFMAppClass` + main form)
- Minimize / restore animations don't play correctly
- App hides completely when minimized

---

## ✅ Solution

The fix detaches the hidden `TFMAppClass` host window and promotes the visible form as the true app window, preserving proper **DWM minimize/restore animation** and **single taskbar integration**.

See [`FMX.TaskbarFix.Win`](./FMX.TaskbarFix.Win.pas) for the implementation.

<img width="1280" height="673" alt="image" src="https://github.com/user-attachments/assets/6ae02175-6d4c-4b34-a889-3a8289eb6800" />


### Usage
```pascal
uses
  FMX.TaskbarFix.Win;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TFMXTaskbarFix.Apply(Self);
end;
```
the video [here](https://www.youtube.com/watch?v=rqd4zhbVZIU) shows the result in Action
