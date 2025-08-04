#!/bin/bash
#SBATCH --job-name=dataverse_download
#SBATCH --cpus-per-task=4
#SBATCH --time=3-00:00
#SBATCH --partition=serial_requeue
#SBATCH --mem=64G
#SBATCH --output=../log/0_dataverse_download_%j.out
#SBATCH --error=../log/0_dataverse_download_%j.err

set -euo pipefail

# ── 1. Move to repo root ────────────────────────────────
# run this script from ./scripts directory
cd "$SLURM_SUBMIT_DIR"
cd ..
echo "   Current directory is: $(pwd)"

# ── 2. Ensure GNU parallel is available ────────────────
module load ncf/1.0.0-fasrc01
module load parallel/20230422-rocky8_x64-ncf

# ── 3. Start parallel downloads ────────────────────────
echo "📥 Starting parallel downloads..."

# Each line in download_all.sh is a wget command
# The -j flag controls concurrency (adjust as needed)
parallel -j 4 < ./bin/file_list.sh

echo "✅ All downloads complete."