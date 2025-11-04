# BMad Framework Symlink Setup

This directory contains the PowerShell script to synchronize the BMad framework across all active projects using symbolic links.

## Quick Start

```powershell
# Run PowerShell as Administrator
.\scripts\setup-symlinks.ps1
```

## What This Does

The script creates symbolic links from the master mydevwf template to all active projects in `mydevwf/projects/`:

1. **`.bmad-core/` folder** - Complete BMad framework (agents, tasks, workflows, templates)
2. **`.claude/commands/` folder** - Slash command interface for agents and tasks
3. **Preserves** `.claude/settings.local.json` - Project-specific settings remain independent

## Why Symlinks?

**Before Symlinks**:
- Framework improvements in master don't propagate to projects
- Each project has a copy of `.bmad-core/` and `.claude/`
- Updates require manual sync or scripts
- Framework drift across projects

**After Symlinks**:
- ✅ **Instant Sync** - Update master once, all projects see changes immediately
- ✅ **Zero Maintenance** - No sync scripts, no manual copying
- ✅ **Consistency** - All projects use same framework version
- ✅ **Fast Iteration** - Rapid framework development and testing

## Architecture

### Master Template (mydevwf/)
```
mydevwf/
├── .bmad-core/           ← Source of truth
│   ├── agents/
│   ├── tasks/
│   ├── templates/
│   ├── checklists/
│   └── data/
├── .claude/
│   ├── commands/         ← Source of truth
│   │   ├── BMad/
│   │   └── bmadInfraDevOps/
│   └── settings.local.json
└── projects/
    ├── hdav2/
    ├── my-saas-app/
    └── ...
```

### Active Project (mydevwf/projects/hdav2/)
```
hdav2/
├── .bmad-core/           ← SYMLINK → mydevwf/.bmad-core/
├── .claude/
│   ├── commands/         ← SYMLINK → mydevwf/.claude/commands/
│   └── settings.local.json  ← Project-specific (NOT symlinked)
├── CLAUDE.md             ← Project-specific (NOT symlinked)
├── .mcp.json             ← Project-specific (NOT symlinked)
└── ... (project files)
```

## Script Features

### ✅ Safe Operations
- **Automatic Backups** - Existing directories backed up with timestamp
- **Validation** - Checks master directories exist before proceeding
- **Skip Existing** - Detects and skips already-symlinked directories
- **Error Handling** - Continues on errors, reports summary at end

### ✅ Git Integration
- **Auto .gitignore** - Adds symlinked folders to project .gitignore
- **Preserves Settings** - Project-specific files remain under version control

### ✅ Verification
- **Detailed Logging** - Shows exactly what was changed in each project
- **Verification Commands** - Provides PowerShell commands to verify symlinks

## Requirements

- **Windows**: Administrator privileges (required for creating symlinks)
- **PowerShell**: Version 5.1 or later
- **Master Template**: Must have `.bmad-core/` and `.claude/commands/` folders

## Usage

### Basic Usage
```powershell
# From mydevwf directory
.\scripts\setup-symlinks.ps1
```

### Custom Paths
```powershell
# Specify custom projects directory
.\scripts\setup-symlinks.ps1 -ProjectsDir "D:\Other\Path\projects"

# Specify custom master directory
.\scripts\setup-symlinks.ps1 -MasterDir "D:\Dev\other-master"
```

### Verification
```powershell
# Verify symlinks were created correctly
Get-ChildItem -Path "D:\Dev\mydevwf\projects\*\.bmad-core" -Force | Select-Object FullName, Target

# Check specific project
Get-Item -Path "D:\Dev\mydevwf\projects\hdav2\.bmad-core" -Force | Select-Object FullName, Target, Attributes
```

## What Gets Symlinked?

| Folder/File | Symlinked? | Why? |
|-------------|------------|------|
| `.bmad-core/` | ✅ Yes | Framework updates should propagate instantly |
| `.claude/commands/` | ✅ Yes | Slash commands mirror framework updates |
| `.claude/settings.local.json` | ❌ No | Project-specific MCP settings |
| `CLAUDE.md` | ❌ No | Project-specific context and instructions |
| `.mcp.json` | ❌ No | Project-specific MCP server configuration |

## Troubleshooting

### "Access Denied" Error
**Problem**: PowerShell not running as Administrator

**Solution**:
1. Right-click PowerShell
2. Select "Run as Administrator"
3. Re-run the script

### Symlink Not Working
**Problem**: Symlink created but not resolving

**Verification**:
```powershell
# Check if it's actually a symlink
Get-Item -Path "D:\Dev\mydevwf\projects\hdav2\.bmad-core" -Force | Format-List *

# Expected output:
# Attributes: ReparsePoint, Directory
# Target: D:\Dev\mydevwf\.bmad-core
```

### Git Shows Symlink Content
**Problem**: Git tracking symlink contents instead of link itself

**Solution**: Ensure `.gitignore` contains:
```gitignore
# BMad Framework (symlinked from master)
.bmad-core/

# Claude commands (symlinked from master)
.claude/commands/
```

## Post-Setup Workflow

### Making Framework Improvements
1. Edit files in **master** `mydevwf/.bmad-core/` or `mydevwf/.claude/commands/`
2. Changes **instantly visible** in all projects via symlinks
3. Test in any active project
4. Commit from **master** template directory
5. All projects automatically use updated framework

### Creating New Projects
1. Run `npm run create-project <template> <project-name>`
2. Run `.\scripts\setup-symlinks.ps1` (sets up symlinks for new project)
3. New project uses latest framework version

### Backup Before Breaking Changes
```powershell
# If making risky framework changes, backup master first
Copy-Item -Path "D:\Dev\mydevwf\.bmad-core" -Destination "D:\Dev\mydevwf\.bmad-core.backup-YYYYMMDD" -Recurse
```

## Migration Path to Git Submodules (Future)

Once framework stabilizes, consider migrating to Git submodules for:
- ✅ Version pinning per project
- ✅ Cross-team collaboration
- ✅ Framework versioning
- ✅ Independent framework repository

**For now**: Symlinks provide rapid iteration speed during active development.

## Related Documentation

- **CLAUDE.md** - Main project instructions and context
- **docs/guides/MCP-QUICK-START.md** - MCP configuration guide
- **docs/guides/WORKFLOW-REFERENCE.md** - Development workflow examples
- **docs/session-logs/** - Historical context and decisions

## Support

For issues or questions:
1. Check existing session logs in `docs/session-logs/`
2. Review CLAUDE.md for latest framework updates
3. Verify master `.bmad-core/` is intact and up-to-date
