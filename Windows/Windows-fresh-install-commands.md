# First steps after installing Windows

Use Windows Terminal and open PowerShell with Admin privileges.

## Disable UAC

```bash
reg.exe ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
```

## Windows Defender exclusions

The **Add-MpPreference** cmdlet modifies settings for Windows Defender. Use this cmdlet to add exclusions for file name extensions, paths, and processes, and to add default actions for high, moderate, and low threats.

```bash
Add-MpPreference -ExclusionPath "C:\Music_production","C:\Users\Jure\Downloads","C:\Windows","D:\","E:\","F:\","H:\","I:\"
```