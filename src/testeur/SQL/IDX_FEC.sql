DROP INDEX IF EXISTS  idx_cpt_date_fec_<cloture> ;
DROP INDEX IF EXISTS idx_date_num_ecr_fec_<cloture>;
DROP INDEX IF EXISTS idx_cpt_fec_<cloture> ;
DROP INDEX IF EXISTS idx_cpt_aux_fec_<cloture>;
DROP INDEX IF EXISTS idx_jrn_fec_<cloture>;
DROP INDEX IF EXISTS idx_piece_fec_<cloture>;
DROP INDEX IF EXISTS idx_devise_fec_<cloture>;
DROP INDEX IF EXISTS idx_trgm_libelle_fec_<cloture> ;
DROP INDEX IF EXISTS idx_trgm_unaccent_libelle_fec_<cloture> ;

commit ;

-- Index sur le num�ro d'�criture (n�cessaire pour les jointures avec la table ecriture_<cloture>)
CREATE INDEX idx_date_num_ecr_fec_<cloture>  ON fec_<cloture> USING btree  (date_cpt, num_ecr);
commit ;


-- Index permettant l'affichage de l'onglet grand-livre
-- RQ : "text_pattern_ops" est supprim� pour permettre les tris sur les num�ros de comptes
CREATE INDEX idx_cpt_date_fec_<cloture>
  ON fec_<cloture>
  USING btree
  (ltrim(num_cpte_gen, '0'::text), lib_cpte_gen, date_cpt);
commit ;

-- Index permettant les filtres sur les comptes g�n�raux
CREATE INDEX idx_cpt_fec_<cloture> ON fec_<cloture> USING btree(ltrim(num_cpte_gen, '0') text_pattern_ops, lib_cpte_gen);
 commit ;
 
-- Index permettant les filtres sur les comptes auxiliaires 
-- modif 26/06/2014 : concat�nation cpt g�n(sans enlever les 0) - cpt aux
CREATE INDEX idx_cpt_aux_fec_<cloture> ON fec_<cloture> USING btree (((fec_<cloture>.num_cpte_gen)||'-'||(fec_<cloture>.num_cpt_aux)) text_pattern_ops, 
	((fec_<cloture>.lib_cpte_gen) ||'-'||(fec_<cloture>.lib_cpt_aux)));
	
-- Index permettant les filtres sur les journaux
commit ;
CREATE INDEX idx_jrn_fec_<cloture> ON fec_<cloture> USING btree(code_jrnal, lib_jrnal);
-- Index permettant de retrouver une pi�ce
commit ;
CREATE INDEX idx_piece_fec_<cloture> ON fec_<cloture> USING btree(num_piece);
-- Index permettant un filtre sur les devises
commit ;
CREATE INDEX idx_devise_fec_<cloture> ON fec_<cloture> USING btree(idevise) WHERE idevise IS NOT NULL AND idevise <> '';

-- Index permettant la recherche text sur le champ libell� d'�criture
commit ;
CREATE EXTENSION IF NOT EXISTS pg_trgm ;
commit ;
CREATE INDEX idx_trgm_libelle_fec_<cloture> ON fec_<cloture> USING gin (lib_ecriture gin_trgm_ops) ;
commit ;
CREATE INDEX idx_trgm_unaccent_libelle_fec_<cloture> ON fec_<cloture> USING gin (unaccent_string(lib_ecriture) gin_trgm_ops) ;