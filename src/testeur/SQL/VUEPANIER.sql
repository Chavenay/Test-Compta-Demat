-- modif 26/06/2014 : concat�nation cpt g�n(sans enlever les 0) - cpt aux
  SELECT d.lib_dir AS "Dossier", a.lib_axe AS "Libell� axe", '<datecloture>'::date AS "Exercice", t.code_jrnal AS "Code Journal", t.lib_jrnal AS "Journal", t.num_ecr AS "Num�ro Ecriture", t.date_cpt AS "Date comptable", ltrim(t.num_cpte_gen, '0'::text) AS "Num�ro Compte", t.lib_cpte_gen AS "Libell� Compte", t.num_cpt_aux AS "Num�ro Compte auxiliaire", t.lib_cpt_aux AS "Libell� Compte auxiliaire",
  ((t.num_cpte_gen)||'-'||(t.num_cpt_aux)) AS "Num�ro Compte G�n-Aux", ((t.lib_cpte_gen)||'-'||(t.lib_cpt_aux)) AS "Libell� Compte G�n-Aux", 
   t.num_piece AS "Num�ro Pi�ce", t.date_piece AS "Date Pi�ce", t.lib_ecriture AS "Libell�", t.mtn_debit AS "D�bit", t.mtn_credit AS "Cr�dit", t.code_lettrage AS "Lettrage", t.date_lettrage AS "Date Lettrage", t.valid_date AS "Date Validation", t.mtn_devise AS "Montant Devise", t.idevise AS "Devise",
                CASE
                    WHEN t.ecr_type = 1 OR t.ecr_type = 11 THEN 'Cl�ture'::text
                    WHEN t.ecr_type = 2 OR t.ecr_type = 12 THEN 'A. Nouveau'::text
                    ELSE ''::text
                END AS "Type �criture",
                CASE
                    WHEN t.ecr_type = 11 OR t.ecr_type = 12 THEN 'G�n�r�e'::text
                    ELSE ''::text
                END AS "G�n�r�e lecode", a.id_panier_dir AS "ID_DIR", a.id_panier_axe AS "ID_AXE", p.id_ligne AS "ID_LIGNE"
           FROM panier_axe a
      JOIN panier_dir d ON d.id_panier_dir = a.id_panier_dir
   JOIN panier_ligne p ON p.id_panier_axe = a.id_panier_axe
   JOIN fec_<cloture> t ON p.id_ligne = t.id_ligne AND p.exercice = '<datecloture>'::date
   