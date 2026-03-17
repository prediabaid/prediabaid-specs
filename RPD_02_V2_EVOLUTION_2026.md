# PrediabAid V2 — Evolution 2026
## RPD-02 : Spécifications des fonctionnalités IA & améliorations

**Version** : 1.0
**Date** : 2026-03-17
**Statut** : Draft
**Prérequis** : V1 MVP déployé et fonctionnel (RPD-01)

---

## Table des matières

1. [Onboarding conversationnel](#1-onboarding-conversationnel)
2. [Coaching IA](#2-coaching-ia)
3. [Recommandation ML](#3-recommandation-ml)
4. [Feedback Loop](#4-feedback-loop)
5. [Explainability](#5-explainability)
6. [Devices étendus](#6-devices-étendus)
7. [Analytics & Outcomes](#7-analytics--outcomes)
8. [Dashboard prescripteur](#8-dashboard-prescripteur)
9. [Architecture technique V2](#9-architecture-technique-v2)

---

## 1. Onboarding conversationnel

### 1.1 Problème V1

Le questionnaire PT est un **formulaire monolithique** de ~25 questions. Taux d'abandon potentiel élevé. L'utilisateur ne comprend pas toujours pourquoi on lui pose ces questions.

### 1.2 Solution V2

Remplacer le formulaire par un **onboarding conversationnel** piloté par LLM, qui pose les mêmes questions mais de manière progressive et empathique.

### 1.3 Spécification

```
┌─────────────────────────────────────────────────────┐
│  Chat Onboarding                                     │
│                                                      │
│  🤖 Bonjour ! Je suis votre coach PrediabAid.       │
│     Comment vous appelez-vous ?                      │
│                                                      │
│  👤 Marie                                            │
│                                                      │
│  🤖 Enchanté Marie ! Pour vous créer un programme    │
│     adapté, j'ai besoin d'en savoir un peu plus      │
│     sur vous. Quel âge avez-vous ?                   │
│                                                      │
│  👤 52 ans                                           │
│                                                      │
│  🤖 Merci Marie. Est-ce qu'il y a des cas de        │
│     diabète dans votre famille ?                     │
│                                                      │
│  👤 Oui, mon père est diabétique type 2              │
│                                                      │
│  🤖 Je comprends. C'est bien que vous preniez les   │
│     devants ! Connaissez-vous votre poids et votre   │
│     taille actuels ?                                 │
│                                                      │
│  ...                                                 │
└─────────────────────────────────────────────────────┘
```

#### Architecture

```
Utilisateur ←→ Chat UI ←→ LLM (Claude API)
                              │
                              ▼
                    ┌─────────────────┐
                    │ Structured Data  │
                    │ Extractor        │
                    │                  │
                    │ Entrée: texte    │
                    │ Sortie: JSON     │
                    │ {                │
                    │   "prenom":      │
                    │     "Marie",     │
                    │   "age": 52,     │
                    │   "diabete_     │
                    │    famille":     │
                    │     "1_parent"   │
                    │ }                │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │ PT Scoring      │
                    │ Engine (V1)     │
                    │ → Groupe, IMC,  │
                    │   Formule       │
                    └─────────────────┘
```

#### Règles du LLM

- **Extraction structurée** : chaque réponse est parsée en données structurées (même format que V1)
- **Scoring identique** : le scoring PT reste le même, seule l'interface change
- **Questions obligatoires** : le LLM doit collecter TOUTES les données nécessaires au scoring
- **Garde-fous** : si l'utilisateur dit "je suis diabétique type 1", interrompre avec message adapté
- **Progressif** : les questions les plus sensibles (poids, antécédents) arrivent après avoir établi un rapport
- **Multi-session** : l'utilisateur peut revenir plus tard et reprendre là où il en était

### 1.4 User Stories

| ID | Story | Priorité |
|----|-------|----------|
| ONB2-01 | En tant que nouvel utilisateur, je fais mon onboarding via une conversation naturelle | P0 |
| ONB2-02 | En tant que nouvel utilisateur, je comprends pourquoi chaque question m'est posée | P0 |
| ONB2-03 | En tant que nouvel utilisateur, je peux revenir terminer mon onboarding plus tard | P1 |
| ONB2-04 | En tant que nouvel utilisateur, je reçois des encouragements pendant le processus | P1 |

---

## 2. Coaching IA

### 2.1 Problème V1

Le système V1 envoie des **vidéos et messages génériques** pré-enregistrés. Pas de personnalisation du ton, du timing, ou du contenu au-delà de la phase courante.

### 2.2 Solution V2

Un **coach IA** basé sur LLM qui :
- Analyse le contexte complet de l'utilisateur (phase, mesures, progression, comportement)
- Génère des messages personnalisés et motivationnels
- Répond aux questions nutrition/santé
- Adapte son ton au profil (âge, niveau, culture)

### 2.3 Cas d'usage

#### 2.3.1 Message quotidien personnalisé

```
CONTEXTE (injecté dans le prompt) :
- Marie, 52 ans, F2, phase PROGRESSIVE jour 15/28
- Glycémie hier : 102 mg/dL (dans la norme)
- Poids cette semaine : -0.3 kg (tendance bonne)
- A suivi le menu 4/5 jours
- N'a pas fait de sport depuis 3 jours

MESSAGE GÉNÉRÉ :
"Bonjour Marie ! Votre glycémie reste stable à 102 mg/dL,
c'est très encourageant. Vous avez bien suivi vos menus cette
semaine, bravo ! Par contre, je remarque que vous n'avez pas
bougé depuis mercredi — même 15 minutes de marche après le
déjeuner ferait une différence. Qu'est-ce qui vous en empêche ?"
```

#### 2.3.2 Réponse aux questions

```
👤 Est-ce que je peux manger des pâtes ce soir ?

🤖 Oui, les pâtes sont prévues dans votre menu de ce soir !
   Vous avez des pennes complètes aux légumes grillés.
   Les pâtes complètes sont meilleures pour votre glycémie
   car les fibres ralentissent l'absorption du sucre.
   Si vous préférez autre chose, je peux vous proposer
   des alternatives.
```

#### 2.3.3 Réaction aux mesures

```
[Glycémie mesurée : 118 mg/dL — en hausse]

🤖 Marie, votre glycémie est à 118 mg/dL ce matin, un peu
   plus haute que d'habitude. Pas de panique — ça peut être
   lié à un repas plus riche hier soir ou au stress.
   Quelques actions pour aujourd'hui :
   • Privilégiez les légumes verts au déjeuner
   • Une marche de 20 min après le repas aide beaucoup
   • On en reparle demain avec la prochaine mesure

   ⚠️ Si votre glycémie reste au-dessus de 126 mg/dL
   pendant 2 jours, je vous recommanderai de consulter
   votre médecin.
```

### 2.4 Architecture

```
┌────────────────────────────────────────────┐
│              Coach IA Service               │
│                                             │
│  ┌───────────┐    ┌──────────────────────┐ │
│  │ Context    │    │ Claude API           │ │
│  │ Builder    │───►│                      │ │
│  │            │    │ System prompt :      │ │
│  │ • Profil   │    │ "Tu es un coach     │ │
│  │ • Phase    │    │  santé bienveillant  │ │
│  │ • Mesures  │    │  et précis..."      │ │
│  │ • Menus    │    │                      │ │
│  │ • Historiq. │    │ + Règles médicales  │ │
│  │ • Objectifs│    │   (garde-fous)      │ │
│  └───────────┘    └──────────┬───────────┘ │
│                              │              │
│  ┌───────────────────────────▼────────────┐│
│  │ Safety Layer                            ││
│  │ • Ne jamais diagnostiquer               ││
│  │ • Référer au médecin si seuils atteints ││
│  │ • Ne pas contredire le programme        ││
│  │ • Pas de conseil médicamenteux          ││
│  └────────────────────────────────────────┘│
└────────────────────────────────────────────┘
```

### 2.5 Garde-fous médicaux (non négociables)

| Règle | Action |
|-------|--------|
| Glycémie ≥ 126 mg/dL x2 jours | "Consultez votre médecin" (pas de coaching, référer) |
| Glycémie ≤ 50 mg/dL | Alerte urgente, pas de coaching |
| Question sur médicaments | "Je ne suis pas habilité à vous conseiller sur les médicaments, parlez-en à votre médecin" |
| Symptômes graves décrits | Redirection urgences/médecin |
| Demande de diagnostic | "Je ne suis pas médecin, mais je peux vous aider avec votre programme" |

### 2.6 API

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/api/v2/coach/message` | Envoyer un message au coach |
| GET | `/api/v2/coach/daily-insight` | Insight personnalisé du jour |
| GET | `/api/v2/coach/history` | Historique de conversation |

---

## 3. Recommandation ML

### 3.1 Problème V1

Le solveur LP sélectionne les recettes sur des **scores nutritionnels statiques**. Il ne sait pas si l'utilisateur aime le poisson ou déteste les brocolis.

### 3.2 Solution V2

Couche de **personnalisation ML** au-dessus du solveur :

```
V1 (maintenu) :                  V2 (ajouté) :
┌──────────────┐                 ┌──────────────────┐
│ Solveur LP   │                 │ ML Scoring        │
│              │                 │                    │
│ Filtre :     │                 │ Inputs :           │
│ • Allergies  │                 │ • Historique suivi │
│ • Casher     │    Score LP     │ • Notes recettes   │
│ • Kcal       │───────────────►│ • Profil similaires│
│              │    +            │ • Saisonnalité     │
│ Score :      │    Score ML     │                    │
│ • Nutrition  │◄───────────────│ Output :           │
│ • Saison     │                 │ • Score perso 0-1  │
└──────────────┘                 └──────────────────┘

Score final = α × Score_LP + β × Score_ML
(α = 0.6, β = 0.4 au début, ajustable)
```

### 3.3 Données collectées pour le ML

| Signal | Source | Poids |
|--------|--------|-------|
| Recette suivie (menu respecté) | Questionnaire repas | Fort |
| Recette substituée | Action substitution | Fort (négatif) |
| Note recette (like/dislike) | UI feedback | Fort |
| Recette non trackée (ignorée) | Absence de tracking | Moyen (négatif) |
| Ingrédients en commun avec recettes aimées | Calcul | Moyen |
| Profils similaires qui aiment cette recette | Collaborative filtering | Faible (au début) |

### 3.4 Modèle

**Phase 1** (peu de données) : Content-based filtering
- Embeddings de recettes basés sur : ingrédients, catégories, type de repas, kcal
- Similarité cosinus avec les recettes "aimées" par l'utilisateur

**Phase 2** (données suffisantes) : Collaborative filtering
- Matrice utilisateurs × recettes (implicite : suivi/pas suivi)
- ALS (Alternating Least Squares) ou Neural Collaborative Filtering

### 3.5 Ajustement dynamique des phases

En plus des menus, le ML peut ajuster :

| Paramètre | V1 (fixe) | V2 (adaptatif) |
|-----------|-----------|----------------|
| Durée PROGRESSIVE | 28 jours (F2, ≥45, ≥25 IMC) | 28j ± ajustement selon perte de poids réelle |
| Ratio kcal INTENSIVE | 0.8 fixe | 0.75-0.85 selon réponse métabolique |
| Nb séances sport/semaine | Fixe par GS | Ajusté selon compliance réelle |

### 3.6 User Stories

| ID | Story | Priorité |
|----|-------|----------|
| ML-01 | En tant qu'utilisateur, mes menus s'améliorent au fil du temps selon mes goûts | P0 |
| ML-02 | En tant qu'utilisateur, je peux noter une recette (j'aime / j'aime pas) | P0 |
| ML-03 | En tant qu'utilisateur, les recettes que je n'aime jamais disparaissent | P1 |
| ML-04 | En tant qu'utilisateur, la durée de mes phases s'adapte à ma progression | P2 |

---

## 4. Feedback Loop

### 4.1 Problème V1

**Zéro feedback.** Le système pousse des recommandations mais ne mesure jamais :
- L'utilisateur a-t-il suivi le menu ?
- La recette lui a-t-elle plu ?
- La phase a-t-elle été efficace ?
- Le programme produit-il des résultats ?

### 4.2 Architecture du feedback loop

```
         RECOMMANDATION                    MESURE
    ┌─────────────────────┐         ┌──────────────────┐
    │ Menu de la semaine   │         │ Questionnaire     │
    │ Vidéo du jour        │────────►│ repas (suivi?)    │
    │ Activité proposée    │         │ Note recette      │
    │ Objectif glycémie    │         │ Sport réalisé?    │
    └─────────────────────┘         │ Mesure glycémie   │
                                     └────────┬─────────┘
                                              │
                                     ┌────────▼─────────┐
                                     │ Event Store       │
                                     │                   │
                                     │ menu_followed     │
                                     │ recipe_rated      │
                                     │ sport_completed   │
                                     │ glycemia_measured  │
                                     │ weight_measured    │
                                     │ video_watched      │
                                     │ phase_completed    │
                                     └────────┬─────────┘
                                              │
                                     ┌────────▼─────────┐
                                     │ Analytics Engine  │
                                     │                   │
                                     │ • Compliance rate │
                                     │ • Recipe scoring  │
                                     │ • Phase efficacy  │
                                     │ • Outcome tracking│
                                     └────────┬─────────┘
                                              │
                                     ┌────────▼─────────┐
                                     │ ML Model Update   │
                                     │                   │
                                     │ Retrain scoring   │
                                     │ Adjust durations  │
                                     │ Personalize content│
                                     └─────────────────┘
```

### 4.3 Events trackés

| Event | Données | Fréquence |
|-------|---------|-----------|
| `menu.followed` | { date, meal_type, recipe_id, followed: bool } | Par repas |
| `recipe.rated` | { recipe_id, rating: 1-5 } | Optionnel |
| `recipe.substituted` | { original_id, substitute_id, reason } | Par substitution |
| `sport.completed` | { activity, duration_min, intensity } | Par session |
| `glycemia.measured` | { value, unit, source } | Quotidien |
| `weight.measured` | { value, source } | Hebdomadaire |
| `video.watched` | { video_id, watched_pct } | Par vidéo |
| `phase.completed` | { phase_id, duration_actual, weight_delta } | Par phase |
| `questionnaire.submitted` | { questionnaire_id, responses } | Variable |

### 4.4 Métriques calculées

| Métrique | Formule | Usage |
|----------|---------|-------|
| Menu compliance | repas suivis / repas proposés | Score utilisateur |
| Recipe affinity | (suivis + notes) / propositions | Scoring ML recettes |
| Sport compliance | séances réalisées / séances proposées | Ajustement phases sportives |
| Glycemia trend | régression linéaire sur 30j | Efficacité programme |
| Weight trend | régression linéaire sur 30j | Progression vers PS/PI |
| Phase efficacy | poids perdu / durée phase | Optimisation durées |

---

## 5. Explainability

### 5.1 Problème V1

Le système ne dit **jamais pourquoi** il recommande quelque chose. L'utilisateur ne sait pas pourquoi ce menu, cette vidéo, cette phase.

### 5.2 Solution V2

Chaque recommandation est accompagnée d'une **explication générée** :

### 5.3 Exemples

#### Menu
```
🍽️ Menu du jour : Saumon vapeur + quinoa + brocolis

💡 Pourquoi ce menu ?
• Le saumon est riche en oméga-3, bénéfique pour votre
  sensibilité à l'insuline
• Le quinoa a un index glycémique bas (35), idéal pour
  maintenir votre glycémie stable
• Ce repas apporte 520 kcal, en ligne avec votre objectif
  de 1600 kcal/jour en phase Intensive
```

#### Phase
```
📅 Vous entrez en phase Progressive (28 jours)

💡 Pourquoi cette phase ?
• Vous avez perdu 2.3 kg en phase Intensive, bravo !
• Votre glycémie s'est stabilisée autour de 100 mg/dL
• La phase Progressive va consolider ces acquis avec un
  retour progressif à un apport calorique normal (2000 kcal)
• L'objectif : que ces nouvelles habitudes deviennent naturelles
```

#### Alerte glycémie
```
⚠️ Glycémie : 130 mg/dL (élevée)

💡 Ce que ça signifie :
• Votre glycémie à jeun est au-dessus de 126 mg/dL
• Cela peut indiquer un diabète non diagnostiqué
• Ce n'est PAS un diagnostic — seul votre médecin peut confirmer
• 👨‍⚕️ Je vous recommande de prendre RDV avec votre médecin
  pour un test HbA1c
```

### 5.4 Architecture

```
Recommandation (menu, phase, alerte)
        │
        ▼
┌───────────────────┐
│ Explanation Engine │
│                    │
│ 1. Template-based  │  ← Pour les règles médicales (déterministe)
│    (V1 rules)      │
│                    │
│ 2. LLM-generated   │  ← Pour le coaching et la nutrition (génératif)
│    (Claude API)     │
│                    │
│ Input: contexte    │
│ Output: texte      │
│ + source citations │
└───────────────────┘
```

**Règle** : les explications médicales (seuils, alertes) utilisent des **templates validés** par un médecin, pas du LLM libre.

---

## 6. Devices étendus

### 6.1 Apple Health / Google Health Connect

| Donnée | Lecture | Écriture |
|--------|---------|----------|
| Pas | ✓ | — |
| Distance | ✓ | — |
| Calories actives | ✓ | — |
| Fréquence cardiaque | ✓ | — |
| Poids | ✓ | ✓ |
| Glycémie | ✓ | ✓ |
| Sommeil | ✓ | — |

**Avantage** : agrège les données de TOUS les appareils de l'utilisateur (montre, balance, glucomètre) sans intégration BLE directe.

### 6.2 CGM (Continuous Glucose Monitoring)

Support des glucomètres en continu :

| Appareil | Méthode d'intégration |
|----------|----------------------|
| FreeStyle Libre (Abbott) | LibreLink app → Apple Health → PrediabAid |
| Dexcom G7 | Dexcom app → Apple Health → PrediabAid |
| Via API directe | Dexcom API (OAuth) / LibreView API |

**Impact fonctionnel** : avec un CGM, la glycémie est mesurée toutes les 5 minutes → les règles de seuil peuvent évoluer vers du **monitoring continu** avec alertes en temps réel.

### 6.3 Wearables

| Donnée | Source | Usage |
|--------|--------|-------|
| Pas quotidiens | Apple Watch, Garmin, Fitbit | Vérification objectif sport |
| Calories brûlées | Idem | Ajustement kcal menus |
| Fréquence cardiaque repos | Idem | Indicateur stress/forme |
| Sommeil (durée + qualité) | Idem | Corrélation avec glycémie |

---

## 7. Analytics & Outcomes

### 7.1 Dashboard utilisateur avancé

```
┌─────────────────────────────────────────────────────┐
│  Mes résultats — 3 mois de programme                 │
│                                                      │
│  📊 Glycémie                    ⚖️ Poids              │
│  ┌─────────────────┐           ┌─────────────────┐  │
│  │  Début: 118     │           │  Début: 87 kg   │  │
│  │  Actuel: 98     │           │  Actuel: 82 kg  │  │
│  │  Δ: -17%  ✅    │           │  Δ: -5.7%  ✅   │  │
│  │  [graphique]    │           │  [graphique]    │  │
│  └─────────────────┘           └─────────────────┘  │
│                                                      │
│  🏃 Activité                   🍽️ Compliance menus   │
│  ┌─────────────────┐           ┌─────────────────┐  │
│  │  150 min/sem     │           │  78% suivi       │  │
│  │  Objectif: 120   │           │  Objectif: 80%   │  │
│  │  ✅ Atteint      │           │  ⚠️ Presque      │  │
│  └─────────────────┘           └─────────────────┘  │
│                                                      │
│  📈 Score de risque PrediabAid                       │
│  ┌─────────────────────────────────────────────┐    │
│  │  Début: 17/40 (G2)  →  Actuel: 11/40 (G2)  │    │
│  │  ████████████░░░░░░░░  → ██████░░░░░░░░░░░  │    │
│  │  Tendance: -35% de risque                    │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

### 7.2 Cohorte analytics (pour l'admin/business)

| Métrique | Description |
|----------|-------------|
| Réduction moyenne glycémie par formule | F1: -X%, F2: -Y%, ... |
| Taux d'atteinte PS par phase | % users atteignant poids santé |
| Durée moyenne par phase | Réel vs prévu |
| Taux de PAUSE | % users entrant en pause et pourquoi |
| NPS par phase | Satisfaction utilisateur |
| Recettes les plus suivies/ignorées | Top/flop recettes |
| Corrélation sport ↔ glycémie | Impact activité sur glucose |

---

## 8. Dashboard prescripteur

### 8.1 Fonctionnalités

Interface web pour les médecins/nutritionnistes qui prescrivent PrediabAid :

| Fonctionnalité | Description |
|----------------|-------------|
| Liste patients | Tous les patients avec statut (phase, dernière mesure, alertes) |
| Fiche patient | Profil complet, courbes glycémie/poids, programme, compliance |
| Alertes | Glycémie hors seuils, inactivité prolongée, abandon |
| Messages | Envoyer un message au patient via l'app |
| Export | Données patient en PDF pour consultation |
| Prescriptions | Ajuster le programme (durée phase, objectif kcal) |

### 8.2 Alertes prescripteur

| Alerte | Seuil | Action |
|--------|-------|--------|
| 🔴 Glycémie critique | ≥ 126 mg/dL x2j | Notification push immédiate |
| 🟠 Glycémie élevée | > 105 mg/dL x3j | Email quotidien |
| 🟠 Inactivité | Pas de connexion 7j | Email hebdo |
| 🟡 Prise de poids | +2 kg en 1 semaine | Alerte dans dashboard |
| 🔴 Hypoglycémie | ≤ 50 mg/dL | Notification push immédiate |

---

## 9. Architecture technique V2

### 9.1 Ajouts à la stack V1

| Composant | Technologie | Usage |
|-----------|-------------|-------|
| LLM | Claude API (Anthropic) | Coaching, onboarding conversationnel, explications |
| ML Pipeline | Python + scikit-learn + LightGBM | Scoring recettes, ajustement phases |
| Vector Store | pgvector (extension PostgreSQL) | Embeddings recettes pour similarité |
| Event Store | PostgreSQL (table events) ou ClickHouse | Feedback loop events |
| Job Scheduler | BullMQ (Node) ou Celery (Python) | ML retrain, daily insights generation |
| Health APIs | Apple HealthKit, Google Health Connect | Données wearables |
| Analytics | Metabase | Dashboard analytics interne |

### 9.2 Architecture complète

```
┌───────────────────────────────────────────────────────────────┐
│                         MOBILE APP                             │
│                    React Native (Expo)                          │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌───────────┐ │
│  │Onboard│ │Menus │ │Track │ │Coach │ │Charts│ │HealthKit  │ │
│  │Chat   │ │      │ │      │ │Chat  │ │      │ │/Health    │ │
│  │(LLM)  │ │      │ │      │ │(LLM) │ │      │ │Connect    │ │
│  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘ └───────────┘ │
└────────────────────────┬──────────────────────────────────────┘
                         │ HTTPS
┌────────────────────────▼──────────────────────────────────────┐
│                       BACKEND API                              │
│                                                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐   │
│  │ V1 Modules   │  │ V2 Modules   │  │ Background Jobs     │   │
│  │              │  │              │  │                     │   │
│  │ Auth         │  │ Coach AI     │  │ Daily insight gen   │   │
│  │ Rules Engine │  │ ML Scoring   │  │ Menu generation     │   │
│  │ Program      │  │ Explain      │  │ ML model retrain    │   │
│  │ Menu Solver  │  │ Feedback     │  │ Notification send   │   │
│  │ Questionnaire│  │ Analytics    │  │ Health data sync    │   │
│  │ Content      │  │              │  │                     │   │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘   │
│         │                │                     │               │
└─────────┼────────────────┼─────────────────────┼───────────────┘
          │                │                     │
  ┌───────▼────────────────▼─────────────────────▼───────────┐
  │                    DATA LAYER                              │
  │                                                            │
  │  ┌──────────────┐  ┌──────────┐  ┌──────────────────────┐│
  │  │ PostgreSQL    │  │ pgvector │  │ Claude API           ││
  │  │              │  │          │  │ (Anthropic)          ││
  │  │ Users        │  │ Recipe   │  │                      ││
  │  │ Subscribers  │  │ embeddings│  │ Coaching prompts    ││
  │  │ Programs     │  │          │  │ Explanations        ││
  │  │ Menus        │  │ User     │  │ Onboarding          ││
  │  │ Readings     │  │ preferences│ │                      ││
  │  │ Events       │  │          │  │                      ││
  │  └──────────────┘  └──────────┘  └──────────────────────┘│
  └────────────────────────────────────────────────────────────┘
```

### 9.3 Tables additionnelles V2

```sql
-- Events de feedback
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID REFERENCES subscribers(id),
    event_type VARCHAR(50) NOT NULL,
    data JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_events_subscriber_type ON events(subscriber_id, event_type, created_at);

-- Préférences recettes (ML)
CREATE TABLE recipe_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID REFERENCES subscribers(id),
    recipe_id VARCHAR(100) NOT NULL,
    rating DECIMAL(2,1), -- 1.0 à 5.0, null si implicite
    followed BOOLEAN,
    substituted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_recipe_prefs ON recipe_preferences(subscriber_id, recipe_id);

-- Embeddings recettes
CREATE TABLE recipe_embeddings (
    recipe_id VARCHAR(100) PRIMARY KEY,
    embedding vector(256), -- pgvector
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Conversations coach
CREATE TABLE coach_conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID REFERENCES subscribers(id),
    messages JSONB NOT NULL, -- [{ role, content, timestamp }]
    context JSONB, -- contexte injecté
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insights générés
CREATE TABLE daily_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscriber_id UUID REFERENCES subscribers(id),
    date_key DATE NOT NULL,
    insight_text TEXT NOT NULL,
    insight_type VARCHAR(50), -- motivation, alert, achievement, tip
    generated_by VARCHAR(20), -- 'template', 'llm'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(subscriber_id, date_key, insight_type)
);
```

### 9.4 Coûts estimés LLM

| Usage | Appels/jour/user | Tokens/appel | Coût/user/mois (Claude Haiku) |
|-------|-----------------|-------------|-------------------------------|
| Daily insight | 1 | ~500 | ~$0.015 |
| Coach chat (5 msg) | 5 | ~1000 | ~$0.075 |
| Menu explanation | 1 | ~300 | ~$0.009 |
| Onboarding (1x) | 1 | ~2000 | ~$0.06 (one-time) |
| **Total mensuel** | | | **~$0.10/user/mois** |

> Avec Claude Haiku pour les messages quotidiens et Sonnet pour le coaching conversationnel. Coût très raisonnable.

---

## 10. Priorités V2

| Lot | Fonctionnalité | Effort | Impact | Priorité |
|-----|---------------|--------|--------|----------|
| 1 | Feedback loop (events + analytics) | Moyen | Très haut | **P0** |
| 2 | Coaching IA (daily insight + chat) | Moyen | Très haut | **P0** |
| 3 | ML scoring recettes (préférences) | Moyen | Haut | **P1** |
| 4 | Explainability (menus + phases) | Faible | Haut | **P1** |
| 5 | Apple Health / Health Connect | Moyen | Haut | **P1** |
| 6 | Onboarding conversationnel | Moyen | Moyen | **P2** |
| 7 | Dashboard prescripteur | Élevé | Moyen | **P2** |
| 8 | CGM support | Faible | Moyen | **P2** |
| 9 | Ajustement dynamique phases (ML) | Élevé | Moyen | **P3** |
| 10 | Cohorte analytics | Moyen | Business | **P3** |

---

*Ce document définit la vision V2. L'implémentation démarre après validation du MVP V1 en production.*
