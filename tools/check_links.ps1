$root = 'E:\UNC Charlotte Dropbox\Matt Nguyen\proffessional_dev\persona_webpage'
$missing = @()
Get-ChildItem -Path $root -Recurse -Include *.html,*.htm,*.css,*.js | ForEach-Object {
    $file = $_.FullName
    $baseDir = Split-Path $file -Parent
    $content = Get-Content -Path $file -Raw -ErrorAction SilentlyContinue
    if (-not $content) { return }
    $pattern = 'src\s*=\s*"([^\"]+)"|href\s*=\s*"([^\"]+)"'
    [regex]::Matches($content,$pattern) | ForEach-Object {
        $url = $_.Groups[1].Value
        if (-not $url) { $url = $_.Groups[2].Value }
        if (-not $url) { return }
        if ($url -match '^(https?:|\/\/|mailto:|tel:|#)') { return }
    # remove query string and fragment
    $clean = $url -split '[\?#]' | Select-Object -First 1
        # Resolve the relative URL against the file's directory so ../ paths work correctly
        $targetPath = Join-Path $baseDir $clean
        try {
            $resolved = Resolve-Path -Path $targetPath -ErrorAction Stop
            # exists
        } catch {
            $missing += "MISSING|$file|$url|$targetPath"
        }
    }
}
if ($missing.Count -eq 0) {
    Write-Output "No missing local links found."
} else {
    $missing | Sort-Object | Get-Unique | ForEach-Object { Write-Output $_ }
}
