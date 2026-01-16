# GitHub Copilot : Guide Pratique pour Équipes

> **Objectif** : Maximiser la productivité avec GitHub Copilot en maîtrisant les agents, le contexte et les commandes personnalisées.

---

## 🎯 Les 3 Piliers

### 1. Agents (`@`) — Cibler le Bon Contexte

| Agent | Usage | Exemple |
|-------|-------|----------|
| `@workspace` | Recherche sémantique dans le code | `@workspace Trouve SaveOrder` |
| `@terminal` | Analyse erreurs shell | `@terminal Pourquoi la compile échoue ?` |
| `@github` | Issues, PRs, commits | `@github Implémente feature #1234` |

**💡 Astuce** : Combiner les agents → `@workspace @terminal Analyse l'erreur`

---

### 2. Contexte — Économiser 70-95% de Tokens 💰

**Le Problème** : Fichiers auto-ajoutés (chips) = 1000-3000 tokens

**La Solution** :

```
❌ [server.ts] "Optimise le code" → 2000 tokens
✅ "@workspace Optimise handleSubmit dans server.ts" → 300 tokens
```

**4 Règles d'Or** :
1. **Retirez les chips inutiles** (texte normal = consomme des tokens)
2. **@workspace > Add Context** (recherche ciblée vs fichier entier)
3. **Texte > Screenshot** (50 tokens vs 1500-3000)
4. **Soyez précis** : "Trouve SaveOrder dans OrderService" vs "Regarde le code"

**Impact** : Économie de **70-95%** sur grandes requêtes 🎯

### 3. Slash Commands — Automatiser Vos Workflows

**Concept** : Créer des commandes réutilisables en fichiers `.md`

**Exemple** : `/commit` analyse le code et génère un message conforme

```markdown
# .github/github-copilot-cmd/commit.md

## Workflow
1. Lire best-practices.md (conventions)
2. Analyser git diff
3. Générer message : type(scope): description
```

**Commandes Disponibles** :
- `/commit` — Message de commit conforme
- `/doc` — Agrège CHANGENOTES en CHANGELOG
- `/clean-migrations` — Archive migrations EF par version
- `/create-cmd` — Génère une nouvelle commande

**💡 Méta-Commandes** : Pas de chaînage natif (`/commit && /doc` ❌), mais créer `/release` qui exécute les deux ✅

---

## 🎯 Fichier `.github/copilot-instructions.md` — Le Cerveau de Votre Projet

### Qu'est-ce que c'est ?

Un fichier de configuration qui **injecte automatiquement des instructions** dans **CHAQUE requête** Copilot de votre projet.

**Analogie** : C'est comme un `.editorconfig` mais pour Copilot → règles appliquées automatiquement sans avoir à les répéter.

### Comment ça marche ?

```
Votre projet/
  .github/
    copilot-instructions.md  ← Copilot lit ce fichier automatiquement
    github-copilot-cmd/      ← Vos slash commands
      commit.md
      doc.md
```

**Activation** : Automatique dès que le fichier existe dans `.github/`

### Que mettre dedans ?

#### 1️⃣ Système de Dispatch (Slash Commands)

```markdown
## Système de Dispatch

Quand l'utilisateur tape `/command`, tu DOIS :
1. Lire `.github/github-copilot-cmd/command.md`
2. Exécuter les instructions comme si c'était ton prompt principal
```

→ Permet de créer des commandes personnalisées (`/commit`, `/doc`, etc.)

#### 2️⃣ Règles Globales de Workflow

```markdown
## Règles Globales

- Validation des prérequis avant exécution
- Pas d'interactif (aucune commande demandant saisie utilisateur)
- Exit silencieux si rien à faire
- Messages concis, pas de verbose
```

→ Copilot respecte ces règles sur **toutes** vos interactions

#### 3️⃣ Optimisations Automatiques

```markdown
## Optimisation de Workflow

### Gestion du Contexte
- Privilégier @workspace ciblé (300-500 tokens)
- Éviter les chips automatiques (1000-3000 tokens)

### Batch Operations
- Lire plusieurs fichiers en parallèle
- Utiliser multi_replace_string_in_file
```

→ **70-95% d'économie de tokens** appliqué automatiquement

#### 4️⃣ Conventions Projet

```markdown
## Conventions C#

- Tous les Services héritent de BaseService
- DTOs dans /Models/Dtos
- Pas de logique métier dans les Controllers
```

→ Copilot génère du code conforme à vos standards **sans avoir à le rappeler**

### Avantages vs Instructions Manuelles

| Approche | Répétition | Cohérence | Onboarding |
|----------|------------|-----------|------------|
| **Instructions manuelles** | ❌ Répéter à chaque fois | 🟡 Variable | 🔴 Difficile |
| **copilot-instructions.md** | ✅ Automatique | ✅ 100% | ✅ Immédiat |

### Exemple Concret : Avant/Après

**❌ Avant (sans copilot-instructions.md)** :
```
Vous : "Crée un service ProductService"
Copilot : Génère du code générique (pas conforme à vos conventions)
Vous : "Non, hérite de BaseService et ajoute le logging"
Copilot : Corrige
Vous : "Ajoute les DTOs dans Models/Dtos"
Copilot : Corrige à nouveau
```
→ 3 allers-retours, verbeux

**✅ Après (avec copilot-instructions.md)** :
```
Vous : "Crée un service ProductService"
Copilot : Génère directement :
  - Hérite de BaseService
  - Logging configuré
  - DTOs dans Models/Dtos
  - Conforme à toutes vos conventions
```
→ 1 seule requête, parfait du premier coup

### 🚀 Impact sur l'Équipe

**Productivité** :
- ⚡ 3-5x moins d'allers-retours
- 💰 70-95% moins de tokens consommés
- 🎯 Code conforme dès la génération

**Qualité** :
- ✅ Standards uniformes (tout le monde génère du code conforme)
- 📚 Conventions documentées et appliquées automatiquement
- 🛡️ Réduction des code reviews (conventions respectées)

**Onboarding** :
- 🆕 Nouveaux devs productifs immédiatement
- 📖 Documentation vivante (instructions = code généré)
- 🔄 Évolution centralisée (modifier 1 fichier = tout le monde suit)

### 📝 Best Practices

1. **Versionnez-le** : Committer dans Git, suivre les évolutions
2. **Documentez par domaine** : Séparer backend, frontend, infra
3. **Itérez** : Enrichir au fur et à mesure des besoins
4. **Partagez** : Commun à toute l'équipe via le repo

### 🎯 Résumé

> **copilot-instructions.md = Pilote automatique pour votre projet**
> 
> - Appliqué **automatiquement** sur chaque requête
> - Économie massive de temps et tokens
> - Code conforme aux standards sans effort
> - Onboarding instantané des nouveaux devs

---

## 📋 Patterns pour Commandes Avancées

### Best Practices Centralisées

Centraliser les règles communes pour éviter la duplication :

```
.github/
  best-practices.md          → Règles partagées
  github-copilot-cmd/
    commit.md               → Lit best-practices.md
    doc.md                  → Lit best-practices.md
```

**Exemple** :
```markdown
## Workflow dans /commit.md
1. **Lire** `.github/best-practices.md`
2. Analyser git diff
3. Générer message conforme
```

### Patterns d'Exécution

**Chain-of-Thought** :
```markdown
1. ANALYSER → Lire fichiers concernés
2. PLANIFIER → Lister les étapes
3. EXÉCUTER → Appliquer changements
4. VÉRIFIER → Relire et valider
```

**Validation Incrémentale** :
```markdown
- Relire après chaque modification
- Corriger immédiatement si erreur
- Ne pas continuer tant qu'il y a des erreurs
```

**Few-Shot Learning** : Fournir 2-3 exemples dans la commande
**Batch Operations** : Collecter tous les changements → Appliquer en 1 batch

---

## 🛠️ Exemples de Commandes Utiles

### Code Review
```markdown
# /review
1. Lire git diff
2. Vérifier conventions + code smells
3. Générer rapport (🔴 Issues, 🟡 Suggestions, ✅ Bonnes pratiques)
```

### Security Check
```markdown
# /security-check
Détecter : secrets en dur, injections SQL, XSS, CORS mal configuré
```

### Architecture Analyzer
```markdown
# /analyze-architecture
Vérifier : Controllers dans /Controllers, Services ne ref pas Controllers, etc.
```

---

## 🎓 Ressources

- 📖 [Prompt Engineering (Anthropic)](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)
- 📖 [OpenAI Prompt Engineering](https://platform.openai.com/docs/guides/prompt-engineering)
- 📖 [GitHub Copilot Docs](https://docs.github.com/copilot)

---

**Dernière MAJ** : Janvier 2026
