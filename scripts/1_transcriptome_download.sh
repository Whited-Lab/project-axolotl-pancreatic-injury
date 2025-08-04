#!/bin/bash
#SBATCH -c 16
#SBATCH -t 0-02:00
#SBATCH -p serial_requeue
#SBATCH --mem=128G
#SBATCH -o ../log/00_output_%j.out
#SBATCH -e ../log/00_errors_%j.err

set -euo pipefail

mkdir -p ../ref
cd ../ref

# -----------------------------------------------------------------------------
# 1) Download and prepare FASTA
# -----------------------------------------------------------------------------
echo "[1] Downloading gzipped FASTA..."
wget -q \
  "http://www.axolotl-omics.org/api?method=Assembly.getSequences&assembly=47&type=dna" \
  -O AmexT_v47_dna.fasta.gz

echo "[1] Decompressing FASTA → AmexT_v47_dna.fasta"
gunzip -c AmexT_v47_dna.fasta.gz > AmexT_v47_dna.fasta

echo "[1] Indexing FASTA with samtools faidx"
samtools faidx AmexT_v47_dna.fasta

# -----------------------------------------------------------------------------
# 2) Download and prepare GTF
# -----------------------------------------------------------------------------
echo "[2] Downloading gzipped GTF and decompressing → AmexT_v47-AmexG_v6.0-DD.gtf"
wget -qO - "https://www.axolotl-omics.org/dl/AmexT_v47-AmexG_v6.0-DD.gtf.gz" \
  | gunzip > AmexT_v47-AmexG_v6.0-DD.gtf

# -----------------------------------------------------------------------------
# 3) Clean GTF to remove empty/duplicated transcript_ids
# -----------------------------------------------------------------------------
FIXED="AmexT_v47-AmexG_v6.0-DD.fixed.gtf"
echo "[2] Cleaning GTF → $FIXED"
awk '
BEGIN { FS=OFS = "\t" }
{
  # extract transcript_id (may be empty)
  if (!match($9, /transcript_id "([^"]*)"/, m)) next
  id = m[1]
  # drop blank IDs
  if (id == "") next
  # keep only the last "|" field
  n = split(id, parts, "|")
  id = parts[n]
  # rewrite transcript_id
  sub(/transcript_id "[^"]*"/, "transcript_id \"" id "\"", $9)
  # dedupe
  if (!seen[id]++) print
}
' AmexT_v47-AmexG_v6.0-DD.gtf > "$FIXED"

echo "All reference files ready in $(pwd):"
echo " - AmexT_v47_dna.fasta"
echo " - AmexT_v47_dna.fasta.fai"
echo " - AmexT_v47-AmexG_v6.0-DD.gtf"
echo " - AmexT_v47-AmexG_v6.0-DD.fixed.gtf"
