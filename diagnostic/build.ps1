param(
    [string]$FfdecJar = 'C:/Program Files (x86)/FFDec/ffdec.jar'
)
$ErrorActionPreference = 'Stop'
$diagnosticRoot = Split-Path -Parent $PSScriptRoot
$originalAppData = $env:APPDATA
Push-Location $diagnosticRoot
try {
    if (!(Test-Path -LiteralPath $FfdecJar)) { throw "JPEXS not found at $FfdecJar" }
    $env:APPDATA = Join-Path ([IO.Path]::GetTempPath()) 'nick-ffdec-profile'
    New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null
    & java -jar $FfdecJar -onerror abort -importScript 'BuilderMain unmodified.swf' 'diagnostic/compiled.swf' 'diagnostic/scripts' *> 'diagnostic/build.log'
    if ($LASTEXITCODE -ne 0) { throw 'Compilation failed. See diagnostic/build.log.' }
    Copy-Item -LiteralPath 'diagnostic/compiled.swf' -Destination 'BuilderMain-diagnostic.swf'
    Write-Output 'Created BuilderMain-diagnostic.swf from BuilderMain unmodified.swf.'
} finally {
    $env:APPDATA = $originalAppData
    Pop-Location
}
