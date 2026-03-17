# PrediabAid — Vision Produit & Roadmap
## RPD-00 : Document stratégique

**Version** : 1.0
**Date** : 2026-03-17
**Auteur** : Product Team
**Statut** : Draft

---

## 1. Vision produit

### 1.1 Mission

**Empêcher les personnes à risque de devenir diabétiques** en leur offrant un programme personnalisé combinant nutrition optimisée, activité physique adaptée, suivi biométrique et coaching intelligent.

### 1.2 Proposition de valeur

| Pour qui | Problème | Solution PrediabAid |
|----------|----------|---------------------|
| Adultes prédiabétiques (IMC 23-40) | Pas de programme structuré entre "tout va bien" et "vous êtes diabétique" | Programme progressif en phases avec menus personnalisés et suivi quotidien |
| Médecins/nutritionnistes | Pas d'outil de suivi entre les consultations | Dashboard patient avec alertes automatiques |
| Assureurs santé / mutuelles | Coût du diabète T2 (>10K€/an/patient) | Prévention mesurable, outcomes traçables |

### 1.3 Positionnement

```
                    Médical pur
                        ▲
                        │
                        │  ✦ PrediabAid
                        │  (programme médical
                        │   + IA personnalisée)
                        │
         Générique ◄────┼────► Personnalisé
                        │
              Noom ✦    │    ✦ Virta Health
              Yazio ✦   │
                        │
                        │
                    Bien-être
```

**Différenciateurs clés** :
1. Base de connaissances médicale validée (430+ règles cliniques)
2. Optimisation de menus sous contraintes (pas juste des suggestions)
3. Intégration glucomètre pour mesure objective
4. Programme en phases adapté au profil de risque

---

## 2. Utilisateurs cibles

### 2.1 Personas

#### Persona 1 : Marie, 52 ans — "La pré-diabétique qui s'ignore"
- **Contexte** : IMC 28, sédentaire, antécédents familiaux diabète T2
- **Douleur** : Son médecin lui dit "faites attention" mais sans programme concret
- **Besoin** : Un plan structuré jour par jour, facile à suivre
- **Formule probable** : F2 (G2 + IMC 25-40)

#### Persona 2 : Karim, 38 ans — "Le profil à risque actif"
- **Contexte** : IMC 24, sportif, score PT élevé (antécédents familiaux forts)
- **Douleur** : En forme mais sait qu'il est à risque génétiquement
- **Besoin** : Suivi glycémique + optimisation nutrition
- **Formule probable** : F4 ou F5 (G2-G3 + IMC < 25)

#### Persona 3 : Dr. Laurent — "Le médecin prescripteur"
- **Contexte** : Médecin généraliste, 200 patients prédiabétiques
- **Douleur** : Ne peut pas suivre chaque patient au quotidien
- **Besoin** : Dashboard de suivi, alertes si glycémie anormale

### 2.2 Jobs to be done

| Job | Fréquence | Importance |
|-----|-----------|------------|
| Savoir si je suis à risque | 1 fois (onboarding) | Critique |
| Avoir un menu adapté à mon profil chaque semaine | Hebdomadaire | Haute |
| Suivre ma glycémie facilement | Quotidien | Haute |
| Comprendre pourquoi on me recommande ça | À chaque recommandation | Moyenne |
| Voir mes progrès dans le temps | Hebdomadaire | Haute |
| Savoir quand je peux relâcher (stabilisation) | Ponctuel | Moyenne |

---

## 3. Roadmap

### 3.1 Vue d'ensemble des phases

```
Phase 1 : MVP (V1)                    Phase 2 : Evolution (V2)
"Remettre en vie"                      "Intelligence"
──────────────────────                 ──────────────────────
Durée estimée : 3-4 mois              Durée estimée : 3-4 mois

✓ Onboarding (PT)                     ✓ Onboarding conversationnel (LLM)
✓ Moteur de règles (JSON)             ✓ ML personnalisation
✓ Programme & phases                  ✓ Feedback loop
✓ Menus optimisés                     ✓ Coaching IA
✓ Suivi quotidien                     ✓ Explications contextuelles
✓ Glucomètre BLE                     ✓ CGM + Apple Health
✓ App mobile (1 codebase)            ✓ Analytics & outcomes
✓ API backend                        ✓ Dashboard prescripteur
✓ Admin basique                       ✓ Multi-langue
```

### 3.2 Phase 1 — MVP : "Remettre en vie"

**Objectif** : Reproduire 100% de la logique métier existante avec un stack moderne. L'app doit être fonctionnelle et déployable.

#### Sprint 0 — Fondations (2 semaines)
- [ ] Setup projet (monorepo, CI/CD, environnements)
- [ ] Modèle de données PostgreSQL
- [ ] Auth (email + token)
- [ ] Extraction des règles Drools → format JSON/YAML
- [ ] Extraction des questionnaires XLS → format JSON
- [ ] Extraction des recettes/aliments → format JSON

#### Sprint 1 — Onboarding & Profiling (2 semaines)
- [ ] Questionnaire PT (formulaire dynamique)
- [ ] Scoring automatique → Groupe (G1/G2/G3)
- [ ] Calcul IMC
- [ ] Matrice éligibilité → Formule (F1-F5)
- [ ] Écran résultat + vidéo éligibilité/exclusion
- [ ] Questionnaire BS (sport) → Groupe sportif (GS1-GS4)

#### Sprint 2 — Programme & Phases (2 semaines)
- [ ] Moteur de règles (JSON-based)
- [ ] Initialisation programme (8 phases)
- [ ] Calcul durées par formule × âge × IMC
- [ ] Transitions de phase (behaviors)
- [ ] Gestion PAUSE / AUDIT
- [ ] Timeline visuelle du programme

#### Sprint 3 — Menus & Nutrition (3 semaines)
- [ ] Import base de recettes + ingrédients
- [ ] Filtrage par contraintes (casher, halal, gluten, végétarien)
- [ ] Scoring recettes (classes nutritionnelles + saisonnalité)
- [ ] Solveur de menus (OR-Tools ou PuLP)
- [ ] Construction menus hebdo (5 repas/jour × 7 jours)
- [ ] Écran menu du jour + recette détaillée
- [ ] Recettes de substitution

#### Sprint 4 — Suivi quotidien (2 semaines)
- [ ] Questionnaires quotidiens (glycémie, repas, humeur, sport)
- [ ] Formulaire dynamique par type de question (29 types)
- [ ] Sauvegarde réponses + scoring
- [ ] Déclenchement règles quotidiennes (vidéos, messages, rappels)
- [ ] Dashboard jour (résumé + objectifs)

#### Sprint 5 — Objets connectés (2 semaines)
- [ ] Intégration glucomètre VivaCheck (BLE)
- [ ] Protocole complet (scan, pair, mesure, historique)
- [ ] Intégration balance (BLE ou API iHealth)
- [ ] Sync des mesures vers le backend
- [ ] Affichage courbes de suivi (glycémie, poids)

#### Sprint 6 — Contenu & Polish (2 semaines)
- [ ] Système de vidéos (catégorisées, contextualisées)
- [ ] Messages et notifications quotidiennes
- [ ] 16 cours éducatifs (CDC)
- [ ] Gestion abonnement (basique)
- [ ] Admin panel (gestion utilisateurs, monitoring)
- [ ] Tests E2E, QA, bug fixes

### 3.3 Phase 2 — V2 : "Intelligence" (post-MVP)

#### Lot 1 — Coaching IA
- [ ] Intégration LLM (Claude API) pour coaching personnalisé
- [ ] Explications contextuelles des recommandations
- [ ] Onboarding conversationnel progressif

#### Lot 2 — Personnalisation ML
- [ ] Modèle de scoring recettes basé sur les retours utilisateur
- [ ] Ajustement dynamique des durées de phase
- [ ] Prédiction de risque personnalisée

#### Lot 3 — Feedback Loop
- [ ] Tracking suivi des menus (suivi/pas suivi)
- [ ] Mesure d'efficacité par phase
- [ ] Ajustement des recommandations

#### Lot 4 — Devices étendus
- [ ] Apple Health / Google Health Connect
- [ ] Support CGM (FreeStyle Libre, Dexcom)
- [ ] Wearables (montre connectée)

#### Lot 5 — Analytics & Prescripteurs
- [ ] Dashboard outcomes (HbA1c, poids, glycémie)
- [ ] Interface prescripteur (médecin)
- [ ] Export données pour études cliniques

---

## 4. Métriques de succès

### 4.1 Métriques produit (V1)

| Métrique | Cible MVP | Mesure |
|----------|-----------|--------|
| Taux de complétion onboarding | > 70% | Users qui finissent PT / Users qui commencent |
| Rétention J7 | > 40% | Users actifs à J+7 / Users onboardés |
| Rétention J30 | > 20% | Users actifs à J+30 |
| Questionnaires remplis/jour | > 1.5 | Moyenne par user actif |
| Menus consultés/semaine | > 3 | Vues menu / user actif |
| Mesures glucomètre/semaine | > 2 | Pour users avec glucomètre |

### 4.2 Métriques santé (V2)

| Métrique | Cible V2 | Mesure |
|----------|----------|--------|
| Réduction glycémie moyenne | -10% à 6 mois | Glycémie M6 vs M0 |
| Perte de poids | -5% à 6 mois | Poids M6 vs M0 |
| Passage en stabilisation | > 50% des users | Users atteignant phase STABILISATION |
| Réduction du risque PT | -3 points score | Score PT M6 vs M0 |

---

## 5. Contraintes et risques

### 5.1 Contraintes

| Contrainte | Impact | Mitigation |
|------------|--------|------------|
| Réglementation santé (RGPD, HDS) | Hébergement données de santé | Hébergeur certifié HDS (OVH, Scaleway) |
| Dispositif médical (marquage CE) | Si le glucomètre est "prescrit" | V1 = bien-être, pas dispositif médical |
| Base de recettes existante | Qualité/quantité à valider | Audit des recettes existantes |
| Protocole BLE VivaCheck | Un seul appareil supporté | Suffisant pour V1, élargir en V2 |
| Budget | Startup → ressources limitées | MVP lean, itératif |

### 5.2 Risques

| Risque | Probabilité | Impact | Mitigation |
|--------|------------|--------|------------|
| Recettes insuffisantes en quantité | Moyen | Haut | Import d'une base externe (Open Food Facts) |
| Protocole BLE obsolète (VivaCheck arrêté) | Moyen | Moyen | Ajouter support Apple Health dès V1 |
| Règles médicales à revalider | Haut | Haut | Review par un médecin avant lancement |
| Adoption faible sans prescripteur | Haut | Haut | Partenariat B2B avec mutuelles/médecins |

---

## 6. Stack technique cible

### V1 — MVP

| Composant | Technologie | Justification |
|-----------|-------------|---------------|
| **Mobile** | React Native (Expo) | 1 codebase, iOS + Android, BLE supporté |
| **Backend** | Node.js (NestJS) ou Python (FastAPI) | Moderne, performant, facile à recruter |
| **Base de données** | PostgreSQL | Robuste, JSONB pour flexibilité |
| **Moteur de règles** | JSON Rules Engine (JS) ou custom Python | Léger, éditable sans déployer |
| **Solveur menus** | OR-Tools (Google) via Python | Remplace LPTK/COIN, mieux maintenu |
| **Auth** | JWT + refresh tokens | Standard |
| **Hébergement** | Scaleway (HDS) ou OVH | Certifié hébergement données de santé |
| **CI/CD** | GitHub Actions | Déjà sur GitHub |
| **Monitoring** | Sentry + PostHog | Erreurs + analytics produit |

### V2 — Extensions

| Composant | Technologie |
|-----------|-------------|
| **LLM** | Claude API (Anthropic) |
| **ML** | Python (scikit-learn / LightGBM) |
| **Vector DB** | pgvector (PostgreSQL extension) |
| **Health data** | Apple HealthKit / Google Health Connect |
| **Analytics** | Metabase ou custom dashboard |

---

## 7. Équipe cible

### V1 — MVP (équipe minimale)

| Rôle | Profil | Temps |
|------|--------|-------|
| Product / Tech Lead | Fullstack senior + vision produit | 100% |
| Dev Backend | Node.js/Python + PostgreSQL | 100% |
| Dev Mobile | React Native + BLE | 100% |
| Nutritionniste / Médecin | Validation des règles médicales | 20% (conseil) |
| Designer UI/UX | Mobile-first | 50% |

### V2 — Renforcement

| Rôle | Profil |
|------|--------|
| ML Engineer | Python, scikit-learn, embeddings |
| Data Analyst | Métriques santé, outcomes |

---

*Ce document est le cadre stratégique. Les spécifications fonctionnelles détaillées sont dans RPD_01 (V1 MVP) et RPD_02 (V2 Evolution).*
