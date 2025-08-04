#!/bin/bash
#SBATCH -N 1
#SBATCH -n 18
#SBATCH --partition=serial_requeue
#SBATCH --error=../log/1_fastq_%a_%j.e
#SBATCH --output=../log/1_fastq_%a_%j.o
#SBATCH --mem=256G
#SBATCH --time=12:00:00

# Define the bam input and output path
BAM_INPUT=("../data/bam/pancreas_run_master_02-23-25.bam")
OUTPUT_DIR="../data/fastq/pancreas_basecall/v5.1.0_fastq"

#install dorado
wget https://cdn.oxfordnanoportal.com/software/analysis/dorado-1.0.2-linux-x64.tar.gz
tar -xzvf dorado-1.0.2-linux-x64.tar.gz

# Run Dorado basecaller
../dorado-1.0.2-linux-x64/bin/dorado demux --no-trim --kit-name SQK-PCB114-24 -t 18 --emit-fastq --output-dir "$OUTPUT_DIR"  "$BAM_INPUT"
echo "demux completed"

# Rename all files with the pattern "*barcodeXX.fastq" to "pass_barcodexx.fastq"
for file in SQK-PCB114-24_barcode*.fastq; do
    # Check if the file exists to avoid issues with empty matches
    if [[ -e "$file" ]]; then
        # Extract the barcode number
        barcode_num=$(echo "$file" | sed 's/.*\(barcode[0-9]*\)\.fastq/\1/')
        # Construct the new file name
        new_name="pass_${barcode_num}.fastq"
        # Rename the file
        mv "$file" "$new_name"
        echo "Renamed $file to $new_name"
    fi
done

# If you have not already, run the following command in terminal to create the mamba environment
# mamba create -n nanopore -c conda-forge -c bioconda isoquant nanoplot minimap2 samtools
# sometimes you have to create the environment first and then install the packages, which looks like this:
# mamba create -n nanopore
# mamba install isoquant
# mamba install nanoplot
# mamba install minimap2
# mamba install samtools

mamba activate nanopore

FASTQ_FILES=("../pancreas_basecall/v5.1.0_basecall/v5.1.0_fastq/pass_barcode01.fastq" \
"../pancreas_basecall/v5.1.0_basecall/v5.1.0_fastq/pass_barcode02.fastq" \
"../pancreas_basecall/v5.1.0_basecall/v5.1.0_fastq/pass_barcode03.fastq" \
"../pancreas_basecall/v5.1.0_basecall/v5.1.0_fastq/pass_barcode04.fastq" \
"../pancreas_basecall/v5.1.0_basecall/v5.1.0_fastq/pass_barcode05.fastq" \
"../pancreas_basecall/v5.1.0_basecall/v5.1.0_fastq/pass_barcode06.fastq" \
"../pancreas_basecall/v5.1.0_basecall/v5.1.0_fastq/pass_barcode07.fastq" \
"../pancreas_basecall/v5.1.0_basecall/v5.1.0_fastq/pass_barcode09.fastq")

INDEX="/path/to/tanaka/transciptome.fa"
DB="/path/to/transcriptome.gtf"
NANOPLOT_1_OUT="../1.0.0_nanoplot"
ALIGNMENT_OUT="../2.0.0_minimap2"
NANOPLOT_2_OUT="../3.0.0_nanoplot"
QUANT_OUT="../4.0.0_isoquant"

# Ensure output directories exist
mkdir -p "$NANOPLOT_1_OUT"
mkdir -p "$ALIGNMENT_OUT"
mkdir -p "$NANOPLOT_2_OUT"
mkdir -p "$QUANT_OUT"

#Pipeline

# Resume point can be set to the name of the step you want to start from
RESUME_FROM=${1:-"start"}

# Determine the specific FASTQ file for this task
FASTQ="${FASTQ_FILES[$SLURM_ARRAY_TASK_ID]}"
BASE_NAME=$(basename "$FASTQ" .fastq)

# Dynamically set a specific job name based on the sample name
scontrol update JobID="${SLURM_JOB_ID}" JobName="cDNA_${BASE_NAME}"

# Pipeline

if [ "$RESUME_FROM" = "start" ] || [ "$RESUME_FROM" = "nanoplot1" ]; then
    echo "Started Nanoplot_1"
    NanoPlot -t 18 --fastq $FASTQ --maxlength 5000 --title ${BASE_NAME} --huge --N50 --plots kde dot -o $NANOPLOT_1_OUT/1.${SLURM_ARRAY_TASK_ID}_${BASE_NAME}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to run Nanoplot_1" >&2
        exit 1
    fi
    echo "Completed Nanoplot_1"
    RESUME_FROM="minimap"
fi

if [ "$RESUME_FROM" = "minimap" ]; then
    echo "Started Alignment"
    minimap2 -y -ax map-ont -k 14 -p 0.8 -N 1 -I 44G -t 18 --MD $INDEX $FASTQ | samtools view -bh -@ 18 | samtools sort > $ALIGNMENT_OUT/2.${SLURM_ARRAY_TASK_ID}_sorted_${BASE_NAME}.bam
    if [ $? -ne 0 ]; then
        echo "Error: Failed to align" >&2
        exit 1
    fi
    echo "Completed Alignment"
    RESUME_FROM="bam"
fi


if [ "$RESUME_FROM" = "index_bam" ]; then
    echo "Started BAM Index"
    samtools index -c $ALIGNMENT_OUT/2.${SLURM_ARRAY_TASK_ID}_sorted_${BASE_NAME}.bam
    if [ $? -ne 0 ]; then
        echo "Error: Failed to index BAM" >&2
        exit 1
    fi
    echo "Completed BAM Index"
    RESUME_FROM="nanoplot2"
fi

if [ "$RESUME_FROM" = "nanoplot2" ]; then
    echo "Started Nanoplot_2"
    NanoPlot -t 18 --bam $ALIGNMENT_OUT/2.${SLURM_ARRAY_TASK_ID}_sorted_${BASE_NAME}.bam --maxlength 5000 --title ${BASE_NAME} --huge --N50 --plots kde dot -o $NANOPLOT_2_OUT/3.${SLURM_ARRAY_TASK_ID}_${BASE_NAME}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to run Nanoplot_2" >&2
        exit 1
    fi
    echo "Completed Nanoplot_2"
    RESUME_FROM="isoquant"
fi

if [ "$RESUME_FROM" = "isoquant" ]; then
    echo "Started Isoquant"
    isoquant.py --reference $INDEX --genedb $DB --bam $ALIGNMENT_OUT/2.${SLURM_ARRAY_TASK_ID}_sorted_${BASE_NAME}.bam --data_type nanopore -o $QUANT_OUT/4.${SLURM_ARRAY_TASK_ID}_${BASE_NAME}
    if [ $? -ne 0 ]; then
        echo "Error: Failed to run Isoquant" >&2
        exit 1
    fi
    echo "Completed Isoquant"
fi