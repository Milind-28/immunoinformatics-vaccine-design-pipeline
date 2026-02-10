"""
Automated NetMHCpan Execution Script

Purpose:
Automates NetMHCpan runs for large sets of peptides across multiple
HLA Class I alleles, enabling scalable CD8+ T-cell epitope prediction.

Inputs:
- Peptide FASTA or text files
- HLA allele list compatible with NetMHCpan

Outputs:
- Raw NetMHCpan prediction files for downstream cleaning and filtering

Developed during MSc Biotechnology thesis (2023–2025).
"""

import os
import subprocess
import glob

# ==== CONFIGURATION ====
allele_folder = "alleles_folder"              # Folder containing .txt allele files
peptide_file = "Example_9mer_peptide.fasta"             # Input peptide file
output_folder = "Netmhcpan_result"           # Folder to store output files

# ==== SETUP ====
os.makedirs(output_folder, exist_ok=True)

# ==== PROCESS EACH ALLELE FILE ====
for allele_path in glob.glob(os.path.join(allele_folder, "*.txt")):
    base_name = os.path.splitext(os.path.basename(allele_path))[0]
    output_xls = os.path.join(output_folder, f"{base_name}_output.xls")

    # Read alleles and create comma-separated string
    with open(allele_path, "r") as f:
        alleles = ",".join([line.strip() for line in f if line.strip()])

    print(f"🚀 Running netMHCpan for {allele_path}...")
    try:
        subprocess.run([
            "./netMHCpan",
            "-p", peptide_file,
            "-BA",
            "-a", alleles,
            "-xls",
            "-xlsfile", output_xls
        ], check=True)
        print(f"✅ Finished: {output_xls}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error running netMHCpan for {allele_path}: {e}")
