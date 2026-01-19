# /doc — Générateur de Documentation Technique Versionnée

## Description

Génère et maintient une documentation technique versionnée (`DOCS/<nom_app>-doc.md`) en agrégeant les CHANGENOTES. Inclut une Architecture Overview organisée par composants majeurs et un historique des versions. Archive automatiquement chaque version dans `DOCS/ARCHIVES/` avant mise à jour.

## Allowed Tools

- `read_file` — Lire les CHANGENOTES, doc existante, fichiers de config
- `list_dir` — Lister CHANGENOTES/ et explorer le workspace
- `file_search` — Détecter package.json, *.csproj, fichiers d'architecture
- `semantic_search` — Analyser le code pour détecter composants majeurs
- `grep_search` — Chercher patterns, classes, interfaces
- `create_file` — Créer/mettre à jour documentation et archives
- `replace_string_in_file` — Mettre à jour sections de la doc
- `run_in_terminal` — Supprimer CHANGENOTES traitées, git operations

## Validation

Avant exécution, vérifier :

1. [ ] Le dossier `CHANGENOTES/` existe
2. [ ] Il contient au moins un fichier `.md` (sinon exit silencieux)
3. [ ] Détecter le nom de l'application pour nommer le fichier doc

## Context

Collecter ces informations :

```bash
ls CHANGENOTES/                       # Liste des notes à traiter
git rev-parse --show-toplevel         # Racine du projet
basename $(git rev-parse --show-toplevel)  # Nom du dossier git (fallback)
```

**Détection du nom de l'application** (ordre de priorité) :
1. `package.json` → champ `name`
2. `*.csproj` → balise `<AssemblyName>` ou nom du fichier
3. `*.sln` → nom du fichier solution
4. Nom du dossier racine git (fallback)

## Workflow

> ⚠️ **IMPORTANT** : Le fichier de documentation est `DOCS/<nom_app>-doc.md`, les archives dans `DOCS/ARCHIVES/`

### 1. Détecter le nom de l'application

- Chercher `package.json`, `*.csproj`, `*.sln` dans le workspace
- Extraire le nom selon priorité définie dans Context
- Si rien trouvé → utiliser nom du dossier git
- Normaliser : lowercase, remplacer espaces par tirets

### 2. Vérifier l'existence de la documentation

**Si `DOCS/<nom_app>-doc.md` n'existe PAS** :
- Lancer **Analyse Initiale Complète** (voir workflow section 3)
- Générer la première version de la doc avec version `0.1.0`
- Skip l'archivage (première version)

**Si `DOCS/<nom_app>-doc.md` existe** :
- Lire le fichier pour extraire la version actuelle
- **Archiver** immédiatement dans `DOCS/ARCHIVES/<nom_app>-doc-v{version_actuelle}.md`
- Continuer le workflow normal

### 3. Analyse Initiale Complète (première génération uniquement)

> Cette étape ne s'exécute QUE si aucune documentation n'existe.

**Objectif** : Créer une Architecture Overview complète en analysant tout le code existant.

**Étapes** :
1. **Scanner la structure du projet** :
   - Lister tous les dossiers et fichiers principaux
   - **Exclure** : `.github/`, `CHANGENOTES/`, `node_modules/`, `bin/`, `obj/`
   - Identifier les dossiers clés (src/, lib/, api/, services/, etc.)
   
2. **Détecter les composants majeurs** :
   - Chercher les classes, interfaces principales (grep_search)
   - Identifier les services, repositories, controllers
   - Détecter les patterns utilisés (search pour: Repository, Factory, Singleton, Strategy)
   
3. **Analyser les dépendances** :
   - Lire package.json / *.csproj pour lister les dépendances externes
   - Identifier les frameworks principaux (React, Angular, .NET, etc.)
   
4. **Identifier les couches architecturales** :
   - Présence de dossiers UI/Frontend, Business/Services, Data/Repositories
   - Structure en couches vs modulaire vs microservices

5. **Générer la section Architecture Overview initiale** :
   - Organiser par **Composants Majeurs** (pas par couches)
   - Format : Pour chaque composant → Description, Responsabilité, Dépendances, Patterns
   
**Critères pour identifier un "Composant Majeur"** :
- Module/dossier avec ≥3 fichiers de code
- Classe/Service référencé dans ≥3 fichiers (dépendances entrantes)
- Présence de tests dédiés
- Nommage explicite (Service, Repository, Manager, Controller, etc.)

### 4. Collecter les CHANGENOTES

- Lister tous les fichiers dans `<project-root>/CHANGENOTES/`
- Les trier par date (ordre chronologique du nom de fichier)
- Parser le frontmatter YAML de chaque fichier
- Lire les sections Changes, Architecture, Summary

### 5. Calculer la nouvelle version (auto-increment sémantique)

**Si `--version X.Y.Z` spécifié** → utiliser cette version

**Sinon, auto-incrémenter** depuis la version actuelle selon les types des CHANGENOTES :

| Condition | Règle de Bump | Exemple |
|-----------|---------------|---------|
| Au moins 1 `feat` + breaking change détecté | **Majeure** (X.0.0) | 1.2.3 → 2.0.0 |
| Au moins 1 `feat` (sans breaking) | **Mineure** (x.Y.0) | 1.2.3 → 1.3.0 |
| Que des `fix`, `update`, `refactor`, `chore`, `docs`, `test` | **Patch** (x.y.Z) | 1.2.3 → 1.2.4 |

**Détection de breaking change** :
- Section "Breaking Changes" présente dans CHANGENOTE
- Mot-clé "BREAKING" dans le message de commit
- Composant marqué `[DEPRECATED]` dans section Architecture

**Version de départ** : Si aucune version n'existe → `0.1.0`

### 6. Analyser le delta architectural

Parser les sections "Architecture" des CHANGENOTES collectées :

**SI au moins 1 CHANGENOTE contient section Architecture** :
- Extraire tous les composants mentionnés (créés, modifiés, deprecated)
- Identifier les nouveaux patterns introduits
- Lister les nouvelles dépendances ajoutées
- **Régénérer complètement la section Architecture Overview**

**Règles de régénération** :
- Lire la doc actuelle pour avoir le contexte existant
- Fusionner avec les nouveaux composants détectés
- Appliquer règles de cycle de vie DEPRECATED :
  - **CHANGENOTE → DOC** : Si composant marqué deprecated dans CHANGENOTE → ajouter `[DEPRECATED]` dans doc
  - **DOC → SUPPRESSION** : Si composant déjà `[DEPRECATED]` dans doc actuelle → le retirer complètement de la nouvelle doc

**SI aucune CHANGENOTE avec section Architecture** :
- Conserver Architecture Overview existante telle quelle

### 7. Générer/Mettre à jour DOCS/<nom_app>-doc.md

**Structure du fichier** :

```markdown
# <Nom Application> — Documentation Technique

> **Version** : X.Y.Z | **Dernière mise à jour** : YYYY-MM-DD

---

## Architecture Overview

Cette section décrit l'architecture actuelle de l'application organisée par composants majeurs.

### <Composant 1>

**Responsabilité** : Description du rôle du composant

**Implémentation** :
- Fichiers principaux : `path/to/file.ts`, `path/to/other.ts`
- Patterns utilisés : Repository Pattern, Dependency Injection
- Dépendances : EntityFrameworkCore, AutoMapper

**Interfaces publiques** :
- `IComponentService.Method()` — Description

### <Composant 2>

...

---

## Version History

### [X.Y.Z] - YYYY-MM-DD

**Résumé** : X features, Y fixes, Z refactors

**Features**
- **scope** : description (hash)

**Bug Fixes**
- **scope** : description (hash)

**Refactoring**
- **scope** : description (hash)

---

### [X.Y.Z-1] - YYYY-MM-DD

...
```

**Génération Architecture Overview** :
- Organiser par composants majeurs (identifiés via analyse ou CHANGENOTES)
- Pour chaque composant : Responsabilité, Implémentation (fichiers, patterns, dépendances), Interfaces publiques
- Exclure les composants `[DEPRECATED]` trouvés dans doc précédente

**Génération Version History** :
- Insérer nouvelle version en tête
- Grouper par type : Features, Bug Fixes, Refactoring, Documentation, Chores
- Résumé avec statistiques (X features, Y fixes, etc.)
- Lister les entrées avec format : `**scope** : description (hash)`

### 8. Nettoyer les CHANGENOTES

- **Par défaut** : supprimer tous les fichiers traités dans `CHANGENOTES/`
- **Si `--keep`** : conserver les fichiers

## Rules

1. **EXCLUSIONS** — Ignorer `.github/` et `CHANGENOTES/` lors de l'analyse du code (lire les CHANGENOTES pour agrégation mais pas analyser comme du code)
2. **EMPLACEMENT** — Documentation dans `DOCS/<nom_app>-doc.md`, archives dans `DOCS/ARCHIVES/`
3. **ARCHIVAGE SYSTÉMATIQUE** — Toujours archiver avant toute modification (sauf première génération)
3. **AUTO-INCREMENT** — Version calculée automatiquement selon types CHANGENOTES (sauf si `--version` forcé)
4. **ANALYSE INITIALE** — Si aucune doc existe, scanner tout le code pour générer Architecture Overview
5. **RÉGÉNÉRATION DELTA** — Réécrire Architecture Overview SEULEMENT si CHANGENOTES contiennent section Architecture
6. **DEPRECATED LIFECYCLE** — CHANGENOTE→doc=[DEPRECATED], doc=[DEPRECATED]→retirer
7. **COMPOSANTS MAJEURS** — Organisation par composants, pas par couches techniques
8. **VERSION DÉPART** — 0.1.0 si première génération
9. **NO verbose** — Messages concis uniquement
10. **NO interactive** — Pas de confirmation demandée
11. **NO signature** — Pas de "Generated by..."

## Arguments

```
/doc $ARGUMENTS
```

| Argument | Description |
|----------|-------------|
| (vide) | Auto-incrémente version, génère doc, supprime CHANGENOTES |
| `--version X.Y.Z` ou `-v X.Y.Z` | Force version spécifique (ex: `/doc -v 2.0.0`) |
| `--keep` ou `-k` | Ne supprime pas les CHANGENOTES après agrégation |
| `--dry-run` ou `-d` | Preview des changements sans modification |
| `--help` ou `-h` | Affiche l'aide de la commande |

**Combinaisons possibles** :
- `/doc` — Auto-increment + génère + nettoie
- `/doc -v 2.0.0` — Force version 2.0.0
- `/doc --keep` — Génère sans supprimer CHANGENOTES
- `/doc --dry-run` — Preview sans action

## Execution

- **NO interactive commands** — Pas de confirmation
- **NO verbose messages** — Juste le résultat
- **NO "Generated by..." signatures**
- **If nothing to do** → exit silently
- **If error** → report concisely

## Output Format

**Mode normal** :
```
✓ DOCS/<nom_app>-doc.md updated [X.Y.Z] - YYYY-MM-DD
  → Archived: DOCS/ARCHIVES/<nom_app>-doc-vX.Y.Z-1.md
  → Architecture Overview regenerated (5 components)
  → Version History: +5 entries (3 features, 2 fixes)
  ✗ CHANGENOTES/ cleared (5 files)
```

**Première génération** :
```
✓ DOCS/<nom_app>-doc.md created [0.1.0] - YYYY-MM-DD
  → Architecture Overview generated (7 components)
  → Initial analysis: src/, api/, services/ scanned
  ✗ CHANGENOTES/ cleared (1 file)
```

**Mode --keep** :
```
✓ DOCS/<nom_app>-doc.md updated [X.Y.Z] - YYYY-MM-DD
  → Archived: DOCS/ARCHIVES/<nom_app>-doc-vX.Y.Z-1.md
  ⊙ CHANGENOTES/ kept (5 files)
```

**Mode dry-run** :
```
⎔ Would update DOCS/<nom_app>-doc.md [1.3.0] - 2026-01-19
  → Archive current version: v1.2.4
  → Auto-increment: 1.2.4 → 1.3.0 (1 feat detected)
  → Architecture: no changes (no Architecture section in CHANGENOTES)
  → Version History: would add 5 entries (1 feat, 3 fix, 1 refactor)
```

**Rien à faire** :
```
(exit silencieux, pas de message)
```
