param(
  [Parameter(Mandatory = $true)]
  [string]$ApkPath,

  [string]$Tag = "apk-latest"
)

$ErrorActionPreference = "Stop"
$repo = "yanlin86/Farm"
$apk = (Resolve-Path -LiteralPath $ApkPath).Path

if ([IO.Path]::GetExtension($apk).ToLowerInvariant() -ne ".apk") {
  throw "ApkPath must point to an .apk file."
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  throw "GitHub CLI (gh) is required. Install it from https://cli.github.com/"
}

gh auth status | Out-Host

$releaseExists = $true
try {
  gh release view $Tag --repo $repo | Out-Host
} catch {
  $releaseExists = $false
}

if (-not $releaseExists) {
  gh release create $Tag $apk --repo $repo --title "APK downloads" --notes "APK files are distributed as GitHub Release assets so files larger than 100 MB can be downloaded." | Out-Host
} else {
  gh release upload $Tag $apk --repo $repo --clobber | Out-Host
}

Write-Host "Uploaded: $apk"
Write-Host "Release: https://github.com/$repo/releases/tag/$Tag"
