# Silva ALL taxonomy database

* Based on Parada et al http://10.1111/1462-2920.13023 primers
* Do not truncate length

started with file

https://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_132_release.zip

`unzip Silva_132_release.zip`

under */Volumes/data/silvardp/SILVA_132_QIIME_release*

`qiime tools import   --type 'FeatureData[Sequence]'   --input-path  rep_set/rep_set_all/99/silva132_99.fna  --output-path all-99_otus.qza`

`qiime tools import --type 'FeatureData[Taxonomy]'  --input-format HeaderlessTSVTaxonomyFormat  --input-path taxonomy/taxonomy_all/99/majority_taxonomy_7_levels.txt --output-path all-ref-taxonomy.qza`

`qiime feature-classifier extract-reads  --i-sequences all-99_otus.qza   --p-f-primer GTGYCAGCMGCCGCGGTAA   --p-r-primer CCGYCAATTYMTTTRAGTTT --o-reads all-ref-seqs.qza`

Missing  because of primers not because of length, since I did not truncate

`qiime feature-classifier fit-classifier-naive-bayes   --i-reference-reads all-ref-seqs.qza   --i-reference-taxonomy all-ref-taxonomy.qza   --o-classifier all-classifier.qza`

I got an error (same classification for all with one sequence)
checked <https://forum.qiime2.org/t/wrong-taxonomy-qzv-file/5287/15>
seems like very short sequences are created during the truncation, so filter the file for sequences greater than certain length

```use 320 as minimum```

`unzip all-ref-seqs.qza`

`cd 9e443d30-1430-41f9-90ae-93c248767b11/data`

`/usr/local/myscripts/fastasingleline dna-sequences.fasta`

`cat dna-sequences.fasta.fasta | awk '{if(length($2)<320)print $0}' |grep -c ^`

464

`cat dna-sequences.fasta.fasta | awk '{if(length($2)>319){printf("%s",$1);printf("%s",$2)}}' > dna-sequences-gt319.fasta`

`cd ../..`

`mv all-ref-seqs.qza all-ref-seqs-b4corr.qza`

`qiime tools import   --type 'FeatureData[Sequence]'   --input-path  9e443d30-1430-41f9-90ae-93c248767b11/data/dna-sequences-gt319.fasta  --output-path all-ref-seqs.qza`

`rm all-classifier.qza`

`qiime feature-classifier fit-classifier-naive-bayes   --i-reference-reads all-ref-seqs.qza   --i-reference-taxonomy all-ref-taxonomy.qza   --o-classifier all-classifier.qza`
