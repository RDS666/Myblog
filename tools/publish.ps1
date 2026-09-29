param(
    [string]$Config = "",
    [switch]$NoPush,
    [switch]$ValidateOnly
)

$ErrorActionPreference = "Stop"
$toolDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $toolDirectory

if ([string]::IsNullOrWhiteSpace($Config)) {
    $Config = Join-Path $projectRoot "publish.config.json"
} elseif (-not [System.IO.Path]::IsPathRooted($Config)) {
    $Config = Join-Path $projectRoot $Config
}

function Get-ConfiguredValue {
    param(
        [object]$Object,
        [string]$Name,
        $DefaultValue
    )

    if ($Object.PSObject.Properties.Name -contains $Name) {
        return $Object.$Name
    }

    return $DefaultValue
}

function Resolve-ProjectPath {
    param([string]$PathValue)

    $normalizedPath = $PathValue.Trim()
    if ($normalizedPath.Length -ge 2) {
        $firstCharacter = $normalizedPath[0]
        $lastCharacter = $normalizedPath[$normalizedPath.Length - 1]
        if (($firstCharacter -eq '"' -and $lastCharacter -eq '"') -or ($firstCharacter -eq "'" -and $lastCharacter -eq "'")) {
            $normalizedPath = $normalizedPath.Substring(1, $normalizedPath.Length - 2).Trim()
        }
    }

    try {
        if ([System.IO.Path]::IsPathRooted($normalizedPath)) {
            return [System.IO.Path]::GetFullPath($normalizedPath)
        }

        return [System.IO.Path]::GetFullPath((Join-Path $projectRoot $normalizedPath))
    } catch [System.ArgumentException] {
        throw "Invalid path in publish config: $PathValue"
    }
}

function ConvertTo-YamlString {
    param([string]$Value)
    return "'" + $Value.Replace("'", "''") + "'"
}

function Add-YamlList {
    param(
        [System.Collections.Generic.List[string]]$Lines,
        [string]$Name,
        [object[]]$Values
    )

    $Lines.Add("${Name}:")
    foreach ($value in $Values) {
        if (-not [string]::IsNullOrWhiteSpace([string]$value)) {
            $Lines.Add("  - " + (ConvertTo-YamlString ([string]$value)))
        }
    }
}

if (-not (Test-Path -LiteralPath $Config -PathType Leaf)) {
    throw "Publish config not found: $Config. Copy publish.config.example.json to publish.config.json."
}

$settings = Get-Content -LiteralPath $Config -Raw -Encoding UTF8 | ConvertFrom-Json
$sourceSetting = [string](Get-ConfiguredValue $settings "file" "")
$slug = [string](Get-ConfiguredValue $settings "slug" "")
$useExistingFrontMatter = [bool](Get-ConfiguredValue $settings "useExistingFrontMatter" $false)
$overwrite = [bool](Get-ConfiguredValue $settings "overwrite" $false)

if ([string]::IsNullOrWhiteSpace($sourceSetting)) {
    throw "The file setting is required."
}

if ($slug -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
    throw "The slug may only contain lowercase letters, numbers, and hyphens, for example: my-first-post."
}

$sourcePath = Resolve-ProjectPath $sourceSetting
if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
    throw "Markdown file not found: $sourcePath"
}

$postsDirectory = Join-Path $projectRoot "source\_posts"
$destinationPath = Join-Path $postsDirectory ($slug + ".md")

if ((Test-Path -LiteralPath $destinationPath) -and -not $overwrite) {
    throw "The post already exists: $destinationPath. Set overwrite to true to update it."
}

$markdown = Get-Content -LiteralPath $sourcePath -Raw -Encoding UTF8
$frontMatterPattern = '(?s)^---\s*\r?\n.*?\r?\n---\s*(?:\r?\n|$)'
$hasFrontMatter = $markdown -match $frontMatterPattern

if ($useExistingFrontMatter) {
    if (-not $hasFrontMatter) {
        throw "useExistingFrontMatter is true, but the document has no valid Front Matter."
    }
    $publishedContent = $markdown
} else {
    if ($hasFrontMatter) {
        $markdown = $markdown -replace $frontMatterPattern, ''
    }

    $title = [string](Get-ConfiguredValue $settings "title" "")
    if ([string]::IsNullOrWhiteSpace($title)) {
        throw "The title setting is required."
    }

    $now = Get-Date
    $dateSetting = [string](Get-ConfiguredValue $settings "date" "auto")
    $updatedSetting = [string](Get-ConfiguredValue $settings "updated" "auto")
    $publishDate = if ([string]::IsNullOrWhiteSpace($dateSetting) -or $dateSetting -eq "auto") { $now.ToString("yyyy-MM-dd HH:mm:ss") } else { $dateSetting }
    $updatedDate = if ([string]::IsNullOrWhiteSpace($updatedSetting) -or $updatedSetting -eq "auto") { $now.ToString("yyyy-MM-dd HH:mm:ss") } else { $updatedSetting }

    $cover = [string](Get-ConfiguredValue $settings "cover" "")
    $coverFile = [string](Get-ConfiguredValue $settings "coverFile" "")
    if (-not [string]::IsNullOrWhiteSpace($coverFile)) {
        $coverSource = Resolve-ProjectPath $coverFile
        if (-not (Test-Path -LiteralPath $coverSource -PathType Leaf)) {
            throw "Cover file not found: $coverSource"
        }

        $assetTargetDirectory = Join-Path $projectRoot ("source\images\posts\" + $slug)
        New-Item -ItemType Directory -Path $assetTargetDirectory -Force | Out-Null
        $coverName = "cover" + [System.IO.Path]::GetExtension($coverSource).ToLowerInvariant()
        Copy-Item -LiteralPath $coverSource -Destination (Join-Path $assetTargetDirectory $coverName) -Force
        $cover = "/images/posts/$slug/$coverName"
    }

    $frontMatter = [System.Collections.Generic.List[string]]::new()
    $frontMatter.Add("---")
    $frontMatter.Add("title: " + (ConvertTo-YamlString $title))
    $frontMatter.Add("date: " + (ConvertTo-YamlString $publishDate))
    $frontMatter.Add("updated: " + (ConvertTo-YamlString $updatedDate))
    Add-YamlList $frontMatter "categories" @((Get-ConfiguredValue $settings "categories" @()))
    Add-YamlList $frontMatter "tags" @((Get-ConfiguredValue $settings "tags" @()))
    if (-not [string]::IsNullOrWhiteSpace($cover)) {
        $frontMatter.Add("cover: " + (ConvertTo-YamlString $cover))
    }
    $description = [string](Get-ConfiguredValue $settings "description" "")
    if (-not [string]::IsNullOrWhiteSpace($description)) {
        $frontMatter.Add("description: " + (ConvertTo-YamlString $description))
    }
    $frontMatter.Add("---")
    $frontMatter.Add("")
    $trimCharacters = [char[]]@([char]0xFEFF, [char]13, [char]10)
    $publishedContent = (($frontMatter -join "`n") + "`n" + $markdown.TrimStart($trimCharacters))
}

if ($ValidateOnly) {
    Write-Host "Config and Markdown validation passed." -ForegroundColor Green
    Write-Host "Publish target: $destinationPath"
    exit 0
}

[System.IO.File]::WriteAllText($destinationPath, $publishedContent, [System.Text.UTF8Encoding]::new($false))

$assetsSetting = [string](Get-ConfiguredValue $settings "assetsDirectory" "")
$assetTargetDirectory = ""
if (-not [string]::IsNullOrWhiteSpace($assetsSetting)) {
    $assetsSource = Resolve-ProjectPath $assetsSetting
    if (-not (Test-Path -LiteralPath $assetsSource -PathType Container)) {
        throw "Article assets directory not found: $assetsSource"
    }

    $assetTargetDirectory = Join-Path $projectRoot ("source\images\posts\" + $slug)
    New-Item -ItemType Directory -Path $assetTargetDirectory -Force | Out-Null
    Copy-Item -Path (Join-Path $assetsSource "*") -Destination $assetTargetDirectory -Recurse -Force
}

Push-Location $projectRoot
try {
    Write-Host "Building the blog to validate the post..." -ForegroundColor Cyan
    & npm.cmd run build
    if ($LASTEXITCODE -ne 0) {
        throw "Hexo build failed. The post was not committed. Fix the error above and try again."
    }

    & git add -- $destinationPath
    if (-not [string]::IsNullOrWhiteSpace($assetTargetDirectory)) {
        & git add -- $assetTargetDirectory
    }
    if (-not [string]::IsNullOrWhiteSpace([string](Get-ConfiguredValue $settings "coverFile" ""))) {
        & git add -- (Join-Path $projectRoot ("source\images\posts\" + $slug))
    }

    & git diff --cached --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "The article is unchanged; nothing to publish." -ForegroundColor Yellow
        exit 0
    }

    $commitMessage = [string](Get-ConfiguredValue $settings "commitMessage" "")
    if ([string]::IsNullOrWhiteSpace($commitMessage)) {
        $commitMessage = "publish: " + [string](Get-ConfiguredValue $settings "title" $slug)
    }

    & git commit -m $commitMessage
    if ($LASTEXITCODE -ne 0) {
        throw "Git commit failed. The post was not pushed."
    }

    $pushEnabled = [bool](Get-ConfiguredValue $settings "push" $true)
    if ($NoPush -or -not $pushEnabled) {
        Write-Host "The post was committed locally. Push was disabled." -ForegroundColor Yellow
        exit 0
    }

    Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
    & git push
    if ($LASTEXITCODE -ne 0) {
        throw "GitHub push failed. The local commit is safe; run git push when the network is available."
    }

    Write-Host "Publish completed. GitHub Actions will update the website." -ForegroundColor Green
    Write-Host "Website: https://rds666.github.io/Myblog/"
} finally {
    Pop-Location
}
