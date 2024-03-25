#!/bin/bash
fastp='/pkg/biology/fastp/fastp_v0.20.0/fastp';

## option parser for linux bash shell
while getopts 'p:n:f:F:a:t:T:R:o:s:' argv
do
case $argv in 
 p) projDir=$OPTARG
  ;;
 n) sampleName=$OPTARG
  ;;
 f) trim_front1=$OPTARG
  ;;
 F) trim_front2=$OPTARG
  ;;
 t) trim_tail1=$OPTARG
  ;;
 T) trim_tail2=$OPTARG
  ;;
 a) adapter_fasta=$OPTARG
  ;;
 R) reads_to_process=$OPTARG
  ;;
 o) out=$OPTARG
  ;;
 s) Sequencing=$OPTARG 
  ;;  
esac
done

if [ ! $projDir ]; then
  echo -e 'set project folder'
  exit -1
fi
if [ ! $sampleName ]
 then
  echo -e 'No sample name'
  exit -1
fi
if [ ! $adapter_fasta ]; 
  then
  adapter_fasta=''
  else 
  adapter_fasta='--adapter_fasta '$adapter_fasta
fi
#trim hand
if [ ! $trim_front1 ]; 
  then
  trim_front1=''
  else 
  trim_front1='--trim_front1 '$trim_front1
fi
if [ ! $trim_front2 ]; 
  then
  trim_front2=''
  else 
  trim_front2='--trim_front2 '$trim_front2
fi
#trim tail
if [ ! $trim_tail1 ]; 
  then
  trim_tail1=''
  else 
  trim_tail1='--trim_tail1 '$trim_tail1
fi
if [ ! $trim_tail2 ]; 
  then
  trim_tail2=''
  else 
  trim_tail2='--trim_tail2 '$trim_tail2
fi
if [ ! $reads_to_process ]; 
  then
  reads_to_process=''
  else 
  reads_to_process='--reads_to_process '$reads_to_process
fi
if [ ! $out ];then
out=''
else
  if [ $Sequencing == "PE" ]; then
  unpaired='--unpaired1 raw/'$sampleName'-'$out'_unpaired_R1.fastq.gz --unpaired2 raw/'$sampleName'-'$out'_unpaired_R2.fastq.gz '
  out='--out1 raw/'$sampleName'-'$out'_R1.fastq.gz --out2 raw/'$sampleName'-'$out'_R2.fastq.gz '$unpaired' \'
  
  elif [ $Sequencing == "SE" ]; then
  unpaired='--unpaired1 raw/'$sampleName'-'$out'_unpaired_R1.fastq.gz'
  out='--out1 raw/'$sampleName'-'$out'_R1.fastq.gz '$unpaired' \' 
   
  else 
  echo -e 'Reference genome ' $Sequencing ' is not supported.'
  exit -1
  fi  
fi  

#project folder
cd $projDir
#fastp instruction
# Setup genome refence
if [ $Sequencing == "PE" ]; then
  $fastp -i raw/$sampleName"_R1.fastq.gz" \
  -I raw/$sampleName"_R2.fastq.gz" \
  $out $trim_front1 \
  $trim_front2 \
  $trim_tail1 \
  $trim_tail2 \
  $adapter_fasta \
  $reads_to_process \
  -j QC/$sampleName".json" \
  -h QC/$sampleName".html" 
else [ $Sequencing == "SE" ];
  $fastp -i raw/$sampleName"_R1.fastq.gz" \  
  $out $trim_front1 \
  $trim_tail1 \
  $adapter_fasta \
  $reads_to_process \
  -j QC/$sampleName".json" \
  -h QC/$sampleName".html" 
fi

if [ $? -eq 0 ]; then
  echo -e $(date)'\t'$sampleName'\tfastp\tDone' >> log/Summary.log
    else
       echo -e $(date)'\t'$sampleName'\tfastp\tStop' >> log/Summary.log
        mv raw/$sampleName"_$out_R1.fastq.gz" temp/$sampleName"_$out_R1.fastq.gz.err"
        mv raw/$sampleName"_$out_R2.fastq.gz" temp/$sampleName"_$out_R2.fastq.gz.err"
        mv raw/$sampleName'-'$out'_unpaired_R1.fastq.gz' temp/$sampleName'-'$out'_unpaired_R1.fastq.gz.err'
        mv raw/$sampleName'-'$out'_unpaired_R2.fastq.gz' temp/$sampleName'-'$out'_unpaired_R2.fastq.gz.err'               
        exit -1
fi    
