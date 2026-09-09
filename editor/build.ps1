param([string]$FfdecJar = 'C:/Program Files (x86)/FFDec/ffdec.jar')
$ErrorActionPreference = 'Stop'
$editorRoot = Split-Path -Parent $PSScriptRoot
$savedAppData = $env:APPDATA
Push-Location $editorRoot
try {
    $env:APPDATA = Join-Path ([IO.Path]::GetTempPath()) 'nick-ffdec-profile'
    New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null
    & java -jar $FfdecJar -onerror abort -importScript 'BuilderMain unmodified.swf' 'editor/compiled.swf' 'editor/scripts' *> 'editor/build.log'
    if ($LASTEXITCODE -ne 0) { throw 'Compilation failed. See editor/build.log.' }
    Copy-Item -LiteralPath 'editor/compiled.swf' -Destination 'BuilderMain-editor.swf'
    & node 'editor/verify-swf.cjs'
    if ($LASTEXITCODE -ne 0) { throw 'Structural validation failed.' }
    Write-Output 'Created and structurally verified BuilderMain-editor.swf.'
} finally {
    $env:APPDATA = $savedAppData
    Pop-Location
}
