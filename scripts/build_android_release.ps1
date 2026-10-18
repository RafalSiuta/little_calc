param(
    [string]$JavaHome = 'C:\Program Files\Java\jdk-20'
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$javaExe = Join-Path $JavaHome 'bin\java.exe'
if (-not (Test-Path -LiteralPath $javaExe)) {
    throw "Java not found: $javaExe"
}

$pubspec = [IO.File]::ReadAllText((Join-Path $projectRoot 'pubspec.yaml'))
$version = [regex]::Match($pubspec, '(?m)^version:\s*(\d+\.\d+\.\d+)\+(\d+)\s*$')
if (-not $version.Success) {
    throw 'Expected a Flutter version in pubspec.yaml, for example 1.2.0+11.'
}

$localPropertiesPath = Join-Path $projectRoot 'android\local.properties'
if (-not (Test-Path -LiteralPath $localPropertiesPath)) {
    throw 'android/local.properties is missing. Run flutter pub get first.'
}

$localProperties = [IO.File]::ReadAllText($localPropertiesPath)
foreach ($entry in @{
    'flutter.versionName' = $version.Groups[1].Value
    'flutter.versionCode' = $version.Groups[2].Value
}.GetEnumerator()) {
    $pattern = '(?m)^' + [regex]::Escape($entry.Key) + '=.*$'
    $replacement = $entry.Key + '=' + $entry.Value
    if ([regex]::IsMatch($localProperties, $pattern)) {
        $localProperties = [regex]::Replace($localProperties, $pattern, $replacement)
    } else {
        $localProperties += [Environment]::NewLine + $replacement
    }
}
[IO.File]::WriteAllText($localPropertiesPath, $localProperties, (New-Object System.Text.UTF8Encoding($false)))

$env:JAVA_HOME = $JavaHome
$env:PATH = (Join-Path $JavaHome 'bin') + [IO.Path]::PathSeparator + $env:PATH
Push-Location (Join-Path $projectRoot 'android')
try {
    & '.\gradlew.bat' ':app:bundleRelease' '--no-daemon' '-Pkotlin.compiler.execution.strategy=in-process'
    if ($LASTEXITCODE -ne 0) {
        throw "Android release build failed with exit code $LASTEXITCODE."
    }
} finally {
    Pop-Location
}

$bundle = Join-Path $projectRoot 'build\app\outputs\bundle\release\app-release.aab'
if (-not (Test-Path -LiteralPath $bundle)) {
    throw "Release build completed but the bundle was not found: $bundle"
}
Write-Output "Release bundle: $bundle"
