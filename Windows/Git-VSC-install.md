# Install Git in Visual Studio Code VSC

## Step 1 - Download and install
Download the installer via <a href="Git website"> and install with Visual Studio Code as the default Editor.
Check if Git is successfully installed by just running "git" in PowerShell

```bash
git
```

## Step 2 - Config your credentials for GitHub

```bash
git config --global user.name "githubusername"
git config --global user.email "alternativegithubemail"
```

## Step 3 - Check the settings
```bash
git config --list --show-origin --show-scope
```
Now you can open Visual Studio Code, open the working folder and initialize repo in the Source Control tab.