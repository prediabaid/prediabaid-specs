# Glyc Pro — Dimension comportementale
## RPD-06 : Psychologie, emotions et changement d'habitudes

**Version** : 1.0
**Date** : 2026-03-19
**Statut** : Valide
**Principe** : La dimension comportementale n'est pas un module separe. Elle est tissee dans le coaching IA. Le coach comprend la psychologie du changement et l'applique naturellement dans chaque interaction.

---

## Table des matieres

1. [Pourquoi c'est indispensable](#1-pourquoi-cest-indispensable)
2. [Cadre theorique](#2-cadre-theorique)
3. [Les 7 dimensions comportementales](#3-les-7-dimensions-comportementales)
4. [Integration dans le coaching IA](#4-integration-dans-le-coaching-ia)
5. [Collecte de donnees comportementales](#5-collecte-de-donnees-comportementales)
6. [Bilans comportementaux](#6-bilans-comportementaux)
7. [Patterns et interventions](#7-patterns-et-interventions)
8. [Garde-fous sante mentale](#8-garde-fous-sante-mentale)
9. [Ce qu'on ne fait pas](#9-ce-quon-ne-fait-pas)
10. [Impact sur le produit](#10-impact-sur-le-produit)

---

## 1. Pourquoi c'est indispensable

### Le constat clinique

L'etude DPP (Diabetes Prevention Program), reference mondiale en prevention du diabete, a demontre que l'**intervention comportementale** reduit le risque de diabete T2 de **58%** — plus efficace que la metformine (31%). L'intervention etait : alimentation + sport + **coaching comportemental**.

Les programmes qui echouent sont ceux qui donnent de l'information sans changer les comportements. Le patient sait qu'il faut manger des legumes. Le probleme n'est pas le savoir, c'est le faire.

### Le trou dans le legacy PrediabAid

| Ce que le legacy avait | Ce qui manquait |
|---|---|
| 1118 recettes optimisees | Comprendre pourquoi le patient ne les suit pas |
| 430 regles medicales | Zero regle sur le comportement |
| Questionnaire humeur (slider 0-10) | Aucune action declenchee par l'humeur |
| Videos "obstacles" (4 videos) | Obstacles techniques, pas emotionnels |
| Messages generiques | Aucune adaptation au contexte emotionnel |

Le systeme collectait l'humeur et n'en faisait rien. C'est comme avoir un thermometre et ne jamais lire la temperature.

### Le benchmark Noom

Noom a bati un business a $600M de CA sur un constat simple : la nutrition est un probleme de psychologie, pas de dietetique. Leur produit : 80% CBT (therapie cognitive-comportementale), 20% nutrition.

Leur limite : aucune dimension medicale. Pas de CGM, pas de solveur nutritionnel, pas de suivi praticien, pas de regles cliniques.

**Glyc Pro peut combiner les deux** : la rigueur medicale (regles, solveur, CGM, praticien) + la dimension comportementale (coaching IA psychologiquement informe). C'est le positionnement unique.

---

## 2. Cadre theorique

Le coaching comportemental de Glyc Pro s'appuie sur 4 modeles valides cliniquement. Pas besoin de les nommer au patient — le coach les applique naturellement.

### 2.1 Modele transtheorique de Prochaska (stades du changement)

```
PRE-CONTEMPLATION → CONTEMPLATION → PREPARATION → ACTION → MAINTIEN
"Pas de probleme"   "Peut-etre"      "Je vais"     "Je fais"  "Je suis"
```

| Stade | Comportement observe | Approche du coach |
|---|---|---|
| **Pre-contemplation** | Le patient minimise ("je mange pas si mal"), compliance faible, peu engage | Ne pas brusquer. Informer doucement, partager des faits sans juger. "Saviez-vous que..." |
| **Contemplation** | Le patient hesite ("je devrais mais..."), ambivalent, pose des questions | Explorer l'ambivalence. "Qu'est-ce qui vous freine ?" Valoriser l'intention |
| **Preparation** | Le patient planifie ("lundi je commence"), cherche des solutions | Aider a planifier. Simplifier le premier pas. "On commence par un seul changement" |
| **Action** | Le patient suit le programme, compliance haute, engage | Encourager, celebrer, anticiper les obstacles. "Vous avez suivi 4 jours, bravo" |
| **Maintien** | Le patient a integre les habitudes, autonome | Renforcer l'identite. "Vous etes quelqu'un qui prend soin de sa sante". Prevenir la rechute |

### 2.2 TCC (Therapie Cognitive-Comportementale) appliquee a l'alimentation

```
SITUATION → PENSEE AUTOMATIQUE → EMOTION → COMPORTEMENT
                                                  │
                                          ┌───────┴───────┐
                                          │               │
                                    RENFORCEMENT      CONSEQUENCE
                                    (plaisir immédiat)  (culpabilite)
                                          │               │
                                          └───────┬───────┘
                                                  │
                                              CYCLE
```

Exemple concret :

```
Situation : Journee stressante au travail, arrive a la maison fatiguee
Pensee : "Je le merite" / "Juste pour ce soir" / "Lundi je recommence"
Emotion : Fatigue + envie de reconfort
Comportement : Commande une pizza
Renforcement : Plaisir immediat (dopamine)
Consequence : Culpabilite, pic glycemique, ecart au programme
Cycle : La prochaine fois que je suis fatiguee → meme schema
```

Le coach identifie ce cycle et propose une **interruption** :

```
🤖 "Marie, je vois que vos ecarts arrivent souvent le soir
    apres des journees longues. C'est classique : quand on est
    fatigue, le cerveau cherche la recompense la plus rapide.
    Ce n'est pas un manque de volonte, c'est de la biologie.

    Idee : on prepare 3 'diners SOS' — des repas de votre
    menu qui se font en moins de 10 minutes. Les soirs
    de fatigue, c'est ceux-la. Pas de decision a prendre,
    pas d'effort. Ca vous dit ?"
```

### 2.3 Entretien motivationnel (Miller & Rollnick)

4 principes :

| Principe | Application dans le coaching |
|---|---|
| **Exprimer de l'empathie** | "Je comprends que c'est difficile" — jamais de jugement |
| **Developper la divergence** | "Vous voulez eviter le diabete. Qu'est-ce qui vous rapproche de cet objectif cette semaine ?" |
| **Rouler avec la resistance** | Si le patient dit "j'en ai marre du programme" → ne pas argumenter, explorer |
| **Renforcer le sentiment d'efficacite** | "Vous avez suivi le programme 4 jours sur 7. Il y a 3 semaines, c'etait 2 sur 7" |

### 2.4 Science des habitudes (BJ Fogg / James Clear)

```
HABITUDE = DECLENCHEUR + ROUTINE + RECOMPENSE

Pour creer une habitude :
  1. Rendre le declencheur evident
  2. Rendre la routine facile
  3. Rendre la recompense immediate
```

Application :

| Habitude cible | Declencheur | Routine | Recompense |
|---|---|---|---|
| Marche post-dejeuner | Fin du repas | 15 min de marche | Coach : "Super ! Votre glycemie vous remerciera" + data CGM si disponible |
| Photo du repas | Assiette prete | Prendre la photo | Feedback immediat du coach + streak visible |
| Petit-dejeuner equilibre | Reveil | Porridge pre-prepare la veille | "3 jours de suite, belle serie !" |

---

## 3. Les 7 dimensions comportementales

### 3.1 Alimentation emotionnelle

**Lien avec le prediabete** : le stress chronique augmente le cortisol, qui augmente la glycemie et favorise le stockage de graisse viscerale. Le stress fait aussi manger (comfort eating), creant un double impact negatif.

**Ce que le coach detecte** :
- Ecarts correles avec des mentions de stress, fatigue, tristesse
- Patterns temporels (ecarts toujours le soir, le weekend, apres le travail)
- Discours revelateur ("je le merite", "j'avais besoin de ca")

**Ce que le coach fait** :
- Identifie le declencheur sans juger : "Qu'est-ce qui s'est passe avant ?"
- Normalise : "Manger pour se reconforter c'est humain, pas une faiblesse"
- Propose des alternatives : "La prochaine fois que vous etes stresse, essayez 5 minutes de respiration ou une marche de 10 minutes. Ca active les memes circuits de recompense"
- Cree des strategies anticipees : menu SOS, snacks sains pre-positionnes

### 3.2 Rapport au sucre

**Lien avec le prediabete** : le sucre active le circuit dopaminergique (recompense) de maniere similaire aux substances addictives. Pour un prediabetique, le sucre est a la fois le declencheur de plaisir et l'ennemi metabolique.

**Ce que le coach fait** :
- Ne dit jamais "c'est interdit" (declenche le desir)
- Explique la mecanique : "Le sucre appelle le sucre. C'est de la biochimie, pas un defaut de caractere"
- Propose des substitutions progressives, pas des coupures brutales
- Valorise chaque reduction : "Vous etes passe de 3 sodas/jour a 1. C'est enorme"
- Si CGM : montre l'impact reel ("Ce soda a fait monter votre glycemie a 185. Le the glace sans sucre : 105")

### 3.3 Sommeil

**Lien avec le prediabete** : dormir moins de 6h augmente le risque de diabete T2 de 40%. Le manque de sommeil augmente la ghréline (hormone de la faim), diminue la leptine (satiete), et reduit la sensibilite a l'insuline.

Le questionnaire PT collecte deja `duree_nuits` (>= 6h ou < 6h). Mais rien n'en est fait.

**Ce que le coach fait** :
- Demande regulierement comment le patient dort (en conversation, pas en questionnaire)
- Correle sommeil et donnees : "Les jours ou vous dormez moins de 6h, votre glycemie du lendemain est 12% plus haute"
- Propose des micro-ajustements : "Essayez de vous coucher 30 minutes plus tot cette semaine"
- Lie le sommeil a la performance du programme : "Dormir 7h c'est aussi efficace qu'un medicament pour votre glycemie"

### 3.4 Stress chronique

**Lien avec le prediabete** : cortisol → glycemie elevee → resistance a l'insuline → stockage visceral. Cercle vicieux.

**Ce que le coach detecte** :
- Mentions de stress dans les conversations
- Correlation entre periodes de stress rapportees et ecarts alimentaires / hausse glycemique
- Patterns de sommeil degrade

**Ce que le coach fait** :
- Ne donne pas de lecons de gestion du stress
- Propose des actions courtes et concretes : "5 respirations profondes avant le repas"
- Lie le stress aux donnees : "Votre glycemie est plus haute cette semaine. Vous avez mentionne une periode chargee au travail — le stress a un impact direct"
- Recommande de l'activite physique comme anti-stress (evidence forte) plutot que de la meditation generique

### 3.5 Cycle restriction / craquage

**Lien avec le prediabete** : les regimes trop restrictifs (ex: phase INTENSIVE a 80% des kcal) menent au craquage, qui mene au pic glycemique, qui mene a la culpabilite, qui mene a l'abandon.

```
Restriction severe → Frustration → Craquage → Culpabilite → Restriction + severe
         └──────────────────────────────────────────────────────────┘
```

**Ce que le coach fait** :
- Detecte le pattern : restriction trop forte suivie d'ecarts importants
- Ajuste : "Votre phase ACTION est peut-etre trop restrictive pour vous. On passe a 85% au lieu de 80% — un ecart de 100 kcal ca reduit la frustration sans impacter les resultats"
- Normalise les ecarts : "Un diner hors-menu par semaine c'est prevu. Ce n'est pas un echec, c'est une soupape"
- Integre les ecarts dans le programme plutot que de les combattre

### 3.6 Environnement social

**Lien avec le prediabete** : repas de famille, diners entre amis, culture alimentaire, pression sociale ("allez, un petit morceau !"). L'environnement est le premier determinant du comportement alimentaire.

**Ce que le coach fait** :
- Anticipe les situations sociales : "Vous avez un diner samedi. Voici comment gerer sans vous priver ni vous culpabiliser"
- Strategies concretes : manger avant, choisir en premier, technique de l'assiette (moitie legumes)
- Pas de discours "dites non a vos amis" (culpabilisant et irealiste)
- Adapte le menu de la semaine : si diner samedi, alleger le dejeuner samedi

### 3.7 Identite et image de soi

**Lien avec le prediabete** : "je suis prediabetique" peut etre vecu comme une etiquette stigmatisante ou comme un signal d'alarme motivant. La facon dont le patient se percoit determine sa trajectoire.

**Ce que le coach fait** :
- Progressivement, passe de "vous suivez un programme" a "vous etes quelqu'un qui prend soin de sa sante"
- Celebre les milestones identitaires, pas juste les chiffres : "Ca fait 30 jours que vous photographiez vos repas. C'est devenu une habitude, plus un effort"
- Reframe le prediabete : pas une maladie, une opportunite d'agir avant. "Vous avez la chance de savoir avant qu'il soit trop tard"

---

## 4. Integration dans le coaching IA

### 4.1 System prompt comportemental

Ajouter au system prompt du coach (RPD-05 section 5.2) :

```markdown
## APPROCHE COMPORTEMENTALE

### Principes fondamentaux
- Tu comprends que le changement alimentaire est un probleme de
  COMPORTEMENT, pas de connaissance. Le patient sait quoi faire.
  Ton role est de l'aider a le faire.
- Chaque ecart est une INFORMATION, pas un echec. Ton premier
  reflexe est de comprendre le contexte, pas de corriger.
- Tu adaptes ton approche au stade de changement du patient
  (pre-contemplation, contemplation, preparation, action, maintien).

### Detection des declencheurs
Quand le patient fait un ecart, identifie le declencheur :
- Emotionnel : stress, fatigue, tristesse, ennui, celebration
- Situationnel : restaurant, famille, voyage, travail, weekend
- Physiologique : faim, manque de sommeil, cycle menstruel
- Cognitif : "je le merite", "juste cette fois", "lundi je recommence"

Tag chaque ecart avec son declencheur pour detecter les patterns.

### Ton et posture
- Bienveillant mais pas condescendant
- Factuel, pas moralisateur
- "Qu'est-ce qui s'est passe ?" pas "Pourquoi n'avez-vous pas..."
- Celebrer les progres, meme minimes
- Ne jamais culpabiliser, meme implicitement
- Ne jamais utiliser le mot "regime"
- Preferer "programme" ou "nouvelles habitudes"

### Habitudes
- Favorise les petits changements empilables plutot que les
  grands bouleversements
- Propose UN changement a la fois
- Utilise le cadre declencheur/routine/recompense
- Cree des "plans B" pour les situations difficiles recurrentes

### Alimentation emotionnelle
- Le sucre active le circuit de recompense (dopamine). C'est
  biologique, pas un defaut de caractere
- Propose des alternatives, pas des interdictions
- Quand un patient dit "j'ai craque" → "Qu'est-ce qui s'est
  passe juste avant ?"

### Sommeil
- Lie systematiquement sommeil et glycemie dans les explications
- "Dormir 7h au lieu de 5h peut reduire votre glycemie autant
  qu'un medicament"
- Demande regulierement comment le patient dort

### Environnement social
- Anticipe les repas sociaux et propose des strategies pratiques
- Pas de "dites non a vos amis" (irealiste et culpabilisant)
- Integre les ecarts sociaux dans le programme plutot que de
  les combattre

### Restriction / craquage
- Si pattern de restriction suivie de craquage → ajuster le budget
  calorique a la hausse plutot que de punir le craquage
- Un ecart prevu est mieux qu'un craquage subi
```

### 4.2 Exemples de conversations

**Ecart detecte via photo repas :**

```
📸 Photo : pizza

🤖 "Pas de jugement — une pizza ca arrive. Par curiosite,
    qu'est-ce qui s'est passe ce soir ? Journee longue,
    flemme de cuisiner, ou envie tout simplement ?"

👤 "Journee horrible au boulot, j'avais zero energie"

🤖 "Ca se comprend. Quand on est epuise, le cerveau
    cherche l'option la plus facile — c'est biologique,
    pas un manque de volonte.

    On a eu ce scenario 3 fois ce mois, toujours le soir
    en semaine. J'ai une idee : on prepare une liste de
    3 'diners SOS' qui se font en 10 minutes max.
    Les soirs ou vous etes videe, c'est ceux-la.
    Zero decision a prendre.

    Je vous propose :
    1. Omelette aux legumes (8 min)
    2. Salade de pois chiches (5 min, se prepare a l'avance)
    3. Soupe en bocal + pain complet (rechauffer 3 min)

    Laquelle vous tente pour la prochaine fois ?"
```

**Patient demotive :**

```
👤 "Ca sert a rien, j'arrive pas a suivre le programme"

🤖 "Je comprends cette frustration. Laissez-moi vous montrer
    quelque chose : il y a 3 semaines, vous suiviez 40% des
    repas. Cette semaine, c'est 65%. En 3 semaines, vous
    avez presque double votre compliance.

    Vous ne le voyez pas parce que vous vous comparez a 100%.
    Mais le progres est la, il est reel. Votre glycemie
    moyenne a baisse de 8% sur cette periode.

    65% c'est mieux que 40%. 70% sera mieux que 65%.
    On ne vise pas la perfection, on vise le progres.

    Qu'est-ce qui est le plus difficile en ce moment ?
    Les repas du soir ?"
```

**Rapport au sucre :**

```
👤 "J'ai trop envie de sucre en ce moment"

🤖 "C'est frequent en phase ACTION quand on reduit les glucides.
    Votre cerveau etait habitue a une dose de dopamine via le
    sucre, et il la reclame. Ca va passer en 10-15 jours.

    En attendant, quelques astuces qui marchent :
    • Un carre de chocolat noir 85% → moins de sucre, meme
      circuit de recompense
    • Des fruits rouges (myrtilles, framboises) → sucre naturel
      + fibres = pic glycemique 3x plus faible qu'un biscuit
    • Un yaourt grec avec une cuillere de miel → proteine +
      petit plaisir

    L'objectif n'est pas d'eliminer le sucre, c'est de
    remplacer les sources rapides par des sources lentes.
    Votre glycemie ne verra pas la difference, mais votre
    cerveau aura sa dose."
```

---

## 5. Collecte de donnees comportementales

### 5.1 Principe : zero questionnaire supplementaire

Les donnees comportementales sont extraites **naturellement** des interactions avec le coach. Pas de formulaire en plus. Le coach ecoute, tague, et analyse.

### 5.2 Tags comportementaux

Chaque interaction pertinente est taguee automatiquement par le LLM :

```json
{
  "date": "2026-03-19",
  "interaction_type": "deviation_detected",
  "meal": "dinner",
  "trigger": {
    "category": "emotional",
    "subcategory": "fatigue",
    "context": "Long day at work, no energy to cook",
    "confidence": 0.9
  },
  "patient_language": {
    "self_blame": false,
    "motivation_level": "medium",
    "stage_of_change": "action"
  }
}
```

### 5.3 Donnees collectees par le coach

| Donnee | Source | Methode |
|---|---|---|
| Declencheur d'ecart | Conversation post-ecart | "Qu'est-ce qui s'est passe ?" → tag automatique |
| Qualite du sommeil | Conversation periodique | "Comment dormez-vous en ce moment ?" |
| Niveau de stress | Mentions dans la conversation | Detection semantique |
| Contexte social des ecarts | Description de la situation | "Diner chez des amis" → tag: social_meal |
| Pensees automatiques | Discours du patient | "Je le merite" → tag: cognitive_permission |
| Niveau de motivation | Engagement global | Frequence d'interactions + compliance + ton |
| Stade de changement | Comportement sur 2 semaines | Algorithme de classification (voir 5.4) |

### 5.4 Detection du stade de changement

```python
def estimate_change_stage(patient: Patient) -> ChangeStage:
    """Estime le stade de changement du patient sur les 14 derniers jours."""

    compliance = patient.menu_compliance_14d
    engagement = patient.interaction_frequency_14d  # messages/jour
    trend = patient.compliance_trend_14d  # pente
    language = patient.recent_language_analysis  # du LLM

    if compliance < 0.3 and engagement < 0.5:
        if language.resistance_high:
            return ChangeStage.PRE_CONTEMPLATION
        return ChangeStage.CONTEMPLATION

    if compliance < 0.5 and trend > 0:
        return ChangeStage.PREPARATION

    if compliance >= 0.5 and compliance < 0.8:
        return ChangeStage.ACTION

    if compliance >= 0.8 and patient.program_week >= 8:
        return ChangeStage.MAINTENANCE

    return ChangeStage.ACTION  # default
```

Le stade est injecte dans le contexte du coach pour adapter le ton et l'approche.

---

## 6. Bilans comportementaux

Les bilans (RPD-05 section 3.3) integrent une section comportementale :

### 6.1 Bilan hebdomadaire

```
📊 Donnees de la semaine
   Poids : -0.4 kg  |  Menus : 78%  |  Sport : 3/4

🧠 Comportement
   2 ecarts cette semaine, les deux en soiree :
   • Mardi : fatigue apres le travail → pizza
   • Vendredi : diner entre amis → hors-menu

   Pattern identifie : la fatigue du soir est votre
   principal declencheur (3e semaine consecutive).
   Les repas du midi sont suivis a 95%.

😴 Sommeil
   3 nuits sous 6h cette semaine (lundi, mercredi, jeudi).
   Correlation observee : glycemie +8% le lendemain des
   nuits courtes.

💡 Strategie
   Cette semaine, on teste 2 choses :
   1. Menu SOS pour les soirs de fatigue (omelette 8 min)
   2. Coucher 30 min plus tot les soirs de semaine
```

### 6.2 Bilan mensuel — section comportementale

```
🧠 Evolution comportementale — Mars 2026

   Stade de changement : ACTION (stable depuis 3 semaines)
   Compliance globale : 72% → tendance ↑

   Declencheurs identifies ce mois :
   ┌──────────────┬────────┬──────────────────────────┐
   │ Declencheur   │ Freq.  │ Evolution                │
   ├──────────────┼────────┼──────────────────────────┤
   │ Fatigue soir  │ 8x     │ Stable (votre principal  │
   │               │        │ challenge)               │
   │ Repas sociaux │ 3x     │ En baisse (vs 5x en fev) │
   │ Stress travail│ 2x     │ Nouveau ce mois          │
   │ Envie sucre   │ 1x     │ En forte baisse (vs 6x)  │
   └──────────────┴────────┴──────────────────────────┘

   Progres notable :
   Les envies de sucre ont chute de 6x a 1x ce mois.
   La substitution chocolat noir + fruits rouges fonctionne
   pour vous.

   Point a travailler :
   La fatigue du soir reste le declencheur principal. Le menu
   SOS a ete utilise 3 fois (sur 8 ecarts). On peut faire
   mieux : preparer les ingredients le dimanche pour la semaine.
```

### 6.3 Structure des donnees comportementales

```json
{
  "period": "2026-03-13/2026-03-19",
  "behavioral": {
    "change_stage": "action",
    "change_stage_trend": "stable",
    "triggers": [
      {
        "category": "emotional",
        "subcategory": "fatigue",
        "count": 3,
        "trend": "stable",
        "day_of_week_pattern": ["tuesday", "thursday", "friday"],
        "time_of_day_pattern": "evening"
      },
      {
        "category": "situational",
        "subcategory": "social_meal",
        "count": 1,
        "trend": "decreasing"
      }
    ],
    "sleep": {
      "nights_under_6h": 3,
      "avg_reported_quality": "medium",
      "glycemia_correlation": "+8% next day"
    },
    "sugar_cravings": {
      "reported_count": 1,
      "trend": "decreasing",
      "strategy_used": "dark_chocolate_substitution"
    },
    "motivation": {
      "level": "medium",
      "self_blame_instances": 0,
      "engagement_frequency": 3.2
    }
  }
}
```

---

## 7. Patterns et interventions

### 7.1 Patterns detectables

Le systeme identifie des patterns recurrents sur 2-4 semaines et declenche des interventions adaptees :

| Pattern | Detection | Intervention |
|---|---|---|
| **Ecarts le soir en semaine** | >= 3 ecarts soiree/semaine, trigger: fatigue | Proposer menus SOS + meal prep dimanche |
| **Craquage post-restriction** | Ecart important apres 3+ jours de compliance parfaite | Augmenter le budget kcal de 5%, ajouter 1 snack |
| **Abandon progressif** | Compliance en baisse sur 3 semaines, interactions en baisse | Message proactif empathique, simplifier les objectifs |
| **Stress → glycemie** | Correlation entre mentions de stress et hausse glycemique | Expliquer le lien cortisol/glycemie, proposer respiration/marche |
| **Weekend deregule** | Compliance semaine > 80%, weekend < 40% | Anticiper le vendredi, prevoir 1 repas libre le samedi |
| **Sommeil degrade** | 3+ nuits < 6h par semaine, recurrent | Lier au programme : "c'est aussi important que les menus" |
| **Plateau motivationnel** | Poids stable > 3 semaines + motivation en baisse | Reframe : stabilite = succes. Chercher d'autres indicateurs de progres |
| **Dependance sucre** | Envies de sucre recurrentes + ecarts sucres | Strategie de substitution progressive, jamais d'interdiction |

### 7.2 Interventions proactives

Le coach n'attend pas que le patient echoue. Il anticipe :

| Moment | Intervention proactive |
|---|---|
| **Vendredi apres-midi** | "Weekend en vue ! Vous avez un repas social prevu ? On peut preparer une strategie" |
| **Apres 2 jours sans interaction** | "Tout va bien ? Pas besoin de tout suivre parfaitement — meme une photo de repas par jour c'est bien" |
| **Veille de fenetre CGM** | "Demain on pose le capteur. Les premiers jours, ne stressez pas si la glycemie monte apres les repas, c'est normal" |
| **Apres un ecart important** | "Pas de jugement. Un repas ne change pas votre trajectoire. On reprend demain" |
| **Milestone atteint** | "1 mois de programme. Vous avez suivi 73% des menus. Il y a un mois, vous partiez de zero" |
| **Pattern negatif detecte** | "J'ai remarque que les mardis sont difficiles pour vous. C'est votre journee la plus chargee ?" |

---

## 8. Garde-fous sante mentale

### 8.1 Regles ajoutees au safety layer

A integrer dans RPD-05 section 6 :

```markdown
## SANTE MENTALE (NON NEGOCIABLE)

9. Si le patient exprime des idees noires, un desespoir
   profond, ou des signes de depression persistante :
   "Je comprends que c'est difficile. Je vous recommande
   d'en parler a votre medecin ou d'appeler le 3114
   (numero national de prevention du suicide).
   Je suis la pour votre programme, mais un professionnel
   peut mieux vous aider sur ce sujet."
   + Alerte praticien.

10. Si le patient decrit des comportements de trouble
    alimentaire (purge, restriction extreme < 800 kcal/jour,
    binge eating, vomissements provoques) :
    "Ce que vous decrivez merite l'accompagnement d'un
    specialiste. Je vous recommande d'en parler a votre
    medecin."
    + Alerte praticien immediate.
    + Ne PAS proposer de plan alimentaire dans ce contexte.

11. Si le patient montre des signes d'obsession alimentaire
    (comptage excessif des calories, angoisse a chaque ecart,
    pesee multiple par jour) :
    Desamorcer doucement : "La perfection n'est pas l'objectif.
    Votre programme fonctionne meme a 70% de compliance."
    Si persistant → "Je pense qu'il serait utile d'en parler
    avec votre praticien."

12. Le coach ne remplace JAMAIS un psychologue ou psychiatre.
    Il utilise des principes de psychologie comportementale
    dans le cadre strict de la nutrition et de l'activite
    physique. Toute problematique qui deborde de ce cadre
    → referrer a un professionnel.
```

### 8.2 Detection automatique

```python
MENTAL_HEALTH_KEYWORDS = [
    # Depression
    "envie de rien", "a quoi bon", "je suis nulle",
    "je n'y arriverai jamais", "tout est foutu",
    # TCA
    "je me fais vomir", "je purge", "je mange rien depuis",
    "3 jours sans manger", "je me suis gavee",
    # Ideation
    "envie de mourir", "je veux disparaitre",
]

def check_mental_health_flags(message: str) -> MentalHealthCheck:
    """Detecte les signaux de detresse mentale."""
    # Detection par mots-cles + analyse LLM du contexte
    # Si flag → bypass le coaching normal, message de securite
```

---

## 9. Ce qu'on ne fait pas

| Approche | Pourquoi non | Alternative |
|---|---|---|
| **Lecons quotidiennes obligatoires** (Noom-style) | Friction, fatigue de contenu, les gens n'aiment pas les devoirs | Le coach integre les concepts naturellement dans la conversation |
| **Score psychologique** | Stigmatisant, reducteur | Observations factuelles internes (stade de changement), jamais communiquees au patient |
| **Labels** ("mangeur emotionnel", "addictif au sucre") | Renforce l'identite negative | Decrire des comportements, pas des personnes |
| **Questionnaires d'humeur quotidiens** | Personne ne les remplit sincerement | Le coach infere l'etat emotionnel de la conversation |
| **Therapie** | Ni ethique ni legal pour une IA | Principes de psychologie comportementale appliques a la nutrition. Au-dela → referrer |
| **Culpabilisation deguisee** ("Vous avez echoue 3 fois") | Contre-productif, renforce le cycle | "3 repas a ameliorer, 32 bien suivis" — reframe positif |
| **Gamification excessive** (points, badges, classements) | Motivation extrinsèque, s'eteint vite | Motivation intrinseque : comprendre pourquoi, voir l'impact reel (CGM, poids, energie) |

---

## 10. Impact sur le produit

### 10.1 Differentiation

```
                    Medical pur
                        ▲
                        │
                        │  ★ Glyc Pro
                        │  (medical + comportemental
                        │   + IA personnalisee)
                        │
         Generique ◄────┼────► Personalise
                        │
              Noom ★    │    ★ Virta Health
              Yazio ★   │
                        │
                    Bien-etre
```

Glyc Pro est le seul a combiner :
- Regles medicales validees (seuils, exclusions, alertes)
- Optimisation nutritionnelle (solveur LP, 1118 recettes)
- CGM (mesure objective)
- Coaching comportemental IA (TCC, entretien motivationnel, habitudes)
- Suivi praticien

### 10.2 Impact sur les metriques

| Metrique | Sans comportemental | Avec comportemental |
|---|---|---|
| Retention J30 | ~20% (standard health apps) | ~35-40% (estimation, cf. Noom 40%) |
| Compliance menus | ~50-60% | ~70-80% (le coach aide a gerer les ecarts) |
| Taux d'abandon | ~60% a 3 mois | ~35-40% (le coach re-engage proactivement) |
| Satisfaction (NPS) | Moyen | Eleve (le patient se sent compris, pas juge) |

### 10.3 Impact sur le pricing

| Offre | Sans comportemental | Avec comportemental |
|---|---|---|
| Essentiel | "App de menus" → 10€/mois | "Programme qui comprend pourquoi vous craquez" → 20€/mois |
| Pro (+ CGM) | "Menus + capteur" → 25€/mois | "Programme complet + coach IA" → 35€/mois |

La dimension comportementale **justifie le pricing premium**. Un solveur de menus c'est une commodite. Un coach qui comprend vos patterns et vous aide a changer, c'est de la valeur perçue.

### 10.4 Cout supplementaire

**Quasi nul.** La dimension comportementale est du prompt engineering dans le system prompt du coach. Pas de module supplementaire, pas de modele ML a entrainer, pas de contenu a creer. Le LLM sait deja faire de la psychologie comportementale — il suffit de le briefer correctement.

Le seul ajout technique : les tags comportementaux dans les conversations (extraction structuree) et l'algorithme de detection du stade de changement (~50 lignes de Python).

---

*Ce document complete RPD-05 (strategie IA). La dimension comportementale est integree dans le coaching IA, pas comme un module separe. Les garde-fous sante mentale sont a ajouter a RPD-05 section 6.*
