# Glyc Pro — Stack technique
## RPD-03 : Architecture, stack et infrastructure

**Version** : 1.0
**Date** : 2026-03-19
**Statut** : Valide
**Contexte** : Ce document definit la stack technique retenue pour Glyc Pro, produit successeur de PrediabAid. Il s'appuie sur la base de connaissances metier documentee dans RPD-00/01/02 et la SPEC_SYSTEME_EXPERT.

---

## Table des matieres

1. [Principes directeurs](#1-principes-directeurs)
2. [Architecture globale](#2-architecture-globale)
3. [Stack detaillee](#3-stack-detaillee)
4. [Structure du monorepo](#4-structure-du-monorepo)
5. [Moteur de regles](#5-moteur-de-regles)
6. [Solveur de menus](#6-solveur-de-menus)
7. [Workflows](#7-workflows)
8. [Modele de donnees](#8-modele-de-donnees)
9. [API](#9-api)
10. [Infrastructure](#10-infrastructure)
11. [Conformite HDS](#11-conformite-hds)
12. [Couts](#12-couts)
13. [Roadmap technique](#13-roadmap-technique)

---

## 1. Principes directeurs

| Principe | Traduction concrete |
|----------|---------------------|
| **2 langages, chacun a sa place** | Python pour la logique metier, TypeScript pour les interfaces |
| **API-first** | FastAPI genere le schema OpenAPI, le frontend consomme un client type-safe auto-genere |
| **As code** | Regles metier en JSON, infra en Python (Pulumi), workflows en Python (Inngest), schema DB en code (SQLModel + Alembic) |
| **Lean** | Pas de service supplementaire tant que le precedent ne sature pas |
| **HDS-ready** | Donnees de sante sur hebergeur certifie des le premier patient reel |

### Ce qui n'est PAS dans la V1

- React Native (PWA d'abord, native en phase 3)
- ML/scoring personnalise (phase 2+)
- Multi-langue (francais uniquement)
- Dashboard prescripteur (phase 2)

---

## 2. Architecture globale

```
┌──────────────────────────────────────────────────────────────────┐
│                          CLIENTS                                  │
│                                                                   │
│   Next.js 15 (App Router)             React Native (phase 3)     │
│   shadcn/ui + Tailwind                Expo                        │
│                                                                   │
│   ┌──────────────────────┐     ┌───────────────────────────┐     │
│   │ Lectures directes    │     │ Logique metier            │     │
│   │ → Supabase SDK       │     │ → FastAPI (openapi-ts)    │     │
│   │   (profil, menus,    │     │   (regles, solveur,       │     │
│   │    historique, RT)    │     │    bilans, coaching IA)   │     │
│   └──────────┬───────────┘     └─────────────┬─────────────┘     │
└──────────────┼───────────────────────────────┼───────────────────┘
               │                               │
      ┌────────▼─────────┐          ┌──────────▼──────────────────┐
      │    SUPABASE       │          │      FASTAPI (Python)       │
      │                   │          │                              │
      │  PostgreSQL       │◄─────────│  Moteur de regles (JSON)    │
      │  Auth (JWT)       │          │  Solveur menus (OR-Tools)   │
      │  Realtime (WS)    │          │  Bilans (pandas/numpy)      │
      │  Storage (S3)     │          │  Coaching IA (Claude SDK)   │
      │  RLS              │          │  Scoring, phases, transitions│
      └──────────────────┘          └──────────────┬──────────────┘
                                                    │
                                         ┌──────────▼─────────────┐
                                         │   INNGEST (workflows)   │
                                         │                         │
                                         │  Onboarding patient     │
                                         │  Regles quotidiennes    │
                                         │  Menus hebdomadaires    │
                                         │  Bilans periodiques     │
                                         │  Relances               │
                                         └─────────────────────────┘
```

### Qui appelle quoi

| Appelant | Cible | Quand |
|----------|-------|-------|
| Frontend | Supabase direct | Lire profil, menus, historique, daily data. Auth. Ecouter les mises a jour en temps reel |
| Frontend | FastAPI | Soumettre questionnaire, demander un nouveau menu, parler au coach IA, declencher un bilan |
| FastAPI | Supabase PG | Lire/ecrire les donnees metier apres traitement |
| FastAPI | OR-Tools | Generer un menu optimise |
| FastAPI | Anthropic | Coaching, explications, onboarding conversationnel (V2) |
| Inngest | FastAPI | Declencher les workflows (cron, events) |
| Supabase RT | Frontend | Pousser les mises a jour en temps reel (alertes, messages) |

---

## 3. Stack detaillee

### 3.1 Frontend — TypeScript

| Brique | Techno | Justification |
|--------|--------|---------------|
| Framework | **Next.js 15** (App Router) | RSC, SSR, layouts, middleware, standard |
| UI | **shadcn/ui** (Radix + Tailwind) | Composants accessibles, personnalisables, pas de runtime |
| Charts | **Recharts** | Courbes CGM, poids, compliance. Suffisant, leger |
| Client API | **openapi-ts** | Auto-genere depuis le schema FastAPI. Zero code, type-safe |
| Formulaires | **React Hook Form + Zod** | 29 types de questions, validation schema-driven |
| Emails | **React Email + Resend** | Templates en TSX, preview en dev, envoi via Resend |
| State | **Zustand** (si besoin) | Leger, pas de boilerplate. TanStack Query pour le server state |

### 3.2 Backend — Python

| Brique | Techno | Justification |
|--------|--------|---------------|
| API | **FastAPI** | Async, OpenAPI auto-genere, Pydantic natif, ecran entre le frontend et la logique metier |
| ORM | **SQLModel** | Pydantic + SQLAlchemy. Un seul modele pour la validation API et l'ORM |
| Migrations | **Alembic** | Schema as code, versionne dans git, auto-genere depuis SQLModel |
| Solveur | **OR-Tools** (Google) | Programmation lineaire pour les menus. Maintenu, documente, natif Python |
| Analyse | **pandas + numpy** | Bilans CGM (time in range, trends, stats descriptives) |
| Validation | **Pydantic v2** | Schemas d'entree/sortie, serialisation, validation |
| IA | **Anthropic SDK** | Coaching, explications, onboarding conversationnel (V2) |
| Regles | **Evaluateur custom** (~500 loc) | Charge et evalue des fichiers JSON de regles par step |

### 3.3 Services

| Service | Techno | Role |
|---------|--------|------|
| DB + Auth + Realtime + Storage | **Supabase** | CRUD, JWT, websockets, fichiers |
| Hosting frontend | **Vercel** | Next.js, edge functions, preview deploys |
| Hosting backend | **Scaleway Serverless Containers** | FastAPI conteneurise, HDS-compatible |
| Workflows | **Inngest** | Steps durables, cron, event-driven. Self-hostable si besoin |
| Emails | **Resend** | Transactionnels (bilans, alertes, relances) |
| Paiements | **Stripe** | Abonnements, webhooks, portail client |
| Analytics | **PostHog** | Funnels, retention, feature flags |
| IaC | **Pulumi (Python)** | Infra as code, meme langage que le backend |
| CI/CD | **GitHub Actions** | Tests, lint, build, deploy |

---

## 4. Structure du monorepo

```
glyc-pro/
│
├── apps/
│   ├── web/                    # Next.js 15 (dashboard praticien)
│   │   ├── app/                # App Router (pages, layouts)
│   │   ├── components/         # Composants UI
│   │   ├── lib/                # Helpers, hooks
│   │   └── generated/          # Client API auto-genere (openapi-ts)
│   │
│   └── api/                    # FastAPI
│       ├── main.py             # Entrypoint, CORS, middleware
│       ├── routers/            # Routes par domaine
│       │   ├── onboarding.py
│       │   ├── questionnaires.py
│       │   ├── program.py
│       │   ├── menus.py
│       │   ├── daily.py
│       │   ├── readings.py
│       │   ├── coach.py
│       │   ├── bilans.py
│       │   └── admin.py
│       ├── engine/             # Moteur de regles
│       │   ├── evaluator.py    # Evaluateur JSON rules
│       │   ├── context.py      # Construction du contexte patient
│       │   └── actions.py      # Executeurs d'actions
│       ├── solver/             # Solveur menus
│       │   ├── optimizer.py    # OR-Tools LP
│       │   ├── constraints.py  # Contraintes (kcal, allergies, saison)
│       │   └── scoring.py      # Scoring nutritionnel des recettes
│       ├── analysis/           # Bilans et analyse CGM
│       │   ├── cgm.py          # Time in range, trends, variabilite
│       │   ├── bilan.py        # Generation de bilans periodiques
│       │   └── stats.py        # Stats descriptives
│       ├── ai/                 # Coaching IA
│       │   ├── coach.py        # Messages personnalises, chat
│       │   ├── prompts.py      # System prompts, templates
│       │   └── safety.py       # Garde-fous medicaux
│       ├── models/             # SQLModel (DB models + Pydantic schemas)
│       │   ├── user.py
│       │   ├── subscriber.py
│       │   ├── program.py
│       │   ├── menu.py
│       │   ├── reading.py
│       │   └── bilan.py
│       ├── workflows/          # Inngest functions
│       │   ├── onboarding.py
│       │   ├── daily.py
│       │   ├── weekly_menu.py
│       │   ├── bilan.py
│       │   └── relance.py
│       ├── Dockerfile
│       └── pyproject.toml
│
├── rules/                      # Regles metier (JSON as code)
│   ├── steps/
│   │   ├── 000_init.json
│   │   ├── 010_data.json
│   │   ├── 020_questionnaires.json
│   │   ├── 030_program.json
│   │   ├── 040_newday.json
│   │   └── 050_counters.json
│   ├── formulas/
│   │   ├── F1.json
│   │   ├── F2.json
│   │   ├── F3.json
│   │   ├── F4.json
│   │   └── F5.json
│   ├── eligibility.json
│   ├── thresholds.json
│   └── scoring/
│       └── pt.json
│
├── data/                       # Donnees de reference (JSON)
│   ├── questionnaires/         # Definitions des 40+ questionnaires
│   ├── recipes/                # Base de recettes + ingredients
│   ├── content/                # Videos, messages, cours
│   └── activities/             # Activites physiques
│
├── infra/                      # Pulumi (Python)
│   ├── __main__.py             # Stack principale
│   ├── database.py             # PostgreSQL Scaleway
│   ├── containers.py           # Serverless Containers (FastAPI)
│   ├── dns.py                  # DNS, certificats
│   └── Pulumi.yaml
│
├── .github/
│   └── workflows/
│       ├── api.yml             # Test + deploy FastAPI
│       ├── web.yml             # Test + deploy Next.js (Vercel)
│       └── infra.yml           # Pulumi preview/up
│
├── docker-compose.yml          # Dev local (PG + API)
├── turbo.json                  # Turborepo config
└── package.json                # Workspace root
```

### Pourquoi Turborepo

Le monorepo contient du Python (api, infra) et du TypeScript (web). Turborepo orchestre les taches (`build`, `lint`, `test`, `generate`) avec cache et parallelisme. Les dependances entre apps sont explicites :

```
web:generate  →  depend de  →  api:openapi
web:build     →  depend de  →  web:generate
api:test      →  depend de  →  rules/*.json
```

---

## 5. Moteur de regles

### 5.1 Pourquoi pas Drools, pas json-rules-engine

Le legacy utilisait Drools 5.6 (Java) avec chainage avant RETE. En analysant les 430 regles, la majorite sont des **conditions → actions** sans chainage complexe. Le RETE etait overkill.

Un evaluateur custom en Python (~500 lignes) couvre 100% des cas :
- Charge les regles par step (000_init → 050_counters)
- Evalue les conditions contre un contexte patient
- Execute les actions dans l'ordre de priorite
- Pas de chainage : chaque step est independant

### 5.2 Format des regles

```json
{
  "id": "glycemie_alerte_diabete",
  "step": "040_newday",
  "priority": 10,
  "description": "Glycemie >= 126 mg/dL pendant 2 jours consecutifs",
  "conditions": {
    "all": [
      { "fact": "glycemie_today", "operator": ">=", "value": 126 },
      { "fact": "glycemie_yesterday", "operator": ">=", "value": 126 }
    ]
  },
  "actions": [
    { "type": "add_video", "value": "video.tr.diabetique_ignore" },
    { "type": "add_message", "severity": "ALERT", "key": "msg.alerte.glycemie_haute" },
    { "type": "trigger_pause", "reason": "glycemie_diabete" }
  ]
}
```

### 5.3 Operateurs supportes

| Operateur | Description | Exemple |
|-----------|-------------|---------|
| `==`, `!=` | Egalite | `"fact": "group_id", "operator": "==", "value": "G2"` |
| `>`, `>=`, `<`, `<=` | Comparaison | `"fact": "bmi", "operator": ">=", "value": 25` |
| `in`, `not_in` | Appartenance | `"fact": "formula_id", "operator": "in", "value": ["F1","F2","F3"]` |
| `exists`, `not_exists` | Presence | `"fact": "glycemie_today", "operator": "exists"` |
| `between` | Intervalle | `"fact": "age", "operator": "between", "value": [18, 45]` |
| `days_since` | Ecart temporel | `"fact": "last_sport_date", "operator": "days_since", "value": { ">=": 3 }` |

### 5.4 Combinateurs

```json
{
  "all": [ ... ]     // ET logique
  "any": [ ... ]     // OU logique
  "none": [ ... ]    // AUCUN (NOR)
}
```

Imbrication possible :

```json
{
  "all": [
    { "fact": "phase", "operator": "==", "value": "INTENSIVE" },
    { "any": [
      { "fact": "weight_delta_pct", "operator": "<=", "value": -5 },
      { "fact": "phase_day", "operator": ">=", "value": 42 }
    ]}
  ]
}
```

### 5.5 Types d'actions

| Type | Parametres | Effet |
|------|-----------|-------|
| `add_video` | `value` (video ID) | Ajoute une video au DayData |
| `add_message` | `severity`, `key` | Ajoute un message (INFO, WARNING, ALERT) |
| `set_field` | `target`, `key`, `value` | Modifie un champ du contexte |
| `increment_counter` | `counter_id`, `amount` | Incremente un compteur |
| `trigger_pause` | `reason` | Met le programme en pause |
| `transition_phase` | `target_phase` | Force une transition de phase |
| `trigger_workflow` | `workflow_id`, `data` | Declenche un workflow Inngest |

### 5.6 Pipeline d'execution

```
Evenement (soumission questionnaire, cron quotidien, mesure)
    │
    ▼
1. Construction du contexte
   - Profil patient (subscriber)
   - Phase courante, jour dans la phase
   - Mesures recentes (glycemie, poids)
   - Reponses questionnaires du jour
   - Compteurs
   - Historique recent (7 jours)
    │
    ▼
2. Chargement des regles par step
   000_init → 010_data → 020_questionnaires → 030_program → 040_newday → 050_counters
    │
    ▼
3. Pour chaque step, par ordre de priorite :
   - Evaluer les conditions contre le contexte
   - Si match → executer les actions
   - Les actions peuvent modifier le contexte (cascade intra-step)
    │
    ▼
4. Persister les changements
   - DayData (videos, messages)
   - Subscriber (poids, phase, flags)
   - Compteurs
   - Evenements Inngest (si trigger_workflow)
```

---

## 6. Solveur de menus

### 6.1 Probleme

Generer un menu de 7 jours (5 repas/jour = 35 repas) qui respecte simultanement :
- Budget calorique quotidien (variable par phase)
- Equilibre nutritionnel (classes d'aliments)
- Contraintes alimentaires (casher, halal, vegetarien, sans gluten)
- Saisonnalite des ingredients
- Variete (pas 2x la meme recette par semaine)
- Score nutritionnel des recettes

C'est un probleme d'**optimisation sous contraintes** resolu par programmation lineaire.

### 6.2 Implémentation OR-Tools

```python
# solver/optimizer.py (schema simplifie)

from ortools.linear_solver import pywraplp

def generate_weekly_menu(
    recipes: list[Recipe],
    target_kcal: int,
    constraints: MenuConstraints,
    preferences: UserPreferences,
) -> WeeklyMenu:

    solver = pywraplp.Solver.CreateSolver("GLOP")

    # Variables : x[r][d][m] = 1 si recette r au jour d au repas m
    x = {}
    for r in recipes:
        for d in range(7):
            for m in MEAL_TYPES:
                x[r.id, d, m] = solver.BoolVar(f"x_{r.id}_{d}_{m}")

    # Contrainte : exactement 1 recette par (jour, repas)
    for d in range(7):
        for m in MEAL_TYPES:
            solver.Add(sum(x[r.id, d, m] for r in recipes) == 1)

    # Contrainte : budget calorique quotidien (marge +-10%)
    for d in range(7):
        daily_kcal = sum(
            r.kcal * x[r.id, d, m]
            for r in recipes for m in MEAL_TYPES
        )
        solver.Add(daily_kcal >= target_kcal * 0.9)
        solver.Add(daily_kcal <= target_kcal * 1.1)

    # Contrainte : variete (max 1 occurrence par recette par semaine)
    for r in recipes:
        solver.Add(
            sum(x[r.id, d, m] for d in range(7) for m in MEAL_TYPES) <= 1
        )

    # Contrainte : allergies / regime
    for r in recipes:
        if not r.matches(constraints):
            for d in range(7):
                for m in MEAL_TYPES:
                    solver.Add(x[r.id, d, m] == 0)

    # Objectif : maximiser le score nutritionnel + saisonnalite
    objective = sum(
        r.nutrition_score * x[r.id, d, m]
        for r in recipes for d in range(7) for m in MEAL_TYPES
    )
    solver.Maximize(objective)

    status = solver.Solve()
    # ... extraction du resultat
```

### 6.3 Ratio calorique par phase

Le budget calorique est module par la phase en cours :

| Phase | Ratio | Exemple (base 2000 kcal) |
|-------|-------|--------------------------|
| CARNET | 1.0 | 2000 |
| DETOX | 0.9 | 1800 |
| PVBF | 0.9 | 1800 |
| INTENSIVE | 0.8 | 1600 |
| PROGRESSIVE | 1.0 | 2000 |
| INTENSIVE_2 | 0.8 | 1600 |
| PROGRESSIVE_2 | 1.0 | 2000 |
| STABILISATION | 1.0 | 2000 |

---

## 7. Workflows

### 7.1 Pourquoi Inngest

| Critere | Inngest | Temporal | BullMQ |
|---------|---------|----------|--------|
| Infra requise | Aucune (managed) | Self-host ou Cloud | Redis |
| SDK Python | Oui | Oui | Non |
| Steps durables | Oui | Oui | Non |
| Cron | Oui | Oui | Oui |
| Cout < 5000 patients | Gratuit | ~100$/mois | Redis ~20$ |
| Self-hostable | Oui (fallback) | Oui | Oui |
| Migration si scale | → Temporal | — | — |

Inngest couvre les besoins V1. Migration vers Temporal en phase 4 si necessaire.

### 7.2 Workflows cles

#### Onboarding

```
Declencheur : user.created

1. [send_welcome_email]     Envoyer email de bienvenue
2. [wait_for_pt]            Attendre completion questionnaire PT (timeout: 7j)
   └── timeout → [relance_pt] Email de rappel, reprendre attente (max 2 relances)
3. [compute_eligibility]    Scorer le PT → Groupe → Formule
4. [init_program]           Creer le programme + phases
5. [wait_for_bs]            Attendre questionnaire sport BS (timeout: 3j)
6. [generate_first_menu]    Generer le premier menu hebdo
7. [send_program_ready]     Notifier le patient que tout est pret
```

#### Quotidien

```
Declencheur : cron "0 6 * * *" (chaque jour a 6h)

Pour chaque patient actif :
1. [load_context]           Charger profil + phase + historique
2. [evaluate_rules]         Executer le pipeline de regles (steps 000-050)
3. [check_phase_transition] Verifier si la phase doit changer
4. [generate_daily_data]    Creer le DayData (videos, messages, rappels)
5. [send_notification]      Push / email si contenu important
```

#### Menu hebdomadaire

```
Declencheur : cron "0 2 * * 1" (chaque lundi a 2h)

Pour chaque patient actif :
1. [load_profile]           Charger profil + phase + contraintes
2. [compute_target_kcal]    Budget calorique selon la phase
3. [run_solver]             OR-Tools → menu optimal 7 jours
4. [save_menu]              Persister dans weekly_menus
5. [notify_patient]         Notifier que le menu est disponible
```

#### Bilan periodique

```
Declencheur : cron "0 8 * * 1" (chaque lundi a 8h)
Condition : patient a >= 7 jours de donnees depuis le dernier bilan

1. [collect_data]           Glycemie, poids, sport, compliance menus (7 derniers jours)
2. [analyze]                Stats descriptives, trends, time in range, deltas
3. [generate_bilan]         Template-based ou LLM selon le type de bilan
4. [save_bilan]             Persister dans bilans
5. [notify_patient]         Email + push avec le resume
6. [notify_practitioner]    Si alertes, notifier le praticien (phase 2)
```

#### Relances

```
Declencheur : event "patient.inactive" (pas de connexion depuis 3j)

1. [send_reminder_1]        Email doux ("On ne vous a pas vu...")
2. [wait_3_days]            sleep(3j)
3. [check_activity]         Le patient est-il revenu ?
   └── oui → fin
   └── non → continuer
4. [send_reminder_2]        Email + push ("Votre programme vous attend")
5. [wait_4_days]            sleep(4j)
6. [check_activity]         Revenu ?
   └── oui → fin
   └── non → [alert_practitioner] Notifier le praticien (phase 2)
```

---

## 8. Modele de donnees

### 8.1 Schema principal

Tables heritees du cahier des charges RPD-01, adaptees a SQLModel :

```python
# models/subscriber.py

class Subscriber(SQLModel, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    user_id: uuid.UUID = Field(foreign_key="users.id")

    # Identite
    sex: str | None = Field(max_length=1, regex="^[MF]$")
    birth_date: date | None
    country: str | None = Field(max_length=2)

    # Mesures
    weight_kg: Decimal | None = Field(max_digits=5, decimal_places=2)
    height_m: Decimal | None = Field(max_digits=3, decimal_places=2)
    bmi: Decimal | None = Field(max_digits=4, decimal_places=1)
    morphology: str | None  # NORMAL, FINE, LARGE

    # Classification
    group_id: str | None     # G1, G2, G3
    sport_group_id: str | None  # GS1-GS4
    formula_id: str | None   # F1-F5, NON_COACHABLE

    # Poids cibles
    ideal_weight_kg: Decimal | None
    health_weight_kg: Decimal | None

    # Preferences alimentaires
    is_kosher: bool = False
    is_halal: bool = False
    is_vegetarian: bool = False
    is_gluten_free: bool = False
```

### 8.2 Tables

| Table | Role | Champs cles |
|-------|------|-------------|
| `users` | Compte utilisateur | email, password_hash, role (patient/practitioner/admin) |
| `subscribers` | Profil sante | sexe, age, IMC, groupe, formule, poids cibles, preferences alimentaires |
| `programs` | Programme du patient | formula_id, start_date |
| `program_phases` | Phases du programme | phase_id, type, start/end_date, duration, behavior, is_current |
| `sport_phases` | Phases sportives | sessions/week, duration, level_min/max |
| `questionnaire_responses` | Reponses | questionnaire_id, date_key, responses (JSONB), score |
| `readings` | Mesures biometriques | type (Glycemy/Kilograms/...), value, unit, date, source |
| `daily_data` | Donnees quotidiennes | date_key, videos (JSONB), messages (JSONB), reminders (JSONB) |
| `weekly_menus` | Menus generes | week_start, target_kcal, phase_ratio, menus (JSONB) |
| `counters` | Compteurs metier | counter_id, value |
| `video_views` | Videos vues | video_id, view_count |
| `connected_devices` | Appareils appairies | device_type, serial_number, unit |
| `subscriptions` | Abonnements | plan, status, stripe_subscription_id |
| `bilans` | Bilans periodiques | period_start, period_end, type, data (JSONB), status |
| `events` | Feedback loop (V2) | event_type, data (JSONB) |

### 8.3 Table bilans (nouveau, absent de RPD-01)

```python
class Bilan(SQLModel, table=True):
    id: uuid.UUID = Field(default_factory=uuid.uuid4, primary_key=True)
    subscriber_id: uuid.UUID = Field(foreign_key="subscribers.id")
    period_start: date
    period_end: date
    bilan_type: str           # weekly, monthly, phase_end, program_end
    status: str = "draft"     # draft, validated, sent

    # Donnees analysees
    data: dict = Field(sa_column=Column(JSONB))
    # {
    #   "glycemia": { "mean": 102, "min": 88, "max": 118, "trend": -0.3, "time_in_range_pct": 82 },
    #   "weight": { "start": 84.2, "end": 83.5, "delta_kg": -0.7, "delta_pct": -0.83 },
    #   "compliance": { "menus_followed_pct": 78, "sport_sessions": 3, "sport_target": 4 },
    #   "phase": { "current": "PROGRESSIVE", "day": 18, "total": 28 },
    #   "alerts": [ { "type": "glycemia_high", "count": 2, "dates": ["2026-03-12", "2026-03-15"] } ]
    # }

    # Resume genere (template ou LLM)
    summary_text: str | None
    generated_by: str         # template, llm

    created_at: datetime = Field(default_factory=datetime.utcnow)
```

---

## 9. API

### 9.1 Principes

- **OpenAPI auto-genere** par FastAPI. Le frontend genere un client type-safe avec `openapi-ts`.
- **Versioning** : `/api/v1/...`
- **Auth** : JWT Supabase. FastAPI valide le token et extrait le `user_id`.
- **Erreurs metier** : HTTP 422 avec un corps structure `{ "code": "NOT_ELIGIBLE", "detail": "..." }`.

### 9.2 Endpoints

| Module | Methode | Endpoint | Description |
|--------|---------|----------|-------------|
| **Onboarding** | POST | `/api/v1/onboarding/pt` | Soumettre le questionnaire PT |
| | GET | `/api/v1/onboarding/pt/result` | Resultat (groupe, formule, videos) |
| | POST | `/api/v1/onboarding/bs` | Soumettre le questionnaire sport |
| **Programme** | GET | `/api/v1/program` | Programme complet (phases, dates, progression) |
| | GET | `/api/v1/program/phase` | Phase courante |
| | POST | `/api/v1/program/pause` | Mettre en pause |
| | POST | `/api/v1/program/resume` | Reprendre |
| **Quotidien** | GET | `/api/v1/daily/{date}` | DayData (videos, messages, resume) |
| | GET | `/api/v1/daily/{date}/questionnaires` | Questionnaires a remplir |
| | POST | `/api/v1/daily/{date}/questionnaires/{id}` | Soumettre reponses → declenche regles |
| **Menus** | GET | `/api/v1/menus/current` | Menu de la semaine |
| | GET | `/api/v1/menus/{week}` | Menu d'une semaine donnee |
| | POST | `/api/v1/menus/substitute` | Substituer une recette |
| | POST | `/api/v1/menus/regenerate` | Regenerer le menu de la semaine |
| **Mesures** | POST | `/api/v1/readings` | Enregistrer une mesure (glycemie, poids) |
| | GET | `/api/v1/readings?type=glycemia&period=7d` | Historique filtre |
| **Bilans** | GET | `/api/v1/bilans` | Liste des bilans |
| | GET | `/api/v1/bilans/{id}` | Detail d'un bilan |
| | POST | `/api/v1/bilans/generate` | Forcer la generation d'un bilan |
| **Coach IA** | POST | `/api/v1/coach/message` | Envoyer un message au coach |
| | GET | `/api/v1/coach/daily-insight` | Insight personnalise du jour |
| | GET | `/api/v1/coach/history` | Historique de conversation |
| **Charts** | GET | `/api/v1/charts/glycemia?period=7d` | Donnees graphique glycemie |
| | GET | `/api/v1/charts/weight?period=30d` | Donnees graphique poids |
| | GET | `/api/v1/charts/activity?period=4w` | Donnees graphique activite |
| | GET | `/api/v1/charts/compliance?period=30d` | Compliance menus |
| **Content** | GET | `/api/v1/content/videos` | Videos disponibles |
| | POST | `/api/v1/content/videos/{id}/view` | Marquer comme vue |
| | GET | `/api/v1/content/courses` | Cours educatifs (CDC) |
| **Devices** | POST | `/api/v1/devices` | Enregistrer un appareil |
| | GET | `/api/v1/devices` | Appareils appairies |
| | POST | `/api/v1/devices/{id}/sync` | Synchroniser les mesures |
| **Subscriptions** | GET | `/api/v1/subscriptions/current` | Abonnement actuel |
| | POST | `/api/v1/subscriptions/checkout` | Creer une session Stripe |
| | POST | `/api/v1/subscriptions/webhook` | Webhook Stripe |
| **Admin** | GET | `/api/v1/admin/users` | Liste des utilisateurs |
| | GET | `/api/v1/admin/users/{id}` | Detail utilisateur |
| | GET | `/api/v1/admin/stats` | Statistiques globales |

### 9.3 Headers

```
Authorization: Bearer <supabase_jwt>
Content-Type: application/json
Accept-Language: fr
X-Timezone: Europe/Paris
```

### 9.4 Pont OpenAPI → client TypeScript

```bash
# Generation automatique apres chaque changement d'API
cd apps/api && python -c "import json; from main import app; print(json.dumps(app.openapi()))" > openapi.json
cd apps/web && npx openapi-ts ../api/openapi.json -o ./generated/api.ts
```

Integre dans le pipeline Turborepo : `api:openapi` → `web:generate` → `web:build`.

---

## 10. Infrastructure

### 10.1 Pulumi — stack

```python
# infra/__main__.py

import pulumi
import pulumi_scaleway as scaleway
import pulumi_vercel as vercel

config = pulumi.Config()
env = pulumi.get_stack()  # dev, staging, prod

# --- PostgreSQL (Scaleway, HDS-eligible) ---
db = scaleway.DatabaseInstance(
    f"glycpro-db-{env}",
    engine="PostgreSQL-16",
    node_type="DB-DEV-S",        # dev: petit, prod: DB-GP-XS
    volume_size_in_gb=10,
    is_ha_cluster=env == "prod",  # HA en prod uniquement
)

db_user = scaleway.DatabaseUser(f"glycpro-user-{env}", ...)
db_name = scaleway.DatabaseDb(f"glycpro-{env}", ...)

# --- FastAPI (Scaleway Serverless Container) ---
api_namespace = scaleway.ContainerNamespace(f"glycpro-api-{env}")

api_container = scaleway.Container(
    f"glycpro-api-{env}",
    namespace_id=api_namespace.id,
    registry_image=f"rg.fr-par.scw.cloud/glycpro/api:{env}",
    min_scale=1 if env == "prod" else 0,
    max_scale=5,
    memory_limit=512,
    cpu_limit=1000,
    environment_variables={
        "DATABASE_URL": db.endpoint_ip.apply(lambda ip: f"postgresql://..."),
        "SUPABASE_URL": config.require("supabase_url"),
        "SUPABASE_SERVICE_KEY": config.require_secret("supabase_service_key"),
        "ANTHROPIC_API_KEY": config.require_secret("anthropic_api_key"),
        "INNGEST_EVENT_KEY": config.require_secret("inngest_event_key"),
        "STRIPE_SECRET_KEY": config.require_secret("stripe_secret_key"),
    },
)

# --- DNS ---
api_domain = scaleway.DomainRecord(
    f"api-{env}",
    dns_zone="glycpro.app",
    name="api" if env == "prod" else f"api-{env}",
    type="CNAME",
    data=api_container.domain_name,
)

# --- Outputs ---
pulumi.export("api_url", api_container.domain_name)
pulumi.export("db_endpoint", db.endpoint_ip)
```

### 10.2 Environnements

| Env | DB | API | Frontend | Usage |
|-----|----|----|----------|-------|
| `dev` | Supabase local (docker) | `uvicorn --reload` | `next dev` | Developpement local |
| `staging` | Scaleway DB-DEV-S | Scaleway Container (min_scale=0) | Vercel Preview | Tests, demos |
| `prod` | Scaleway DB-GP-XS (HA) | Scaleway Container (min_scale=1) | Vercel Production | Production |

### 10.3 CI/CD (GitHub Actions)

```
Push sur main
    │
    ├── jobs.api:
    │   1. pytest (rules + API)
    │   2. docker build + push → Scaleway Registry
    │   3. pulumi up (met a jour le container)
    │
    ├── jobs.web:
    │   1. generate (openapi-ts)
    │   2. build + lint
    │   3. deploy → Vercel (auto via integration)
    │
    └── jobs.infra:
        1. pulumi preview
        2. pulumi up (si main)
```

---

## 11. Conformite HDS

Les donnees de glycemie, poids, et profil sante des patients sont des **donnees de sante a caractere personnel** (article L.1111-8 du Code de la sante publique). Leur hebergement en France necessite un hebergeur **certifie HDS**.

### Strategie

| Composant | Hebergeur | HDS ? | Donnees sensibles ? |
|-----------|-----------|-------|---------------------|
| PostgreSQL (donnees sante) | **Scaleway** | **Oui** (certifie HDS) | Oui — glycemie, poids, profil medical |
| FastAPI (backend) | **Scaleway** | **Oui** | Transite par les donnees, pas de stockage |
| Supabase Auth | **Supabase Cloud** | Non | Non — email + JWT, pas de donnees medicales |
| Supabase Realtime | **Supabase Cloud** | Non | Non — notifications, pas de donnees brutes |
| Supabase Storage | **Scaleway S3** (redirige) | **Oui** | Oui si documents medicaux |
| Next.js frontend | **Vercel** | Non | Non — rendu, pas de stockage |

### Regles

1. **Aucune donnee de sante dans Supabase Cloud.** Supabase est utilise uniquement pour l'auth (email/JWT) et le realtime (notifications sans donnees brutes).
2. **Toutes les donnees medicales dans PostgreSQL Scaleway** (certifie HDS).
3. FastAPI se connecte directement a PostgreSQL Scaleway, pas via Supabase.
4. Les tokens JWT Supabase sont utilises pour l'authentification, mais FastAPI valide et extrait le `user_id` pour requeter la DB Scaleway.

---

## 12. Couts

### Phase 1 — Launch (< 50 patients)

| Service | Cout mensuel |
|---------|-------------|
| Scaleway DB-DEV-S (PostgreSQL) | 12 EUR |
| Scaleway Serverless Container | 5-15 EUR |
| Vercel Pro | 20 USD |
| Supabase Pro (auth + realtime) | 25 USD |
| Inngest | 0 USD (free tier) |
| Resend | 0 USD (free tier) |
| Anthropic (Claude) | 10-20 USD |
| Stripe | 0 USD fixe (% par transaction) |
| PostHog | 0 USD (free tier) |
| Pulumi | 0 USD (free tier individual) |
| **Total** | **~75-95 USD/mois** |

### Phase 3 — Scale (500-5000 patients)

| Service | Cout mensuel estime |
|---------|---------------------|
| Scaleway DB-GP-XS (HA) | 80 EUR |
| Scaleway Containers (x3) | 50-100 EUR |
| Vercel Pro | 20 USD |
| Supabase Pro | 25 USD |
| Inngest Pro | 50 USD |
| Resend Starter | 20 USD |
| Anthropic | 100-500 USD |
| **Total** | **~350-800 USD/mois** |

---

## 13. Roadmap technique

| Phase | Milestone | Ajouts a la stack |
|-------|-----------|-------------------|
| **1 — Launch** | 0-50 praticiens | Stack decrite dans ce document |
| **2 — Traction** | 50-500 | Portail patient (2e app Next.js dans le monorepo), Cal.com, dashboard prescripteur |
| **3 — Scale** | 500-5000 | React Native (Expo) pour les patients, ML pipeline (scikit-learn), CGM APIs directes (Dexcom, LibreView) |
| **4 — Enterprise** | 5000+ | Temporal (remplace Inngest), Supabase self-hosted sur Scaleway, pgvector pour recommandations, monitoring avance (Grafana) |

---

*Ce document est la reference technique. La logique metier detaillee (regles, formules, questionnaires) reste dans SPEC_SYSTEME_EXPERT et RPD-01/02.*
