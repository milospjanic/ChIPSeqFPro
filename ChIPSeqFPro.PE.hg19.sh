#!/bin/bash

SECONDS=0

###fastqc quality control - requires fastqc installed and placed in PATH

ls -1 *fastq.gz > commands.1
sed -i 's/^/.\/FastQC\/fastqc /g' commands.1

source commands.1

mkdir FastQC_OUTPUT
mv *zip FastQC_OUTPUT
mv *html FastQC_OUTPUT

###mapping with BWA

files=(*fastq.gz)
for (( i=0; i<${#files[@]} ; i+=2 )) ; do
    mkdir "${files[i]}.${files[i+1]}.BWA"    
done 

GenomeDir='~/reference_genomes/hg19/'
GenomeFasta='~/reference_genomes/hg19/hg19.fa'
mkdir STATS

files=(*fastq.gz)
for (( i=0; i<${#files[@]} ; i+=2 )) ; do

echo $(pwd)/${files[i]} $(pwd)/${files[i+1]}
Reads="$(pwd)/"${files[i]}" $(pwd)/"${files[i+1]}"" 
Cores=$1

echo $Reads

cat >> commands.2.${files[i]}.${files[i+1]}.tmp <<EOL
    #!/bin/bash
    echo Proccessing `pwd`: ${files[i]} ${files[i+1]}
    
    # run bwa mem
    bwa mem -M -t $Cores $GenomeFasta $Reads > ${files[i]}.${files[i+1]}.sam
    
    # run samtools to convert sam to bam
    samtools view -Sb ${files[i]}.${files[i+1]}.sam > ${files[i]}.${files[i+1]}.bam
    
    # get stats on bam files
    samtools flagstat ${files[i]}.${files[i+1]}.bam > ${files[i]}.${files[i+1]}.flagstats
    mv ${files[i]}.${files[i+1]}.flagstats ../STATS/
    
    #convert bam to bigwig
    cd ..
    ./bam2bigwig.sh ${files[i]}.${files[i+1]}.BWA/${files[i]}.${files[i+1]}.bam
    
    #running MACS2 on bam
    macs2 -t ${files[i]}.${files[i+1]}.BWA/${files[i]}.${files[i+1]}.bam -g hs -n ${files[i]}.${files[i+1]}.MACS2
    

EOL
  done
  
files=(*fastq.gz)
for (( i=0; i<${#files[@]} ; i+=2 )) ; do
    sed -i "3i\\\tcd ${files[i]}.${files[i+1]}.BWA" commands.2.${files[i]}.${files[i+1]}.tmp
    sed -i "4i\\\t# enter the correct folder" commands.2.${files[i]}.${files[i+1]}.tmp
done

for (( i=0; i<${#files[@]} ; i+=2 )) ; do
    sed -i "2i\ Reads=\"`pwd`/${files[i]} `pwd`/${files[i+1]} \"" commands.2.${files[i]}.${files[i+1]}.tmp
done

for (( i=0; i<${#files[@]} ; i+=2 )) ; do
    source commands.2.${files[i]}.${files[i+1]}.tmp
done

rm *tmp
