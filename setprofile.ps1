$profilePath = Split-Path -Path $PROFILE
copy .\Microsoft.PowerShell_profile.ps1 $profilePath
copy .\utils.ps1 $profilePath