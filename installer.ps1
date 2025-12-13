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
    @{Name="Pomodoro Timer"; WingetId="Marlon.Pomodoro"} # ejemplo Pomodoro
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
        "redhat.vscode-yaml"               # YAML
    )

    foreach ($ext in $Extensions) {
        Write-Host "⬇ Installing VS Code extension: $ext"
        code --install-extension $ext --force
    }
}

Write-Host "`n✅ Selected installations completed."
