# Data submission

## Genome

Started new SRA submission 

- Project

- Sample : Mimarks Table [file](https://github.com/suzumar/transect_ms/blob/main/files/MIMARKS.survey.water.5.0.xlsx)

- SRA_metadata [file](https://github.com/suzumar/transect_ms/blob/main/files/SRA_metadata.xlsx)

```
cat /Users/suzuki/Documents/GitHub/transect_ms/files/fastq_list.txt | grep R1 | sed 's/_R1.*//' > libraries
cat /Users/suzuki/Documents/GitHub/transect_ms/files/fastq_list.txt | grep R1 > read1.txt
cat /Users/suzuki/Documents/GitHub/transect_ms/files/fastq_list.txt | grep R2 > read2.txt
```

SRA Submission number SUB12378559 

