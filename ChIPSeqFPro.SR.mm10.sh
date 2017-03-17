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
for (( i=0; i<${#files[@]} ; i+=1 )) ; do
    mkdir "${files[i]}.BWA"    
done 

GenomeDir='~/reference_genomes/mm10/'
GenomeFasta='~/reference_genomes/mm10/mm10.fa'
mkdir STATS

files=(*fastq.gz)
for (( i=0; i<${#files[@]} ; i+=1 )) ; do

echo $(pwd)/${files[i]}
Reads="$(pwd)/"${files[i]}""
Cores=$1

echo $Reads

cat >> commands.2.${files[i]}.tmp <<EOL
    #!/bin/bash
    echo Proccessing `pwd`: ${files[i]}
    
    # run bwa mem
    bwa mem -M -t $Cores $GenomeFasta $Reads > ${files[i]}.sam
    
    # run samtools to convert sam to bam
    samtools view -Sb ${files[i]}.sam > ${files[i]}.bam
    
    # get stats on bam files
    samtools flagstat ${files[i]}.bam > ${files[i]}.flagstats
    mv ${files[i]}.flagstats ../STATS/
    
    #convert bam to bigwig
    ./bam2bigwig.sh ${files[i]}.bam
    
    cd ..

EOL
  done
  
files=(*fastq.gz)
for (( i=0; i<${#files[@]} ; i+=1 )) ; do
    sed -i "3i\\\tcd ${files[i]}.BWA" commands.2.${files[i]}.tmp
    sed -i "4i\\\t# enter the correct folder" commands.2.${files[i]}.tmp
done

for (( i=0; i<${#files[@]} ; i+=1 )) ; do
    sed -i "2i\ Reads=\"`pwd`/${files[i]} \"" commands.2.${files[i]}.tmp
done

for (( i=0; i<${#files[@]} ; i+=1 )) ; do
    source commands.2.${files[i]}.tmp
done

rm *tmp
