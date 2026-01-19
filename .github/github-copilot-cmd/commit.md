# /commit — Générateur Intelligent de Messages de Commit

> ⚠️ **WORKFLOW CRITIQUE** :
> 1. Analyser les changements et générer le message
> 2. **CRÉER LE FICHIER CHANGENOTE** avec `create_file` (hash: pending)
> 3. `git add -A` + `git commit -m "message"`
> 4. Récupérer le hash, mettre à jour le CHANGENOTE
> 5. `git commit --amend --no-edit`
> 
> Le CHANGENOTE doit être **INCLUS** dans le commit, pas créé après !

## Description

Analyse les fichiers modifiés, extrait l'essence du changement et génère un message de commit court, uniforme et conforme aux Conventional Commits. Stage, commit et génère automatiquement une CHANGENOTE pour traçabilité.

## Allowed Tools

- `get_changed_files` — Récupérer les diffs des fichiers modifiés
- `read_file` — Lire le contexte additionnel si nécessaire
- `run_in_terminal` — Exécuter les commandes git (add, commit, push)
- `create_file` — Créer le fichier CHANGENOTE

## Validation

Avant exécution, vérifier :

1. [ ] Le répertoire courant est un repo git (`git rev-parse --is-inside-work-tree`)
2. [ ] Il y a des changements à committer (staged ou unstaged)
3. [ ] Si aucun changement → exit silencieux

## Context

Collecter ces informations avant de générer le message :

```bash
git status --short                    # Liste des fichiers modifiés
git diff HEAD                         # Contenu des changements
git branch --show-current             # Branche courante
```

## Workflow

### 1. Collecter les changements

- Utiliser `get_changed_files` pour obtenir les diffs staged et unstaged
- **Filtrer les fichiers** : ignorer tous les fichiers dans `.github/` et `CHANGENOTES/`
- Si rien de staged → stager tous les changements (`git add -A`)
- **Note** : Le CHANGENOTE généré sera ajouté manuellement après, ne pas l'exclure du commit final

### 2. Analyser le code produit

Pour chaque fichier modifié :
- Identifier le **type de changement** : ajout (NEW), modification (MODIFIED), suppression (DELETED), refactor
- Extraire les **éléments clés** : fonctions, classes, interfaces, variables importantes
- Détecter le **scope** : dossier principal, module, feature concernée
- **Détecter les changements structurels** :
  - Nouveaux composants créés (classes, interfaces, services, repositories)
  - Design patterns identifiables (Repository, Factory, Singleton, Strategy, etc.)
  - Dépendances externes ajoutées (packages NuGet, npm, etc.)
  - Couches architecturales modifiées (Data, Business, UI, Infrastructure)
  - Breaking changes sur interfaces publiques
  - Composants dépréciés (marqués avec `[Obsolete]`, `@deprecated`, etc.)

### 3. Déduire le type de commit

| Pattern détecté | Type |
|----------------|------|
| Nouvelle feature, nouveau fichier fonctionnel | `feat` |
| Correction de bug, fix | `fix` |
| Mise à jour de dépendances, config | `update` |
| Restructuration sans changement de comportement | `refactor` |
| Documentation, README, comments | `docs` |
| Tests ajoutés/modifiés | `test` |
| Maintenance, CI, scripts | `chore` |

### 4. Déterminer le scope

Déduire automatiquement depuis :
- Le dossier principal touché (`src/auth` → `auth`)
- Le module concerné (`components/Button` → `button`)
- La feature (`api/users` → `users`)

**Règle** : Scope = nom court, lowercase, sans path complet

### 5. Générer le message

Format : `type(scope): description`

**Règles du message :**
- Max 50 caractères (idéal) à 72 caractères (max)
- Présent de l'indicatif : "add" pas "added"
- Minuscule après le `:`
- Pas de point final
- Verbe d'action en premier : add, fix, update, remove, refactor, improve

### 6. Créer la CHANGENOTE (AVANT le commit)

**IMPORTANT** : Créer le fichier CHANGENOTE AVANT de committer, pour qu'il soit inclus dans le commit !

**Emplacement** : `<project-root>/CHANGENOTES/` (PAS dans `.github/`)

**Nom du fichier** : `<YYYY-MM-DD>_<HHMMSS>_<type>_<scope>.md`
- Exemple : `CHANGENOTES/2025-12-11_143200_feat_auth.md`

**Contenu** :
```markdown
---
type: <type>
scope: <scope>
date: <ISO 8601 datetime>
hash: <short commit hash>
branch: <branch name>
---

# <message du commit>

## Changes
- `path/to/file.ts` — **NEW/MODIFIED/DELETED**: description du changement avec contexte
- `path/to/other.ts` — **MODIFIED**: description avec impact

## Architecture
*(Optionnel : généré SI changements structurels détectés)*
- **Components**: Classes/interfaces/modules créés ou modifiés (ex: `UserRepository`, `IUserService`)
- **Patterns**: Design patterns utilisés (ex: Repository Pattern, Dependency Injection, Factory)
- **Dependencies**: Nouvelles dépendances externes ajoutées (ex: EntityFrameworkCore 9.0, AutoMapper)
- **Layers**: Couches architecturales impactées (ex: Data Access, Business Logic, UI, Infrastructure)
- **Breaking Changes**: Modifications d'API publique si applicable (ex: `IUserService.GetUser()` signature changed)
- **Deprecated**: Composants marqués comme obsolètes (ex: `[DEPRECATED] OldAuthService - use IAuthService`)

## Summary
<Résumé en 2-4 phrases : quoi, pourquoi, impact principal>
```

**Règles CHANGENOTE** :
- **EMPLACEMENT** : `CHANGENOTES/` à la racine du projet (jamais dans `.github/`)
- Le dossier est créé automatiquement s'il n'existe pas
- Le frontmatter YAML est obligatoire (utilisé par `/doc`)
- **Section Architecture** : Générée automatiquement SI changements structurels détectés (nouveaux composants, patterns, dépendances, breaking changes)
- **Changes** : Inclure status NEW/MODIFIED/DELETED et contexte d'implémentation
- Le Summary est généré depuis l'analyse du diff avec plus de détails sur l'impact
- Pas de contenu verbeux, mais suffisamment détaillé pour comprendre l'architecture
- **Le hash sera "pending" car le commit n'est pas encore fait**

### 7. Exécuter le commit

Maintenant que le CHANGENOTE est créé, committer le tout :

```bash
git add -A                           # Stage tout, y compris le CHANGENOTE
git commit -m "type(scope): message"
```

### 8. Mettre à jour le hash dans le CHANGENOTE

Après le commit, récupérer le hash et mettre à jour le fichier CHANGENOTE :
- Récupérer le hash : `git rev-parse --short HEAD`
- Remplacer `hash: pending` par `hash: <short-hash>` dans le fichier

### 9. Amend le commit (pour inclure le hash)

```bash
git add CHANGENOTES/
git commit --amend --no-edit
```

### 10. Push (si demandé)

- Si `$ARGUMENTS` contient `--push` ou `-p` → push automatique
- Sinon → ne pas push

## Rules

> ⚠️ **RÈGLE #1 ABSOLUE** : Créer le CHANGENOTE AVANT le commit, puis amend pour inclure le hash.

1. **EXCLUSIONS** — Ignorer les changements dans `.github/` et `CHANGENOTES/` lors de l'analyse (mais inclure le CHANGENOTE généré dans le commit final)
2. **CHANGENOTE AVANT COMMIT** — Créer `CHANGENOTES/<date>_<type>_<scope>.md` AVANT de committer
3. **INCLUS DANS LE COMMIT** — Le CHANGENOTE doit faire partie du commit, pas être séparé
4. **Scope OBLIGATOIRE** — Jamais de commit sans scope : `fix(auth):` pas `fix:`
5. **Message court** — Max 72 caractères, idéalement 50
6. **Présent** — "add feature" pas "added feature"
7. **Lowercase** — Après le `:`, tout en minuscule
8. **Pas de point final** — Économie d'espace
9. **Un commit = un changement logique** — Si plusieurs changes distincts, suggérer de splitter
10. **NO verbose** — Pas d'explication longue, juste le commit
11. **NO interactive** — Pas de demande de confirmation
12. **NO signature** — Pas de "Generated by Copilot"

## Arguments

```
/commit $ARGUMENTS
```

| Argument | Description |
|----------|-------------|
| (vide) | Commit avec message auto-généré |
| `--push` ou `-p` | Commit + push automatique |
| `--amend` ou `-a` | Amend le dernier commit |
| `--dry-run` ou `-d` | Preview du message sans committer |
| `--no-note` | Skip la génération de CHANGENOTE |
| `--help` ou `-h` | Affiche l'aide de la commande |
| `"message custom"` | Utilise ce message au lieu de générer |

## Execution

- **NO interactive commands** — Pas de `git commit` sans `-m`
- **NO verbose messages** — Juste le résultat final
- **NO "Generated by..." signatures**
- **If nothing to do** → exit silently (pas de message "rien à committer")
- **If error** → report concisely

## Output Format

**Mode normal** — Après commit réussi :
```
✓ type(scope): message [branch-name abc1234]
  → CHANGENOTES/2025-12-11_143200_type_scope.md
```

**Mode push** — Si push effectué :
```
✓ type(scope): message [branch-name abc1234] → pushed
  → CHANGENOTES/2025-12-11_143200_type_scope.md
```

**Mode dry-run** — Preview sans action :
```
⎔ type(scope): message (dry-run)
```

**Mode --no-note** — Sans CHANGENOTE :
```
✓ type(scope): message [branch-name abc1234]
```
