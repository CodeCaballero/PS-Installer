<#
.SYNOPSIS
    Interactive QA Tools Installer using Winget and VS Code CLI

.DESCRIPTION
    Installs QA tools and selected VS Code extensions. Tools:
    - OBS Studio
    - Python
    - VS Code + selected extensions
    - Git
    - k6
    - Google Chrome
    - Mozilla Firefox
    - Azure CLI
    - Notepad++
    - MobaXterm
    - Pomodoro Timer
#>

# ---------------------------
# Define tools to install
# ---------------------------
$Tools = @(
    @{Name="OBS Studio"; WingetId="OBSProject.OBSStudio"},
    @{Name="Python"; WingetId="Python.Python.3"},
    @{Name="VS Code"; WingetId="Microsoft.VisualStudioCode"},
    @{Name="Git"; WingetId="Git.Git"},
    @{Name="k6"; WingetId="LoadImpact.k6"},
    @{Name="Google Chrome"; WingetId="Google.Chrome"},
    @{Name="Mozilla Firefox"; WingetId="Mozilla.Firefox"},
    @{Name="Azure CLI"; WingetId="Microsoft.AzureCLI"},
    @{Name="Notepad++"; WingetId="Notepad++.Notepad++"},
    @{Name="MobaXterm"; WingetId="Mobatek.MobaXterm"},
    @{Name="IntelliJ IDEA Community"; WingetId="JetBrains.IntelliJIDEA.Community"}, 
    @{Name="Docker"; WingetId="Docker.DockerDesktop"},
    @{Name="Eclipse Temurin 21 JDK"; WingetId="EclipseAdoptium.Temurin.21.JDK"},
    @{Name="DBeaver"; WingetId="DBeaver.DBeaver"},
    @{Name="ShareX"; WingetId="ShareX.ShareX"},
    @{Name="7-Zip"; WingetId="7zip.7zip"},
    @{Name="PowerToys"; WingetId="Microsoft.PowerToys"},
    @{Name="Telerik Fiddler Everywhere"; WingetId="Telerik.FiddlerEverywhere"},
    @{Name="Everything"; WingetId="voidtools.Everything"},
    @{Name="Windows Terminal"; WingetId="Microsoft.WindowsTerminal"},
    @{Name="WinMerge"; WingetId="WinMerge.WinMerge"},
    @{Name="Sabrogden.Ditto"; WingetId="Sabrogden.Ditto"},
    @{Name="OWASP.ZedAttackProxy"; WingetId="OWASP.ZedAttackProxy"},
    @{Name="NVDA"; WingetId="NVAccess.NVDA"},
    @{Name="JAMSoftware.TreeSize.Free"; WingetId="JAMSoftware.TreeSizeFree"},
    @{Name="Pomodoro Timer"; WingetId="Marlon.Pomodoro"} 
)

# ---------------------------
# Display interactive menu
# ---------------------------
Write-Host "==============================="
Write-Host " QA Tools Installer (Winget) "
Write-Host "==============================="

for ($i=0; $i -lt $Tools.Count; $i++) {
    Write-Host "[$($i+1)] $($Tools[$i].Name)"
}
Write-Host "[A] All tools"

Write-Host "`nSelect the tools to install (e.g., 1,3,5) or A for All:"
$selection = Read-Host

# ---------------------------
# Determine selected indices
# ---------------------------
if ($selection.Trim().ToUpper() -eq "A") {
    $selectedIndices = 0..($Tools.Count-1)
} else {
    $selectedIndices = $selection -split "," | ForEach-Object { ($_ -as [int]) - 1 }
}

# ---------------------------
# Install selected tools via Winget
# ---------------------------
foreach ($index in $selectedIndices) {
    if ($index -ge 0 -and $index -lt $Tools.Count) {
        $tool = $Tools[$index]
        Write-Host "`n⬇ Installing $($tool.Name) via Winget..."
        winget install --id $tool.WingetId --silent --accept-package-agreements --accept-source-agreements
    }
}

# ---------------------------
# Install VS Code extensions (only if VS Code was selected)
# ---------------------------
$vsCodeIndex = $Tools | Where-Object {$_.Name -eq "VS Code"} | ForEach-Object {$Tools.IndexOf($_)}
if ($selectedIndices -contains $vsCodeIndex) {
    Write-Host "`n⬇ Installing VS Code extensions..."

    $Extensions = @(
        "rangav.vscode-thunder-client",   # Thunder Client
        "eamodio.gitlens",                 # GitLens
        "mhutchie.git-graph",              # Git Graph
        "donjayamanne.githistory",         # Git History
        "ms-python.python",                # Python
        "AykutSarac.jsoncrack-vscode",     # JSON Crack
        "formulahendry.auto-close-tag",    # Auto Close Tag
        "eriklynd.json-tools",             # JSON Tools
        "ms-azuretools.vscode-azurecli",   # Azure CLI
        "pkief.material-icon-theme",       # Material Icon Theme
        "mikestead.dotenv",                # DotENV
        "redhat.vscode-yaml"               # YAML
    )

    foreach ($ext in $Extensions) {
        Write-Host "⬇ Installing VS Code extension: $ext"
        code --install-extension $ext --force
    }
}

# ---------------------------
# Ensure Windows Terminal Shortcut exists
# ---------------------------
Write-Host "`n🔧 Checking Shortcuts..."
$desktopPath = [Environment]::GetFolderPath("Desktop")
$terminalShortcutPath = Join-Path $desktopPath "Windows Terminal.lnk"

if (-not (Test-Path $terminalShortcutPath)) {
    try {
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($terminalShortcutPath)
        $Shortcut.TargetPath = "wt.exe" # Lanza la terminal moderna
        $Shortcut.Description = "Open QA Command Center"
        $Shortcut.Save()
        Write-Host "➕ Created 'Windows Terminal' shortcut on Desktop." -ForegroundColor Green
    } catch {
        Write-Host "⚠ Could not create shortcut automatically." -ForegroundColor Yellow
    }
}

Write-Host "`n✅ Selected installations completed."
