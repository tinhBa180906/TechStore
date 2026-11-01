param(
    [Parameter(Mandatory=$true)][string]$TomcatHome,
    [Parameter(Mandatory=$true)][string]$DeployedApp,
    [string]$JavaHome = $env:JAVA_HOME,
    [string]$BaseUrl = 'http://localhost:8081/TechStore'
)
$ErrorActionPreference = 'Stop'
# Does not migrate/deploy/restart. Run against the local deployment of these same sources.
# DBContext must point to local development SQL Server, never production.
$projectRoot = Split-Path $PSScriptRoot -Parent
Push-Location $projectRoot
try {
    $javacExe = if ($JavaHome) { Join-Path $JavaHome 'bin/javac.exe' } else { 'javac.exe' }
    $javaExe = if ($JavaHome) { Join-Path $JavaHome 'bin/java.exe' } else { 'java.exe' }
    New-Item -ItemType Directory -Path build/qr-check/classes,build/qr-check/test-classes -Force | Out-Null
    $libraries = "$TomcatHome/lib/*;$DeployedApp/WEB-INF/lib/*"
    $sources = @(Get-ChildItem src/java -Recurse -Filter *.java | ForEach-Object FullName)
    & $javacExe -encoding UTF-8 -cp $libraries -d build/qr-check/classes $sources
    if ($LASTEXITCODE -ne 0) { throw 'Production Java compilation failed.' }
    & $javacExe -encoding UTF-8 -cp "build/qr-check/classes;$libraries" -d build/qr-check/test-classes tests/QRPaymentIntegrationTest.java
    if ($LASTEXITCODE -ne 0) { throw 'Test Java compilation failed.' }
    & $javaExe -cp "build/qr-check/test-classes;build/qr-check/classes;$libraries" QRPaymentIntegrationTest $BaseUrl |
        Tee-Object -FilePath build/qr-check/integration-results.txt
    if ($LASTEXITCODE -ne 0) { throw 'Integration checks failed; inspect build/qr-check/integration-results.txt.' }
} finally { Pop-Location }
