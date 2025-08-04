#!/usr/bin/env bash
set -euo pipefail

mkdir -p data/bam && wget -c --header="X-Dataverse-key: 7ad91d69-1f9a-4f2b-97b7-4bb66f0b7e8d" -O data/bam/pancreas_run_master_02-23-25.bam "https://dataverse.harvard.edu/api/access/datafile/11716088"
mkdir -p ref      && wget -c --header="X-Dataverse-key: 7ad91d69-1f9a-4f2b-97b7-4bb66f0b7e8d" -O ref/samplesheet.tab                    "https://dataverse.harvard.edu/api/access/datafile/11716087"
