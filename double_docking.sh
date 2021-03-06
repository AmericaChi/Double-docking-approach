#!/bin/bash                                                                                                                                                            
#########################################
#bash script to perform a double docking procedure
#output: complex_out.pdb, peptide_out.pdb
#this algorithm need: config.txt, config_flex.txt, protein$i.pdb and peptide$j.pdb files in the rooth directory.
#call via: bash double_docking_general.sh
# Author: L. América Chi
#12.05.2022 
#########################################

# environment variable definitions                                                                                                                                    
export vina='/path/bin/vina'
export pdbqt2pdb='/path/MGLToolsPckgs/AutoDockTools/Utilities24/pdbqt_to_pdb.py'
export pythonsh='/path/MGLTools-1.5.6/mgltools_x86_64Linux2_1.5.6/bin/pythonsh'
UTILITIES=/path/MGLTools-1.5.6/mgltools_x86_64Linux2_1.5.6/MGLToolsPckgs/AutoDockTools/Utilities24
# end variable definitions

for i in 0 1 2; do
        receptor=dendri${i}
        mkdir -p $receptor
        rm -f receptor.pdb
        rm -f receptor.pdbqt
        cp ${receptor}.pdb  receptor.pdb

        $pythonsh ${UTILITIES}/prepare_receptor4.py -r receptor.pdb -o receptor.pdbqt

        for j in 0 1 2 3 4 5; do
        ligand=peptide${j}
        mkdir -p $receptor/$ligand
        cp receptor.pdbqt $receptor/$ligand/receptor.pdbqt
        cp receptor.pdb $receptor/$ligand/receptor.pdb
        cp ${ligand}.pdb $receptor/$ligand/ligand.pdb
        cp config.txt $receptor/$ligand
        cp config_flex.txt $receptor/$ligand
        cd $receptor/$ligand

        ### starts first blind rigid docking
        $pythonsh ${UTILITIES}/prepare_ligand4.py -l ligand.pdb -Z -o ligand.pdbqt
        $vina --config config.txt > vina.log
        $pythonsh $pdbqt2pdb -f ligand_out.pdbqt
        sed '1d' ligand_out.pdb > peptide_out.pdb
        cat receptor.pdb peptide_out.pdb > complex.pdb
        grep -Ev 'ENDMDL' complex.pdb > complex_out.pdb

        #localize your new box center, grep should be modified according to your system
        n=D${i}p${j}
        p=`grep 'CA  TYR     4 ' complex_out.pdb | awk 'BEGIN{OFS="\t\t";}{print $6, $7, $8}'`;
        echo "${n}  ${p}" >> ubica.txt;

        local=${ligand}'_local'
        x=`grep "D"${i}"p"${j} ubica.txt | awk '{print $2}'`
        y=`grep "D"${i}"p"${j} ubica.txt | awk '{print $3}'`
        z=`grep "D"${i}"p"${j} ubica.txt | awk '{print $4}'`
        ### end localize
        ### end first docking

        #starts second local flexible docking
        mkdir -p $local
        cp receptor.pdbqt $local/receptor.pdbqt
        cp receptor.pdb $local/receptor.pdb
        cp ligand_out.pdb $local/ligand.pdb
        cp config_flex.txt $local/config_flex.txt
        cd $local

        cp config_flex.txt config_flex_tmp.txt
        sed 's/##xx/'$x'/g;s/##yy/'$y'/g;s/##zz/'$z'/g' config_flex_tmp.txt > config_flex.txt
        rm -f config_flex_tmp.txt

        $pythonsh ${UTILITIES}/prepare_ligand4.py -l ligand.pdb -o ligand.pdbqt
        $vina --config config_flex.txt > vina.log
        $pythonsh $pdbqt2pdb -f ligand_out.pdbqt
        sed '1d' ligand_out.pdb > peptide_out.pdb
        cat receptor.pdb peptide_out.pdb > complex.pdb
        grep -Ev 'ENDMDL' complex.pdb > complex_out.pdb
        ### end second docking

        cd ../../../

        done
done
