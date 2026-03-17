# PrediabAid — Spécification du Système Expert
## Document de référence pour la modernisation

**Version** : 1.0
**Date** : 2026-03-17
**Objectif** : Documenter exhaustivement la base de connaissances et la logique métier du système legacy PrediabAid pour permettre sa refonte.

---

## Table des matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Architecture du système expert](#2-architecture-du-système-expert)
3. [Profiling & Éligibilité (PT)](#3-profiling--éligibilité-pt)
4. [Formules de coaching (F1-F5)](#4-formules-de-coaching-f1-f5)
5. [Phases du programme](#5-phases-du-programme)
6. [Règles métier (Base de connaissances)](#6-règles-métier-base-de-connaissances)
7. [Questionnaires](#7-questionnaires)
8. [Optimisation des menus](#8-optimisation-des-menus)
9. [Activité physique & Phases sportives](#9-activité-physique--phases-sportives)
10. [Vidéos & Messages](#10-vidéos--messages)
11. [Objets connectés](#11-objets-connectés)
12. [Modèle de données](#12-modèle-de-données)
13. [Pistes de modernisation](#13-pistes-de-modernisation)

---

## 1. Vue d'ensemble

### 1.1 Qu'est-ce que PrediabAid ?

PrediabAid est une **plateforme de prévention du prédiabète** qui combine :
- Évaluation du risque via questionnaires
- Programme personnalisé en phases (détox → intensif → progressif → stabilisation)
- Suivi nutritionnel avec optimisation de menus sous contraintes
- Suivi d'activité physique adapté au profil
- Mesures biométriques via objets connectés (glucomètre, balance)
- Contenu éducatif vidéo contextualisé

### 1.2 Composants du système expert

```
┌─────────────────────────────────────────────────────────┐
│                    SYSTÈME EXPERT                        │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐ │
│  │    BASE DE    │  │   MOTEUR     │  │    BASE DE    │ │
│  │ CONNAISSANCES │  │ D'INFÉRENCE  │  │    FAITS      │ │
│  │              │  │              │  │              │ │
│  │ • 430+ règles │  │ Drools 5.6   │  │ • Profil user │ │
│  │ • Seuils méd. │  │ Chaînage     │  │ • Mesures     │ │
│  │ • Formules    │  │ avant (RETE) │  │ • Réponses Q. │ │
│  │ • Phases prog │  │              │  │ • Historique  │ │
│  └──────────────┘  └──────────────┘  └───────────────┘ │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │          SOLVEUR D'OPTIMISATION (C++)             │   │
│  │  Programmation linéaire (LPTK/COIN)               │   │
│  │  Sélection de recettes + Construction de menus    │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### 1.3 Pipeline d'exécution des règles

Le moteur Drools exécute les règles dans un ordre contrôlé via des **RuleSteps** :

| Ordre | Step ID | Rôle |
|-------|---------|------|
| 1 | `Abonne_000_INIT` | Initialisation du programme et des phases |
| 10 | `Abonne_010_DATA` | Chargement des données dynamiques (poids, glycémie, etc.) |
| 20 | `Abonne_020_DATA_QUESTIONNAIRES` | Traitement des réponses questionnaires |
| 30 | `Abonne_030_PROG` | Gestion du programme (phases, transitions) |
| 40 | `Abonne_040_NEWDAY` | Opérations quotidiennes (vidéos, messages, milestones) |
| 50 | `Abonne_050_DATA_COUNTERS` | Mise à jour des compteurs |
| 100 | `Abonne_090_OUT` | Nettoyage et sortie |

---

## 2. Architecture du système expert

### 2.1 Fichiers de règles Drools

| Fichier | Lignes | Nb règles | Domaine |
|---------|--------|-----------|---------|
| `prediabaid.abonne` | 5 688 | ~399 | Programme, phases, formules, quotidien, milestones |
| `prediabaid.questionnaires` | 621 | ~30 | Scoring, groupes, éligibilité, vidéos PT |
| `prediabaid.menus` | 515 | ~25 | Menus, kcal, jours spéciaux |

**Localisation** : `prediabaid-decision-server/rules/prod/`

### 2.2 Données de référence

| Données | Format | Localisation |
|---------|--------|-------------|
| Questionnaires (40+) | XLS | `data/questionnaires/` |
| Messages | XLSX | `data/messages/simples/` |
| Vidéos (11 catégories) | XLS | `data/videos/` |
| Activités | XLS | `data/activites/` |
| Recettes | XLS | `data/menus/` |
| Messages vidéos | XLSX | `data/messages/videos/` |

---

## 3. Profiling & Éligibilité (PT)

### 3.1 Questionnaire PT — Structure complète

Le questionnaire PT (Personal Test) est le **point d'entrée** du système. Il détermine l'éligibilité et le programme.

#### Catégorie 1 : Accueil (`pt.cat.acceuil`)

| Question | ID | Type | Contraintes |
|----------|-----|------|------------|
| Prénom | `prenom` | Text | — |
| Sexe | `sexe` | Radio | homme, femme |
| Date de naissance | `date_naissance` | Date | — |
| Email | `mail` | Email | — |
| Pays | `pays` | ComboSearch | US, FR, CH |
| Diabétique ? | `diabetique` | Radio | non, oui_type1, oui_type2 |

#### Catégorie 2 : Statut & Mesures (`pt.cat.yourstatus`)

| Question | ID | Type | Contraintes | Condition |
|----------|-----|------|------------|-----------|
| État (US) | `etat` | ComboSearch | 50 états US | `pt.pays = US` |
| Ethnie | `ethnie` | Radio | 7 choix | `pt.pays = US` |
| Morphologie | `morphologie` | Radio | gracile, moyen, large | — |
| Répartition masse grasse | `repartition_mg` | Radio | gynoïde, androïde, partout, pas de kilos | — |
| Système d'unités | `unit_system` | Radio | us, metric | — |
| Poids | `poids` | Kilograms | 30-200 kg | — |
| Taille | `taille` | Meters | 0.8-2.2 m | — |

**Champs calculés** :
- `imc` = poids / taille² (IMC/BMI)
- `age` = calculé depuis `date_naissance`

#### Catégorie 3 : Habitudes (`pt.cat.yourhabits`)

| Question | ID | Type | Points par choix |
|----------|-----|------|-----------------|
| Durée des repas | `duree_repas` | Radio | <21min: 2, 21-40min: 2, >40min: 0 |
| Grignotage | `grignotage` | Radio | jamais: 0, 1-2x: 3, 3+: 5 |
| Somnolences | `somnolences` | Radio | rarement: 0, souvent: 1 |
| Édulcorants | `edulcorants` | Radio | oui: 0, parfois: 0, non: 0, pas de sucre: 0 |
| Bière | `biere` | Radio | jamais: 0, 1v/j: 0, 1v/repas: 1, davantage: 3 |
| Stress/appétit | `stress` | Radio | ouvre: 1, coupe: 0, sans effet: 0 |
| Durée des nuits | `duree_nuits` | Radio | ≥6h: 0, <6h: 1 |

#### Catégorie 4 : Antécédents (`pt.cat.moreinformations`)

| Question | ID | Type | Points par choix |
|----------|-----|------|-----------------|
| Hypertendu | `hypertendu` | Radio | non: 0, modérée: 1, sévère: 2, NSP: 0 |
| Prise de poids 12 mois | `prise_poids_12mois` | Radio | non: 0, 5%: 1, 5-10%: 3, >10%: 5 |
| Diabète T2 famille | `diabetique_t2_famille` | Radio | non: 0, gd-parent/frère: 1, 1 parent: 2, 2 parents: 3, famille: 5, NSP: 0 |
| Hausse glycémie | `hausse_glycemie` | Radio | non: 0, 1 fois: 2, 2 fois: 2, NSP: 0 |
| Végétalien | `vegetalien` | Radio | oui, non |
| Condition médicale | `condition_medical` | Radio | maladie chronique, trouble alimentaire, malaises, étourdissements, vomissements, larmes, non |

### 3.2 Scoring et classification en groupes

```
Score PT = Σ (points de toutes les réponses)

┌─────────────────────┬──────────┐
│ Plage de score      │ Groupe   │
├─────────────────────┼──────────┤
│ 1 - 10              │ G1       │
│ 11 - 20             │ G2       │
│ ≥ 21                │ G3       │
│ 0 (aucun score)     │ Exclu    │
└─────────────────────┴──────────┘
```

### 3.3 Matrice d'éligibilité Groupe × IMC → Formule

| Groupe | IMC < 23 | IMC 23 - 39.9 | IMC ≥ 40 |
|--------|----------|---------------|----------|
| **G1** | NON_COACHABLE | **F1** | NON_COACHABLE |
| **G2** | **F4** | **F2** | NON_COACHABLE |
| **G3** | **F5** | **F3** | NON_COACHABLE |

### 3.4 Vidéos d'éligibilité

| Groupe | IMC | Vidéo déclenchée |
|--------|-----|-----------------|
| G1 | 23-25 | `pt.eligible.g1.23_25` |
| G1 | 25-30 | `pt.eligible.g1.25_30` |
| G1 | 30-40 | `pt.eligible.g1.30_40` |
| G2 | <25 | `pt.eligible.g2.moins23` |
| G2 | 25-30 | `pt.eligible.g2.25_30` |
| G2 | 30-40 | `pt.eligible.g2.30_40` |
| G3 | <25 | `pt.eligible.g2.moins23` |
| G3 | 25-30 | `pt.eligible.g2.25_30` |
| G3 | 30-40 | `pt.eligible.g2.30_40` |

### 3.5 Règles d'exclusion

- **G1 + IMC < 23** → Questionnaire interrompu, vidéo `pt.exclusion.imc_23`
- **Score = 0** → Questionnaire interrompu, vidéo d'exclusion

---

## 4. Formules de coaching (F1-F5)

### 4.1 Formule F1 (G1, IMC 23-40) — Risque faible, surpoids

| Phase | Age < 45 & IMC < 25 | Age < 45 & IMC ≥ 25 | Age ≥ 45 & IMC < 25 | Age ≥ 45 & IMC ≥ 25 |
|-------|---------------------|---------------------|---------------------|---------------------|
| CARNET | 2j | 2j | 2j | 2j |
| DETOX | 1j | 2j | 1j | 1j |
| INTENSIVE | 0j | 42j + `JUMP_PROG2` | 0j | 0j |
| PROGRESSIVE | 7j + `ADD_WEEK` | 84j | 7j + `ADD_WEEK` | 28j |
| INTENSIVE_2 | 0j | 14j | 0j | 0j |
| PROGRESSIVE_2 | 0j | 7j + `ADD_WEEK` | 0j | 0j |
| STABILISATION | 365j | 365j | 365j | 365j |

### 4.2 Formule F2 (G2, IMC 23-40) — Risque modéré, surpoids

| Phase | Age < 45 & IMC < 25 | Age < 45 & IMC ≥ 25 | Age ≥ 45 & IMC < 25 | Age ≥ 45 & IMC ≥ 25 |
|-------|---------------------|---------------------|---------------------|---------------------|
| CARNET | 2j | 2j | 2j | 2j |
| DETOX | 1j | 2j | 1j | 1j |
| INTENSIVE | 0j | 21j + `JUMP_PROG2` | 0j | 0j |
| PROGRESSIVE | 7j + `ADD_WEEK` | 42j | 7j + `ADD_WEEK` | 28j |
| INTENSIVE_2 | 0j | 21j | 0j | 0j |
| PROGRESSIVE_2 | 0j | 7j + `ADD_WEEK` | 0j | 0j |
| STABILISATION | 365j | 365j | 365j | 365j |

### 4.3 Formule F3 (G3, IMC 23-40) — Risque élevé, surpoids

| Phase | Age < 45 & IMC < 25 | Age < 45 & IMC ≥ 25 | Age ≥ 45 & IMC < 25 | Age ≥ 45 & IMC ≥ 25 |
|-------|---------------------|---------------------|---------------------|---------------------|
| CARNET | 2j | 2j | 2j | 2j |
| INTENSIVE | 0j | 28j + `JUMP_PROG2` | 0j | 0j |
| PROGRESSIVE | 7j + `JUMP_STAB` | 56j + `LOOP_2_LAST` | 7j + `JUMP_STAB` | 28j |
| INTENSIVE_2 | 0j | 28j | 0j | 0j |
| PROGRESSIVE_2 | 0j | 56j + `LOOP_2_LAST` | 0j | 0j |
| STABILISATION | 365j | 365j | 365j | 365j |

> Note : F3 n'a **pas de phase DETOX**

### 4.4 Formule F4 (G2, IMC < 23) — Risque modéré, poids normal

| Phase | Age < 45 | Age ≥ 45 |
|-------|----------|----------|
| CARNET | 2j | 2j |
| DETOX | 1j | 2j |
| PVBF | 28j | 42j |
| PROGRESSIVE | 21j | 42j |
| STABILISATION | 365j | 365j |

> Note : F4 utilise la phase **PVBF** au lieu d'INTENSIVE

### 4.5 Formule F5 (G3, IMC < 23) — Risque élevé, poids normal

| Phase | Age < 45 | Age ≥ 45 |
|-------|----------|----------|
| CARNET | 2j | 2j |
| DETOX | 0j | 1j |
| PVBF | 28j | 42j |
| PROGRESSIVE | 28j | 42j |
| STABILISATION | 365j | 365j |

### 4.6 Comportements de phase (Phase Behaviors)

| Behavior | Description |
|----------|-------------|
| `IF_PS_JUMP_TO_PROGRESSIVE_2` | Si le poids santé est atteint → sauter à PROGRESSIVE_2 |
| `IF_PI_JUMP_TO_STABILISATION` | Si le poids idéal est atteint → sauter à STABILISATION |
| `UNTIL_PI_ADD_ONE_WEEK` | Ajouter 1 semaine à la phase tant que le poids idéal n'est pas atteint |
| `UNTIL_PI_LOOP_TWO_LAST_PHASES` | Boucler sur les 2 dernières phases jusqu'à atteinte du poids idéal |

### 4.7 Calcul du poids santé

| Groupe | Tolérance | Calcul |
|--------|-----------|--------|
| G1 | 5 kg | `abonne.calculPS(5.0)` |
| G2, G3 | 10 kg | `abonne.calculPS(10.0)` |

---

## 5. Phases du programme

### 5.1 Inventaire complet des phases

| Phase | Type | Durée typique | Description |
|-------|------|---------------|-------------|
| **CARNET** | Per-day | 2 jours | Journal alimentaire initial, collecte de données de base |
| **DETOX** | Per-day | 0-2 jours | Préparation, réduction des toxines |
| **PVBF** | Weekly | 28-42 jours | Phase de base (F4/F5 uniquement) |
| **INTENSIVE** | Weekly | 0-42 jours | Perte de poids active, engagement fort |
| **PROGRESSIVE** | Weekly | 7-84 jours | Transition vers changements durables |
| **INTENSIVE_2** | Weekly | 0-28 jours | Second cycle intensif si nécessaire |
| **PROGRESSIVE_2** | Weekly | 0-56 jours | Second cycle progressif |
| **STABILISATION** | Weekly | 365 jours | Maintien du poids, habitudes pérennes |
| **PAUSE** | Spécial | Jusqu'à 365j | Mise en pause du programme |
| **AUDIT** | Spécial | 7-21 jours | Évaluation périodique |
| **PAUSE_SPORT** | Sportif | 365 jours | Pause de l'activité physique |

### 5.2 Diagramme des transitions

```
                    ┌──────────┐
        ┌──────────►│  PAUSE   │◄─── Glycémie ≥ 126 x2 jours
        │           └────┬─────┘     ou choix utilisateur
        │                │
        │          Sortie PAUSE
        │                │
        ▼                ▼
   ┌─────────┐    ┌──────────┐    ┌───────────┐
   │ CARNET  │───►│  DETOX   │───►│   PVBF    │ (F4/F5)
   │ (2j)    │    │ (0-2j)   │    │ (28-42j)  │
   └─────────┘    └────┬─────┘    └─────┬─────┘
                       │                │
                       ▼                │
                 ┌───────────┐          │
                 │ INTENSIVE │◄─────────┘
                 │ (0-42j)   │
                 └─────┬─────┘
                       │
          ┌────────────┤ PS atteint?
          │            │
          ▼            ▼
   ┌────────────┐ ┌───────────┐
   │PROGRESSIVE │ │PROGRESSIVE│
   │  (7-84j)   │ │    _2     │
   └──────┬─────┘ └─────┬─────┘
          │              │
          │   PI atteint?│
          │              │
          ▼              ▼
   ┌───────────┐  ┌───────────┐
   │INTENSIVE_2│  │STABILISA- │
   │  (0-28j)  │──►│   TION    │
   └───────────┘  │  (365j)   │
                  └───────────┘
                       │
                  ┌────┴────┐
                  │  AUDIT  │ (périodique)
                  └─────────┘
```

### 5.3 Ratio calorique par phase

| Phase | Ratio kcal | Effet |
|-------|-----------|-------|
| CARNET | 1.0 | 100% des besoins |
| DETOX | 1.0 | 100% |
| INTENSIVE | **0.8** | **80% → restriction calorique** |
| INTENSIVE_2 | **0.8** | **80%** |
| PROGRESSIVE | 1.0 | 100% |
| PROGRESSIVE_2 | 1.0 | 100% |
| PVBF | 1.0 | 100% |
| STABILISATION | **1.2** | **120% → maintien/surplus** |
| PAUSE | 1.0 | 100% |
| AUDIT | 1.0 | 100% |

---

## 6. Règles métier (Base de connaissances)

### 6.1 Règles de glycémie

| # | Nom de la règle | Condition | Action |
|---|----------------|-----------|--------|
| 1 | `Diabetique_qui_s_ignore_j1` | glycémie ≥ **126 mg/dL** ET jour 1 (première mesure `bqglycemie`) | Vidéo `video.tr.diabetique_ignore_j1` |
| 2 | `Diabetique_qui_s_ignore_j2` | **2 jours consécutifs** glycémie ≥ 126 ET phase CARNET ≥ 2j | Vidéo `video.tr.diabetique_ignore_j2` + Rappel RDV médecin + **Insertion PAUSE 365 jours** |
| 3 | `Passage_seuil_glycemie` | glycémie passe de > 105 à **50 < x ≤ 105 mg/dL** | Vidéo `video.ac.glycemie_normale` |
| 4 | `glycemie_basse` | glycémie ≤ **50 mg/dL** ET jour 1 | Rappel `abonne.glycemie_basse` |

#### Seuils glycémiques résumés

```
  0 ──────── 50 ──────── 105 ──────── 126 ────────►  mg/dL
  │          │            │            │
  │  HYPO    │  NORMAL    │  ÉLEVÉ     │  DIABÈTE
  │  ≤50     │  51-105    │  106-125   │  ≥126
  │          │            │            │
  │ Alerte   │ Vidéo si   │            │ J1: vidéo
  │ rappel   │ passage    │            │ J2: PAUSE
  │          │ du seuil   │            │ + RDV médecin
```

### 6.2 Règles de poids

| # | Nom | Condition | Action |
|---|-----|-----------|--------|
| 1 | `Atteinte_Poids_Sante` | Poids actuel ≤ poids santé ET amélioration vs précédent | Vidéo `video.ac.atteinte_poids_sante` |
| 2 | `Atteinte_tour_de_taille_ideal_homme` | Homme ET tour de taille ≤ **102 cm** ET amélioration | Vidéo `video.ac.atteinte_tourtaille` |
| 3 | `PI_atteint_saut_stabilisation` | Poids idéal atteint ET phase avec behavior `IF_PI_JUMP_TO_STABILISATION` | Saut vers phase STABILISATION |

### 6.3 Règles de phase et transitions

| # | Nom | Condition | Action |
|---|-----|-----------|--------|
| 1 | `PhaseResetDates` | Phase sans date de fin ET date de démarrage valide | Recalcul des dates de toutes les phases |
| 2 | `NewDay_PhaseTerminee_MessageAgenda` | Phase courante terminée | Message de fin de phase dans l'agenda |
| 3 | `NewDay_DebutPhase_Video_Table` | Début d'une nouvelle phase (11 variantes) | Vidéo spécifique à la phase |
| 4 | `InsertPhaseAt` | Condition de pause/audit | Insertion d'une phase dans le programme |

### 6.4 Règles de jours spéciaux (fêtes religieuses)

| Date | Condition | Message |
|------|-----------|---------|
| 25 déc. | Non-casher ET non-halal | `abonne.intro.christmas` |
| 6 déc. | Non-casher ET non-halal | `abonne.intro.st_nicholas_day` |
| Purim | Casher | `abonne.intro.purim` |
| Eid al-Fitr | Halal | `abonne.intro.fin_ramadan` |
| Pâques | Non-casher ET non-halal | `abonne.intro.easter` |
| Pessah (6j) | Casher | `abonne.intro.passover_day_X` |

### 6.5 Règles de menus spéciaux (ex: 31 décembre)

| Régime | Recette attribuée |
|--------|-------------------|
| Standard | `grilled.beef.sirloin.french.beans` |
| Halal | `oriental.veal.saute.rice.pasta` |
| Casher | `kosher.grilled.beef.sirloin.french.beans` |
| Sans gluten | `herb.roasted.seabass.spinach.quinoa` |
| Halal + sans gluten | `herb.roasted.seabass.spinach.quinoa` |
| Casher + sans gluten | `herb.roasted.seabass.spinach.quinoa` |

### 6.6 Compteurs et monitoring

| Compteur | Logique |
|----------|---------|
| `nb_glycemie_precedentes_inf_actuel` | Nombre de glycémies précédentes inférieures à l'actuelle (seuil 1%) |
| Vidéos vues | `Map<idVideo, nbVues>` dans `AbonneHistoryData` |
| Perte de poids | `perteDePoids` calculé dynamiquement |

---

## 7. Questionnaires

### 7.1 Inventaire complet (40+ questionnaires)

| Catégorie | ID | Nom | Usage |
|-----------|----|-----|-------|
| **Profiling** | `pt` | Personal Test | Éligibilité, classification |
| **Exercice (BE)** | `ba` | Baseline Assessment | Évaluation initiale sport |
| | `bc` | Continuation | Suivi sport |
| | `binit` | Initialization | Introduction sport |
| | `bq` | General | Questionnaire sport général |
| | `bs` | Sport Score | Classification groupe sportif |
| **Santé (BH)** | `bh` | Health Balance | Bilan biométrique |
| **Quotidien (BQ)** | `bqcarnet` | Food Diary | Journal alimentaire |
| | `bqpdej` | Breakfast | Petit-déjeuner |
| | `bqdej` | Lunch | Déjeuner |
| | `bqdiner` | Dinner | Dîner |
| | `bqencas_am` | Afternoon Snack | Encas après-midi |
| | `bqencas_matin` | Morning Snack | Encas matin |
| | `bqglycemie` | Blood Glucose | Glycémie quotidienne |
| | `bqhumeur` | Mood | Humeur |
| | `bqsport` | Sport | Activité physique quotidienne |
| **Éducation (CDC)** | `cours1`→`cours16` | Courses 1-16 | 16 modules éducatifs |
| **Alcool (AUDIT)** | `baudit` | AUDIT Test | Test complet alcool |
| | `baj` | Alcohol Frequency | Fréquence jour |
| | `baj3` | 3-item Alcohol | Version 3 items |
| | `baj6` | 6-item Alcohol | Version 6 items |
| | `sortie_audit` | Exit Audit | Sortie phase audit |
| **Pause** | `pause` | Pause Entry | Entrée en pause |
| | `sortie_pause` | Exit Pause | Sortie normale |
| | `sortie_pause_arret` | Exit Stop | Arrêt programme |
| | `sortie_pause_sport` | Exit Sport Pause | Reprise sport |
| **Contact** | `cb` | Contact Basic | Infos contact basiques |
| | `cc` | Contact Complete | Infos contact complètes |
| **Satisfaction** | `sat1` | Satisfaction | Enquête satisfaction |
| **Quiz** | `quiz6+` | Knowledge Quiz | Tests de connaissances |
| **Exercice test** | `et` | Exercise Test | Test d'effort |

### 7.2 Types de questions supportés (29 types)

#### Types basiques
| Type | Valeur retournée | Description |
|------|-----------------|-------------|
| `Text` | String | Texte libre |
| `Email` | String | Email validé |
| `Radio` | String | Choix unique |
| `Combo` | String | Dropdown |
| `ComboSearch` | String | Dropdown avec recherche |
| `Date` | Date | Sélecteur de date |
| `Num` | Double | Nombre décimal |
| `Int` | Integer | Nombre entier |

#### Types slider
| Type | Valeur | Description |
|------|--------|-------------|
| `SliderNum` | Double | Slider numérique |
| `SliderInt` | Integer | Slider entier |
| `SliderRadio` | String | Slider avec libellés |
| `SliderRadioTime` | String | Slider durée |
| `SliderRadioDuration` | String | Slider durée |

#### Types avec unités (objets connectés)
| Type | Unité | Description |
|------|-------|-------------|
| `Kilograms` | kg | Poids |
| `Meters` | m | Taille |
| `Centimeters` | cm→m | Mesures |
| `Glycemy` | mg/dL | Glycémie |
| `Balance_DCIValue` | kcal | Apport calorique |
| `Balance_VFatLevelValue` | 1-60 | Graisse viscérale |
| `Balance_MuscleValue` | % | Masse musculaire |
| `Balance_SkeletonValue` | kg | Masse osseuse |
| `Balance_WaterValue` | % | Hydratation |
| `Balance_WeightFatValue` | % | Masse grasse |
| `Tracker_NbSteps` | pas | Nombre de pas |
| `Tracker_Distance` | km | Distance |
| `Tracker_Calories` | kcal | Calories brûlées |

#### Types quiz
| Type | Description |
|------|-------------|
| `QuizzQuestion` | Question de quiz |
| `QuizzResult` | Résultat de quiz |
| `ActivitePhysique` | Sélection d'activité |
| `PhoneNumber` | Numéro de téléphone |

### 7.3 Scoring du questionnaire BS (Sport)

```
Score BS = Σ (points sport)

┌─────────────────────┬───────────────┐
│ Plage de score      │ Groupe sportif│
├─────────────────────┼───────────────┤
│ 0 - 8               │ GS1           │
│ 9 - 18              │ GS2           │
│ 19 - 35             │ GS3           │
│ ≥ 36                │ GS4           │
└─────────────────────┴───────────────┘
```

### 7.4 Mapping questionnaires ↔ repas

| Type de repas | Questionnaire |
|---------------|---------------|
| PETIT_DEJEUNER | `bqpdej` |
| SNACK_AM | `bqencas_matin` |
| DEJEUNER | `bqdej` |
| SNACK_PM | `bqencas_am` |
| DINER | `bqdiner` |

### 7.5 Structure JSON d'un questionnaire

```json
{
  "questionnaireForm": {
    "idQuestionnaire": "pt",
    "dateKey": "2025-05-22",
    "currentCategory": "pt.cat.acceuil",
    "offline": false,
    "categories": [
      {
        "category": "pt.cat.acceuil",
        "idNextCategory": "pt.cat.yourstatus",
        "questions": [
          {
            "id": "prenom",
            "label": "pt.prenom",
            "type": "Text",
            "order": 1
          },
          {
            "id": "poids",
            "label": "pt.poids",
            "type": "Kilograms",
            "rangeMin": 30.0,
            "rangeMax": 200.0
          }
        ]
      }
    ],
    "results": {
      "ended": true,
      "interrupted": false,
      "score": 9.0,
      "responses": [
        {
          "responsesMap": {
            "prenom": { "value": "John" },
            "imc": { "value": "24.88", "scorePart": 0.0 },
            "group": { "value": "G1" },
            "formule": { "value": "F1" }
          }
        }
      ],
      "videos": [{ "idVideo": "pt.eligible.g1.23_25" }]
    }
  }
}
```

---

## 8. Optimisation des menus

### 8.1 Vue d'ensemble

Le système de menus utilise une **approche en 2 phases** :

```
Phase 1 : SÉLECTION DES RECETTES          Phase 2 : CONSTRUCTION DES MENUS
(Programmation linéaire — LPTK/COIN)       (Heuristique gloutonne + recherche locale)

Entrée : profil, contraintes, recettes    Entrée : recettes sélectionnées + créneaux
Sortie : liste de recettes par type       Sortie : menus quotidiens sur 7 jours
```

### 8.2 Modèle de programmation linéaire

#### Fonction objectif

**Maximiser** le score total des recettes sélectionnées.

Score d'une recette = moyenne des scores de ses ingrédients :

```
Score(ingrédient) = (5 - ClasseOccurrence) × 2 + aléatoire(-2, +2)

Classe A → (5-1)×2 = 8 points
Classe B → (5-2)×2 = 6 points
Classe C → (5-3)×2 = 4 points
Classe D → (5-4)×2 = 2 points

Score(recette) = Σ Score(ingrédients) / nb_ingrédients
                 ÷ 10 si un ingrédient est hors saison
```

#### Variables de décision

| Variable | Type | Description |
|----------|------|-------------|
| `OccurrenceRecette[r]` | Continue ≥ 0 | Nb d'apparitions de la recette r dans la semaine |
| `OccurrenceRecetteParTypeRepas[r, t]` | Continue | Apparitions par type de repas |
| `OccurrenceRecetteParTypeComposantRepas[r, t, c]` | Continue | Par composant de repas |
| `IndicatricesRecettes[r]` | Binaire {0,1} | 1 si la recette est sélectionnée |

#### Contraintes

**C1 — Nombre total de recettes par composant** :
```
∀ (typeRepas t, composant c) :
  Σ OccurrenceParComposant[r, t, c] = NbCréneaux[t, c]
```

**C2 — Fréquence max par recette** :
```
∀ recette r avec maxHebdo > 0 :
  OccurrenceRecette[r] ≤ maxHebdo
```

**C3 — Fréquence par catégorie alimentaire** :
```
∀ catégorie alimentaire C avec maxHebdo > 0 :
  Σ OccurrenceRecette[r] pour r contenant des ingrédients de C ≤ maxHebdo
```

**C4 — Fréquence par recettes équivalentes** :
```
∀ groupe d'équivalence E :
  Σ OccurrenceRecette[r] pour r ∈ E ≤ maxFrequence(E)
```

**C5 — Incompatibilités alimentaires (casher)** :
```
∀ typeRepas t :
  Σ Occ[r contenant Liste1] + Σ Occ[r contenant Liste2] ≤ totalOccurrences(t)
  (Ex: pas de viande + laitier dans le même type de repas)
```

**C6 — Liaison indicatrices ↔ occurrences** :
```
OccurrenceRecette[r] ≤ M × IndicatricesRecettes[r]  (M = maxHebdo)
```

#### Configuration du solveur

- **Presolve** : activé
- **MIP Gap** : 0.2 (20% de tolérance)
- **Phase 1** : trouver une solution réalisable (MaxSols=1)
- **Phase 2** : optimiser pendant 2 secondes max

### 8.3 Contraintes alimentaires

| Contrainte | Filtrage |
|------------|----------|
| **Casher** | Pas de mélange viande/laitier par repas |
| **Halal** | Recettes compatibles halal uniquement |
| **Sans gluten** | Recettes sans gluten uniquement |
| **Végétarien** | Recettes végétariennes uniquement |
| **Saisonnalité** | Score ÷10 si hors saison |
| **Fréquence** | Max par semaine par recette et par catégorie |

### 8.4 Structure des repas

| Type de repas | Composants possibles |
|---------------|---------------------|
| PETIT_DEJEUNER | PLAT, ACCOMPAGNEMENT, BOISSON, DESSERT |
| SNACK_AM | PLAT, DESSERT, BOISSON |
| DEJEUNER | ENTRÉE, PLAT, ACCOMPAGNEMENT, DESSERT, BOISSON |
| SNACK_PM | PLAT, DESSERT, BOISSON |
| DINER | ENTRÉE, PLAT, ACCOMPAGNEMENT, DESSERT, BOISSON |

### 8.5 Calcul des besoins caloriques

```
DER (Dépense Énergétique au Repos) = calculé depuis abonne (âge, sexe, poids, taille)
kcal/jour = DER × phaseKcalRatio

Exemple INTENSIVE : kcal/jour = DER × 0.8  (restriction 20%)
Exemple STABILISATION : kcal/jour = DER × 1.2  (surplus 20%)
```

### 8.6 Saisonnalité

```
Ingrédient en saison si :
  - moisDebut ≤ moisFin  : moisDebut ≤ moisActuel ≤ moisFin
  - moisDebut > moisFin  : moisActuel ≥ moisDebut OU moisActuel ≤ moisFin
    (ex: octobre→mars = saison hivernale)
```

---

## 9. Activité physique & Phases sportives

### 9.1 Classification sportive

4 groupes sportifs (GS1-GS4) issus du questionnaire BS :

| Groupe | Score BS | Niveau de forme |
|--------|---------|-----------------|
| GS1 | 0-8 | Sédentaire |
| GS2 | 9-18 | Peu actif |
| GS3 | 19-35 | Modérément actif |
| GS4 | ≥ 36 | Actif |

### 9.2 Phases sportives

32 règles d'initialisation (8 par groupe × 4 groupes) basées sur **âge** et **IMC** :

**Paramètres par phase sportive** :

| Paramètre | Description |
|-----------|-------------|
| `nbSeances` | Nombre de séances par semaine |
| `dureeMinSceance` | Durée minimale par séance (minutes) |
| `levelMin` | Niveau de difficulté minimum |
| `levelMax` | Niveau de difficulté maximum |

### 9.3 Gestion du handicap

| Type | Code | Impact |
|------|------|--------|
| Handicap total | `isHandicapeD` | Activités adaptées D uniquement |
| Handicap haut du corps | `isHandicapeHH` | Activités adaptées HH |
| Handicap bas du corps | `isHandicapeHB` | Activités adaptées HB |

Chaque activité définit son applicabilité : `HH`, `HB`, `D` via un `TypeApplicabilite`.

### 9.4 Phases sportives spéciales

| Phase | Durée | Déclencheur |
|-------|-------|-------------|
| PAUSE_SPORT | 365j | Insertion avec PAUSE programme |
| PAUSE_SPORT_BAS | Variable | Handicap bas du corps |
| PAUSE_SPORT_HAUT | Variable | Handicap haut du corps |

---

## 10. Vidéos & Messages

### 10.1 Catégories de vidéos

| Fichier source | Catégorie | Description |
|---------------|-----------|-------------|
| `Videos_achievements.xls` | Accomplissements | Milestones atteints |
| `Videos_CDC.xls` | Cours du jour | Contenu éducatif quotidien |
| `Videos_diet.xls` | Nutrition | Conseils diététiques |
| `Videos_exercise.xls` | Exercice | Guides d'activité |
| `Videos_lifestyle.xls` | Mode de vie | Habitudes saines |
| `Videos_oc.xls` | Obstacles | Gestion des difficultés |
| `Videos_preparation.xls` | Préparation | Onboarding |
| `Videos_program.xls` | Programme | Vue d'ensemble |
| `Videos_pt.xls` | Personal Test | Résultats PT |
| `Videos_quiz.xls` | Quiz | Quiz interactifs |
| `Videos_scientific.xls` | Scientifique | Contenu médical |

### 10.2 Modèle de vidéo

```
Video {
  idVideo: String          // Identifiant unique (= clé message)
  title: String            // Clé message du titre
  rubrique: String         // Catégorie/section
  keywords: List<String>   // Mots-clés pour recherche
  text: String             // Version texte du contenu
  learnMore: String        // Liens complémentaires
  priority: Integer        // Priorité d'affichage
  showOnlyOne: Boolean     // Afficher seul ou en liste
}
```

### 10.3 Vidéos de début de phase (11 règles)

Chaque phase déclenche une vidéo spécifique à son démarrage :

| Phase | Vidéo |
|-------|-------|
| CARNET | Vidéo intro carnet |
| DETOX | Vidéo intro détox |
| INTENSIVE | Vidéo intro intensif |
| PROGRESSIVE | Vidéo intro progressif |
| INTENSIVE_2 | Vidéo intro intensif 2 |
| PROGRESSIVE_2 | Vidéo intro progressif 2 |
| STABILISATION | Vidéo intro stabilisation |
| PAUSE | Vidéo intro pause |
| AUDIT | Vidéo intro audit |
| PVBF | Vidéo intro PVBF |
| ... | ... |

### 10.4 Vidéos d'accomplissement

| Condition | Vidéo |
|-----------|-------|
| Poids santé atteint | `video.ac.atteinte_poids_sante` |
| Tour de taille idéal (homme ≤ 102cm) | `video.ac.atteinte_tourtaille` |
| Glycémie redevenue normale | `video.ac.glycemie_normale` |

### 10.5 Messages et notifications

**Types de messages** :

| Sévérité | Usage |
|----------|-------|
| INFO | Messages informatifs |
| Reminder | Rappels (RDV médecin, glycémie basse, etc.) |

**Fichiers de messages** :

| Fichier | Contenu |
|---------|---------|
| `Messages_prediabaid_intro.xls` | Messages d'introduction quotidiens |
| `Messages_prediabaid_program.xlsx` | Messages liés au programme |
| `Messages_prediabaid_formulaires.xlsx` | Labels des questionnaires |
| `Messages_prediabaid_bilans.xlsx` | Messages de bilan |
| `Messages_prediabaid_CDC.xlsx` | Cours du jour |
| `Messages_prediabaid_quiz.xlsx` | Quiz |
| `Messages_prediabaid_satisfaction.xlsx` | Satisfaction |
| `Messages_ErreursService.xls` | Erreurs techniques |

---

## 11. Objets connectés

### 11.1 Glucomètre

**Appareil** : VivaCheck Ino Smart (BLE)

| Paramètre | Valeur |
|-----------|--------|
| Nom BLE | `"BLE-Vivachek"` |
| Service UUID | `0003cdd0-0000-1000-8000-00805f9b0131` |
| Write UUID | `0003cdd2-0000-1000-8000-00805f9b0131` |
| Notify UUID | `0003cdd1-0000-1000-8000-00805f9b0131` |
| Protocole | Modbus RTU variant, CRC-16 |
| Unités | mg/dL ou mmol/L |

**Commandes du protocole** :

| Commande | Octets | Description |
|----------|--------|-------------|
| Serial Number | `0x77 0x55 ... 0x01` | Lecture n° série |
| Unit System | `0xAA 0x55 ... 0x02` | Lecture unité (mg/dL ou mmol/L) |
| Set Time | `0x44 0x66 ... + datetime` | Synchronisation horloge |
| History | `0xDD 0x55 ... 0x03` | Lecture historique mémoire |
| Status | `0x12 0x99 ... 0x0C` | Statut en temps réel |

**Machine à états de mesure** :

```
code 11 → Bandelette insérée
code 22 → Prêt pour le test
code 33 → Sang détecté
code 44 → RÉSULTAT → valeur = (byte_high × 100 + byte_low) / 10
code 55 → Erreur
```

**Conversion d'unités** :
```
mg/dL → mmol/L : valeur / 18.018018
mmol/L → mg/dL : valeur × 18.018018
```

### 11.2 Balance connectée

**Appareils** : iHealth (via OAuth API) + balance BLE (Hetai)

| Mesure | Type question | Unité |
|--------|--------------|-------|
| Poids | `Kilograms` | kg |
| Masse grasse | `Balance_WeightFatValue` | % |
| Masse musculaire | `Balance_MuscleValue` | % |
| Masse osseuse | `Balance_SkeletonValue` | kg |
| Hydratation | `Balance_WaterValue` | % |
| Graisse viscérale | `Balance_VFatLevelValue` | 1-60 |
| DCI | `Balance_DCIValue` | kcal |

### 11.3 Tracker d'activité

| Mesure | Type question | Unité |
|--------|--------------|-------|
| Nombre de pas | `Tracker_NbSteps` | pas |
| Distance | `Tracker_Distance` | km |
| Calories | `Tracker_Calories` | kcal |

### 11.4 API de synchronisation

**Endpoint** : `POST /api/v1/liveReading`

```json
[
  {
    "type": "Glycemy",
    "value": 98.5,
    "date": "2025-05-22T08:30:00"
  }
]
```

**Headers** :
- `Api-Key: 8ebe0ccd8281f72c5651b9a54e688b9780fb3d70`
- `User-Token: <session_token>`
- `User-TimeZone: <timezone>`
- `Accept-Language: <locale>`

---

## 12. Modèle de données

### 12.1 Entité centrale : Abonné (Subscriber)

```
Abonne
├── Identité
│   ├── idAbonne: Long
│   ├── sexe: {F, M}
│   ├── dateNaissance: Date
│   ├── age: Integer (calculé)
│   └── morphologie: {NORMAL, FINE, LARGE}
│
├── Mesures
│   ├── poidsKG: Double
│   ├── tailleM: Double
│   ├── imc: Double (calculé)
│   ├── poidsIdealKG: Double (calculé)
│   ├── poidsSanteKG: Double (calculé)
│   └── nbGrossesses: Integer
│
├── Classification
│   ├── idGroupe: {G1, G2, G3}
│   └── idGroupeSportif: {GS1, GS2, GS3, GS4}
│
├── Préférences alimentaires
│   ├── casher: Boolean
│   ├── halal: Boolean
│   ├── vegetarien: Boolean
│   └── sansGluten: Boolean
│
├── Programme (1-to-1)
│   ├── idFormule: {F1, F2, F3, F4, F5, NON_COACHABLE}
│   ├── phases: List<AbonnePhase>
│   └── phasesSportives: List<AbonnePhaseSportive>
│
├── Agenda (1-to-1)
│   ├── dayData: List<DayData>           // Données quotidiennes
│   ├── activitesData: List<ActivitesData>  // Activités hebdo
│   ├── menusData: List<MenusData>       // Menus hebdo
│   ├── tomorrowData: List<TomorrowData> // Prédictions J+1
│   └── counters: List<Counter>          // Compteurs globaux
│
├── Données dynamiques (1-to-1)
│   ├── dernierPoids: HistoryData
│   ├── dernierTourDeTaille: HistoryData
│   ├── glycemie: HistoryData
│   ├── premiereGlycemie: Data
│   ├── perteDePoids: Double
│   ├── isHandicapeD / HH / HB: Boolean
│   └── dateDemarrage / dateFinAbonnement: Date
│
├── Réponses questionnaires: List<QuestionnaireResponses>
├── Historique: AbonneHistoryData (vidéos vues)
├── Recettes compatibles: List<Recette>
└── Catégories aliments compatibles: List<AlimentCategory>
```

### 12.2 Phase

```
AbonnePhase
├── idPhase: String           // CARNET, DETOX, INTENSIVE, etc.
├── debutPhase: Date
├── finPhase: Date
├── dureeMinJ: Integer        // Durée en jours
├── dureeInitiale: Integer
├── phaseBehavior: String     // IF_PS_JUMP_TO_PROGRESSIVE_2, etc.
└── dayFullWeekStart: Integer
```

### 12.3 Données quotidiennes

```
DayData
├── dateKey: String (YYYYMMDD)
├── videos: List<VideoReference>
├── messages: List<Message>
│   └── Message { severity, idMessage, arguments[] }
├── reminder: List<String>
└── mapNotes: Map<String, AbonneNote>
```

### 12.4 Menu Data

```
MenusData
├── dateKey: String
├── der: Integer                    // Dépense énergétique au repos
├── phaseKcalRatio: Double          // 0.8 à 1.2
├── nbKCalJournalierBesoin: Integer // kcal/jour cible
├── menuPhaseId: String
├── needCallSolver: Boolean
└── menusQuotidiens: List<Menu>
    └── Menu
        ├── dateKey: String
        └── repas: Map<TypeRepas, Repas>
            └── Repas
                ├── typeRepas: TypeRepas
                └── composantsRepas: List<ComposantRepas>
                    └── ComposantRepas { typeComposant, idRecette }
```

### 12.5 Stockage (legacy)

| Couche | Technologie | Usage |
|--------|-------------|-------|
| SQL (MySQL) | Doctrine ORM | Users, Subscriptions, Payments, Tokens |
| MongoDB | Doctrine ODM | Abonnés, Questionnaires, Agendas, Menus, Mesures connectées |
| SQLite (iOS) | CoreData | Cache local (ConnectedObjectData, type="Glycemy") |
| SQLite (Android) | Room | Cache local (MesureDb, type="Glycemy") |

---

## 13. Pistes de modernisation

### 13.1 Stack technique — Ce qui est obsolète

| Composant | Legacy | Problème |
|-----------|--------|----------|
| Backend web | Symfony 2.6, PHP 5.3 | EOL depuis 2017 |
| Decision server | Java 1.6, Spring 3, Jersey 1.8 | EOL, vulnérabilités |
| Drools | 5.6 | Version très ancienne (actuelle: 9.x) |
| Libs ed-* | Java 1.6, Maven | Dépendances Eurodecision internes |
| iOS | Swift ancien, iOS 8+ | APIs dépréciées |
| Android | SDK 26, Support Lib | Besoin de Jetpack/Compose |
| WordPress | Ancien, plugins obsolètes | Sécurité |
| Menu solver | C++ avec LPTK | Difficulté de maintenance |

### 13.2 Ce qui a de la valeur (à conserver)

| Élément | Pourquoi |
|---------|----------|
| **430+ règles métier Drools** | Expertise médicale codifiée — à extraire et moderniser |
| **Matrice Groupe × IMC → Formule** | Logique de personnalisation validée |
| **40+ questionnaires structurés** | Instruments d'évaluation complets |
| **Seuils glycémiques** | Connaissances médicales critiques (50, 105, 126 mg/dL) |
| **Modèle d'optimisation de menus** | Formulation LP complète avec contraintes nutritionnelles |
| **Phases sportives par profil** | 32 configurations d'entraînement personnalisées |
| **Protocole VivaCheck BLE** | Reverse-engineering complet du protocole glucomètre |

### 13.3 Opportunités d'amélioration fonctionnelle

#### A. Moteur de règles → IA hybride

```
Actuel :                              Cible possible :
┌──────────────┐                      ┌──────────────────────┐
│ Règles fixes │                      │ Règles médicales     │ (non négociables)
│ (Drools)     │          →           │ + ML personnalisation│ (apprentissage)
│ Seuils codés │                      │ + LLM explications   │ (capacité d'expliquer)
└──────────────┘                      └──────────────────────┘
```

- **Règles médicales** (seuils glycémie, exclusions) → garder en dur, ce sont des contraintes réglementaires
- **Personnalisation** (durée phases, choix vidéos, scoring recettes) → candidat ML
- **Explications** → module d'explication IA ("nous vous recommandons X parce que...")

#### B. Gestion de l'incertitude

Le système actuel est **binaire** (glycémie ≥ 126 → alerte). Possibilités :
- Logique floue pour les seuils intermédiaires
- Facteurs de confiance Bayésiens
- Modèle prédictif de risque (au lieu de seuils fixes)

#### C. Apprentissage

Le système actuel ne **s'adapte pas**. Possibilités :
- Tracker l'efficacité des recommandations (recettes suivies, poids perdu)
- Ajuster les durées de phase selon les résultats observés
- Recommandation collaborative (utilisateurs similaires)

#### D. Menus — Optimisation enrichie

Le solveur C++ peut être remplacé par :
- **OR-Tools** (Google) — Python, plus maintenu que LPTK
- **PuLP** (Python) — plus simple, suffisant pour la taille du problème
- Ajout de préférences utilisateur (goûts, allergies multiples)
- Prise en compte du budget

#### E. Objets connectés — Élargissement

- Support de glucomètres récents (FreeStyle Libre, Dexcom) via CGM
- Apple Health / Google Health Connect comme hub central
- Wearables (Apple Watch, Garmin) pour activité temps réel

---

## Annexes

### A. Fichiers sources clés

#### Règles Drools
```
prediabaid-decision-server/rules/prod/
├── prediabaid.abonne              (5688 lignes, ~399 règles)
├── prediabaid.questionnaires      (621 lignes, ~30 règles)
└── prediabaid.menus               (515 lignes, ~25 règles)
```

#### Business Objects (Java)
```
prediabaid-decision-server/src/main/java/com/prediabaid/bo/
├── abonne/
│   ├── Abonne.java                (entité centrale)
│   ├── data/
│   │   ├── AbonneDynamicData.java (données dynamiques)
│   │   ├── AbonneQuestionnairesData.java
│   │   └── AbonneQuestionnairesHistoryData.java
│   ├── programme/
│   │   ├── AbonneProgramme.java
│   │   ├── AbonnePhase.java
│   │   └── AbonnePhaseSportive.java
│   ├── agenda/
│   │   ├── Agenda.java
│   │   ├── DayData.java
│   │   ├── MenusData.java
│   │   ├── ActivitesData.java
│   │   └── Counter.java
│   └── menu/
│       └── MenusData.java
├── questions/
│   ├── Questionnaire.java
│   ├── Question.java
│   └── response/
│       ├── QuestionnaireResponses.java
│       └── ResponseValue.java
├── videos/Video.java
├── messages/Message.java
└── activites/Activite.java
```

#### Données de référence
```
prediabaid-data/data/
├── questionnaires/     (40+ fichiers XLS)
│   ├── PT/            (profiling)
│   ├── BE/            (exercice)
│   ├── BH/            (santé)
│   ├── BQ/            (quotidien)
│   ├── CDC/           (16 cours)
│   ├── AUDIT/         (alcool)
│   ├── PAUSE/         (pause)
│   ├── Contact/       (contact)
│   ├── SAT/           (satisfaction)
│   └── Quizz/         (quiz)
├── messages/
│   ├── simples/       (10 fichiers XLSX)
│   ├── videos/        (12 fichiers XLSX)
│   ├── activites/     (2 fichiers XLS)
│   └── menus/         (descriptions recettes)
├── videos/            (11 fichiers XLS)
└── activites/         (Activites.xls)
```

#### Optimisation menus (C++)
```
prediabaid-menu-chooser/src/
├── opt/
│   ├── SessionOpt.hh/cc              (orchestrateur)
│   ├── lp/
│   │   ├── SessionLP.hh/cc           (wrapper solveur LP)
│   │   └── selection_recettes/
│   │       ├── SessionSelectionRecettes.hh/cc
│   │       ├── Frequency*.hh/cc      (contraintes fréquence)
│   │       ├── OccurrenceRecette*.hh/cc
│   │       └── NbRecettes*.hh/cc
│   └── heuristics/
│       └── construction_menus/
│           └── SessionConstructionMenus.hh/cc
└── bo/
    └── dietetique/
        ├── recette/Recette.hh/cc
        └── aliment/Aliment.hh/cc
```

### B. API clés

| Endpoint | Méthode | Description |
|----------|---------|-------------|
| `/api/v1/questionnaire` | POST | Soumettre un questionnaire |
| `/api/v1/questionnaires` | GET | Récupérer les questionnaires disponibles |
| `/api/v1/liveReading` | POST | Envoyer des mesures connectées |
| `/ihealth/register/{userId}` | GET | OAuth iHealth |
| `/admins/ihealth/callback/{userId}` | GET | Callback OAuth iHealth |
| `/patients/{userId}/checkup/quantitative` | GET | Dernières mesures connectées |

### C. Constantes système

| Constante | Valeur | Usage |
|-----------|--------|-------|
| API Key | `8ebe0ccd8281f72c5651b9a54e688b9780fb3d70` | Auth API mobile |
| Glycémie haute | 126 mg/dL | Seuil diabète |
| Glycémie basse | 50 mg/dL | Seuil hypoglycémie |
| Glycémie normale | ≤ 105 mg/dL | Seuil retour normal |
| Tour de taille homme | 102 cm | Seuil idéal |
| PAUSE max | 365 jours | Durée maximale pause |
| STABILISATION | 365 jours | Durée phase stabilisation |
| Tolérance poids G1 | 5 kg | Calcul poids santé |
| Tolérance poids G2/G3 | 10 kg | Calcul poids santé |
| LP MIP Gap | 0.2 | Tolérance optimisation |
| LP timeout Phase 2 | 2s | Temps max optimisation |

---

*Document généré par analyse complète du codebase PrediabAid (13 repositories).*
