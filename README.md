# fish-gen
This program is developed for creating fishplot for visualizing clonal evolution pattern of cancer patient with two time points data(e.g. Diagnosis and Progression) obtained from Exome/target sequencing using fishplot R package. It can also generate fishplot if there are multiple founders in clone sets.
The input file containing clonal cellularity / cancer cell fraction at two time points data obtained from QuantumClone or any similar kind of software.

#Syntax for running the program
perl fishgen.pl -i meta_file.txt -o <output_dir>

-i <input meta file> e.g. meta_file.txt
-0 <output_dir> specify output directory for creating fishplots

#meta_file.txt contains two tab separated column SID and path of CCF/clonal cellularity file.
#Example of meta_file.txt
SID	FILE
SID1	SID_CLONES/SID1.txt
SID2	SID_CLONES/SID2.txt
SID3	SID_CLONES/SID3.txt
SID4	SID_CLONES/SID4.txt
SID5	SID_CLONES/SID5.txt
#Example of meta_file.txt

#Example of CCF/clonal cellularity file (e.g. SID1.txt)
Clone  CCF_TP1 CCF_TP2
1	2.22044604925031e-16	0.357497712069053
2	0.888658190497977	0.361422682852844
3	1	1
4	2.22044604925031e-16	0.41067535419425
#Example of CCF/clonal cellularity file (e.g. SID1.txt)

