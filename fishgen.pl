#!/usr/bin/perl
#This program is developed by Dr. Lingaraja Jena for making fishplot
# at two time points data(e.g. Diagnosis and Progression) using fishplot R package.
# Very useful if there are multiple founder in clone sets
# Prior to running the program, chrisamiller/fishplot R package should be installed in your system
# Reference https://rdrr.io/github/chrisamiller/fishplot/ 
# If you want to change the fishplot figure, you may change thr R script generated in <output> directory
$number_args = $#ARGV + 1;

if($number_args !=4)
{
INPUT_ERROR();
}
elsif(($ARGV[0]!~m/\-i/i) && ($ARGV[2]!~m/\-O/i))
{
INPUT_ERROR();
}
else
{
print "Input meta_file: $ARGV[1]\n";
print "Output Directory: $ARGV[3]\n";
$meta_file=$ARGV[1];
$output_dir=$ARGV[3];
if(!-e $output_dir)
{
mkdir($output_dir);
}

open(META_FILE,"$meta_file") || die "No such input meta file:$meta_file\n";
@meta=<META_FILE>;
close(META_FILE);
	for($f=1;$f<scalar(@meta);$f++)
	{
	$meta[$f]=~s/\n//g;
	@meta_pos = split(/\t/,$meta[$f]);
	$sid=$meta_pos[0];
	$sid_loc=$meta_pos[1];
	gen_fishplot($sid,$sid_loc);
	}


}

sub INPUT_ERROR
{
print '##############INPUT ERROR#####';
print "\nIncorrect arguments.\n\nCorrect syntax should be:\n";
print "perl fishgen.pl -i meta_file.txt -o <output_dir>\n";
print '##############',"\n";
}

sub gen_fishplot
{
$sid1=$_[0];
$sid1_loc=$_[1];
print "SAMPLE ID : $sid1\n";

$clone_file="$sid1_loc";
$sort_file="CLONE_CELLULARITY_SORT.txt";
$parent_file="SORT_PARENT_CLONE_CELLULARITY.txt";
$fishplot_file="SORT_PARENT_CLONE_CELLULARITY_FISHPLOT.txt";

open(file1,"$clone_file") || die "Unable to open $clone_file: No such file!!\n";
@fc1=<file1>;
close(file1);
$total_fc1=(@fc1);

open(file2,">CLONE_CELLULARITY_P.txt");

for($i=0;$i<$total_fc1;$i++)
{
$fc1[$i]=~s/\n//g;
$fc1[$i]=~s/\"//g;
@fc1_pos=split(/\t/,$fc1[$i]);
$fc1_pos[1]=$fc1_pos[1]*100;
$fc1_pos[2]=$fc1_pos[2]*100;
print file2 "$fc1_pos[0]\t$fc1_pos[1]\t$fc1_pos[2]\n";
}
close(file2);

system("sort -k 2nr -k 3nr CLONE_CELLULARITY_P.txt >$sort_file");


open(file1,"$sort_file") || die "Unable to open $sort_file: No such file!!\n";
@fc1=<file1>;
close(fle1);
$total_file1=(@fc1);

open(file2,">$sort_file") || die "Unable to create $sort_file !!";
$power=12;
for($n=0;$n<$total_file1;$n++)
{
$fc1[$n]=~s/\n//g;
@fc1_pos=split(/\t/,$fc1[$n]);
if($fc1_pos[1]==0)
{
$fc1_pos[1]=1/(10**$power);
$power++;
}
if($fc1_pos[2]==0)
{
$fc1_pos[2]=1/(10**$power);
$power++;
}
print file2 "$fc1_pos[0]\t$fc1_pos[1]\t$fc1_pos[2]\n";
}
close(file2);

########
open(file1,"$sort_file") || die "Unable to open $sort_file: No such file!!\n";
@vaf=<file1>;
close(file1);
$total_vaf=(@vaf);

%tp1=();
%tp2=();
%parents=();
%clones=();

for($i=0;$i<$total_vaf;$i++)
{
$vaf[$i]=~s/\n//g;
@vaf_pos=split(/\t/,$vaf[$i]);
$tp1{"$vaf_pos[0]"}=$vaf_pos[1];
$tp2{"$vaf_pos[0]"}=$vaf_pos[2];
$parents{"$vaf_pos[0]"}=0;
$clones{"$i"}=$vaf_pos[0];
}
open(file2,">$parent_file") || die "Unable to create $parent_file !!\n";

print file2 "$clones{\"0\"}\t$tp1{$clones{\"0\"}}\t$tp2{$clones{\"0\"}}\t$parents{$clones{\"0\"}}\n";
$founder=1;
for($i=1;$i<$total_vaf;$i++)
{
$vaf[$i]=~s/\n//g;
@vaf_pos=split(/\t/,$vaf[$i]);
$count=0;
for($j=0;$j<$i;$j++)
{
if(($tp1{$clones{"$j"}} >= $tp1{$clones{"$i"}}) && ($tp2{$clones{"$j"}} >= $tp2{$clones{"$i"}}))
{
$parents{$clones{"$i"}}=$j+1;
$tp1{$clones{"$j"}}=$tp1{$clones{"$j"}} - $tp1{$clones{"$i"}};
$tp2{$clones{"$j"}}=$tp2{$clones{"$j"}} - $tp2{$clones{"$i"}};
$count++;
last;
}
}

if($count==0)
{
$parents{$clones{"$i"}}=0;
$founder++;
}
print file2 "$clones{\"$i\"}\t$tp1{$clones{\"$i\"}}\t$tp2{$clones{\"$i\"}}\t$parents{$clones{\"$i\"}}\n";
}
close(file2);



open(file1,"$parent_file") || die "Unable to open $parent_file: No such file!!";
@fc1=<file1>;
close(file1);
$total_clone=(@fc1);


$mat1='';
$mat2='';
$par='';
$clones='';

open(file4,">$fishplot_file");
print file4 "Clone\tTP1\tTP2\tParents\n";

for($i=0;$i<$total_clone;$i++)
{
$fc1[$i]=~s/\n//g;
@fc1_pos=split(/\t/,$fc1[$i]);

$fc1_pos[1]=$fc1_pos[1]/$founder;
$fc1_pos[2]=$fc1_pos[2]/$founder;
print file4 "$fc1_pos[0]\t$fc1_pos[1]\t$fc1_pos[2]\t$fc1_pos[3]\n";
$mat1=$mat1.', '.$fc1_pos[1];
$mat2=$mat2.', '.$fc1_pos[2];

$par=$par.', '.$fc1_pos[3];
$clones=$clones.','.$fc1_pos[0];

}
close(file4);
$mat1=~s/\, //;
$mat=$mat1.$mat2;
$par=~s/\, //;
$clones=~s/\,//;
$clones=~s/\,/","/g;
$clones="\"".$clones."\"";

$fish_r=$sid.'_fish.R';

open(file3,">$output_dir/$fish_r");

##################################
print file3 "library(fishplot)\n";
print file3 "timepoints=c(0,100)\n";
print file3 "frac.table = matrix( c($mat), ncol=length(timepoints))\n";
print file3 "parents = c($par)\n";
print file3 "clone.annots = c($clones)\n";
print file3 "fish = createFishObject(frac.table,parents,timepoints=timepoints,clone.annots=clone.annots)\n";
print file3 "fish = layoutClones(fish)\n";
$file_name=$sid1.'_fishplot.png';
print file3 "png(\"$output_dir/$file_name\", width=5, height=4, unit=\"in\", res=400)\n";
print file3 "fishPlot(fish,shape=\"spline\",title.btm=\"$sid1\", cex.title=0.5, vlines=c(0,100), vlab=c(\"TP1\",\"TP2\"))\n";
print file3 "dev.off()\n";
################################3
close(file3);
#chdir($output_dir);
system("Rscript $output_dir/$fish_r");
}
##########333
unlink("CLONE_CELLULARITY_P.txt");
unlink("CLONE_CELLULARITY_SORT.txt");
unlink("CLONE_CELLULARITY_SORT.txt");
unlink("SORT_PARENT_CLONE_CELLULARITY.txt");
unlink("SORT_PARENT_CLONE_CELLULARITY_FISHPLOT.txt");

print "\n\nCOMPLETED\n\n";
print "This is beta version.\n";
print "For any error or suggestions. Please contact  Dr. Lingaraja Jena (lingaraja.jena\@gmail.com)\n\nThank you...\n\n";

print "#This program is developed by Dr. Lingaraja Jena for making fishplot\n";
print "# at two time points data(e.g. Diagnosis and Progression) using fishplot R package.\n";
print "# Very useful, if there are multiple founder in clone sets\n";
print "# Prior to running the program, chrisamiller/fishplot R package should be installed in your system\n";
print "# Reference: https://rdrr.io/github/chrisamiller/fishplot/ \n";
print "# If you want to change the fishplot figure, you may change thr R script generated in <output> directory $output_dir\n";


