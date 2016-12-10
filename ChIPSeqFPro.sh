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

files=(*fastq.gz)
for (( i=0; i<${#files[@]} ; i+=2 )) ; do

echo $(pwd)/${files[i]} $(pwd)/${files[i+1]}
Reads="$(pwd)/"${files[i]}" $(pwd)/"${files[i+1]}" 

echo $Reads

cat >> commands.2.${files[i]}.${files[i+1]}.tmp <<EOL
    #!/bin/bash
    echo Proccessing `pwd`: ${files[i]} ${files[i+1]}
    # enter the correct folder
	  cd ${files[i]}.${files[i+1]}.STAR
    # run bwa
    
    cd ..

EOL
  done
  
files=(*fastq.gz)
for (( i=0; i<${#files[@]} ; i+=2 )) ; do
    sed -i "8i\\\tcd ${files[i]}.${files[i+1]}.STAR" commands.2.${files[i]}.${files[i+1]}.tmp
done

for (( i=0; i<${#files[@]} ; i+=2 )) ; do
    sed -i "2i\ Reads=\"`pwd`/${files[i]} `pwd`/${files[i+1]} --readFilesCommand zcat\"" commands.2.${files[i]}.${files[i+1]}.tmp
done

for (( i=0; i<${#files[@]} ; i+=2 )) ; do
    source commands.2.${files[i]}.${files[i+1]}.tmp
done

