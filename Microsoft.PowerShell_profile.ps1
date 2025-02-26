### PowerShell Profile Refactor
### Version 1.03 - Refactored

$debug = $false

if ($debug) {
	Write-Host "#######################################" -ForegroundColor Red
	Write-Host "#           Debug mode enabled        #" -ForegroundColor Red
	Write-Host "#          ONLY FOR DEVELOPMENT       #" -ForegroundColor Red
	Write-Host "#                                     #" -ForegroundColor Red
	Write-Host "#       IF YOU ARE NOT DEVELOPING     #" -ForegroundColor Red
	Write-Host "#       JUST RUN \`Update-Profile\`     #" -ForegroundColor Red
	Write-Host "#        to discard all changes       #" -ForegroundColor Red
	Write-Host "#   and update to the latest profile  #" -ForegroundColor Red
	Write-Host "#               version               #" -ForegroundColor Red
	Write-Host "#######################################" -ForegroundColor Red
}


#################################################################################################################################
############                                                                                                         ############
############                                          !!!   WARNING:   !!!                                           ############
############                                                                                                         ############
############                DO NOT MODIFY THIS FILE. THIS FILE IS HASHED AND UPDATED AUTOMATICALLY.                  ############
############                    ANY CHANGES MADE TO THIS FILE WILL BE OVERWRITTEN BY COMMITS TO                      ############
############                       https://github.com/ChrisTitusTech/powershell-profile.git.                         ############
############                                                                                                         ############
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
############                                                                                                         ############
############                      IF YOU WANT TO MAKE CHANGES, USE THE Edit-Profile FUNCTION                         ############
############                              AND SAVE YOUR CHANGES IN THE FILE CREATED.                                 ############
############                                                                                                         ############
#################################################################################################################################

#opt-out of telemetry before doing anything, only if PowerShell is run as admin
if ([bool]([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsSystem) {
	[System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::Machine)
}

# Import Modules and External Profiles
# Ensure Terminal-Icons module is installed before importing

if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
	Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
}
Import-Module -Name Terminal-Icons

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
	Import-Module "$ChocolateyProfile"
}

# Admin Check and Prompt Customization
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
function prompt {
	if ($isAdmin) { "[" + (Get-Location) + "] # " } else { "[" + (Get-Location) + "] $ " }
}
$adminSuffix = if ($isAdmin) { " [ADMIN]" } else { "" }
$Host.UI.RawUI.WindowTitle = "PowerShell {0}$adminSuffix" -f $PSVersionTable.PSVersion.ToString()

# Enhanced PowerShell Experience
# Enhanced PSReadLine Configuration
$PSReadLineOptions = @{
	EditMode                      = 'Windows'
	HistoryNoDuplicates           = $true
	HistorySearchCursorMovesToEnd = $true
	Colors                        = @{
		Command   = '#87CEEB'  # SkyBlue (pastel)
		Parameter = '#98FB98'  # PaleGreen (pastel)
		Operator  = '#FFB6C1'  # LightPink (pastel)
		Variable  = '#DDA0DD'  # Plum (pastel)
		String    = '#FFDAB9'  # PeachPuff (pastel)
		Number    = '#B0E0E6'  # PowderBlue (pastel)
		Type      = '#F0E68C'  # Khaki (pastel)
		Comment   = '#D3D3D3'  # LightGray (pastel)
		Keyword   = '#8367c7'  # Violet (pastel)
		Error     = '#FF6347'  # Tomato (keeping it close to red for visibility)
	}
	PredictionSource              = 'History'
	PredictionViewStyle           = 'ListView'
	BellStyle                     = 'None'
}
Set-PSReadLineOption @PSReadLineOptions

# Custom key handlers
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function DeleteChar
Set-PSReadLineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord
Set-PSReadLineKeyHandler -Chord 'Alt+d' -Function DeleteWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+LeftArrow' -Function BackwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function Undo
Set-PSReadLineKeyHandler -Chord 'Ctrl+y' -Function Redo

# Custom functions for PSReadLine
Set-PSReadLineOption -AddToHistoryHandler {
	param($line)
	$sensitive = @('password', 'secret', 'token', 'apikey', 'connectionstring')
	$hasSensitive = $sensitive | Where-Object { $line -match $_ }
	return ($null -eq $hasSensitive)
}

# Improved prediction settings
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -MaximumHistoryCount 10000

# Get theme from profile.ps1 or use a default theme
function Get-Theme {
	$config = "$env:USERPROFILE\.config\oh-my-posh.omp.json"
	$configPath = "$env:USERPROFILE\.config"
	if (!(Test-Path -Path $config -PathType Leaf)) {
		try {
			if (!(Test-Path -Path $ConfigPath)) {
				New-Item -Path $configPath -ItemType "directory"
			}
			Invoke-RestMethod https://github.com/raugadh/powershell-profile/raw/main/oh-my-posh.omp.json -OutFile $config
			oh-my-posh init pwsh --config 'C:\Users\Rudra\.config\oh-my-posh.omp.json' | Invoke-Expression
		}
		catch {
			Write-Error "Failed to create the Oh My Posh config. Error: $_"
		}
	}
	else {
		oh-my-posh init pwsh --config 'C:\Users\Rudra\.config\oh-my-posh.omp.json' | Invoke-Expression
	}
}

## Final Line to set prompt
Get-Theme

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
	Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
}
else {
	Write-Host "zoxide command not found. Attempting to install via winget..."
	try {
		winget install -e --id ajeetdsouza.zoxide
		Write-Host "zoxide installed successfully. Initializing..."
		Invoke-Expression (& { (zoxide init powershell | Out-String) })
	}
	catch {
		Write-Error "Failed to install zoxide. Error: $_"
	}
}

Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force

#load Utils asynchronously
$AsyncScriptblock = {
	. $env:userprofile\Documents\Powershell\utils.ps1
}
Import-ProfileAsync $AsyncScriptblock