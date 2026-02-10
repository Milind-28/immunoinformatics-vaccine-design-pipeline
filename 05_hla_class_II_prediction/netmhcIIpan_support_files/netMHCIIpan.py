import os
import subprocess
import math

# Paths to input and output files
allele_file = "HLA_II_alleles_List.txt"
peptide_file = "Example.fasta"
output_dir = "Example_results"

# Default number of alleles per batch
batch_size = 40

# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)

# Read alleles from the file
with open(allele_file, "r") as f:
    alleles = f.read().splitlines()

# Calculate number of batches
total_alleles = len(alleles)
batch_size = math.ceil(total_alleles / 200) if total_alleles > 6000 else batch_size
num_batches = math.ceil(total_alleles / batch_size)

# Process each batch
for i in range(num_batches):
    # Get the alleles for the current batch
    start_index = i * batch_size
    end_index = min(start_index + batch_size, total_alleles)
    batch_alleles = alleles[start_index:end_index]

    # Combine alleles into a comma-separated string
    allele_string = ",".join(batch_alleles)

    # Define the output file for this batch
    chunk_output = os.path.join(output_dir, f"batch_{i+1}_output.xls")

    # Construct the netMHCIIpan command
    command = [
        "./netMHCIIpan",
        "-f", peptide_file,
        "-BA",
        "-a", allele_string,
        "-xls",
        "-xlsfile", chunk_output
    ]

    # Print the command being executed
    print("Running command:")
    print(" ".join(command))

    # Execute the command
    try:
        subprocess.run(command, check=True)
        print(f"Finished processing batch {i+1}, results saved to {chunk_output}")

        # Verify if the output file is non-empty
        if os.path.exists(chunk_output) and os.path.getsize(chunk_output) > 0:
            print(f"Output file {chunk_output} is valid.")
        else:
            print(f"Warning: Output file {chunk_output} is empty or missing.")

    except subprocess.CalledProcessError as e:
        print(f"Error: Command failed for batch {i+1}. Error: {e}")

# Script completed
print("All batches processed.")
