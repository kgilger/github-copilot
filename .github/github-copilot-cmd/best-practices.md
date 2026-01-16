# Best Practices — Catalogue Technique par Domaine

Ce fichier contient les **patterns techniques spécifiques** à injecter dans les commandes générées par `/create-cmd`.
Il est enrichi automatiquement au fur et à mesure de la création de nouvelles commandes.

> ℹ️ **Note** : Les règles générales de workflow et optimisation sont dans `.github/copilot-instructions.md`

---

## 🔀 Git

### Commits
- **Format conventionnel** — `type(scope): description`
- **Scope OBLIGATOIRE** — Jamais de commit sans scope : `fix(auth):` pas `fix:`
- **Types standards** : `feat`, `fix`, `update`, `refactor`, `docs`, `chore`, `test`
- **Max 72 caractères** — Ligne unique, concise
- **Pas de point final** — Économie d'espace
- **Présent** — "add" pas "added"
- **Minuscule après `:` — `fix(auth): typo` pas `fix(auth): Typo`

### Déduction automatique

- **Scope depuis path** — Extraire le scope du chemin : `src/auth/login.ts` → `auth`
- **Type depuis pattern** — Mapper le type selon le changement détecté :

| Pattern | Type |
|---------|------|
| Nouveau fichier fonctionnel | `feat` |
| Fix, correction, patch | `fix` |
| Dépendances, config | `update` |
| Restructuration sans changement comportement | `refactor` |
| README, comments, docs | `docs` |
| Tests | `test` |
| CI, scripts, maintenance | `chore` |

### Mode preview
- **Dry-run** — Toujours proposer un mode preview (`--dry-run`) pour les actions destructives ou importantes

### Workflow Git
- **Atomic commits** — Un commit = un changement logique
- **Stage explicite** — Toujours `git add` avant commit
- **Vérifier le diff** — Analyser `git diff --cached` avant commit
- **Push automatique** — Sauf si spécifié autrement

### Contexte à collecter
```bash
git status                    # État actuel
git diff HEAD                 # Changements non commités
git branch --show-current     # Branche courante
git log --oneline -10         # Historique récent
```

---

## 🌐 API

### Requêtes
- **Timeout défini** — Toujours spécifier un timeout
- **Retry logic** — Réessayer sur erreurs transitoires (5xx, timeout)
- **Rate limiting** — Respecter les limites, implémenter backoff

### Gestion des erreurs
- **Codes HTTP** — Gérer explicitement 4xx et 5xx
- **Messages d'erreur** — Extraire et afficher le message de l'API
- **Fallback** — Prévoir un comportement dégradé si possible

### Sécurité
- **Pas de secrets en dur** — Variables d'environnement uniquement
- **Headers auth** — Bearer token, API key selon le service

---

## 📁 Files

### Manipulation
- **Chemins absolus** — Ou relatifs au root du projet
- **Vérifier existence** — Avant lecture/écriture
- **Backup avant modif** — Pour les fichiers critiques

### Permissions
- **Vérifier droits** — Avant écriture
- **Respecter .gitignore** — Ne pas toucher aux fichiers ignorés

### Nettoyage
- **Supprimer les temp** — Nettoyer les fichiers temporaires créés
- **Pas de fichiers orphelins** — Toujours nettoyer après soi

---

## 🐳 Docker

### Build
- **Multi-stage** — Réduire la taille des images
- **Cache layers** — Ordonner les instructions pour maximiser le cache
- **Tags explicites** — Pas de `:latest` en production

### Run
- **Cleanup** — `--rm` pour les conteneurs temporaires
- **Logs** — Rediriger ou limiter les logs
- **Resources** — Limiter CPU/memory si nécessaire

### Registry
- **Login sécurisé** — Via variables d'environnement
- **Push après tag** — Toujours taguer avant push

---

## 📦 NPM / Yarn

### Installation
- **Lockfile** — Toujours committer `package-lock.json` ou `yarn.lock`
- **CI mode** — Utiliser `npm ci` en CI, pas `npm install`

### Publication
- **Version bump** — Suivre semver
- **Changelog** — Mettre à jour avant publish
- **Dry-run** — Tester avec `--dry-run` avant publish réel

### Scripts
- **Noms standards** — `build`, `test`, `start`, `lint`
- **Pre/post hooks** — Utiliser pour automatiser

---

## 🚀 CI/CD

### Pipelines
- **Fail fast** — Arrêter au premier échec
- **Paralléliser** — Jobs indépendants en parallèle
- **Cache dependencies** — Accélérer les builds

### Déploiement
- **Environnements séparés** — dev, staging, prod
- **Rollback prévu** — Toujours pouvoir revenir en arrière
- **Health checks** — Vérifier après déploiement

### Secrets
- **Variables CI** — Jamais en dur dans le code
- **Rotation** — Prévoir la rotation des secrets
- **Audit** — Logger les accès aux secrets

---

## 🔧 Terminal

### Commandes
- **Pas d'interactif** — Éviter les prompts (`-y`, `--yes`, `--non-interactive`)
- **Codes de sortie** — Vérifier `$?` ou `$LASTEXITCODE`
- **Timeout** — Limiter les commandes longues

### Output
- **Redirection** — Capturer stdout et stderr
- **Parsing** — Utiliser des formats parsables (JSON, CSV)
- **Truncate** — Limiter l'output pour éviter le spam

---

## 📝 Documentation

### Format
- **Markdown** — Standard pour la doc
- **Sections claires** — Headers hiérarchiques
- **Exemples** — Toujours inclure des exemples d'usage

### Maintenance
- **À jour** — Mettre à jour quand le code change
- **Changelog** — Documenter les changements importants

### CHANGENOTES System
- **Frontmatter YAML** — Métadonnées parsables (`type`, `scope`, `date`, `hash`, `branch`)
- **Nommage horodaté** — `YYYY-MM-DD_HHMMSS_type_scope.md` pour tri naturel
- **Atomicité** — Une note = un commit

### CHANGELOG
- **Keep a Changelog** — Respecter le standard https://keepachangelog.com
- **Sections par type** — Grouper avec emojis (🚀 Features, 🐛 Fixes, etc.)
- **Unreleased** — Section temporaire avant versionnement
- **Versionnement sémantique** — `[X.Y.Z] - YYYY-MM-DD`

### Archivage
- **Versions séparées** — `docs/versions/vX.Y.Z.md` pour historique
- **Nettoyage après agrégation** — Supprimer les notes traitées (sauf `--keep`)

---

## 🗄️ Entity Framework / Migrations

### Convention de Nommage
- **Format standard EF** — `{TIMESTAMP}_{Description}.cs` où timestamp = `YYYYMMDDHHmmss`
- **Exemple** — `20250626151049_add_user_email_validation.cs`
- **Descriptif** — Description claire en snake_case

### Snapshot Protection
- **DataContextModelSnapshot.cs** — JAMAIS archiver, toujours à la racine de `Migrations/`
- **Designer files** — Ne pas manipuler manuellement, EF les gère automatiquement

### Archivage par Version
- **Structure** — `Migrations/v{version}/` pour versions stabilisées
- **Git history** — Utiliser `git mv` (pas `Move-Item`) pour préserver l'historique
- **Fichiers à archiver** — Seulement les `.cs` de migrations, pas le snapshot

### MSBuild Configuration
- **FastBuild mode** — Exclure migrations archivées pour accélérer la compilation dev
- **Syntaxe exclusion** — `<Compile Remove="Migrations\v{version}\**\*.cs" />`
- **Chemins MSBuild** — Utiliser `\` (backslash) pas `/`
- **Conditional build** — `<ItemGroup Condition="'$(FastBuild)' == 'true'">` pour exclusion conditionnelle

### Modes de Build
- **Dev rapide** — `dotnet build /p:FastBuild=true` (exclut anciennes migrations)
- **Dev complet** — `dotnet build` (inclut tout)
- **Production** — `dotnet build -c Release` (inclut tout, FastBuild désactivé par défaut)

### Projet Structure
- **Projet Data unique** — Pattern `*.Data.csproj` pour identifier le projet de données
- **Multi-projet** — Si plusieurs projets Data, utiliser le premier trouvé

---

## 🔧 .csproj Manipulation

### Lecture/Écriture
- **Parser XML** — Utiliser des outils XML, pas de regex sur MSBuild
- **Préserver format** — Garder indentation et structure existante
- **Commentaires** — Ajouter des commentaires explicatifs pour les configs complexes

### PropertyGroup
- **Conditional values** — `Condition="'$(Variable)' == 'value'"` pour surcharges
- **Default values** — `<Var Condition="'$(Var)' == ''">default</Var>`

### ItemGroup
- **Wildcards** — `**\*.cs` pour inclusion récursive
- **Exclusions** — `<Compile Remove="path\**\*.cs" />` pour exclure
- **Ordre** — Alphabétique/chronologique pour lisibilité

### Injection de Config
- **Placement** — Insérer après le premier `<PropertyGroup>`
- **Idempotence** — Vérifier existence avant injection
- **Update** — Compléter plutôt que remplacer si config existe déjà
