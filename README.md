# ChIPSeqFPro

ChiPSeqFPro (short from ChIP-Seq Full Processing) is a pipeline that will perform full processing of ChIPSeq data starting from the fastq.gz files. It performs fastqc quality control, mapping to the human genome hg19 or mouse mm10 using bwa, sam to bam conversion, peak calling with MACS, and finally creates bigwig files from bam files using bam2BigWig tool.

