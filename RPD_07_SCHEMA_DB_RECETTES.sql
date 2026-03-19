-- =============================================================================
-- SCHEMA DB : Recettes, Aliments, Menus — Migration Excel → PostgreSQL/Supabase
-- Projet : Glyc Pro (ex-Prediabaid)
-- Date : 2026-03-19
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- ENUMS
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TYPE food_class AS ENUM ('A', 'B', 'C', 'D');
CREATE TYPE occurrence_class AS ENUM ('A', 'B', 'C', 'D');

CREATE TYPE rubrique AS ENUM (
  'PROTEINE', 'LEGUME', 'FECULENT', 'LEGUMINEUSE',
  'MATIERE_GRASSE', 'FRUIT', 'DESSERT', 'SNACK',
  'PETIT_DEJEUNER', 'COMPLEMENT_ALIMENTAIRE',
  'ASSAISONNEMENT', 'AUTRE'
);

CREATE TYPE type_repas AS ENUM (
  'PETIT_DEJEUNER', 'SNACK_AM', 'DEJEUNER', 'SNACK_PM', 'DINER'
);

CREATE TYPE type_composant_repas AS ENUM (
  'PETIT_DEJEUNER', 'SNACK', 'ENTREE', 'PLAT', 'DESSERT'
);

CREATE TYPE phase AS ENUM (
  'DETOX', 'INTENSIVE', 'PVBF', 'PROGRESSIVE', 'STABILISATION'
);


-- ─────────────────────────────────────────────────────────────────────────────
-- CATÉGORIES D'ALIMENTS
-- Source : Categories_Aliments.xlsx + Messages_Categories.xlsx
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE aliment_categories (
  id              text PRIMARY KEY,             -- "01", "02", etc.
  name_key        text NOT NULL,                -- clé i18n ex: "aliment.category.01.dairy.products"
  categorie_generale text,                      -- clé i18n du groupe parent
  rubrique        rubrique,
  min_hebdo       integer,                      -- -1=illimité, 0=interdit, >0=min par semaine
  max_hebdo       integer,
  est_casher      boolean NOT NULL DEFAULT false,
  est_vegetarien  boolean NOT NULL DEFAULT false,
  est_halal       boolean NOT NULL DEFAULT false,
  sans_gluten     boolean NOT NULL DEFAULT false,
  est_adaptable   boolean NOT NULL DEFAULT false,
  -- Traductions dénormalisées
  name_fr         text,
  name_en         text,
  name_es         text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE aliment_categories IS 'Catégories d''aliments (63 catégories). Source: Categories_Aliments.xlsx';


-- ─────────────────────────────────────────────────────────────────────────────
-- ALIMENTS (base nutritionnelle)
-- Source : Aliments.xlsx + Messages_Aliments.xlsx
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE aliments (
  id                text PRIMARY KEY,           -- "17107", "01012", etc.
  category_id       text NOT NULL REFERENCES aliment_categories(id),
  food_class        food_class,
  occurrence_class  occurrence_class,
  season_start_month integer CHECK (season_start_month BETWEEN 1 AND 12),
  season_end_month   integer CHECK (season_end_month BETWEEN 1 AND 12),
  -- Valeurs nutritionnelles (pour 100g)
  energy_kcal       numeric,
  protein_g         numeric,
  lipid_tot_g       numeric,
  carbohydrt_g      numeric,
  fiber_td_g        numeric,
  sugar_tot_g       numeric,
  fa_sat_g          numeric,
  fa_mono_g         numeric,
  fa_poly_g         numeric,
  -- Traductions dénormalisées
  name_fr           text,
  name_en           text,
  name_es           text,
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_aliments_category ON aliments(category_id);
CREATE INDEX idx_aliments_food_class ON aliments(food_class);

COMMENT ON TABLE aliments IS 'Base de 5260 aliments avec données nutritionnelles. Source: Aliments.xlsx';


-- ─────────────────────────────────────────────────────────────────────────────
-- RECETTES
-- Source : Recettes.xlsx + Messages_Recettes.xlsx
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE recipes (
  id                    text PRIMARY KEY,       -- "oriental.veal.saute.rice.pasta"
  description_key       text,                   -- clé i18n pour la description
  id_photo              text,                   -- clé de la photo
  duree_preparation     integer,                -- minutes
  duree_cuisson         integer,                -- minutes
  nb_kcal_journalier_definition integer,        -- seuil kcal de base (ex: 1500)
  composant_repas       type_composant_repas,   -- PLAT, ENTREE, DESSERT, PETIT_DEJEUNER, SNACK
  fete                  text,                   -- occasion spéciale (nullable)
  -- Traductions dénormalisées
  name_fr               text,
  name_en               text,
  name_es               text,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE recipes IS '1118 recettes uniques. Source: Recettes.xlsx';


-- ─────────────────────────────────────────────────────────────────────────────
-- INGRÉDIENTS DE RECETTE (AlimentPortion)
-- Chaque recette contient N ingrédients avec portion + unité
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE recipe_ingredients (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  recipe_id       text NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  aliment_id      text NOT NULL REFERENCES aliments(id),
  portion         numeric NOT NULL,             -- quantité (ex: 250, 0.5, 3)
  unite           text NOT NULL,                -- unité (g, ml, cup, unit, Tbsp., tsp., pinch, slice, sprig, clove, cl)
  sort_order      integer NOT NULL DEFAULT 0,   -- ordre d'affichage
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_recipe_ingredients_recipe ON recipe_ingredients(recipe_id);
CREATE INDEX idx_recipe_ingredients_aliment ON recipe_ingredients(aliment_id);

COMMENT ON TABLE recipe_ingredients IS 'Ingrédients des recettes (~6000 lignes). Relation N:1 vers recipes et aliments.';


-- ─────────────────────────────────────────────────────────────────────────────
-- CONDITIONS D'ACTIVATION PAR PHASE / KCAL
-- Détermine dans quelles phases et tranches caloriques une recette est disponible
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE recipe_phase_conditions (
  id                      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  recipe_id               text NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  types_repas             type_repas[] NOT NULL DEFAULT '{}', -- ex: {DEJEUNER, DINER}
  nb_kcal_activation      integer,              -- seuil kcal minimum d'activation
  nb_kcal_maximum         integer,              -- seuil kcal maximum
  phase_activation        text,                 -- phase(s) : "INTENSIVE", "PROGRESSIVE/STABILISATION", etc.
  created_at              timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_recipe_phase_recipe ON recipe_phase_conditions(recipe_id);

COMMENT ON TABLE recipe_phase_conditions IS 'Conditions d''activation des recettes par phase diététique et niveau calorique.';
COMMENT ON COLUMN recipe_phase_conditions.phase_activation IS 'Peut contenir plusieurs phases séparées par "/" (ex: INTENSIVE/PROGRESSIVE)';


-- ─────────────────────────────────────────────────────────────────────────────
-- ALLERGIES
-- Source : Allergies.xlsx
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE allergies (
  id              text PRIMARY KEY,             -- "ba.laitage", "ba.ble", etc.
  reponse_bilan   text NOT NULL,                -- "ba.laitage.oui", etc.
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Catégories exclues par allergie (relation M:N)
CREATE TABLE allergy_excluded_categories (
  allergy_id      text NOT NULL REFERENCES allergies(id) ON DELETE CASCADE,
  category_id     text NOT NULL REFERENCES aliment_categories(id),
  PRIMARY KEY (allergy_id, category_id)
);

-- Aliments spécifiques exclus par allergie (relation M:N)
CREATE TABLE allergy_excluded_aliments (
  allergy_id      text NOT NULL REFERENCES allergies(id) ON DELETE CASCADE,
  aliment_id      text NOT NULL REFERENCES aliments(id),
  PRIMARY KEY (allergy_id, aliment_id)
);

COMMENT ON TABLE allergies IS '33 types d''allergies avec catégories et aliments exclus. Source: Allergies.xlsx';


-- ─────────────────────────────────────────────────────────────────────────────
-- INCOMPATIBILITÉS CASHER
-- Source : Aliments_Incompatibles_Casher.xlsx
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE kosher_incompatibilities (
  id              bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  category_id_1   text NOT NULL REFERENCES aliment_categories(id),
  category_id_2   text NOT NULL REFERENCES aliment_categories(id),
  UNIQUE (category_id_1, category_id_2)
);

COMMENT ON TABLE kosher_incompatibilities IS 'Paires de catégories incompatibles casher (9 règles).';


-- ─────────────────────────────────────────────────────────────────────────────
-- RESTRICTIONS PAR PHASE
-- Source : RestrictionPhaseAlimentCategory.xlsx
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE phase_category_restrictions (
  phase_id        phase NOT NULL,
  category_id     text NOT NULL REFERENCES aliment_categories(id),
  PRIMARY KEY (phase_id, category_id)
);

COMMENT ON TABLE phase_category_restrictions IS 'Catégories interdites par phase diététique (6 restrictions).';


-- ─────────────────────────────────────────────────────────────────────────────
-- CONVERSIONS D'UNITÉS
-- Source : UnitConvert.xlsx
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE unit_conversions (
  id                    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  unit                  text NOT NULL,            -- "Tbsp.", "cup", "g", etc.
  category_name         text,                     -- nom catégorie (si spécifique)
  category_id           text,                     -- id catégorie (si spécifique)
  aliment_name          text,                     -- nom aliment (si spécifique)
  aliment_id            text,                     -- id aliment (si spécifique)
  priority              numeric NOT NULL DEFAULT 0,
  systems               text NOT NULL DEFAULT 'ALL', -- "ALL", "US", "UK", "METRIC"
  grams                 numeric,                  -- équivalent en grammes
  ml                    numeric,                  -- équivalent en ml
  round_precision       numeric,                  -- précision d'arrondi
  discrete_fractionals  text,                     -- "0.5, 1" → valeurs discrètes autorisées
  -- Traductions
  name_fr               text,
  name_en               text,
  created_at            timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE unit_conversions IS '148 règles de conversion d''unités (génériques et spécifiques par catégorie/aliment).';


-- ─────────────────────────────────────────────────────────────────────────────
-- MAPPING SYSTÈME D'UNITÉS
-- Source : UnitConvert.xlsx (sheet UnitSystemResponseMapping)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE unit_system_mappings (
  response_key    text PRIMARY KEY,               -- "pt.unit_system.us"
  unit_system     text NOT NULL                    -- "US", "UK", "METRIC"
);


-- ─────────────────────────────────────────────────────────────────────────────
-- DÉFINITIONS DE MENUS PAR PHASE
-- Source : Menus.xlsx (1 sheet par phase)
-- Matrice : phase × type_repas × rubrique_label × kcal_target → kcal_value
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE menu_definitions (
  id                bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  phase             phase NOT NULL,
  phase_kcal_ratio  numeric,                      -- ratio multiplicateur (ex: 0.8 pour INTENSIVE)
  type_repas        type_repas NOT NULL,
  rubrique_label    text NOT NULL,                 -- "PETIT-DÉJEUNER", "Légume Entrée", "Protéine Plat", etc.
  is_active         boolean NOT NULL DEFAULT false,
  -- Objectifs caloriques par niveau (JSONB = flexible car les niveaux varient par phase)
  kcal_targets      jsonb NOT NULL DEFAULT '{}',   -- ex: {"1100": 100, "1200": 150, "1500": 200, ...}
  created_at        timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX idx_menu_def_unique ON menu_definitions(phase, type_repas, rubrique_label);

COMMENT ON TABLE menu_definitions IS 'Définition des compositions de repas par phase. Chaque ligne = une rubrique dans un type de repas pour une phase donnée.';
COMMENT ON COLUMN menu_definitions.kcal_targets IS 'Map JSON: clé = objectif calorique journalier, valeur = kcal alloués à cette rubrique dans ce repas.';


-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE DE CORRESPONDANCES CATÉGORIES (metadata enrichie)
-- Source : Correspondances_Categories_Aliments.xlsx
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE category_correspondences (
  category_id       text NOT NULL REFERENCES aliment_categories(id),
  group_name        text,                          -- "Dairy and Substitutes", etc.
  supports_diet_preferences boolean DEFAULT false,  -- filtre préférences alimentaires
  supports_ingredients      boolean DEFAULT false,  -- utilisable comme ingrédient
  PRIMARY KEY (category_id)
);


-- ─────────────────────────────────────────────────────────────────────────────
-- TABLE GÉNÉRIQUE DE TRADUCTIONS (pour les clés non liées aux entités)
-- Source : Messages_*.xlsx (toutes les clés qui ne sont pas des IDs d'entités)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE translations (
  key             text PRIMARY KEY,
  fr              text,
  en              text,
  es              text,
  l4              text,
  l5              text,
  l6              text,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE translations IS 'Traductions génériques i18n pour les clés non attachées à une entité spécifique.';


-- ─────────────────────────────────────────────────────────────────────────────
-- FONCTIONS UTILITAIRES
-- ─────────────────────────────────────────────────────────────────────────────

-- Trigger auto-update de updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_aliment_categories_updated BEFORE UPDATE ON aliment_categories
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_aliments_updated BEFORE UPDATE ON aliments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_recipes_updated BEFORE UPDATE ON recipes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_translations_updated BEFORE UPDATE ON translations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ─────────────────────────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY (Supabase)
-- ─────────────────────────────────────────────────────────────────────────────

-- Toutes ces tables sont des données de référence en lecture seule pour les utilisateurs
ALTER TABLE aliment_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE aliments ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_phase_conditions ENABLE ROW LEVEL SECURITY;
ALTER TABLE allergies ENABLE ROW LEVEL SECURITY;
ALTER TABLE allergy_excluded_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE allergy_excluded_aliments ENABLE ROW LEVEL SECURITY;
ALTER TABLE kosher_incompatibilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE phase_category_restrictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE unit_conversions ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE translations ENABLE ROW LEVEL SECURITY;

-- Policy : lecture publique pour les données de référence (authenticated users)
CREATE POLICY "Lecture données de référence" ON aliment_categories FOR SELECT USING (true);
CREATE POLICY "Lecture données de référence" ON aliments FOR SELECT USING (true);
CREATE POLICY "Lecture données de référence" ON recipes FOR SELECT USING (true);
CREATE POLICY "Lecture données de référence" ON recipe_ingredients FOR SELECT USING (true);
CREATE POLICY "Lecture données de référence" ON recipe_phase_conditions FOR SELECT USING (true);
CREATE POLICY "Lecture données de référence" ON allergies FOR SELECT USING (true);
CREATE POLICY "Lecture données de référence" ON allergy_excluded_categories FOR SELECT USING (true);
CREATE POLICY "Lecture données de référence" ON allergy_excluded_aliments FOR SELECT USING (true);
CREATE POLICY "Lecture données de référence" ON kosher_incompatibilities FOR SELECT USING (true);
CREATE POLICY "Lecture données de référence" ON phase_category_restrictions FOR SELECT USING (true);
CREATE POLICY "Lecture données de référence" ON unit_conversions FOR SELECT USING (true);
CREATE POLICY "Lecture données de référence" ON menu_definitions FOR SELECT USING (true);
CREATE POLICY "Lecture données de référence" ON translations FOR SELECT USING (true);


-- ─────────────────────────────────────────────────────────────────────────────
-- VUES UTILES
-- ─────────────────────────────────────────────────────────────────────────────

-- Vue recette complète avec ingrédients
CREATE VIEW v_recipe_details AS
SELECT
  r.id AS recipe_id,
  r.name_fr AS recipe_name_fr,
  r.name_en AS recipe_name_en,
  r.duree_preparation,
  r.duree_cuisson,
  r.composant_repas,
  r.nb_kcal_journalier_definition,
  ri.sort_order,
  ri.portion,
  ri.unite,
  a.id AS aliment_id,
  a.name_en AS aliment_name_en,
  a.name_fr AS aliment_name_fr,
  a.energy_kcal,
  a.protein_g,
  a.lipid_tot_g,
  a.carbohydrt_g,
  ac.name_fr AS category_name_fr,
  ac.rubrique
FROM recipes r
JOIN recipe_ingredients ri ON ri.recipe_id = r.id
JOIN aliments a ON a.id = ri.aliment_id
JOIN aliment_categories ac ON ac.id = a.category_id
ORDER BY r.id, ri.sort_order;

-- Vue valeurs nutritionnelles par recette (somme des ingrédients)
CREATE VIEW v_recipe_nutrition AS
SELECT
  r.id AS recipe_id,
  r.name_fr,
  r.name_en,
  r.composant_repas,
  COUNT(ri.id) AS nb_ingredients,
  ROUND(SUM(a.energy_kcal * ri.portion / 100.0), 1) AS total_kcal,
  ROUND(SUM(a.protein_g * ri.portion / 100.0), 1) AS total_protein_g,
  ROUND(SUM(a.lipid_tot_g * ri.portion / 100.0), 1) AS total_lipid_g,
  ROUND(SUM(a.carbohydrt_g * ri.portion / 100.0), 1) AS total_carb_g,
  ROUND(SUM(a.fiber_td_g * ri.portion / 100.0), 1) AS total_fiber_g
FROM recipes r
JOIN recipe_ingredients ri ON ri.recipe_id = r.id
JOIN aliments a ON a.id = ri.aliment_id
GROUP BY r.id, r.name_fr, r.name_en, r.composant_repas;
