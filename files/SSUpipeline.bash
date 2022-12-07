#/bin/bash
# This script runs a pipeline of analysis for SSU rRNA genes amplifies with the 
# Parada et al. 2016 doi: 10.1111/1462-2920.13023 primers. It assumes that the 
# reads were demultiplexed fastq files, that the reads are labeled with R1 and
# R2 (the only occurrences of this regular expression in the sequence name, and 
# that we will analyze a range of samples where the sample number is after the 
# first "_" and followed by a "-" example : 5613-814-515yF-926pfR_R1.fastq for 
# sample 814. It is also assumed that qiime2-2018.8 was installed used miniconda
#in the system

# Marcelino Suzuki suzuki@obs-banyuls.fr 31 January 2019

# Usage : SSUpipeline.bash <first sample number> <last sample number>

i=$1
j=$2

# Activate environment

	source activate qiime2-2018.8

# Go to directory where fastq files are stored

	cd /work/gitai/300818/16Sfiles/

# Create directory specific for working samples and enter this directory

	mkdir ${i}-${j}
	cd ${i}-${j}

# Move samples 

	ls .. | gawk -F "-" -v frst=${i} -v last=${j} '{if($0~/fastq/&&$2>=frst&&$2<=last)print "mv ../"$0" ."}' | /bin/sh
	wait

# Create manifest file

	ls *.fastq | awk -F "-" 'BEGIN{printf("%s\n","sample-id,absolute-filepath,direction")}\
							{if($0~/R1/){print $2",$PWD/"$0",forward"}else{print $2",$PWD/"$0",reverse"}}'\
							 > pe-33-manifest.csv

# Qiime2 import sequences

	qiime tools import --type 'SampleData[PairedEndSequencesWithQuality]' --input-path pe-33-manifest.csv --output-path ${i}-${j}-paired-end-demux.qza --input-format PairedEndFastqManifestPhred33

# Qiime2 demultiuplex sequences

	qiime demux summarize  --i-data  ${i}-${j}-paired-end-demux.qza  --o-visualization ${i}-${j}-demux.qzv
	wait
	
# Qiime2 DADA2 denoise sequences make ASV table

	qiime dada2 denoise-paired --i-demultiplexed-seqs ${i}-${j}-paired-end-demux.qza --p-trim-left-f 19   --p-trim-left-r 20   --p-trunc-len-f 300   --p-trunc-len-r 250   --o-table ${i}-${j}-table.qza   --o-representative-sequences ${i}-${j}-rep-seqs.qza   --o-denoising-stats ${i}-${j}-denoising-stats.qza
	wait 

# Qiime2 naive bayes classify all against universal database

	qiime feature-classifier classify-sklearn --i-classifier /Volumes/data/silvardp/SILVA_132_QIIME_release/all-classifier.qza  --i-reads ${i}-${j}-rep-seqs.qza  --o-classification ${i}-${j}-taxonomy.qza
	wait

# Qiime2 make ASV table for chloroplasts 

	qiime taxa filter-table --i-table ${i}-${j}-table.qza --i-taxonomy ${i}-${j}-taxonomy.qza --p-include chloroplast --o-filtered-table ${i}-${j}-chloroplast-table.qza
	wait

# Qiime2 retrieve chloroplast sequences

	qiime taxa filter-seqs --i-sequences ${i}-${j}-rep-seqs.qza --i-taxonomy ${i}-${j}-taxonomy.qza --p-include chloroplast --o-filtered-sequences ${i}-${j}-chloroplast-rep-seqs.qza
	wait

# Qiime2 make ASV table for eukaryotes

	qiime taxa filter-table --i-table ${i}-${j}-table.qza --i-taxonomy ${i}-${j}-taxonomy.qza --p-include eukaryota --o-filtered-table ${i}-${j}-eukaryota-table.qza
	wait

# Qiime2 retrieve eukaryote 18S sequences

	qiime taxa filter-seqs --i-sequences ${i}-${j}-rep-seqs.qza --i-taxonomy ${i}-${j}-taxonomy.qza --p-include eukaryota --o-filtered-sequences ${i}-${j}-eukaryota-rep-seqs.qza
	wait

# Qiime2 make ASV table for prokaryotes

	qiime taxa filter-table --i-table ${i}-${j}-table.qza --i-taxonomy ${i}-${j}-taxonomy.qza --p-exclude eukaryota,chloroplast,mitochondria --p-include D_0__ --o-filtered-table ${i}-${j}-proka-table.qza
	wait 

# Qiime2 retrieve prokaryote 18S sequences

	qiime taxa filter-seqs --i-sequences ${i}-${j}-rep-seqs.qza --i-taxonomy ${i}-${j}-taxonomy.qza --p-exclude eukaryota,chloroplast,mitochondria --p-include D_0__ --o-filtered-sequences ${i}-${j}-proka-rep-seqs.qza
	wait 

# Qiime2 naive bayes classify chloroplasts against PhytoRef database

	qiime feature-classifier classify-sklearn --i-classifier /Volumes/data/pr2rdp/PhytoRef-classifier.qza  --i-reads ${i}-${j}-chloroplast-rep-seqs.qza  --o-classification ${i}-${j}-chloroplast-taxonomy.qza
	wait

# Qiime2 naive bayes classify chloroplasts against Silva132 prokaryote database

	qiime feature-classifier classify-sklearn --i-classifier /Volumes/data/silvardp/SILVA_132_QIIME_release/classifier.qza  --i-reads ${i}-${j}-proka-rep-seqs.qza  --o-classification ${i}-${j}-proka-taxonomy.qza
	wait

# Qiime2 create prokaryte OTU table collapsed at species level

	qiime taxa collapse --i-table ${i}-${j}-proka-table.qza --i-taxonomy  ${i}-${j}-proka-taxonomy.qza --p-level 7 --output-dir ${i}-${j}-proka-tax-table
	wait

# Export collapsed prokaryte OTU table artifact in shell readable format 

	qiime tool export --input-path ${i}-${j}-proka-tax-table/collapsed_table.qza --output-path ${i}-${j}-proka-tax-table-unzip 
	wait

# Biom, convert prokaryte table to tsv to fix format (i.e. this table has taxonomy as the OTU name)

	biom convert -i ${i}-${j}-proka-tax-table-unzip/data/feature-table.biom -o ${i}-${j}-proka-table-tax.txt  --header-key taxonomy --to-tsv
	wait

# Fix table format

	cat ${i}-${j}-proka-table-tax.txt | gawk -F "\t" '{if($1!~/#/){printf("%s\t",NR-2);{for(i=2;i<=NF;i++)printf("%s\t",$i)};printf("%s\n",$1)}else{print $0}}' >${i}-${j}-proka-table-final.txt
	wait

# Export prokaryte table artifact in shell readable format 

	qiime tool export --input-path ${i}-${j}-proka-table.qza --output-path ${i}-${j}-proka-table
	wait 

# Export prokaryte taxonomy  artifact in shell readable format 

	qiime tool export --input-path ${i}-${j}-proka-taxonomy.qza --output-path ${i}-${j}-proka-taxonomy 
	wait

# Fix prokaryte taxonomy to a biom readable format

	mv ${i}-${j}-proka-taxonomy/data/taxonomy.tsv ${i}-${j}-proka-taxonomy/data/taxonomy.tsv%
	sed 's/Feature\ ID/#OTUID/;s/Taxon/taxonomy/;s/Confidence/confidence/' ${i}-${j}-proka-taxonomy/data/taxonomy.tsv% > ${i}-${j}-proka-taxonomy/data/taxonomy.tsv
	wait

# biom add prokaryote taxonomy to prokaryote ASV table

	biom add-metadata -i ${i}-${j}-proka-table/*/data/feature-table.biom -o ${i}-${j}-proka-table-final-full.biom --observation-metadata-fp ${i}-${j}-proka-taxonomy/*/data/taxonomy.tsv --sc-separated taxonomy
	wait

# biom convert ASV table to tsv format

	biom convert -i ${i}-${j}-proka-table-final-full.biom -o ${i}-${j}-proka-table-final-full.txt  --header-key taxonomy --to-tsv
	wait 

# Qiime2 create prokaryte OTU table collapsed at species level

	qiime taxa collapse --i-table ${i}-${j}-chloroplast-table.qza --i-taxonomy  ${i}-${j}-chloroplast-taxonomy.qza --p-level 10 --output-dir ${i}-${j}-chloroplast-tax-table
	wait

# Export collapsed prokaryte OTU table artifact in shell readable format 

	qiime tool export --input-path ${i}-${j}-chloroplast-tax-table/collapsed_table.qza --output-path ${i}-${j}-chloroplast-tax-table-unzip 
	wait

# Biom, convert prokaryte table to tsv to fix format (i.e. this table has taxonomy as the OTU name)

	biom convert -i ${i}-${j}-chloroplast-tax-table-unzip/data/feature-table.biom -o ${i}-${j}-chloroplast-table-tax.txt  --header-key taxonomy --to-tsv
	wait

# Fix table format 

	cat ${i}-${j}-chloroplast-table-tax.txt | gawk -F "\t" '{if($1!~/#/){printf("%s\t",NR-2);{for(i=2;i<=NF;i++)printf("%s\t",$i)};printf("%s\n",$1)}else{print $0}}' >${i}-${j}-chloroplast-table-final.txt
	wait

# Export prokaryte table artifact in shell readable format 

	qiime tool export --input-path ${i}-${j}-chloroplast-table.qza --output-path ${i}-${j}-chloroplast-table
	wait

# Export prokaryte taxonomy  artifact in shell readable format 

	qiime tool export --input-path ${i}-${j}-chloroplast-taxonomy.qza --output-path ${i}-${j}-chloroplast-taxonomy 
	wait

# Fix prokaryte taxonomy to a biom readable format

	mv ${i}-${j}-chloroplast-taxonomy/data/taxonomy.tsv ${i}-${j}-chloroplast-taxonomy/data/taxonomy.tsv%
	sed 's/Feature\ ID/#OTUID/;s/Taxon/taxonomy/;s/Confidence/confidence/' ${i}-${j}-chloroplast-taxonomy/data/taxonomy.tsv% > ${i}-${j}-chloroplast-taxonomy/data/taxonomy.tsv
	wait

# biom add prokaryote taxonomy to prokaryote ASV table

	biom add-metadata -i ${i}-${j}-chloroplast-table/*/data/feature-table.biom -o ${i}-${j}-chloroplast-table-final-full.biom --observation-metadata-fp ${i}-${j}-chloroplast-taxonomy/*/data/taxonomy.tsv --sc-separated taxonomy
	wait

# biom convert ASV table to tsv format
	biom convert -i ${i}-${j}-chloroplast-table-final-full.biom -o ${i}-${j}-chloroplast-table-final-full.txt  --header-key taxonomy --to-tsv
