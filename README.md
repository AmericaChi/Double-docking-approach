# Double-docking-approach

#########################################
#bash script to perform a double docking procedure usually between a protein/dendrimer and peptides.
#output: complex_out.pdb, peptide_out.pdb
#this algorithm need: config.txt, config_flex.txt, protein$i.pdb and peptide$j.pdb files in the rooth directory.
#call via: bash double_docking_general.sh
# Author: L. América Chi
#27.01.2022 
# Please cite: (pending).
#########################################

A double molecular docking is performed in order to have initial dendrimer/protein-peptide complexes by using Autodock Vina program. First, a blind rigid docking is performed separately for all combinations of conformers/structures. Once the peptide found a binding site, a second flexible local docking is performed in this area for each system allowing a better adaptation in the binding site.
