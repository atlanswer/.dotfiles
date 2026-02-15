function setproxy {
    $env:GIT_SSH_COMMAND="'C:\windows\System32\OpenSSH\ssh.exe' -o ProxyCommand='C:\Program Files\Git\clangarm64\bin\connect.exe -H localhost:1080 %h %p'"
    $env:ALL_PROXY="socks5://localhost:1080"
    $env:HTTPS_PROXY="http://localhost:1080"
    $env:HTTP_PROXY=$env:https_proxy
}

function unsetproxy {
    $env:GIT_SSH_COMMAND=$null
    $env:ALL_PROXY=$null
    $env:HTTPS_PROXY=$null
    $env:HTTP_PROXY=$null
}

function EnableSystemProxy {
    $reg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    sp -Path $reg -Name ProxyEnable -Value 1
}

function DisableSystemProxy {
    $reg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    sp -Path $reg -Name ProxyEnable -Value 0
}

function Expand-EnvironmentVariablesRecursively($unexpanded) {
    $previous = ''
    $expanded = $unexpanded
    while($previous -ne $expanded) {
        $previous = $expanded
        $expanded = [System.Environment]::ExpandEnvironmentVariables($previous)
    }
    return $expanded
}

function Update-SessionEnvironment {
    $env:Path = Expand-EnvironmentVariablesRecursively([System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User"))
}
Set-Alias refreshenv Update-SessionEnvironment

function Enter-VsDev {
    $vspath = & vswhere -property InstallationPath
    $devshellpath = Join-Path $vspath "Common7/Tools/Microsoft.VisualStudio.DevShell.dll"
    Import-Module $devshellpath
    Enter-VsDevShell -VsInstallPath $vspath -Arch arm64 -SkipAutomaticLocation
}

function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}

$env:PAGER = "less"
$env:EDITOR = "nvim"

Set-PSReadLineOption -EditMode Vi
Set-PsFzfOption -PSReadlineChordProvider "Ctrl+t" -PSReadlineChordReverseHistory "Ctrl+r"

$colorCode = "`e[38;2;87;86;83m"
$resetCode = "`e[0m"

function Invoke-Starship-TransientFunction {
    $c = &starship module character
    $hr = "─" * $Host.UI.RawUI.WindowSize.width
    return "`n`n$colorCode$hr$resetCode`n$c"
}

Invoke-Expression (& { (zoxide init powershell | Out-String) })

Invoke-Expression (&starship init powershell)
Enable-TransientPrompt

