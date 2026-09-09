param([string]$FfdecJar = 'C:/Program Files (x86)/FFDec/ffdec.jar')
$ErrorActionPreference = 'Stop'
$harnessRoot = Split-Path -Parent $PSScriptRoot
$savedAppData = $env:APPDATA
Push-Location $harnessRoot
try {
    $env:APPDATA = Join-Path ([IO.Path]::GetTempPath()) 'nick-ffdec-profile'
    New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null
    & java -jar $FfdecJar -onerror abort -importScript 'BuilderMain unmodified.swf' 'harness/compiled.swf' 'harness/scripts' *> 'harness/build.log'
    if ($LASTEXITCODE -ne 0) { throw 'Compilation failed. See harness/build.log.' }
    Copy-Item -LiteralPath 'harness/compiled.swf' -Destination 'BuilderMain-harness.swf'
    & node 'harness/verify-swf.cjs'
    if ($LASTEXITCODE -ne 0) { throw 'Structural validation failed.' }
    Write-Output 'Created and structurally verified BuilderMain-harness.swf.'
} finally {
    $env:APPDATA = $savedAppData
    Pop-Location
}
