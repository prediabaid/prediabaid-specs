# Glyc Pro — Synthese metier
## RPD-04 : Base de connaissances, logique metier et regles

**Version** : 1.0
**Date** : 2026-03-19
**Statut** : Valide
**Source** : Extraction et synthese de la SPEC_SYSTEME_EXPERT_PREDIABAID, RPD-01 et RPD-02.

Ce document est le reference metier. Il decrit **ce que le systeme sait et fait**, independamment de la stack technique.

---

## Table des matieres

1. [Parcours patient](#1-parcours-patient)
2. [Profiling et eligibilite](#2-profiling-et-eligibilite)
3. [Formules de coaching](#3-formules-de-coaching)
4. [Phases du programme](#4-phases-du-programme)
5. [Regles metier](#5-regles-metier)
6. [Menus et nutrition](#6-menus-et-nutrition)
7. [Activite physique](#7-activite-physique)
8. [Questionnaires](#8-questionnaires)
9. [Bilans](#9-bilans)
10. [Contenu pedagogique](#10-contenu-pedagogique)
11. [Objets connectes et mesures](#11-objets-connectes-et-mesures)
12. [Glossaire](#12-glossaire)

---

## 1. Parcours patient

```
Inscription
    │
    ▼
Questionnaire PT (~25 questions)
    │
    ├── Exclu → video d'exclusion, fin
    │
    ▼
Score PT → Groupe (G1/G2/G3)
    │
    ▼
Groupe × IMC → Formule (F1-F5) ou NON_COACHABLE
    │
    ▼
Questionnaire BS (sport) → Groupe sportif (GS1-GS4)
    │
    ▼
Initialisation programme
    ├── Phases (CARNET → ... → STABILISATION)
    ├── Phases sportives
    ├── Premier menu hebdo (solveur LP)
    └── Premier DayData (videos, messages)
    │
    ▼
Boucle quotidienne
    ├── Questionnaires (glycemie, repas, sport, humeur)
    ├── Mesures (glucometre, balance)
    ├── Evaluation des regles → videos, messages, alertes
    ├── Suivi du menu
    └── Bilan periodique
    │
    ▼
Transitions de phase (automatiques ou declenchees)
    │
    ▼
Stabilisation (365 jours) → fin de programme
```

---

## 2. Profiling et eligibilite

### 2.1 Questionnaire PT

4 categories, ~25 questions. Chaque reponse contribue au score.

**Categorie 1 — Accueil** : prenom, sexe, date de naissance, email, pays, diabetique (oui/non/type).

**Categorie 2 — Statut et mesures** :

| Question | Type | Calcul |
|----------|------|--------|
| Morphologie | Radio | gracile, moyen, large |
| Repartition masse grasse | Radio | gynoide, androide, partout, pas de kilos |
| Poids | Kilograms | 30-200 kg |
| Taille | Meters | 0.8-2.2 m |

Champs calcules : `IMC = poids / taille²`, `age = aujourd'hui - date_naissance`.

**Categorie 3 — Habitudes** (chaque reponse = points) :

| Question | Reponses et points |
|----------|--------------------|
| Duree des repas | <21min: 2, 21-40min: 2, >40min: 0 |
| Grignotage | jamais: 0, 1-2x: 3, 3+: 5 |
| Somnolences | rarement: 0, souvent: 1 |
| Biere | jamais: 0, 1v/j: 0, 1v/repas: 1, davantage: 3 |
| Stress/appetit | ouvre: 1, coupe: 0, sans effet: 0 |
| Duree des nuits | >=6h: 0, <6h: 1 |

**Categorie 4 — Antecedents** (chaque reponse = points) :

| Question | Reponses et points |
|----------|--------------------|
| Hypertension | non: 0, moderee: 1, severe: 2 |
| Prise de poids 12 mois | non: 0, 5%: 1, 5-10%: 3, >10%: 5 |
| Diabete T2 famille | non: 0, gd-parent: 1, 1 parent: 2, 2 parents: 3, famille: 5 |
| Hausse glycemie | non: 0, 1-2 fois: 2 |

### 2.2 Scoring → Groupes

```
Score PT = somme de tous les points

  1-10   → G1 (risque faible)
  11-20  → G2 (risque modere)
  >= 21  → G3 (risque eleve)
  0      → Exclu
```

### 2.3 Matrice d'eligibilite

| | IMC < 23 | IMC 23-39.9 | IMC >= 40 |
|---|---|---|---|
| **G1** | NON_COACHABLE | **F1** | NON_COACHABLE |
| **G2** | **F4** | **F2** | NON_COACHABLE |
| **G3** | **F5** | **F3** | NON_COACHABLE |

Cas d'exclusion :
- IMC >= 40 → toujours NON_COACHABLE
- G1 + IMC < 23 → video `pt.exclusion.imc_23`, fin
- Score = 0 → video d'exclusion, fin

### 2.4 Videos d'eligibilite

Chaque combinaison Groupe x tranche IMC declenche une video specifique :

| Groupe | IMC | Video |
|--------|-----|-------|
| G1 | 23-25 | `pt.eligible.g1.23_25` |
| G1 | 25-30 | `pt.eligible.g1.25_30` |
| G1 | 30-40 | `pt.eligible.g1.30_40` |
| G2/G3 | <25 | `pt.eligible.g2.moins23` |
| G2/G3 | 25-30 | `pt.eligible.g2.25_30` |
| G2/G3 | 30-40 | `pt.eligible.g2.30_40` |

---

## 3. Formules de coaching

5 formules, chacune definit une sequence de phases avec des durees conditionnees par age et IMC.

### F1 — G1, IMC 23-40 (risque faible, surpoids)

| Phase | <45 & IMC<25 | <45 & IMC>=25 | >=45 & IMC<25 | >=45 & IMC>=25 |
|-------|---|---|---|---|
| CARNET | 2j | 2j | 2j | 2j |
| DETOX | 1j | 2j | 1j | 1j |
| INTENSIVE | 0j | 42j + JUMP_PROG2 | 0j | 0j |
| PROGRESSIVE | 7j + ADD_WEEK | 84j | 7j + ADD_WEEK | 28j |
| INTENSIVE_2 | 0j | 14j | 0j | 0j |
| PROGRESSIVE_2 | 0j | 7j + ADD_WEEK | 0j | 0j |
| STABILISATION | 365j | 365j | 365j | 365j |

### F2 — G2, IMC 23-40 (risque modere, surpoids)

| Phase | <45 & IMC<25 | <45 & IMC>=25 | >=45 & IMC<25 | >=45 & IMC>=25 |
|-------|---|---|---|---|
| CARNET | 2j | 2j | 2j | 2j |
| DETOX | 1j | 2j | 1j | 1j |
| INTENSIVE | 0j | 21j + JUMP_PROG2 | 0j | 0j |
| PROGRESSIVE | 7j + ADD_WEEK | 42j | 7j + ADD_WEEK | 28j |
| INTENSIVE_2 | 0j | 21j | 0j | 0j |
| PROGRESSIVE_2 | 0j | 7j + ADD_WEEK | 0j | 0j |
| STABILISATION | 365j | 365j | 365j | 365j |

### F3 — G3, IMC 23-40 (risque eleve, surpoids)

| Phase | <45 & IMC<25 | <45 & IMC>=25 | >=45 & IMC<25 | >=45 & IMC>=25 |
|-------|---|---|---|---|
| CARNET | 2j | 2j | 2j | 2j |
| INTENSIVE | 0j | 28j + JUMP_PROG2 | 0j | 0j |
| PROGRESSIVE | 7j + JUMP_STAB | 56j + LOOP_2_LAST | 7j + JUMP_STAB | 28j |
| INTENSIVE_2 | 0j | 28j | 0j | 0j |
| PROGRESSIVE_2 | 0j | 56j + LOOP_2_LAST | 0j | 0j |
| STABILISATION | 365j | 365j | 365j | 365j |

F3 n'a **pas de phase DETOX**.

### F4 — G2, IMC < 23 (risque modere, poids normal)

| Phase | <45 | >=45 |
|-------|-----|------|
| CARNET | 2j | 2j |
| DETOX | 1j | 2j |
| PVBF | 28j | 42j |
| PROGRESSIVE | 21j | 42j |
| STABILISATION | 365j | 365j |

F4 utilise **PVBF** au lieu d'INTENSIVE.

### F5 — G3, IMC < 23 (risque eleve, poids normal)

| Phase | <45 | >=45 |
|-------|-----|------|
| CARNET | 2j | 2j |
| DETOX | 0j | 1j |
| PVBF | 28j | 42j |
| PROGRESSIVE | 28j | 42j |
| STABILISATION | 365j | 365j |

### Calcul du poids sante (PS)

| Groupe | Tolerance | Methode |
|--------|-----------|---------|
| G1 | 5 kg | `calculPS(5.0)` |
| G2, G3 | 10 kg | `calculPS(10.0)` |

Le poids sante est le seuil qui declenche les behaviors de saut de phase.

---

## 4. Phases du programme

### 4.1 Inventaire

| Phase | Type | Duree typique | Ratio kcal | Role |
|-------|------|---|---|---|
| **CARNET** | Per-day | 2j | 1.0 | Journal alimentaire initial |
| **DETOX** | Per-day | 0-2j | 1.0 | Preparation, reduction toxines |
| **PVBF** | Weekly | 28-42j | 1.0 | Phase de base (F4/F5 uniquement, poids normal) |
| **INTENSIVE** | Weekly | 0-42j | **0.8** | Perte de poids active, restriction calorique |
| **PROGRESSIVE** | Weekly | 7-84j | 1.0 | Retour progressif a l'alimentation normale |
| **INTENSIVE_2** | Weekly | 0-28j | **0.8** | Second cycle de perte de poids |
| **PROGRESSIVE_2** | Weekly | 0-56j | 1.0 | Second cycle progressif |
| **STABILISATION** | Weekly | 365j | **1.2** | Maintien, surplus calorique |
| **PAUSE** | Special | Jusqu'a 365j | 1.0 | Programme suspendu |
| **AUDIT** | Special | 7-21j | 1.0 | Evaluation periodique (alcool) |
| **PAUSE_SPORT** | Sportif | 365j | — | Pause activite physique |

### 4.2 Transitions

```
CARNET (2j) → DETOX (0-2j) → INTENSIVE ou PVBF
                                    │
                              ┌─────┴──────┐
                              │             │
                         PROGRESSIVE    PROGRESSIVE_2
                              │          (si PS atteint)
                              │             │
                         INTENSIVE_2        │
                              │             │
                              └──────┬──────┘
                                     │
                                STABILISATION (365j)
```

### 4.3 Behaviors (logique dynamique)

Les behaviors modifient le parcours en fonction de l'evolution du patient :

| Behavior | Condition | Action |
|----------|-----------|--------|
| `IF_PS_JUMP_TO_PROGRESSIVE_2` | Poids actuel <= poids sante | Sauter directement a PROGRESSIVE_2 |
| `IF_PI_JUMP_TO_STABILISATION` | Poids actuel <= poids ideal | Sauter directement a STABILISATION |
| `UNTIL_PI_ADD_ONE_WEEK` | Poids ideal non atteint | Prolonger la phase de 7 jours |
| `UNTIL_PI_LOOP_TWO_LAST_PHASES` | Poids ideal non atteint | Recommencer les 2 dernieres phases |

Ces behaviors sont attaches a une phase dans la definition de la formule. Ils sont evalues a chaque fin de phase.

### 4.4 PAUSE

Declenchee par :
- Glycemie >= 126 mg/dL pendant 2 jours consecutifs (automatique)
- Choix de l'utilisateur (via questionnaire `pause`)

Duree : jusqu'a 365 jours. Sortie via questionnaire `sortie_pause` (reprise) ou `sortie_pause_arret` (arret definitif).

### 4.5 AUDIT

Phase d'evaluation alcool, inseree periodiquement. Questionnaire `baudit` (test AUDIT standard). Duree : 7-21 jours.

---

## 5. Regles metier

### 5.1 Glycemie

4 zones, 4 seuils :

```
  0 ─────── 50 ─────── 105 ─────── 126 ────────► mg/dL
  │          │           │           │
  │  HYPO    │  NORMAL   │  ELEVE    │  DIABETE
```

| Regle | Condition | Actions |
|-------|-----------|---------|
| Hypoglycemie | glycemie <= 50 | Rappel `abonne.glycemie_basse` |
| Retour a la normale | glycemie passe de >105 a <=105 | Video `video.ac.glycemie_normale` |
| Diabetique ignore J1 | glycemie >= 126 (1ere mesure) | Video `video.tr.diabetique_ignore_j1` |
| Diabetique ignore J2 | glycemie >= 126 pendant 2 jours consecutifs | Video + rappel RDV medecin + **PAUSE 365j** |

### 5.2 Poids

| Regle | Condition | Actions |
|-------|-----------|---------|
| Poids sante atteint | poids <= poids_sante ET amelioration | Video `video.ac.atteinte_poids_sante` |
| Tour de taille ideal (homme) | tour_taille <= 102 cm ET amelioration | Video `video.ac.atteinte_tourtaille` |
| Poids ideal → stabilisation | poids_ideal atteint ET behavior = IF_PI_JUMP_TO_STABILISATION | Saut vers STABILISATION |

### 5.3 Phases et transitions

| Regle | Condition | Actions |
|-------|-----------|---------|
| Phase terminee | date >= fin_phase | Message de fin dans l'agenda |
| Debut de phase | nouvelle phase commence | Video specifique a la phase (11 variantes) |
| Recalcul dates | phase sans date de fin + date de demarrage valide | Recalcul des dates de toutes les phases |
| Insertion phase | condition de pause ou audit | Insertion d'une phase dans le programme |

### 5.4 Jours speciaux

Messages adaptes aux preferences religieuses :

| Date | Condition | Message |
|------|-----------|---------|
| 25 decembre | Non-casher ET non-halal | `abonne.intro.christmas` |
| 6 decembre | Non-casher ET non-halal | `abonne.intro.st_nicholas_day` |
| Purim | Casher | `abonne.intro.purim` |
| Eid al-Fitr | Halal | `abonne.intro.fin_ramadan` |
| Paques | Non-casher ET non-halal | `abonne.intro.easter` |
| Pessah (6j) | Casher | `abonne.intro.passover_day_X` |

### 5.5 Menus speciaux

Le 31 decembre, le diner est remplace par une recette speciale selon le regime :

| Regime | Recette |
|--------|---------|
| Standard | `grilled.beef.sirloin.french.beans` |
| Halal | `oriental.veal.saute.rice.pasta` |
| Casher | `kosher.grilled.beef.sirloin.french.beans` |
| Sans gluten | `herb.roasted.seabass.spinach.quinoa` |

### 5.6 Compteurs

| Compteur | Logique |
|----------|---------|
| `nb_glycemie_precedentes_inf_actuel` | Nombre de glycemies anterieures < glycemie actuelle (seuil 1%) |
| Videos vues | Map<idVideo, nbVues> |
| Perte de poids | Delta dynamique depuis le debut du programme |

---

## 6. Menus et nutrition

### 6.1 Structure des repas

5 repas par jour, 7 jours par semaine = 35 creneaux a remplir.

| Repas | Composants |
|-------|-----------|
| Petit-dejeuner | plat, accompagnement, boisson, dessert |
| Encas matin | plat, dessert, boisson |
| Dejeuner | entree, plat, accompagnement, dessert, boisson |
| Encas apres-midi | plat, dessert, boisson |
| Diner | entree, plat, accompagnement, dessert, boisson |

### 6.2 Budget calorique

```
DER (Depense Energetique au Repos) = f(age, sexe, poids, taille)
kcal/jour = DER × ratio_phase

Exemple :
- Femme 52 ans, 82 kg, 1.65 m → DER ≈ 1450 kcal
- Phase INTENSIVE (ratio 0.8) → budget = 1160 kcal/jour
- Phase STABILISATION (ratio 1.2) → budget = 1740 kcal/jour
```

### 6.3 Scoring des recettes

Chaque recette est scoree selon ses ingredients :

```
Score(ingredient) = (5 - classe_occurrence) × 2 + aleatoire(-2, +2)

Classe A → 8 points    (a privilegier)
Classe B → 6 points
Classe C → 4 points
Classe D → 2 points    (a limiter)

Score(recette) = moyenne des scores ingredients
                 ÷ 10 si un ingredient est hors saison
```

### 6.4 Contraintes du solveur

| Contrainte | Description |
|------------|-------------|
| **Budget kcal** | kcal/jour dans la marge ±10% du budget cible |
| **Variete** | Max 1 occurrence par recette par semaine |
| **Frequence categorie** | Max hebdo par categorie d'aliment (ex: poisson max 3x/semaine) |
| **Casher** | Pas de melange viande/laitier dans le meme repas |
| **Halal** | Uniquement des recettes compatibles halal |
| **Sans gluten** | Uniquement des recettes sans gluten |
| **Vegetarien** | Uniquement des recettes vegetariennes |
| **Saisonnalite** | Penalisation (score ÷10) si ingredient hors saison |
| **Equivalences** | Max de frequence pour les groupes de recettes similaires |

### 6.5 Saisonnalite

```
Ingredient en saison si :
  moisDebut <= moisFin  → moisDebut <= moisActuel <= moisFin
  moisDebut > moisFin   → moisActuel >= moisDebut OU moisActuel <= moisFin
                           (ex: octobre→mars = legumes d'hiver)
```

### 6.6 Processus

```
1. Charger le profil (phase, regime, allergies)
2. Calculer le budget kcal (DER × ratio_phase)
3. Filtrer les recettes compatibles (regime, allergies)
4. Scorer les recettes (nutrition + saison)
5. Solveur LP → selection optimale de recettes
6. Heuristique → placement dans les 35 creneaux
7. Persister le menu hebdo
```

---

## 7. Activite physique

### 7.1 Classification sportive

Questionnaire BS → score → groupe :

| Groupe | Score BS | Profil |
|--------|---------|--------|
| GS1 | 0-8 | Sedentaire |
| GS2 | 9-18 | Peu actif |
| GS3 | 19-35 | Moderement actif |
| GS4 | >= 36 | Actif |

### 7.2 Phases sportives

32 regles d'initialisation (8 phases × 4 groupes). Chaque phase sportive definit :

| Parametre | Description |
|-----------|-------------|
| `nbSeances` | Seances par semaine |
| `dureeMinSeance` | Duree min par seance (minutes) |
| `levelMin` | Difficulte minimum |
| `levelMax` | Difficulte maximum |

Les parametres varient selon **groupe sportif × age × IMC**.

### 7.3 Handicap

3 types, chacun filtre les activites disponibles :

| Type | Code | Impact |
|------|------|--------|
| Total | `isHandicapeD` | Activites adaptees D uniquement |
| Haut du corps | `isHandicapeHH` | Activites adaptees HH |
| Bas du corps | `isHandicapeHB` | Activites adaptees HB |

### 7.4 Pause sport

Declenchee en parallele d'une PAUSE programme. Duree 365 jours max. Sortie via questionnaire `sortie_pause_sport`.

---

## 8. Questionnaires

### 8.1 Inventaire (40+ questionnaires)

| Categorie | IDs | Usage |
|-----------|-----|-------|
| **Profiling** | `pt` | Eligibilite, classification |
| **Sport** | `ba`, `bc`, `binit`, `bq`, `bs` | Evaluation et suivi sportif |
| **Sante** | `bh` | Bilan biometrique |
| **Quotidien** | `bqglycemie`, `bqpdej`, `bqdej`, `bqdiner`, `bqencas_matin`, `bqencas_am`, `bqhumeur`, `bqsport`, `bqcarnet` | Suivi journalier |
| **Education** | `cours1` → `cours16` | 16 modules pedagogiques |
| **Alcool** | `baudit`, `baj`, `baj3`, `baj6`, `sortie_audit` | Evaluation consommation alcool |
| **Pause** | `pause`, `sortie_pause`, `sortie_pause_arret`, `sortie_pause_sport` | Gestion des pauses |
| **Contact** | `cb`, `cc` | Informations de contact |
| **Satisfaction** | `sat1` | Enquete satisfaction |
| **Quiz** | `quiz6+` | Tests de connaissances |

### 8.2 Types de questions (29 types)

**Basiques** : Text, Email, Radio, Combo, ComboSearch, Date, Num, Int

**Sliders** : SliderNum, SliderInt, SliderRadio, SliderRadioTime, SliderRadioDuration

**Unites** : Kilograms, Meters, Centimeters, Glycemy

**Balance** : Balance_DCIValue, Balance_VFatLevelValue, Balance_MuscleValue, Balance_SkeletonValue, Balance_WaterValue, Balance_WeightFatValue

**Tracker** : Tracker_NbSteps, Tracker_Distance, Tracker_Calories

**Autres** : QuizzQuestion, QuizzResult, ActivitePhysique, PhoneNumber

### 8.3 Mapping questionnaires → repas

| Repas | Questionnaire |
|-------|---------------|
| Petit-dejeuner | `bqpdej` |
| Encas matin | `bqencas_matin` |
| Dejeuner | `bqdej` |
| Encas apres-midi | `bqencas_am` |
| Diner | `bqdiner` |

### 8.4 Declenchement des regles

Chaque soumission de questionnaire declenche le pipeline de regles :

```
Patient soumet bqglycemie (glycemie = 130 mg/dL)
    │
    ▼
Pipeline de regles :
    glycemie_diabete_j1 → 130 >= 126 → OUI → video alerte
    glycemie_basse      → 130 > 50   → NON
    passage_seuil       → pas de changement de zone → NON
    │
    ▼
DayData mis a jour :
    videos += "video.tr.diabetique_ignore_j1"
```

---

## 9. Bilans

Module absent du legacy, ajoute dans Glyc Pro. Les donnees existent (mesures, questionnaires, compliance), mais le legacy ne les agregeait jamais pour le patient.

### 9.1 Types de bilans

| Type | Frequence | Contenu |
|------|-----------|---------|
| **Hebdomadaire** | Chaque lundi | Glycemie (moy, min, max, trend), poids (delta), compliance menus, sport, humeur |
| **Mensuel** | Chaque 1er du mois | Idem + evolution sur 30j, comparaison avec le mois precedent |
| **Fin de phase** | A chaque transition | Bilan de la phase terminee : objectifs atteints ?, deltas poids/glycemie, duree reelle vs prevue |
| **Fin de programme** | Entree en STABILISATION | Bilan global : evolution depuis J0, score PT re-evalue, progres objectifs |

### 9.2 Donnees du bilan

```json
{
  "period": { "start": "2026-03-10", "end": "2026-03-16" },
  "glycemia": {
    "mean": 102,
    "min": 88,
    "max": 118,
    "std_dev": 8.5,
    "trend": -0.3,
    "time_in_range_pct": 82,
    "readings_count": 7
  },
  "weight": {
    "start": 84.2,
    "end": 83.5,
    "delta_kg": -0.7,
    "delta_pct": -0.83,
    "vs_health_weight": 3.5,
    "vs_ideal_weight": 8.5
  },
  "compliance": {
    "menus_followed_pct": 78,
    "meals_tracked": 28,
    "meals_total": 35,
    "recipes_substituted": 3,
    "sport_sessions_done": 3,
    "sport_sessions_target": 4,
    "sport_minutes": 105,
    "questionnaires_completed": 6,
    "questionnaires_expected": 7
  },
  "phase": {
    "current": "PROGRESSIVE",
    "day_in_phase": 18,
    "total_days": 28,
    "formula": "F2"
  },
  "alerts": [
    { "type": "glycemia_high", "count": 1, "dates": ["2026-03-15"] }
  ]
}
```

### 9.3 Resume genere

Deux modes :
- **Template** : pour les bilans hebdo standards, texte pre-ecrit avec variables injectees
- **LLM** : pour les bilans de phase/programme, resume personnalise (Claude API)

Les alertes medicales (seuils, references medecin) utilisent toujours des **templates valides par un medecin**, jamais du LLM libre.

---

## 10. Contenu pedagogique

### 10.1 Videos

11 categories, declenchees par les regles ou les transitions de phase :

| Categorie | Declencheur |
|-----------|-------------|
| Accomplissements | Poids sante atteint, glycemie normale, tour de taille |
| Cours du jour (CDC) | 16 modules, 1 par jour |
| Nutrition | Contextuel (phase, progression) |
| Exercice | Selon groupe sportif et phase |
| Mode de vie | Habitudes, sommeil, stress |
| Obstacles | Gestion des difficultes, rechute |
| Preparation | Onboarding |
| Programme | Vue d'ensemble, transitions |
| Personal Test | Resultats PT, eligibilite/exclusion |
| Quiz | Tests de connaissances |
| Scientifique | Contenu medical (diabete, glycemie, nutrition) |

Chaque video : `idVideo`, titre, rubrique, mots-cles, texte, priorite, `showOnlyOne` (afficher seule ou en liste).

### 10.2 Messages

2 niveaux de severite :
- **INFO** : messages informatifs (introduction quotidienne, programme, bilans)
- **Reminder** : rappels (RDV medecin, glycemie basse, objectif sport)

8 fichiers de messages : intro, programme, formulaires, bilans, CDC, quiz, satisfaction, erreurs.

### 10.3 Cours CDC

16 modules educatifs (`cours1` → `cours16`), un par jour. Chaque cours est un questionnaire avec du contenu pedagogique integre.

---

## 11. Objets connectes et mesures

### 11.1 Glucometre VivaCheck Ino Smart

| Parametre | Valeur |
|-----------|--------|
| Connexion | BLE (Bluetooth Low Energy) |
| Nom BLE | `BLE-Vivachek` |
| Protocole | Modbus RTU variant, CRC-16 |
| Unites | mg/dL ou mmol/L |

Commandes : lecture numero de serie, lecture unite, synchronisation horloge, lecture historique, statut en temps reel.

Machine a etats de mesure :

```
Bandelette inseree (11) → Pret (22) → Sang detecte (33) → Resultat (44) ou Erreur (55)
Resultat = (byte_high × 100 + byte_low) / 10
```

Conversion : `mg/dL = mmol/L × 18.018018`

### 11.2 Balance connectee

iHealth (OAuth API) + balance BLE (Hetai).

| Mesure | Type | Unite |
|--------|------|-------|
| Poids | Kilograms | kg |
| Masse grasse | Balance_WeightFatValue | % |
| Masse musculaire | Balance_MuscleValue | % |
| Masse osseuse | Balance_SkeletonValue | kg |
| Hydratation | Balance_WaterValue | % |
| Graisse viscerale | Balance_VFatLevelValue | 1-60 |
| DCI | Balance_DCIValue | kcal |

### 11.3 Tracker d'activite

| Mesure | Type | Unite |
|--------|------|-------|
| Pas | Tracker_NbSteps | pas |
| Distance | Tracker_Distance | km |
| Calories | Tracker_Calories | kcal |

### 11.4 Strategie V1 (Glyc Pro)

Le BLE direct (VivaCheck) necessite React Native. En V1 (PWA), les donnees CGM arrivent via :
- **API** : LibreView (FreeStyle Libre), Dexcom API
- **Apple Health / Health Connect** : aggrege toutes les sources
- **Saisie manuelle** : formulaire dans l'app

Le support BLE natif est prevu en phase 3 (React Native).

---

## 12. Glossaire

| Terme | Definition |
|-------|-----------|
| **PT** | Personal Test — questionnaire d'eligibilite |
| **BS** | Sport Score — questionnaire de classification sportive |
| **G1/G2/G3** | Groupes de risque (faible/modere/eleve) |
| **GS1-GS4** | Groupes sportifs (sedentaire → actif) |
| **F1-F5** | Formules de coaching (combinaison groupe × IMC) |
| **IMC** | Indice de Masse Corporelle = poids / taille² |
| **DER** | Depense Energetique au Repos |
| **PS** | Poids Sante — seuil cible (tolerance 5 ou 10 kg selon groupe) |
| **PI** | Poids Ideal — seuil optimal |
| **PVBF** | Phase de base pour les formules F4/F5 (poids normal) |
| **Behavior** | Logique dynamique attachee a une phase (saut, prolongation, boucle) |
| **DayData** | Donnees quotidiennes generees par le moteur de regles (videos, messages, rappels) |
| **LP** | Linear Programming — methode d'optimisation pour les menus |
| **CGM** | Continuous Glucose Monitoring — glucometre en continu |
| **HDS** | Hebergeur de Donnees de Sante — certification obligatoire en France |
| **NON_COACHABLE** | Patient non eligible au programme (IMC hors bornes ou G1 + IMC < 23) |
| **RETE** | Algorithme de chainage avant utilise par Drools (legacy) |
| **RLS** | Row Level Security — securite au niveau des lignes dans PostgreSQL/Supabase |

---

*Ce document est la reference metier. Pour la stack technique, voir RPD-03. Pour les specs fonctionnelles detaillees, voir RPD-01 (V1) et RPD-02 (V2).*
