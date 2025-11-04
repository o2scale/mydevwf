<#
.SYNOPSIS
    Setup symlinks for .bmad-core and .claude folders across all active projects

.DESCRIPTION
    This script creates symbolic links from the master mydevwf template to all
    active projects, ensuring framework improvements propagate instantly.

.PARAMETER ProjectsDir
    Path to the projects directory (default: D:\Dev\mydevwf\projects)

.PARAMETER MasterDir
    Path to the master template directory (default: D:\Dev\mydevwf)

.EXAMPLE
    .\setup-symlinks.ps1
    .\setup-symlinks.ps1 -ProjectsDir "D:\Dev\mydevwf\projects"
#>

param(
    [string]$ProjectsDir = "D:\Dev\mydevwf\projects",
    [string]$MasterDir = "D:\Dev\mydevwf"
)

# Requires Administrator privileges for creating symlinks on Windows
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script requires Administrator privileges to create symlinks on Windows" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again" -ForegroundColor Yellow
    exit 1
}

# Validate master directories exist
$masterBmadCore = Join-Path $MasterDir ".bmad-core"
$masterClaudeCommands = Join-Path $MasterDir ".claude\commands"

if (-not (Test-Path $masterBmadCore)) {
    Write-Host "ERROR: Master .bmad-core folder not found at: $masterBmadCore" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $masterClaudeCommands)) {
    Write-Host "ERROR: Master .claude/commands folder not found at: $masterClaudeCommands" -ForegroundColor Red
    exit 1
}

# Validate projects directory exists
if (-not (Test-Path $ProjectsDir)) {
    Write-Host "ERROR: Projects directory not found: $ProjectsDir" -ForegroundColor Red
    exit 1
}

# Get all project directories
$projects = Get-ChildItem -Path $ProjectsDir -Directory

if ($projects.Count -eq 0) {
    Write-Host "WARNING: No projects found in $ProjectsDir" -ForegroundColor Yellow
    exit 0
}

Write-Host "`n=== BMad Framework Symlink Setup ===" -ForegroundColor Cyan
Write-Host "Master: $MasterDir" -ForegroundColor Gray
Write-Host "Projects: $ProjectsDir" -ForegroundColor Gray
Write-Host "Found $($projects.Count) project(s)`n" -ForegroundColor Gray

$successCount = 0
$errorCount = 0
$skippedCount = 0

foreach ($project in $projects) {
    Write-Host "Processing: $($project.Name)" -ForegroundColor White

    $projectBmadCore = Join-Path $project.FullName ".bmad-core"
    $projectClaudeDir = Join-Path $project.FullName ".claude"
    $projectClaudeCommands = Join-Path $projectClaudeDir "commands"
    $projectClaudeSettings = Join-Path $projectClaudeDir "settings.local.json"

    try {
        # -----------------------
        # Handle .bmad-core/
        # -----------------------
        if (Test-Path $projectBmadCore) {
            # Check if it's already a symlink
            $item = Get-Item $projectBmadCore -Force
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                Write-Host "  [OK] .bmad-core/ already symlinked" -ForegroundColor Green
            } else {
                # Backup existing directory
                $backupPath = "$projectBmadCore.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                Write-Host "  -> Backing up existing .bmad-core/ to: $(Split-Path $backupPath -Leaf)" -ForegroundColor Yellow
                Move-Item -Path $projectBmadCore -Destination $backupPath -Force

                # Create symlink
                New-Item -ItemType SymbolicLink -Path $projectBmadCore -Target $masterBmadCore -Force | Out-Null
                Write-Host "  [OK] .bmad-core/ symlinked successfully" -ForegroundColor Green
            }
        } else {
            # Create new symlink
            New-Item -ItemType SymbolicLink -Path $projectBmadCore -Target $masterBmadCore -Force | Out-Null
            Write-Host "  [OK] .bmad-core/ symlinked successfully (new)" -ForegroundColor Green
        }

        # -----------------------
        # Handle .claude/commands/
        # -----------------------

        # Ensure .claude directory exists
        if (-not (Test-Path $projectClaudeDir)) {
            New-Item -ItemType Directory -Path $projectClaudeDir -Force | Out-Null
        }

        # Backup settings.local.json if it exists (before we touch commands)
        $settingsBackup = $null
        if (Test-Path $projectClaudeSettings) {
            $settingsBackup = Get-Content $projectClaudeSettings -Raw
        }

        # Handle commands folder
        if (Test-Path $projectClaudeCommands) {
            # Check if it's already a symlink
            $item = Get-Item $projectClaudeCommands -Force
            if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                Write-Host "  [OK] .claude/commands/ already symlinked" -ForegroundColor Green
            } else {
                # Backup existing directory
                $backupPath = "$projectClaudeCommands.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                Write-Host "  -> Backing up existing .claude/commands/ to: $(Split-Path $backupPath -Leaf)" -ForegroundColor Yellow
                Move-Item -Path $projectClaudeCommands -Destination $backupPath -Force

                # Create symlink
                New-Item -ItemType SymbolicLink -Path $projectClaudeCommands -Target $masterClaudeCommands -Force | Out-Null
                Write-Host "  [OK] .claude/commands/ symlinked successfully" -ForegroundColor Green
            }
        } else {
            # Create new symlink
            New-Item -ItemType SymbolicLink -Path $projectClaudeCommands -Target $masterClaudeCommands -Force | Out-Null
            Write-Host "  [OK] .claude/commands/ symlinked successfully (new)" -ForegroundColor Green
        }

        # Restore settings.local.json if it was backed up
        if ($settingsBackup) {
            Set-Content -Path $projectClaudeSettings -Value $settingsBackup -Force
            Write-Host "  [OK] Preserved .claude/settings.local.json" -ForegroundColor Green
        } else {
            # Create default settings.local.json
            $defaultSettings = @{
                enableAllProjectMcpServers = $false
            } | ConvertTo-Json
            Set-Content -Path $projectClaudeSettings -Value $defaultSettings -Force
            Write-Host "  [OK] Created default .claude/settings.local.json" -ForegroundColor Green
        }

        # -----------------------
        # Update .gitignore
        # -----------------------
        $gitignorePath = Join-Path $project.FullName ".gitignore"
        $gitignoreUpdated = $false

        if (Test-Path $gitignorePath) {
            $gitignoreContent = Get-Content $gitignorePath -Raw

            # Check if .bmad-core is already in .gitignore
            if ($gitignoreContent -notmatch "\.bmad-core") {
                Add-Content -Path $gitignorePath -Value "`n# BMad Framework (symlinked from master)`n.bmad-core/"
                $gitignoreUpdated = $true
            }

            # Check if .claude is in .gitignore (we want to ignore symlinked commands but keep settings.local.json)
            if ($gitignoreContent -notmatch "\.claude/commands") {
                Add-Content -Path $gitignorePath -Value "`n# Claude commands (symlinked from master)`n.claude/commands/"
                $gitignoreUpdated = $true
            }

            if ($gitignoreUpdated) {
                Write-Host "  [OK] Updated .gitignore" -ForegroundColor Green
            }
        }

        $successCount++
        Write-Host "" # Blank line between projects

    } catch {
        Write-Host "  ✗ ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
        Write-Host "" # Blank line between projects
    }
}

# Summary
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "[OK] Success: $successCount project(s)" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "✗ Errors:  $errorCount project(s)" -ForegroundColor Red
}
if ($skippedCount -gt 0) {
    Write-Host "[SKIP] Skipped: $skippedCount project(s)" -ForegroundColor Yellow
}

Write-Host "`n=== Verification ===" -ForegroundColor Cyan
Write-Host "Run this command to verify symlinks:" -ForegroundColor Gray
Write-Host "Get-ChildItem -Path `"$ProjectsDir\*\.bmad-core`" -Force | Select-Object FullName, Target" -ForegroundColor White
Write-Host "" # Blank line

Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host "1. Verify symlinks are working correctly" -ForegroundColor Gray
Write-Host "2. Test a project to ensure agents load correctly" -ForegroundColor Gray
Write-Host "3. Make a change in master .bmad-core/ and verify it appears in projects" -ForegroundColor Gray
Write-Host "4. Commit project .gitignore updates (if modified)" -ForegroundColor Gray
Write-Host "" # Blank line

if ($errorCount -eq 0) {
    Write-Host "[OK] Symlink setup completed successfully!" -ForegroundColor Green
} else {
    Write-Host "[WARN] Symlink setup completed with errors. Please review above." -ForegroundColor Yellow
}
