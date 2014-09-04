DROP VIEW IF EXISTS vue_balance_<cloture> ;
DROP VIEW IF EXISTS vue_ecriture_<cloture>;
DROP VIEW IF EXISTS vue_ecriture_simple_<cloture>;
DROP VIEW IF EXISTS vue_erreur_<cloture>;



-- Cr�ation des vues
CREATE OR REPLACE VIEW vue_balance_<cloture> AS
SELECT min(balance_<cloture>.id_balance) AS "ID",
ltrim(balance_<cloture>.ecr_cte_lig_gen_nid, '0'::text) AS "Num�ro Compte",
balance_<cloture>.ecr_cte_lig_gen_lib AS "Libell� Compte",
NULL::unknown AS "Num�ro Compte auxiliaire",
NULL::unknown AS "Libell� Compte auxiliaire",
NULL::unknown AS "Num�ro Compte G�n-Aux",
NULL::unknown AS "Libell� Compte G�n-Aux",
sum(balance_<cloture>.sld_an_deb) AS "D�bit � Nouveau",
sum(balance_<cloture>.sld_an_cre) AS "Cr�dit � Nouveau",
sum(balance_<cloture>.mass_av_clo_deb) AS "D�bit (av. cl�ture)",
sum(balance_<cloture>.mass_av_clo_cre) AS "Cr�dit (av. cl�ture)",
sum(balance_<cloture>.mass_ap_clo_deb) AS "D�bit (ap. cl�ture)",
sum(balance_<cloture>.mass_ap_clo_cre) AS "Cr�dit (ap. cl�ture)",
GREATEST(sum(balance_<cloture>.mass_av_clo_deb)-sum(balance_<cloture>.mass_av_clo_cre), 0.0) AS "Solde D�bit (av. cl�ture)",
GREATEST(sum(balance_<cloture>.mass_av_clo_cre)-sum(balance_<cloture>.mass_av_clo_deb), 0.0) AS "Solde Cr�dit (av. cl�ture)",
GREATEST(sum(balance_<cloture>.mass_ap_clo_deb)-sum(balance_<cloture>.mass_ap_clo_cre), 0.0) AS "Solde D�bit (ap. cl�ture)",
GREATEST(sum(balance_<cloture>.mass_ap_clo_cre)-sum(balance_<cloture>.mass_ap_clo_deb), 0.0) AS "Solde Cr�dit (ap. cl�ture)",
sum(balance_<cloture>.nbr_lign) AS "Nombre lignes",
CASE WHEN sum(nbr_lign) != 0.0 THEN (sum(mass_av_clo_deb)+sum(mass_av_clo_cre)) / sum(nbr_lign) ELSE 0.0 END AS "Montant moyen", 
max(balance_<cloture>.max_lign) AS "Maximum"
 FROM balance_<cloture>
GROUP BY ltrim(balance_<cloture>.ecr_cte_lig_gen_nid, '0'::text), balance_<cloture>.ecr_cte_lig_gen_lib;
-- modif 26/06/2014 : concat�nation cpt g�n(sans enlever les 0) - cpt aux
CREATE OR REPLACE VIEW vue_balance_aux_<cloture> AS
SELECT balance_<cloture>.id_balance AS "ID",
 ltrim(balance_<cloture>.ecr_cte_lig_gen_nid, '0'::text) AS "Num�ro Compte", 
 balance_<cloture>.ecr_cte_lig_gen_lib AS "Libell� Compte", 
 balance_<cloture>.num_cpt_aux AS "Num�ro Compte auxiliaire", 
 balance_<cloture>.lib_cpt_aux AS "Libell� Compte auxiliaire", 
 ((balance_<cloture>.ecr_cte_lig_gen_nid)||'-'||(balance_<cloture>.num_cpt_aux)) AS "Num�ro Compte G�n-Aux",
 ((balance_<cloture>.ecr_cte_lig_gen_lib)||'-'||(balance_<cloture>.lib_cpt_aux)) AS "Libell� Compte G�n-Aux",
  balance_<cloture>.sld_an_deb AS "D�bit � Nouveau", 
 balance_<cloture>.sld_an_cre AS "Cr�dit � Nouveau", 
 balance_<cloture>.mass_av_clo_deb AS "D�bit (av. cl�ture)", 
 balance_<cloture>.mass_av_clo_cre AS "Cr�dit (av. cl�ture)", 
 balance_<cloture>.mass_ap_clo_deb AS "D�bit (ap. cl�ture)", 
 balance_<cloture>.mass_ap_clo_cre AS "Cr�dit (ap. cl�ture)", 
 balance_<cloture>.sld_av_clo_mtn_deb AS "Solde D�bit (av. cl�ture)", 
 balance_<cloture>.sld_av_clo_mtn_cre AS "Solde Cr�dit (av. cl�ture)", 
 balance_<cloture>.sld_ap_clo_mtn_deb AS "Solde D�bit (ap. cl�ture)", 
 balance_<cloture>.sld_ap_clo_mtn_cre AS "Solde Cr�dit (ap. cl�ture)", 
 balance_<cloture>.nbr_lign AS "Nombre lignes", 
 balance_<cloture>.avr_lign_ecr AS "Montant moyen", 
 balance_<cloture>.max_lign AS "Maximum"
  FROM balance_<cloture>; 

CREATE OR REPLACE VIEW vue_ecriture_simple_<cloture> AS
SELECT num_ecr AS "Num�ro Ecriture",
code_jrnal AS "Code Journal",
lib_jrnal AS "Journal",
date_cpt AS "Date comptable",
lib_ecriture AS "Tous les Libell�s",
sum_debit AS "D�bit",
sum_credit AS "Cr�dit",
date_piece AS "Date Pi�ce",
num_piece AS "Num�ro Pi�ce",
       CASE
           WHEN taux_tva > 0::numeric THEN 'Cr�diteur'::text
           WHEN taux_tva < 0::numeric THEN 'D�biteur'::text
           ELSE 'Nul'::text
       END AS "Sens TVA",
abs(taux_tva) AS "Taux TVA",
nb_ligne AS "Nombre de lignes",
       CASE
           WHEN ecr_type = 1 OR ecr_type = 11 THEN 'Cl�ture'::text
           WHEN ecr_type = 2 OR ecr_type = 12 THEN 'A. Nouveau'::text
           ELSE ''::text
       END AS "Type �criture",
       CASE
           WHEN ecr_type = 11 OR ecr_type = 12 THEN 'G�n�r�e'::text
           ELSE ''::text
       END AS "G�n�r�e lecode"
  FROM ecriture_<cloture> 
  WHERE ((ecr_type != 11) AND (ecr_type != 12));

CREATE OR REPLACE VIEW vue_ecriture_<cloture> AS
SELECT
       CASE
           WHEN NOT e.idem_codejrnal THEN 'X'::text
           ELSE ''::text
       END AS "Diff�rents codes journaux",
       CASE
           WHEN NOT e.idem_debcre THEN 'X'::text
           ELSE ''::text
       END AS "Ecriture non �quilibr�e",
       CASE
           WHEN NOT e.idem_datecpt THEN 'X'::text
           ELSE ''::text
       END AS "Diff�rentes dates comptables",
       CASE
           WHEN NOT e.idem_numpiece THEN 'X'::text
           ELSE ''::text
       END AS "Diff�rents num�ros de pi�ce",
       CASE
           WHEN NOT e.idem_datepiece THEN 'X'::text
           ELSE ''::text
       END AS "Diff�rentes dates pi�ce",
       CASE
           WHEN NOT e.idem_codelet THEN 'X'::text
           ELSE ''::text
       END AS "Diff�rents lettrages",
e.num_ecr AS "Num�ro Ecriture",
l.code_jrnal AS "Code Journal",
l.lib_jrnal AS "Journal",
l.date_cpt AS "Date comptable",
l.lib_ecriture AS "Libell�",
e.lib_ecriture AS "Tous les Libell�s",
ltrim(l.num_cpte_gen,
'0'::text) AS "Num�ro Compte",
l.lib_cpte_gen AS "Libell� Compte",
l.mtn_debit AS "D�bit",
l.mtn_credit AS "Cr�dit",
l.date_piece AS "Date Pi�ce",
l.num_piece AS "Num�ro Pi�ce",
l.code_lettrage AS "Lettrage",
l.id_ligne AS "ID",
       CASE
           WHEN e.taux_tva > 0::numeric THEN 'Cr�diteur'::text
           WHEN e.taux_tva < 0::numeric THEN 'D�biteur'::text
           ELSE 'Nul'::text
       END AS "Sens TVA",
abs(e.taux_tva) AS "Taux TVA",
e.nb_ligne AS "Nombre de lignes",
       CASE
           WHEN e.ecr_type = 1 OR e.ecr_type = 11 THEN 'Cl�ture'::text
           WHEN e.ecr_type = 2 OR e.ecr_type = 12 THEN 'A. Nouveau'::text
           ELSE ''::text
       END AS "Type �criture",
       CASE
           WHEN e.ecr_type = 11 OR e.ecr_type = 12 THEN 'G�n�r�e'::text
           ELSE ''::text
       END AS "G�n�r�e lecode",
l.num_cpt_aux AS "Num�ro Compte auxiliaire",
l.lib_cpt_aux AS "Libell� Compte auxiliaire"
  FROM (select * from ecriture_<cloture> WHERE ((ecr_type != 11) AND (ecr_type != 12))  ) e
  JOIN fec_<cloture> l ON e.num_ecr = l.num_ecr; 
  
CREATE VIEW vue_erreur_<cloture> AS
 SELECT "Diff�rents codes journaux",
"Ecriture non �quilibr�e",
"Diff�rentes dates comptables",
"Diff�rents num�ros de pi�ce",
"Diff�rentes dates pi�ce",
"Diff�rents lettrages",
"Num�ro Ecriture",
"Code Journal",
"Journal",
"Date comptable",
"Libell�",
"Tous les Libell�s",
"Num�ro Compte",
"Libell� Compte",
"D�bit",
"Cr�dit",
"Date Pi�ce",
"Num�ro Pi�ce",
"Lettrage",
"ID",
"Sens TVA",
"Taux TVA",
"Nombre de lignes",
"Type �criture",
"G�n�r�e lecode",
"Num�ro Compte auxiliaire",
"Libell� Compte auxiliaire"
   FROM vue_ecriture_<cloture>
  WHERE "Diff�rents codes journaux" = 'X'::text
OR "Ecriture non �quilibr�e" = 'X'::text
OR "Diff�rentes dates comptables" = 'X'::text
OR "Diff�rents num�ros de pi�ce" = 'X'::text
OR "Diff�rentes dates pi�ce" = 'X'::text
OR "Diff�rents lettrages" = 'X'::text ;



