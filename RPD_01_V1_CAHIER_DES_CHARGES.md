# PrediabAid V1 — Cahier des charges MVP
## RPD-01 : Spécifications fonctionnelles et techniques

**Version** : 1.0
**Date** : 2026-03-17
**Statut** : Draft
**Objectif** : Reconstruire 100% de la logique métier existante avec un stack moderne.

---

## Table des matières

1. [Module 1 : Authentification & Gestion utilisateur](#module-1--authentification--gestion-utilisateur)
2. [Module 2 : Onboarding & Profiling](#module-2--onboarding--profiling)
3. [Module 3 : Moteur de règles](#module-3--moteur-de-règles)
4. [Module 4 : Programme & Phases](#module-4--programme--phases)
5. [Module 5 : Menus & Nutrition](#module-5--menus--nutrition)
6. [Module 6 : Suivi quotidien](#module-6--suivi-quotidien)
7. [Module 7 : Objets connectés](#module-7--objets-connectés)
8. [Module 8 : Contenu (Vidéos, Messages, Cours)](#module-8--contenu)
9. [Module 9 : Notifications & Rappels](#module-9--notifications--rappels)
10. [Module 10 : Admin](#module-10--admin)
11. [Module 11 : Abonnement & Paiement](#module-11--abonnement--paiement)
12. [Architecture technique](#architecture-technique)
13. [Modèle de données](#modèle-de-données)
14. [API Reference](#api-reference)

---

## Module 1 : Authentification & Gestion utilisateur

### 1.1 User Stories

| ID | Story | Priorité |
|----|-------|----------|
| AUTH-01 | En tant qu'utilisateur, je peux créer un compte avec email + mot de passe | P0 |
| AUTH-02 | En tant qu'utilisateur, je peux me connecter avec mes identifiants | P0 |
| AUTH-03 | En tant qu'utilisateur, je peux réinitialiser mon mot de passe | P0 |
| AUTH-04 | En tant qu'utilisateur, je peux protéger l'app avec un code PIN | P1 |
| AUTH-05 | En tant qu'utilisateur, je peux modifier mon profil (nom, email, téléphone) | P1 |
| AUTH-06 | En tant qu'utilisateur, je peux supprimer mon compte (RGPD) | P0 |

### 1.2 Spécifications fonctionnelles

#### Inscription
- Champs : email (unique), mot de passe (min 8 chars, 1 majuscule, 1 chiffre), prénom, nom
- Validation email par lien de confirmation
- Création automatique du profil Abonné vide

#### Connexion
- Email + mot de passe → JWT access token (15 min) + refresh token (30 jours)
- Stockage sécurisé du token (Keychain iOS, Keystore Android)
- Session persistante tant que refresh token valide

#### Sécurité
- Rate limiting : 5 tentatives/minute par IP
- Tokens JWT signés (RS256)
- Refresh token rotation
- Logout = invalidation du refresh token

### 1.3 API Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/api/v1/auth/register` | Inscription |
| POST | `/api/v1/auth/login` | Connexion |
| POST | `/api/v1/auth/refresh` | Rafraîchir le token |
| POST | `/api/v1/auth/logout` | Déconnexion |
| POST | `/api/v1/auth/forgot-password` | Demande reset mot de passe |
| POST | `/api/v1/auth/reset-password` | Reset avec token |
| GET | `/api/v1/users/me` | Profil courant |
| PATCH | `/api/v1/users/me` | Modifier profil |
| DELETE | `/api/v1/users/me` | Supprimer compte |

---

## Module 2 : Onboarding & Profiling

### 2.1 User Stories

| ID | Story | Priorité |
|----|-------|----------|
| ONB-01 | En tant que nouvel utilisateur, je peux remplir le questionnaire PT pour évaluer mon risque | P0 |
| ONB-02 | En tant que nouvel utilisateur, je vois mon résultat d'éligibilité avec une vidéo explicative | P0 |
| ONB-03 | En tant que nouvel utilisateur non éligible, je comprends pourquoi et suis redirigé | P0 |
| ONB-04 | En tant que nouvel utilisateur éligible, je remplis le questionnaire BS (sport) | P0 |
| ONB-05 | En tant que nouvel utilisateur, je vois un récapitulatif de mon profil avant de commencer | P1 |

### 2.2 Questionnaire PT — Spécification complète

#### Flow

```
Écran 1 : Bienvenue
    │
Écran 2 : Identité (prénom, sexe, date naissance, email)
    │
Écran 3 : Exclusion rapide
    │   Question : "Êtes-vous diabétique ?"
    │   → Si oui_type1 ou oui_type2 : écran d'exclusion + redirection
    │
Écran 4 : Pays + État (conditionnel si US)
    │   Question : "Dans quel pays vivez-vous ?"
    │   → Si US : question "Dans quel état ?"
    │   → Si US : question ethnie
    │
Écran 5 : Mesures physiques
    │   Morphologie (gracile/moyen/large)
    │   Répartition masse grasse (gynoïde/androïde/partout/pas de kilos)
    │   Système d'unités (métrique/US)
    │   Poids (30-200 kg ou équivalent lbs)
    │   Taille (0.8-2.2 m ou équivalent ft/in)
    │   → Calcul IMC automatique en arrière-plan
    │   → Si IMC < 23 ou ≥ 40 : noter pour exclusion post-scoring
    │
Écran 6 : Habitudes de vie
    │   Durée repas (<21min / 21-40 / >40)        [2, 2, 0 pts]
    │   Grignotage (jamais / 1-2x / 3+)           [0, 3, 5 pts]
    │   Somnolences (rarement / souvent)           [0, 1 pts]
    │   Édulcorants (oui / parfois / non / pas de sucre)  [0, 0, 0, 0]
    │   Bière (jamais / 1v/j / 1v/repas / +)      [0, 0, 1, 3 pts]
    │   Stress & appétit (ouvre / coupe / sans effet) [1, 0, 0 pts]
    │   Durée nuits (≥6h / <6h)                    [0, 1 pts]
    │
Écran 7 : Antécédents médicaux
    │   Hypertension (non / modérée / sévère / NSP)    [0, 1, 2, 0]
    │   Prise poids 12 mois (non / 5% / 5-10% / >10%) [0, 1, 3, 5]
    │   Diabète T2 famille (non / gd-parent / 1 parent / 2 / famille / NSP) [0,1,2,3,5,0]
    │   Hausse glycémie (non / 1x / 2x / NSP)         [0, 2, 2, 0]
    │   Végétalien (oui / non)                          [informatif]
    │   Condition médicale (7 choix)                    [informatif]
    │
Écran 8 : Résultat
    │   Score = Σ points
    │   Groupe : G1 (1-10) / G2 (11-20) / G3 (≥21)
    │   Éligibilité : Groupe × IMC → Formule ou NON_COACHABLE
    │   → Vidéo d'éligibilité ou d'exclusion
    │   → Si éligible : enchaîner sur BS
    │   → Si exclu : message + suggestion consultation médecin
```

#### Règles de scoring

```json
{
  "scoring_rules": {
    "groups": [
      { "id": "G1", "label": "Risque faible", "score_min": 1, "score_max": 10 },
      { "id": "G2", "label": "Risque modéré", "score_min": 11, "score_max": 20 },
      { "id": "G3", "label": "Risque élevé", "score_min": 21, "score_max": null }
    ],
    "eligibility_matrix": [
      { "group": "G1", "bmi_min": 23, "bmi_max": 39.99, "formula": "F1" },
      { "group": "G2", "bmi_min": 23, "bmi_max": 39.99, "formula": "F2" },
      { "group": "G3", "bmi_min": 23, "bmi_max": 39.99, "formula": "F3" },
      { "group": "G2", "bmi_min": 0, "bmi_max": 22.99, "formula": "F4" },
      { "group": "G3", "bmi_min": 0, "bmi_max": 22.99, "formula": "F5" },
      { "group": "G1", "bmi_min": 0, "bmi_max": 22.99, "formula": "NON_COACHABLE" },
      { "group": "*", "bmi_min": 40, "bmi_max": null, "formula": "NON_COACHABLE" }
    ]
  }
}
```

#### Vidéos d'éligibilité

| Groupe | IMC | Video ID |
|--------|-----|----------|
| G1 | 23-25 | `pt.eligible.g1.23_25` |
| G1 | 25-30 | `pt.eligible.g1.25_30` |
| G1 | 30-40 | `pt.eligible.g1.30_40` |
| G2 | <25 | `pt.eligible.g2.moins23` |
| G2 | 25-30 | `pt.eligible.g2.25_30` |
| G2 | 30-40 | `pt.eligible.g2.30_40` |
| G3 | <25 | `pt.eligible.g2.moins23` |
| G3 | 25-30 | `pt.eligible.g2.25_30` |
| G3 | 30-40 | `pt.eligible.g2.30_40` |

### 2.3 Questionnaire BS (Sport)

Après le PT, l'utilisateur éligible remplit le questionnaire BS.

**Scoring** :
```
Score 0-8   → GS1 (sédentaire)
Score 9-18  → GS2 (peu actif)
Score 19-35 → GS3 (modérément actif)
Score ≥ 36  → GS4 (actif)
```

**Résultat** : `idGroupeSportif` stocké dans le profil Abonné.

### 2.4 Calculs dérivés à l'onboarding

| Calcul | Formule | Stockage |
|--------|---------|----------|
| IMC | `poids / (taille²)` | `abonne.imc` |
| Âge | `today - dateNaissance` (en années) | `abonne.age` |
| Poids santé | `calculPS(5.0)` si G1, `calculPS(10.0)` si G2/G3 | `abonne.poidsSanteKG` |
| Poids idéal | Calcul selon morphologie, sexe, taille | `abonne.poidsIdealKG` |

### 2.5 Critères d'acceptation

- [ ] Un utilisateur peut compléter le PT en moins de 10 minutes
- [ ] Le scoring est identique au legacy (mêmes points, mêmes groupes)
- [ ] Les vidéos d'éligibilité/exclusion s'affichent correctement
- [ ] Les champs conditionnels (US state, ethnie) apparaissent/disparaissent
- [ ] Un utilisateur exclu ne peut pas accéder au programme
- [ ] Le questionnaire BS n'apparaît qu'après un PT réussi
- [ ] Les données sont sauvegardées même si l'utilisateur quitte en cours

### 2.6 API Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/v1/questionnaires/:id` | Récupérer un questionnaire (structure + questions) |
| POST | `/api/v1/questionnaires/:id/responses` | Soumettre les réponses |
| GET | `/api/v1/questionnaires/:id/results` | Récupérer le résultat (score, groupe, formule) |
| GET | `/api/v1/onboarding/status` | Statut de l'onboarding (étape courante) |

---

## Module 3 : Moteur de règles

### 3.1 Principe

Remplacer Drools par un **moteur de règles léger basé sur JSON/YAML**. Les règles médicales sont stockées en fichiers de configuration, éditables sans déployer du code.

### 3.2 Format des règles

```json
{
  "rule_id": "glycemie_diabete_j1",
  "name": "Diabétique qui s'ignore - Jour 1",
  "description": "Première glycémie ≥ 126 mg/dL",
  "priority": 100,
  "conditions": {
    "all": [
      { "fact": "glycemie.current.value", "operator": ">=", "value": 126 },
      { "fact": "glycemie.history.count", "operator": "==", "value": 0 },
      { "fact": "days_since_start", "operator": ">=", "value": 1 }
    ]
  },
  "actions": [
    { "type": "add_video", "params": { "id": "video.tr.diabetique_ignore_j1" } }
  ]
}
```

### 3.3 Catégories de règles à migrer

| Catégorie | Nb règles legacy | Priorité migration |
|-----------|-----------------|-------------------|
| Glycémie (seuils, alertes) | 4 | P0 |
| Poids (atteinte PS, PI) | 3 | P0 |
| Phase transitions | ~20 | P0 |
| Formule × durée phase | ~78 (F1-F5) | P0 |
| Vidéos de début de phase | 11 | P1 |
| Jours spéciaux (fêtes) | 12 | P2 |
| Menus spéciaux | 6 | P2 |
| Sports phases init | 32 | P1 |
| Compteurs | ~10 | P1 |
| Questionnaire scoring | ~30 | P0 |

### 3.4 Architecture du moteur

```
┌──────────────────────┐
│   Fichiers JSON/YAML  │  ← Éditables sans code
│   /rules/             │
│   ├── medical.json    │  (glycémie, poids, exclusions)
│   ├── phases.json     │  (transitions, durées, behaviors)
│   ├── formulas.json   │  (F1-F5, durées par âge/IMC)
│   ├── sports.json     │  (GS1-GS4, phases sportives)
│   ├── menus.json      │  (kcal ratios, jours spéciaux)
│   └── content.json    │  (vidéos, messages par contexte)
└──────────┬───────────┘
           │
    ┌──────▼──────┐
    │ Rule Engine  │  ← Évalue conditions → déclenche actions
    │ (service)    │
    └──────┬──────┘
           │
    ┌──────▼──────────────────────────────┐
    │ Actions disponibles :                │
    │ • add_video(id)                      │
    │ • add_message(severity, id)          │
    │ • add_reminder(id)                   │
    │ • transition_phase(target)           │
    │ • insert_pause(duration_days)        │
    │ • set_value(field, value)            │
    │ • trigger_notification(type, data)   │
    └─────────────────────────────────────┘
```

### 3.5 Exécution ordonnée

Conserver le concept de **RuleSteps** du legacy :

| Ordre | Step | Règles évaluées |
|-------|------|-----------------|
| 1 | INIT | Initialisation programme, insertion phases |
| 2 | DATA | Chargement données dynamiques (dernier poids, glycémie, etc.) |
| 3 | QUESTIONNAIRES | Traitement réponses, scoring |
| 4 | PROGRAMME | Transitions de phase, behaviors |
| 5 | DAILY | Vidéos du jour, messages, milestones |
| 6 | COUNTERS | Mise à jour compteurs |
| 7 | OUTPUT | Nettoyage, préparation réponse |

### 3.6 Critères d'acceptation

- [ ] 100% des règles médicales (glycémie, poids) produisent les mêmes résultats que Drools
- [ ] Les règles sont éditables via fichiers JSON sans modifier le code
- [ ] Le moteur s'exécute en < 100ms pour un profil utilisateur
- [ ] Les actions sont tracées dans un log pour debugging
- [ ] Tests unitaires couvrant chaque règle individuellement

---

## Module 4 : Programme & Phases

### 4.1 User Stories

| ID | Story | Priorité |
|----|-------|----------|
| PROG-01 | En tant qu'utilisateur, je vois ma phase courante et sa progression | P0 |
| PROG-02 | En tant qu'utilisateur, je suis notifié quand je change de phase | P0 |
| PROG-03 | En tant qu'utilisateur, je peux mettre mon programme en pause | P1 |
| PROG-04 | En tant qu'utilisateur, je vois une timeline de mon programme complet | P1 |
| PROG-05 | En tant qu'utilisateur, je vois combien de jours il me reste dans la phase | P0 |

### 4.2 Initialisation du programme

À la fin de l'onboarding, le système crée le programme :

```
Entrée : idFormule (F1-F5), age, imc, idGroupeSportif
Sortie : Liste de phases avec dates et durées
```

#### Phases créées

| Phase | Type | Présente dans |
|-------|------|---------------|
| CARNET | Per-day | F1, F2, F3, F4, F5 |
| DETOX | Per-day | F1, F2, F4, F5 |
| PVBF | Weekly | F4, F5 uniquement |
| INTENSIVE | Weekly | F1, F2, F3 |
| PROGRESSIVE | Weekly | F1, F2, F3, F4, F5 |
| INTENSIVE_2 | Weekly | F1, F2, F3 |
| PROGRESSIVE_2 | Weekly | F1, F2, F3 |
| STABILISATION | Weekly | Toutes |

### 4.3 Durées des phases

Stocker en JSON (remplace les 78 règles Drools) :

```json
{
  "F2": {
    "CARNET": { "default": 2 },
    "DETOX": {
      "rules": [
        { "conditions": { "age": "<45", "bmi": "<25" }, "duration": 1 },
        { "conditions": { "age": "<45", "bmi": ">=25" }, "duration": 2 },
        { "conditions": { "age": ">=45", "bmi": "<25" }, "duration": 1 },
        { "conditions": { "age": ">=45", "bmi": ">=25" }, "duration": 1 }
      ]
    },
    "INTENSIVE": {
      "rules": [
        { "conditions": { "age": "<45", "bmi": "<25" }, "duration": 0 },
        { "conditions": { "age": "<45", "bmi": ">=25" }, "duration": 21, "behavior": "IF_PS_JUMP_TO_PROGRESSIVE_2" },
        { "conditions": { "age": ">=45", "bmi": "<25" }, "duration": 0 },
        { "conditions": { "age": ">=45", "bmi": ">=25" }, "duration": 0 }
      ]
    },
    "PROGRESSIVE": {
      "rules": [
        { "conditions": { "age": "<45", "bmi": "<25" }, "duration": 7, "behavior": "UNTIL_PI_ADD_ONE_WEEK" },
        { "conditions": { "age": "<45", "bmi": ">=25" }, "duration": 42 },
        { "conditions": { "age": ">=45", "bmi": "<25" }, "duration": 7, "behavior": "UNTIL_PI_ADD_ONE_WEEK" },
        { "conditions": { "age": ">=45", "bmi": ">=25" }, "duration": 28 }
      ]
    },
    "STABILISATION": { "default": 365 }
  }
}
```

### 4.4 Transitions de phase

| Behavior | Logique |
|----------|---------|
| `IF_PS_JUMP_TO_PROGRESSIVE_2` | Si `poids_actuel ≤ poids_sante` → sauter à PROGRESSIVE_2, sinon continuer |
| `IF_PI_JUMP_TO_STABILISATION` | Si `poids_actuel ≤ poids_ideal` → sauter à STABILISATION |
| `UNTIL_PI_ADD_ONE_WEEK` | À la fin de la phase, si PI non atteint → ajouter 7 jours |
| `UNTIL_PI_LOOP_TWO_LAST_PHASES` | Boucler INTENSIVE_2 + PROGRESSIVE_2 tant que PI non atteint |

### 4.5 Gestion PAUSE

**Déclencheurs** :
1. Utilisateur choisit "pause" (questionnaire PAUSE)
2. Glycémie ≥ 126 mg/dL pendant 2 jours consécutifs

**Comportement** :
- Insertion d'une phase PAUSE (365 jours max)
- Insertion d'une phase PAUSE_SPORT parallèle
- Programme gelé
- Sortie via questionnaire SORTIE_PAUSE

### 4.6 API Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/v1/program` | Programme complet (phases, dates, progression) |
| GET | `/api/v1/program/current-phase` | Phase courante avec jours restants |
| POST | `/api/v1/program/pause` | Mettre en pause |
| POST | `/api/v1/program/resume` | Reprendre après pause |
| GET | `/api/v1/program/timeline` | Timeline visuelle |

---

## Module 5 : Menus & Nutrition

### 5.1 User Stories

| ID | Story | Priorité |
|----|-------|----------|
| MENU-01 | En tant qu'utilisateur, je reçois un menu personnalisé chaque semaine | P0 |
| MENU-02 | En tant qu'utilisateur, je vois le menu du jour (5 repas) | P0 |
| MENU-03 | En tant qu'utilisateur, je peux voir le détail d'une recette (ingrédients, préparation) | P0 |
| MENU-04 | En tant qu'utilisateur, je peux remplacer une recette par une alternative | P1 |
| MENU-05 | En tant qu'utilisateur, mes contraintes alimentaires sont respectées | P0 |
| MENU-06 | En tant qu'utilisateur, mes menus respectent mon objectif calorique | P0 |

### 5.2 Pipeline de génération

```
1. FILTRAGE (règles dures)
   ├── Exclure recettes incompatibles (casher/halal/gluten/végétarien)
   ├── Exclure recettes hors phase (phaseActivation)
   ├── Exclure recettes hors kcal (trop caloriques pour la cible)
   └── Vérifier incompatibilités alimentaires (pas viande+laitier si casher)

2. SCORING
   ├── Score nutritionnel par ingrédient (A=8, B=6, C=4, D=2)
   ├── Bonus saisonnalité (÷10 si hors saison)
   ├── Jitter aléatoire (±2) pour variété
   └── Score recette = moyenne des scores ingrédients

3. SÉLECTION (solveur LP — OR-Tools)
   ├── Maximiser score total
   ├── Contrainte : fréquence max par recette
   ├── Contrainte : fréquence max par catégorie alimentaire
   ├── Contrainte : fréquence max par groupe de recettes équivalentes
   ├── Contrainte : nb exact de recettes par créneau (repas × composant)
   └── Contrainte : incompatibilité par type de repas (casher)

4. CONSTRUCTION
   ├── Assigner recettes aux créneaux (7 jours × 5 repas × composants)
   ├── Optimisation locale (swaps pour améliorer variété)
   └── Générer recettes de substitution par créneau

5. STOCKAGE
   └── Sauvegarder MenusData avec menusQuotidiens
```

### 5.3 Structure d'un menu

```json
{
  "week_start": "2026-03-16",
  "phase": "INTENSIVE",
  "target_kcal": 1800,
  "phase_ratio": 0.8,
  "effective_kcal": 1440,
  "days": [
    {
      "date": "2026-03-16",
      "meals": {
        "PETIT_DEJEUNER": {
          "components": [
            { "type": "PLAT", "recipe_id": "porridge.fruits.rouges", "substitutes": ["tartine.confiture", "yaourt.granola"] },
            { "type": "BOISSON", "recipe_id": "the.vert", "substitutes": ["cafe.noir", "infusion.menthe"] }
          ]
        },
        "DEJEUNER": {
          "components": [
            { "type": "ENTREE", "recipe_id": "salade.tomates.mozza" },
            { "type": "PLAT", "recipe_id": "poulet.grille.haricots.verts" },
            { "type": "DESSERT", "recipe_id": "pomme.cuite.cannelle" }
          ]
        },
        "DINER": {
          "components": [
            { "type": "PLAT", "recipe_id": "saumon.vapeur.quinoa" },
            { "type": "ACCOMPAGNEMENT", "recipe_id": "legumes.grilles" }
          ]
        }
      }
    }
  ]
}
```

### 5.4 Ratios caloriques par phase

| Phase | Ratio | Exemple (DER=2000) |
|-------|-------|---------------------|
| CARNET | 1.0 | 2000 kcal/jour |
| DETOX | 1.0 | 2000 |
| INTENSIVE | 0.8 | **1600** |
| INTENSIVE_2 | 0.8 | **1600** |
| PROGRESSIVE | 1.0 | 2000 |
| PROGRESSIVE_2 | 1.0 | 2000 |
| PVBF | 1.0 | 2000 |
| STABILISATION | 1.2 | **2400** |

### 5.5 Modèle de données recette

```json
{
  "id": "poulet.grille.haricots.verts",
  "name_key": "recipe.poulet.grille.haricots.verts",
  "photo_id": "poulet_grille_hv.jpg",
  "prep_time_minutes": 30,
  "meal_types": ["DEJEUNER", "DINER"],
  "component_types": ["PLAT"],
  "kcal_definition": 1500,
  "kcal_activation": 1200,
  "phase_activation": "DETOX",
  "max_per_week": 2,
  "equivalent_group": "poulet_grille_variants",
  "portions": [
    { "food_id": "poulet.blanc", "quantity": 150, "unit": "g" },
    { "food_id": "haricots.verts", "quantity": 200, "unit": "g" },
    { "food_id": "huile.olive", "quantity": 10, "unit": "ml" }
  ]
}
```

### 5.6 Critères d'acceptation

- [ ] Un menu hebdomadaire est généré en < 5 secondes
- [ ] Les contraintes casher/halal/gluten/végétarien sont 100% respectées
- [ ] Aucune recette n'apparaît plus de `maxHebdo` fois par semaine
- [ ] Le total calorique quotidien est dans ±10% de la cible
- [ ] Chaque créneau a au moins 2 recettes de substitution
- [ ] Les ingrédients de saison sont favorisés

### 5.7 API Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/v1/menus/current-week` | Menu de la semaine courante |
| GET | `/api/v1/menus/:date` | Menu d'un jour spécifique |
| POST | `/api/v1/menus/generate` | Forcer la régénération d'un menu |
| POST | `/api/v1/menus/:date/meals/:mealType/substitute` | Remplacer une recette |
| GET | `/api/v1/recipes/:id` | Détail d'une recette |
| GET | `/api/v1/recipes/:id/substitutes` | Alternatives à une recette |

---

## Module 6 : Suivi quotidien

### 6.1 User Stories

| ID | Story | Priorité |
|----|-------|----------|
| TRACK-01 | En tant qu'utilisateur, je remplis mon questionnaire glycémie chaque jour | P0 |
| TRACK-02 | En tant qu'utilisateur, je remplis mes questionnaires repas après chaque repas | P0 |
| TRACK-03 | En tant qu'utilisateur, je peux tracker mon humeur | P1 |
| TRACK-04 | En tant qu'utilisateur, je peux tracker mon activité sportive | P0 |
| TRACK-05 | En tant qu'utilisateur, je vois un dashboard résumé de ma journée | P0 |
| TRACK-06 | En tant qu'utilisateur, je vois des graphiques de progression (poids, glycémie) | P0 |

### 6.2 Questionnaires quotidiens

| Questionnaire | Moment | Questions clés |
|---------------|--------|---------------|
| `bqglycemie` | Matin | Valeur glycémie (type: Glycemy, range: 0.2-6.2 mmol/L) |
| `bqpdej` | Après petit-déjeuner | Suivi du petit-déjeuner |
| `bqencas_matin` | Matin | Encas matin (si applicable) |
| `bqdej` | Après déjeuner | Suivi du déjeuner |
| `bqencas_am` | Après-midi | Encas après-midi (si applicable) |
| `bqdiner` | Après dîner | Suivi du dîner |
| `bqhumeur` | Soir | Humeur du jour |
| `bqsport` | Après activité | Activité physique réalisée |

### 6.3 Formulaire dynamique

Le système de questionnaire doit supporter les **29 types de questions** du legacy. Pour le MVP, prioriser :

**P0 (indispensables)** :
- `Text`, `Radio`, `Combo`, `ComboSearch`, `Date`
- `Num`, `Int`, `Kilograms`, `Meters`, `Centimeters`
- `Glycemy`, `ActivitePhysique`

**P1 (importants)** :
- `SliderNum`, `SliderInt`, `SliderRadio`
- `Balance_*` (tous les types balance)
- `Tracker_*` (tous les types tracker)

**P2 (secondaires)** :
- `QuizzQuestion`, `QuizzResult`
- `Email`, `PhoneNumber`

### 6.4 Déclenchement des règles après saisie

Chaque soumission de questionnaire déclenche le moteur de règles :

```
Utilisateur soumet bqglycemie (glycémie = 130 mg/dL)
    │
    ▼
Moteur de règles évalue :
    ├── glycemie_diabete_j1 → 130 ≥ 126 → OUI → ajouter vidéo alerte
    ├── glycemie_basse → 130 > 50 → NON
    └── passage_seuil → pas de changement de zone → NON
    │
    ▼
Résultat :
    └── DayData.videos += "video.tr.diabetique_ignore_j1"
```

### 6.5 Dashboard jour

```
┌─────────────────────────────────┐
│  Lundi 16 Mars 2026             │
│  Phase : PROGRESSIVE (J12/28)   │
│  ─────────────────────────────  │
│                                  │
│  📊 Glycémie : 98 mg/dL  ✓     │
│  ⚖️  Poids : 82.3 kg (-0.5)    │
│  🍽️  Repas : 3/5 trackés       │
│  🏃 Sport : 30 min marche       │
│  😊 Humeur : Bien               │
│                                  │
│  ─────────────────────────────  │
│  📹 Vidéo du jour :             │
│  "Les fibres et la glycémie"    │
│                                  │
│  💬 Message :                    │
│  "Votre glycémie est stable,    │
│   continuez comme ça !"         │
└─────────────────────────────────┘
```

### 6.6 Graphiques de progression

| Graphique | Données | Période |
|-----------|---------|---------|
| Glycémie | Valeurs quotidiennes + seuils (50/105/126) | 7 jours glissants |
| Poids | Valeurs + poids santé + poids idéal | 30 jours glissants |
| Tour de taille | Valeurs + seuil (102cm homme) | 30 jours |
| Activité | Minutes/semaine + objectif | 4 semaines |

### 6.7 API Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/v1/daily/:date` | Dashboard du jour (DayData complet) |
| GET | `/api/v1/daily/:date/questionnaires` | Questionnaires à remplir |
| POST | `/api/v1/daily/:date/questionnaires/:id` | Soumettre réponses |
| GET | `/api/v1/charts/glycemia?period=7d` | Données graphique glycémie |
| GET | `/api/v1/charts/weight?period=30d` | Données graphique poids |
| GET | `/api/v1/charts/activity?period=4w` | Données graphique activité |

---

## Module 7 : Objets connectés

### 7.1 User Stories

| ID | Story | Priorité |
|----|-------|----------|
| DEV-01 | En tant qu'utilisateur, je peux appairer mon glucomètre VivaCheck via Bluetooth | P0 |
| DEV-02 | En tant qu'utilisateur, je peux prendre une mesure de glycémie depuis l'app | P0 |
| DEV-03 | En tant qu'utilisateur, je peux récupérer l'historique de mon glucomètre | P1 |
| DEV-04 | En tant qu'utilisateur, je peux appairer ma balance connectée | P1 |
| DEV-05 | En tant qu'utilisateur, mes mesures sont automatiquement synchronisées | P0 |

### 7.2 Glucomètre VivaCheck — Spécification BLE

#### Identification
| Paramètre | Valeur |
|-----------|--------|
| Device name | `"BLE-Vivachek"` |
| Service UUID | `0003cdd0-0000-1000-8000-00805f9b0131` |
| Write characteristic | `0003cdd2-0000-1000-8000-00805f9b0131` |
| Notify characteristic | `0003cdd1-0000-1000-8000-00805f9b0131` |

#### Protocole de communication

**Format de message** : `[0x7B][PAYLOAD][CRC16][0x7D]`
- Préfixe : `0x7B` ('{')
- Postfixe : `0x7D` ('}')
- CRC : CRC-16 Modbus (polynôme 0xA001, init 0xFFFF)

**Séquence d'appairage** :
```
1. Scan BLE → filtrer "BLE-Vivachek"
2. Connect GATT
3. Discover services → trouver service UUID
4. Enable notifications sur characteristic notify
5. Envoyer commande SERIAL_NUMBER
6. Recevoir n° série → afficher les 5 derniers chiffres
7. Utilisateur confirme → stocker comme device appairé
8. Envoyer commande UNIT_SYSTEM → recevoir mg/dL ou mmol/L
9. Envoyer commande SET_TIME → synchroniser horloge
10. Prêt pour mesure
```

**Séquence de mesure** :
```
1. Envoyer commande STATUS (polling)
2. Recevoir statut :
   - code 11 → Bandelette insérée        → UI: étape 1 ✓
   - code 22 → Prêt pour le test          → UI: étape 2 ✓
   - code 33 → Sang détecté               → UI: étape 3 (attente)
   - code 44 → RÉSULTAT                   → UI: afficher valeur
   - code 55 → Erreur                     → UI: réessayer
3. Extraire valeur : (byte_high × 100 + byte_low) / 10 → mg/dL
4. Si unité = mmol/L : convertir ÷ 18.018
5. Sauvegarder en local + sync API
```

**Commandes binaires** :

| Commande | Payload hex |
|----------|-------------|
| SERIAL_NUMBER | `01 10 01 20 77 55 00 00 01 0B 0B 04` |
| UNIT_SYSTEM | `01 10 01 20 AA 55 00 00 02 01 0D 08` |
| SET_TIME | `01 10 01 20 44 66 00 06` + 6 bytes datetime |
| HISTORY | `01 10 01 20 DD 55 00 00 03 0A 06 0C` |
| STATUS | `01 10 01 20 12 99 00 00 0C 05 04 07` |

### 7.3 Balance connectée

**V1** : Support basique via données manuelles (questionnaire BH) ou API iHealth si disponible.

| Mesure | Type | Unité |
|--------|------|-------|
| Poids | Kilograms | kg |
| Masse grasse | Balance_WeightFatValue | % |
| Masse musculaire | Balance_MuscleValue | % |
| Hydratation | Balance_WaterValue | % |

### 7.4 Sync API

**Endpoint** : `POST /api/v1/readings`

```json
{
  "readings": [
    {
      "type": "Glycemy",
      "value": 98.5,
      "unit": "mg/dL",
      "date": "2026-03-16T08:30:00Z",
      "source": "vivachek_ble"
    }
  ]
}
```

### 7.5 Critères d'acceptation

- [ ] Le scan BLE détecte le VivaCheck en < 10 secondes
- [ ] L'appairage fonctionne avec les 5 derniers chiffres du numéro de série
- [ ] Une mesure complète (de l'insertion bandelette au résultat) est fluide
- [ ] Les mesures sont stockées localement en cas d'absence de réseau
- [ ] La sync vers le backend se fait automatiquement quand le réseau revient
- [ ] La déconnexion BLE est gérée gracieusement (reconnexion auto si "keep")

---

## Module 8 : Contenu

### 8.1 User Stories

| ID | Story | Priorité |
|----|-------|----------|
| CONT-01 | En tant qu'utilisateur, je reçois une vidéo contextuelle chaque jour | P0 |
| CONT-02 | En tant qu'utilisateur, je peux suivre les 16 cours éducatifs | P1 |
| CONT-03 | En tant qu'utilisateur, je vois des messages motivationnels | P1 |
| CONT-04 | En tant qu'utilisateur, je reçois des messages de fêtes adaptés à mon régime | P2 |

### 8.2 Vidéos

#### Catégories (11)

| Catégorie | Description | Déclencheur |
|-----------|-------------|-------------|
| Achievements | Milestones atteints | Atteinte poids santé, glycémie normale, etc. |
| CDC | Cours du jour | Programmé par phase |
| Diet | Nutrition | Contextuel (phase, progression) |
| Exercise | Activité | Selon phase sportive |
| Lifestyle | Mode de vie | Quotidien |
| Obstacles | Difficultés | Détection via questionnaires |
| Preparation | Onboarding | Début de programme |
| Program | Programme | Transition de phase |
| PT | Personal Test | Résultat onboarding |
| Quiz | Quiz interactifs | Périodique |
| Scientific | Contenu médical | Programmé |

#### Structure vidéo

```json
{
  "id": "video.ac.atteinte_poids_sante",
  "title_key": "video.ac.atteinte_poids_sante.title",
  "category": "achievements",
  "priority": 10,
  "show_only_one": false,
  "content_url": "https://cdn.prediabaid.com/videos/...",
  "thumbnail_url": "https://cdn.prediabaid.com/thumbs/...",
  "duration_seconds": 120
}
```

### 8.3 Messages

| Type | Exemples | Stockage |
|------|----------|----------|
| Introduction quotidienne | "Bonjour Marie, jour 12 de votre phase progressive" | DayData.messages |
| Rappels médicaux | "Votre glycémie était élevée hier, pensez à consulter" | DayData.reminders |
| Fêtes | "Joyeux Noël ! Voici un menu spécial adapté" | DayData.messages |
| Milestones | "Bravo ! Vous avez atteint votre poids santé !" | DayData.messages |

### 8.4 Cours éducatifs (CDC)

16 cours avec questionnaire de compréhension à la fin de chaque cours.

| Cours | ID | Sujet (à confirmer avec contenu legacy) |
|-------|----|----------------------------------------|
| 1 | `cours1` | Introduction au prédiabète |
| 2 | `cours2` | Comprendre la glycémie |
| ... | ... | ... |
| 16 | `cours16` | Maintenir ses acquis |

### 8.5 API Endpoints

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/v1/content/videos/today` | Vidéos du jour |
| GET | `/api/v1/content/videos/:id` | Détail d'une vidéo |
| POST | `/api/v1/content/videos/:id/seen` | Marquer comme vue |
| GET | `/api/v1/content/courses` | Liste des cours |
| GET | `/api/v1/content/courses/:id` | Détail d'un cours + quiz |
| GET | `/api/v1/content/messages/today` | Messages du jour |

---

## Module 9 : Notifications & Rappels

### 9.1 Types de notifications

| Type | Déclencheur | Exemple |
|------|-------------|---------|
| Rappel glycémie | Matin, pas de mesure | "N'oubliez pas votre mesure de glycémie" |
| Rappel repas | Après heure du repas, pas de tracking | "Comment s'est passé votre déjeuner ?" |
| Nouveau menu | Lundi matin | "Votre menu de la semaine est prêt !" |
| Alerte glycémie | Glycémie hors seuils | "Votre glycémie est élevée, consultez votre médecin" |
| Changement phase | Transition de phase | "Vous entrez en phase Progressive !" |
| Vidéo du jour | Nouvelle vidéo disponible | "Nouvelle vidéo : Les fibres et la glycémie" |
| Milestone | Atteinte objectif | "Bravo ! -2kg depuis le début !" |

### 9.2 Configuration

Push notifications via Firebase Cloud Messaging (FCM) pour Android + APNs pour iOS (géré par Expo Notifications si React Native).

---

## Module 10 : Admin

### 10.1 Fonctionnalités MVP

| Fonctionnalité | Priorité |
|----------------|----------|
| Liste des utilisateurs avec statut (phase, dernière connexion) | P0 |
| Détail utilisateur (profil, programme, mesures) | P0 |
| Voir les réponses aux questionnaires | P1 |
| Alertes : glycémie hors seuils | P0 |
| Statistiques globales (nb users, rétention, phases) | P1 |
| Gestion du contenu (vidéos, messages) | P2 |
| Export données (CSV) | P1 |

### 10.2 Stack

Admin panel web en **React** (ou framework admin type AdminJS / Retool).

---

## Module 11 : Abonnement & Paiement

### 11.1 MVP simplifié

Pour le MVP, simplifier par rapport au legacy (qui avait Stripe + PayPal + CardConnect) :

| Fonctionnalité | V1 | V2 |
|----------------|----|----|
| Plan gratuit (essai) | ✓ | ✓ |
| Plan payant (mensuel) | ✓ | ✓ |
| Plan payant (annuel) | — | ✓ |
| Paiement Stripe | ✓ | ✓ |
| Paiement Apple/Google IAP | — | ✓ |
| Codes promo | — | ✓ |
| Parrainage | — | ✓ |

### 11.2 Plans

| Plan | Prix | Accès |
|------|------|-------|
| Essai gratuit | 0€ (14 jours) | Onboarding + phase CARNET |
| Premium mensuel | À définir | Tout le programme |
| Premium annuel | À définir | Tout le programme + réduction |

---

## Architecture technique

### Stack

```
┌──────────────────────────────────────────┐
│              Mobile App                    │
│         React Native (Expo)                │
│  ┌──────────┐ ┌──────────┐ ┌───────────┐ │
│  │ Screens   │ │ BLE      │ │ Local     │ │
│  │ (UI)      │ │ Manager  │ │ Storage   │ │
│  └──────────┘ └──────────┘ └───────────┘ │
└──────────────────┬───────────────────────┘
                   │ HTTPS / REST
┌──────────────────▼───────────────────────┐
│              Backend API                   │
│         NestJS / FastAPI                   │
│  ┌──────────┐ ┌──────────┐ ┌───────────┐ │
│  │ Auth     │ │ Rule     │ │ Menu      │ │
│  │ Module   │ │ Engine   │ │ Solver    │ │
│  └──────────┘ └──────────┘ └───────────┘ │
│  ┌──────────┐ ┌──────────┐ ┌───────────┐ │
│  │ Quest.   │ │ Program  │ │ Content   │ │
│  │ Module   │ │ Module   │ │ Module    │ │
│  └──────────┘ └──────────┘ └───────────┘ │
└──────────────────┬───────────────────────┘
                   │
┌──────────────────▼───────────────────────┐
│              PostgreSQL                    │
│  users, abonnes, questionnaires,          │
│  programs, menus, readings, content       │
└──────────────────────────────────────────┘
```

### Monorepo

```
prediabaid/
├── apps/
│   ├── mobile/          # React Native (Expo)
│   ├── api/             # Backend (NestJS ou FastAPI)
│   └── admin/           # Admin panel (React)
├── packages/
│   ├── rules/           # Moteur de règles + fichiers JSON
│   ├── solver/          # Menu solver (Python/OR-Tools)
│   └── shared/          # Types partagés, constantes
├── data/
│   ├── rules/           # Règles métier (JSON/YAML)
│   ├── questionnaires/  # Définitions questionnaires (JSON)
│   ├── recipes/         # Base de recettes (JSON)
│   └── content/         # Vidéos, messages (JSON)
├── docs/                # Documentation
└── docker-compose.yml
```

---

## Modèle de données

### Schéma PostgreSQL principal

```sql
-- Utilisateur
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    enabled BOOLEAN DEFAULT TRUE
);

-- Profil abonné (données santé)
CREATE TABLE subscribers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    -- Identité
    sex VARCHAR(1) CHECK (sex IN ('M', 'F')),
    birth_date DATE,
    age INTEGER,
    country VARCHAR(2),
    state VARCHAR(50),
    -- Mesures
    weight_kg DECIMAL(5,2),
    height_m DECIMAL(3,2),
    bmi DECIMAL(4,1),
    morphology VARCHAR(10), -- NORMAL, FINE, LARGE
    -- Classification
    group_id VARCHAR(5), -- G1, G2, G3
    sport_group_id VARCHAR(5), -- GS1, GS2, GS3, GS4
    formula_id VARCHAR(20), -- F1-F5, NON_COACHABLE
    -- Poids cibles
    ideal_weight_kg DECIMAL(5,2),
    health_weight_kg DECIMAL(5,2),
    -- Préférences alimentaires
    is_kosher BOOLEAN DEFAULT FALSE,
    is_halal BOOLEAN DEFAULT FALSE,
    is_vegetarian BOOLEAN DEFAULT FALSE,
    is_gluten_free BOOLEAN DEFAULT FALSE,
    -- Métadonnées
    subscription_start DATE,
    subscription_end DATE,
    connected_objects_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Programme
CREATE TABLE programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID REFERENCES subscribers(id),
    formula_id VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Phases du programme
CREATE TABLE program_phases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    program_id UUID REFERENCES programs(id),
    phase_id VARCHAR(20) NOT NULL, -- CARNET, DETOX, INTENSIVE, etc.
    phase_type VARCHAR(10), -- per_day, weekly
    start_date DATE,
    end_date DATE,
    duration_days INTEGER,
    initial_duration INTEGER,
    behavior VARCHAR(50), -- IF_PS_JUMP_TO_PROGRESSIVE_2, etc.
    sort_order INTEGER,
    is_current BOOLEAN DEFAULT FALSE
);

-- Phases sportives
CREATE TABLE sport_phases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    program_id UUID REFERENCES programs(id),
    phase_id VARCHAR(20) NOT NULL,
    start_date DATE,
    end_date DATE,
    duration_days INTEGER,
    sessions_per_week INTEGER,
    min_session_duration INTEGER, -- minutes
    level_min INTEGER,
    level_max INTEGER,
    sort_order INTEGER
);

-- Réponses aux questionnaires
CREATE TABLE questionnaire_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID REFERENCES subscribers(id),
    questionnaire_id VARCHAR(50) NOT NULL,
    date_key DATE NOT NULL,
    responses JSONB NOT NULL, -- { "question_id": { "value": ..., "score_part": ... } }
    score DECIMAL(6,2),
    ended BOOLEAN DEFAULT FALSE,
    interrupted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Mesures (objets connectés + manuelles)
CREATE TABLE readings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID REFERENCES subscribers(id),
    type VARCHAR(50) NOT NULL, -- Glycemy, Kilograms, Balance_*, Tracker_*
    value DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20),
    date TIMESTAMPTZ NOT NULL,
    source VARCHAR(50), -- vivachek_ble, manual, ihealth_api
    synced BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Données quotidiennes
CREATE TABLE daily_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID REFERENCES subscribers(id),
    date_key DATE NOT NULL,
    videos JSONB DEFAULT '[]', -- [{ "id": "video.ac...", "seen": false }]
    messages JSONB DEFAULT '[]', -- [{ "severity": "INFO", "key": "..." }]
    reminders JSONB DEFAULT '[]',
    notes JSONB DEFAULT '{}',
    UNIQUE(subscriber_id, date_key)
);

-- Menus hebdomadaires
CREATE TABLE weekly_menus (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID REFERENCES subscribers(id),
    week_start DATE NOT NULL,
    phase_id VARCHAR(20),
    target_kcal INTEGER,
    phase_ratio DECIMAL(3,2),
    effective_kcal INTEGER,
    menus JSONB NOT NULL, -- Structure complète des 7 jours
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(subscriber_id, week_start)
);

-- Compteurs
CREATE TABLE counters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID REFERENCES subscribers(id),
    counter_id VARCHAR(100) NOT NULL,
    value DECIMAL(10,2) DEFAULT 0,
    UNIQUE(subscriber_id, counter_id)
);

-- Vidéos vues
CREATE TABLE video_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID REFERENCES subscribers(id),
    video_id VARCHAR(100) NOT NULL,
    view_count INTEGER DEFAULT 1,
    last_viewed_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(subscriber_id, video_id)
);

-- Appareils connectés
CREATE TABLE connected_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID REFERENCES subscribers(id),
    device_type VARCHAR(20) NOT NULL, -- glucometer, scale, tracker
    device_name VARCHAR(100),
    serial_number VARCHAR(50),
    unit VARCHAR(10), -- mg/dL, mmol/L
    paired_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE
);

-- Abonnements
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    plan VARCHAR(50) NOT NULL,
    status VARCHAR(20) DEFAULT 'active', -- active, paused, cancelled, expired
    start_date DATE NOT NULL,
    end_date DATE,
    stripe_subscription_id VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index
CREATE INDEX idx_readings_subscriber_type ON readings(subscriber_id, type, date);
CREATE INDEX idx_daily_data_subscriber ON daily_data(subscriber_id, date_key);
CREATE INDEX idx_questionnaire_responses_subscriber ON questionnaire_responses(subscriber_id, questionnaire_id, date_key);
CREATE INDEX idx_weekly_menus_subscriber ON weekly_menus(subscriber_id, week_start);
```

---

## API Reference

### Vue d'ensemble

| Module | Base path | Nb endpoints |
|--------|-----------|-------------|
| Auth | `/api/v1/auth/` | 6 |
| Users | `/api/v1/users/` | 3 |
| Onboarding | `/api/v1/onboarding/` | 4 |
| Questionnaires | `/api/v1/questionnaires/` | 4 |
| Program | `/api/v1/program/` | 5 |
| Menus | `/api/v1/menus/` | 6 |
| Daily | `/api/v1/daily/` | 6 |
| Readings | `/api/v1/readings/` | 3 |
| Devices | `/api/v1/devices/` | 4 |
| Content | `/api/v1/content/` | 6 |
| Notifications | `/api/v1/notifications/` | 3 |
| Admin | `/api/v1/admin/` | 8 |
| Subscriptions | `/api/v1/subscriptions/` | 4 |
| **Total** | | **~62 endpoints** |

### Headers communs

```
Authorization: Bearer <jwt_token>
Content-Type: application/json
Accept-Language: fr
X-Timezone: Europe/Paris
```

### Codes de réponse

| Code | Usage |
|------|-------|
| 200 | Succès |
| 201 | Créé |
| 400 | Erreur de validation |
| 401 | Non authentifié |
| 403 | Non autorisé |
| 404 | Ressource non trouvée |
| 422 | Erreur métier (ex: pas éligible) |
| 429 | Rate limit |
| 500 | Erreur serveur |

---

*Ce document est le cahier des charges complet du MVP V1. Pour les évolutions V2 (IA, ML, feedback loop), voir RPD_02.*
