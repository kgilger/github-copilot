# /clean-migrations — Archive EF Migrations by Version

## Description

Archive Entity Framework migrations into versioned subdirectories (`Migrations/v{version}/`) and configure `.csproj` to exclude archived migrations in FastBuild mode for faster development builds while preserving all migrations for production deployments.

---

## Allowed Tools

- `file_search` — Find `*.Data.csproj` file
- `list_dir` — Scan `Migrations/` directory
- `read_file` — Read `.csproj` configuration
- `run_in_terminal` — Execute `git mv` commands
- `replace_string_in_file` — Update `.csproj` exclusion rules
- `create_directory` — Create `Migrations/v{version}/` folder

---

## Validation

### Prérequis

1. **Paramètre version obligatoire** — `$ARGUMENTS` doit contenir une version (format: `v1.2.3` ou `1.2.3`)
2. **Projet Data existe** — Au moins un fichier `*.Data.csproj` trouvé dans le workspace
3. **Dossier Migrations existe** — `Migrations/` présent dans le projet Data
4. **Migrations non archivées** — Au moins un fichier `.cs` à la racine de `Migrations/` (hors `DataContextModelSnapshot.cs`)

### Validation des Entrées

- Version format: `^v?\d+\.\d+\.\d+` (accepte `v1.2.3` ou `1.2.3`)
- Normaliser: toujours ajouter le préfixe `v` (ex: `1.2.3` → `v1.2.3`)

### Conditions d'Exit Silencieux

- Aucune migration à archiver (toutes déjà dans des sous-dossiers)
- Dossier `Migrations/v{version}/` existe déjà et contient les migrations

---

## Workflow

### 1. Parse & Validate Version

```
Input: $ARGUMENTS
Extract: version (format v1.2.3 ou 1.2.3)
Normalize: add 'v' prefix if missing
Validate: regex ^v\d+\.\d+\.\d+$
```

**Si invalid** → Erreur: `Invalid version format. Use: /clean-migrations v1.2.3`

---

### 2. Locate Data Project

```
Search: *.Data.csproj in workspace
If multiple found: use first match
If none found: Erreur "No *.Data.csproj found in workspace"
Extract: project directory path
```

---

### 3. Scan Migrations Folder

```
Path: {ProjectDir}/Migrations/
List: *.cs files at root level (not subdirectories)
Exclude: DataContextModelSnapshot.cs (NEVER archive)
Filter: Only files matching EF convention (YYYYMMDDHHmmss_*.cs)
```

**Si aucune migration trouvée** → Exit silencieux

---

### 4. Create Version Folder

```
Target: {ProjectDir}/Migrations/v{version}/
If exists: verify it's empty or contains only migrations
Create if missing
```

---

### 5. Archive Migrations

Pour chaque migration non archivée :

```powershell
git mv Migrations/{MigrationFile}.cs Migrations/v{version}/{MigrationFile}.cs
```

**Important** :
- Utiliser `git mv` (pas `Move-Item`) pour préserver l'historique git
- Ne jamais déplacer `DataContextModelSnapshot.cs`
- Ne jamais déplacer les fichiers `.Designer.cs` associés (EF les gère automatiquement)

---

### 6. Update .csproj Configuration

#### Si FastBuild config absente

Injecter après le premier `<PropertyGroup>` :

```xml
  <!-- FastBuild mode: exclude archived migrations for faster dev builds -->
  <PropertyGroup>
    <FastBuild Condition="'$(FastBuild)' == ''">false</FastBuild>
  </PropertyGroup>

  <PropertyGroup Condition="'$(FastBuild)' == 'true'">
    <DefineConstants>$(DefineConstants);FASTBUILD</DefineConstants>
  </PropertyGroup>

  <ItemGroup Condition="'$(FastBuild)' == 'true'">
    <!-- Exclude archived migrations in FastBuild mode -->
    <Compile Remove="Migrations\v{version}\**\*.cs" />
  </ItemGroup>
```

#### Si FastBuild config existe

Ajouter la ligne d'exclusion dans `<ItemGroup Condition="'$(FastBuild)' == 'true'>` :

```xml
    <Compile Remove="Migrations\v{version}\**\*.cs" />
```

**Important** :
- Garder l'ordre alphabétique/chronologique des versions
- Utiliser `\` (backslash) pour les chemins MSBuild (pas `/`)
- Utiliser `**\*.cs` pour correspondre récursivement

---

### 7. Output Summary

```
✅ {count} migrations archived in v{version}
   {ProjectName}.Data.csproj updated (FastBuild exclusions)

Usage:
  Dev (fast):     dotnet build /p:FastBuild=true
  Dev (full):     dotnet build
  Prod/Release:   dotnet build -c Release

Next: Review changes and commit with /commit
```

---

## Rules

### 1. Paramètre Obligatoire
Version MUST be provided. No prompt, no interactive mode.
```
❌ /clean-migrations
✅ /clean-migrations v1.2.3
✅ /clean-migrations 1.2.3
```

### 2. Snapshot Protection
`DataContextModelSnapshot.cs` MUST NEVER be archived. Always keep at `Migrations/` root.

### 3. Git History Preservation
Use `git mv` (not `Move-Item`) to preserve file history in git.

### 4. Idempotence
Running `/clean-migrations v1.2.3` multiple times must be safe:
- Skip if version folder exists and populated
- Don't duplicate `.csproj` exclusion rules

### 5. No Commit
Command only stages changes. Developer commits manually or uses `/commit`.

### 6. Designer Files
Don't explicitly move `.Designer.cs` files — EF handles them automatically.

### 7. FastBuild Usage
After archiving, developers use:
```powershell
# Fast dev builds (exclude archived migrations)
dotnet build /p:FastBuild=true

# Full builds (include all migrations)
dotnet build

# Production builds (always include all)
dotnet build -c Release
```

### 8. Mode --help
Display usage if `$ARGUMENTS` is `--help` or `-h`:
```
/clean-migrations — Archive EF Migrations by Version

Archives Entity Framework migrations into versioned folders and configures
FastBuild mode to exclude them during development for faster compilation.

Usage:
  /clean-migrations <version>

Arguments:
  <version>    Version number (format: v1.2.3 or 1.2.3)

Examples:
  /clean-migrations v1.2.3
  /clean-migrations 1.2.3

Configuration:
  After archiving, use FastBuild mode for faster dev builds:
    dotnet build /p:FastBuild=true    (excludes archived migrations)
    dotnet build                      (includes all migrations)
    dotnet build -c Release           (includes all migrations)

Notes:
  - Archives all non-archived .cs files from Migrations/ root
  - Never archives DataContextModelSnapshot.cs
  - Preserves git history (uses git mv)
  - Updates *.Data.csproj with exclusion rules
  - Does not commit (use /commit after reviewing changes)
```

### 9. Error Messages
Keep error messages concise and actionable:
- Missing version: `Missing version parameter. Usage: /clean-migrations v1.2.3`
- Invalid format: `Invalid version format '{input}'. Expected: v1.2.3 or 1.2.3`
- No project: `No *.Data.csproj found in workspace`
- No migrations folder: `Migrations/ folder not found in {ProjectName}`
- No migrations: Exit silently (nothing to archive)

### 10. Multi-Project Handling
If multiple `*.Data.csproj` found:
- Use the first match
- Display warning: `Multiple Data projects found, using: {ProjectName}`

---

## Validation Checklist

Before execution, verify:
- [ ] Version parameter provided and valid
- [ ] `*.Data.csproj` exists
- [ ] `Migrations/` folder exists
- [ ] At least one non-archived migration file exists
- [ ] `DataContextModelSnapshot.cs` excluded from archiving

After execution, verify:
- [ ] All migrations moved to `Migrations/v{version}/`
- [ ] `DataContextModelSnapshot.cs` still at root
- [ ] `.csproj` contains FastBuild exclusion for this version
- [ ] `git status` shows moved files (not deleted/added)
- [ ] Summary output displayed

---

## Examples

### Basic Usage
```bash
# Archive migrations for version 1.2.3
/clean-migrations v1.2.3
```

### After Command
```bash
# Test FastBuild mode
dotnet build /p:FastBuild=true

# Review changes
git status

# Commit with /commit
/commit
```

### Result Structure
```
Migrations/
├── v1.0.0/
│   ├── 20230115120000_InitialCreate.cs
│   └── 20230620143000_AddUsers.cs
├── v1.2.3/
│   ├── 20240101090000_FixUserIndex.cs
│   └── 20240315110000_AddOrders.cs
├── 20251220151049_CurrentMigration.cs
└── DataContextModelSnapshot.cs
```

### .csproj Configuration
```xml
<PropertyGroup>
  <FastBuild Condition="'$(FastBuild)' == ''">false</FastBuild>
</PropertyGroup>

<ItemGroup Condition="'$(FastBuild)' == 'true'">
  <Compile Remove="Migrations\v1.0.0\**\*.cs" />
  <Compile Remove="Migrations\v1.2.3\**\*.cs" />
</ItemGroup>
```
