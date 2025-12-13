# Herramientas: Python, VS Code + extensiones, Notepad++, Git, Chrome, Firefox, Azure CLI
# Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# Invoke-Expression (Invoke-WebRequest "https://raw.githubusercontent.com/CodeCaballero/tools/main/tools/Apps.ps1" -UseBasicParsing).Content
$TempDir = "$env:TEMP\DevTools"
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

# Script idempotente para QA corporativo con resumen de versiones

$TempDir = "$env:TEMP\DevTools"
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

# Función para comprobar si un programa está instalado
function IsInstalled($DisplayName) {
    $registryPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($path in $registryPaths) {
        $app = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*$DisplayName*" }
        if ($app) { return $app.DisplayVersion }
    }
    return $null
}

# Función para obtener la última release de GitHub
function Get-LatestGitHubRelease($repo, $pattern) {
    $release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest"
    $asset = $release.assets | Where-Object { $_.name -like $pattern } | Select-Object -First 1
    return $asset.browser_download_url
}

# Diccionario para guardar versiones
$Versions = @{}

# -------------------------------
# 1️⃣ Python
if (-not (IsInstalled "Python")) {
    $PythonURL = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe"
    $PythonExe = "$TempDir\python.exe"
    Invoke-WebRequest $PythonURL -OutFile $PythonExe
    Start-Process $PythonExe -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
}
$Versions["Python"] = (& python --version 2>&1).Trim()

# -------------------------------
# 2️⃣ VS Code
if (-not (IsInstalled "Visual Studio Code")) {
    $VSCodeURL = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
    $VSCodeExe = "$TempDir\vscode.exe"
    Invoke-WebRequest $VSCodeURL -OutFile $VSCodeExe
    Start-Process $VSCodeExe -ArgumentList "/VERYSILENT /MERGETASKS=!runcode" -Wait
}
$VSCodePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd"
$Versions["VS Code"] = (& $VSCodePath --version | Select-Object -First 1).Trim()

# Extensiones VS Code
if (Test-Path $VSCodePath) {
    $extensions = @(
        "ms-python.python",
        "ms-python.vscode-pylance",
        "eamodio.gitlens",
        "rangav.vscode-thunder-client",
        "ms-vsts.team"
    )
    foreach ($ext in $extensions) {
        & $VSCodePath --install-extension $ext --force
    }
}

# -------------------------------
# 3️⃣ Notepad++ (GitHub)
if (-not (IsInstalled "Notepad++")) {
    $NppURL = Get-LatestGitHubRelease "notepad-plus-plus/notepad-plus-plus" "*Installer.x64.exe"
    $NppExe = "$TempDir\npp.exe"
    Invoke-WebRequest $NppURL -OutFile $NppExe
    Start-Process $NppExe -ArgumentList "/S" -Wait
}
$Versions["Notepad++"] = IsInstalled "Notepad++"

# -------------------------------
# 4️⃣ Git (GitHub)
if (-not (IsInstalled "Git")) {
    $GitURL = Get-LatestGitHubRelease "git-for-windows/git" "*64-bit.exe"
    $GitExe = "$TempDir\git.exe"
    Invoke-WebRequest $GitURL -OutFile $GitExe
    Start-Process $GitExe -ArgumentList "/SILENT" -Wait
}
$Versions["Git"] = (& git --version).Trim()

# -------------------------------
# 5️⃣ Google Chrome
if (-not (IsInstalled "Google Chrome")) {
    $ChromeURL = "https://dl.google.com/chrome/install/standalonesetup64.exe"
    $ChromeExe = "$TempDir\chrome.exe"
    Invoke-WebRequest $ChromeURL -OutFile $ChromeExe
    Start-Process $ChromeExe -ArgumentList "/silent /install" -Wait
}
$Versions["Chrome"] = IsInstalled "Google Chrome"

# -------------------------------
# 6️⃣ Mozilla Firefox
if (-not (IsInstalled "Mozilla Firefox")) {
    $FirefoxURL = "https://download.mozilla.org/?product=firefox-stable-latest-ssl&os=win64&lang=en-US"
    $FirefoxExe = "$TempDir\firefox.exe"
    Invoke-WebRequest $FirefoxURL -OutFile $FirefoxExe
    Start-Process $FirefoxExe -ArgumentList "-ms" -Wait
}
$Versions["Firefox"] = IsInstalled "Mozilla Firefox"

# -------------------------------
# 7️⃣ Azure CLI
if (-not (IsInstalled "Microsoft Azure CLI")) {
    $AzureCLIURL = "https://aka.ms/installazurecliwindows"
    $AzureCLIExe = "$TempDir\AzureCLI.msi"
    Invoke-WebRequest $AzureCLIURL -OutFile $AzureCLIExe
    Start-Process msiexec.exe -ArgumentList "/i $AzureCLIExe /quiet /norestart" -Wait
}
$Versions["Azure CLI"] = (& az version --output json | ConvertFrom-Json).azureCli.Trim()

# Azure DevOps CLI extension
if (Get-Command az -ErrorAction SilentlyContinue) {
    az extension add --name azure-devops
}

# -------------------------------
# 8️⃣ k6 (GitHub)
if (-not (Get-Command k6 -ErrorAction SilentlyContinue)) {
    $k6URL = Get-LatestGitHubRelease "grafana/k6" "*windows-amd64.msi"
    $k6MSI = "$TempDir\k6.msi"
    Invoke-WebRequest $k6URL -OutFile $k6MSI
    Start-Process msiexec.exe -ArgumentList "/i $k6MSI /quiet /norestart" -Wait
}
$Versions["k6"] = (& k6 version).Trim()

# -------------------------------
# Mostrar resumen de versiones
Write-Host "`n✅ Resumen de versiones instaladas:`n"
foreach ($key in $Versions.Keys) {
    Write-Host "$key`t: $($Versions[$key])"
}

Write-Host "`n✅ Todas las aplicaciones esenciales para QA corporativo están instaladas y actualizadas."
