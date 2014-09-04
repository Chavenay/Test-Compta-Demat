-- attention syntaxe :  
-- fichier lu � 3 endroits dans le code source, syntaxe strict obligatoire



 


DROP VIEW IF EXISTS vue_journal_<cloture>;
-- modif 27/06/2014 : concat�nation cpt g�n(sans enlever les 0) - cpt aux
CREATE OR REPLACE VIEW vue_journal_<cloture> AS
SELECT t.id_ligne AS "ID",
t.code_jrnal AS "Code Journal",
t.lib_jrnal AS "Journal",
t.num_ecr AS "Num�ro Ecriture",
t.date_cpt AS "Date comptable",
ltrim(t.num_cpte_gen,
'0'::text) AS "Num�ro Compte",
t.lib_cpte_gen AS "Libell� Compte",
((t.num_cpte_gen)||'-'||(t.num_cpt_aux)) AS "Num�ro Compte G�n-Aux",
((t.lib_cpte_gen)||'-'||(t.lib_cpt_aux)) AS "Libell� Compte G�n-Aux",
t.mtn_debit AS "D�bit",
t.mtn_credit AS "Cr�dit",
t.lib_ecriture AS "Libell�",
t.date_piece AS "Date Pi�ce",
t.num_piece AS "Num�ro Pi�ce",
t.code_lettrage AS "Lettrage",
t.num_cpt_aux AS "Num�ro Compte auxiliaire",
t.lib_cpt_aux AS "Libell� Compte auxiliaire",
CASE
            WHEN t.ecr_type = 1 OR t.ecr_type = 11 THEN 'Cl�ture'::text
            WHEN t.ecr_type = 2 OR t.ecr_type = 12 THEN 'A. Nouveau'::text
            ELSE ''::text
END AS "Type �criture",
CASE 
WHEN t.ecr_type = 11 OR t.ecr_type = 12 THEN 'G�n�r�e'::text 
ELSE ''::text 
END AS "G�n�r�e lecode",
t.date_lettrage AS "Date Lettrage",
t.valid_date AS "Date Validation",
t.mtn_devise AS "Montant Devise",
t.idevise AS "Devise",
CASE 
			WHEN t.alto2_taux_tva > 0::numeric THEN 'Cr�diteur' 
			WHEN t.alto2_taux_tva < 0::numeric THEN 'D�biteur' 
			ELSE 'Nul' 
END AS "Sens TVA",
abs(t.alto2_taux_tva) AS "Taux TVA" 
<vue_champs_compl>
FROM fec_<cloture> t 
WHERE ((ecr_type != 11) AND (ecr_type != 12));
