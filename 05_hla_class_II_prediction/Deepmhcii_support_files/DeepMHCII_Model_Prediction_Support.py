import torch
from pathlib import Path
from torch.utils.data import DataLoader
from tqdm import tqdm
from deepmhcii.datasets import MHCIIDataset
from deepmhcii.networks import DeepMHCII
from deepmhcii.models import Model

def predict_binding_affinity_single(model_path, peptides_file, alleles_file, output_file, model_config, batch_size=32):
    # Load peptides
    with open(peptides_file, "r") as f:
        peptides = [line.strip() for line in f if line.strip()]

    # Load alleles (name and sequence)
    alleles = []
    with open(alleles_file, "r") as f:
        for line in f:
            parts = line.strip().split("\t")  # Ensure tab-separated format
            if len(parts) == 2:
                alleles.append((parts[0], parts[1]))
            else:
                print(f"Skipping malformed line in alleles file: {line.strip()}")

    if not peptides or not alleles:
        raise ValueError("Peptides or Alleles file is empty or incorrectly formatted.")

    # Prepare data
    data = [[allele[0], peptide, allele[1]] for allele in alleles for peptide in peptides]
    dataset = MHCIIDataset(
        data,
        peptide_pad=model_config["padding"]["peptide_pad"],
        peptide_len=model_config["padding"]["peptide_len"],
        mhc_len=model_config["padding"]["mhc_len"],
    )
    data_loader = DataLoader(dataset, batch_size=batch_size, shuffle=False)

    # Load model
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = Model(DeepMHCII, model_path=model_path, **model_config["model"])
    model.load_model()
    model.model.to(device)  # Move model to appropriate device

    # Prepare for predictions
    # Prepare for predictions
    results = []
    for batch_idx, batch in enumerate(tqdm(data_loader, desc="Predicting Binding Affinity")):
      if isinstance(batch, dict):  # For prediction mode
          peptide_x = batch["peptide_x"].to(device)
          mhc_x = batch["mhc_x"].to(device)
      else:  # For training/validation mode
          inputs, _ = batch
          peptide_x = inputs["peptide_x"].to(device)
          mhc_x = inputs["mhc_x"].to(device)

    # Pass the tensors directly as positional arguments
      predictions = model.get_scores((peptide_x, mhc_x)).detach().cpu().numpy()

      for idx, (allele_name, peptide) in enumerate(
          [(d[0], d[1]) for d in data[batch_idx * batch_size : (batch_idx + 1) * batch_size]]
      ):
          results.append(f"{allele_name}\t{peptide}\t{predictions[idx]:.6f}")


    # Save results to text file
    with open(output_file, "w") as f:
        f.write("Allele\tPeptide\tPredicted Affinity\n")
        f.write("\n".join(results))
    print(f"Predictions saved to {output_file}")


# Example Usage
if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Predict binding affinity using a single model.")
    parser.add_argument("--model_path", required=True, help="Path to the trained model file.")
    parser.add_argument("--peptides_file", required=True, help="Path to the text file containing peptide sequences.")
    parser.add_argument("--alleles_file", required=True, help="Path to the text file containing allele sequences.")
    parser.add_argument("--output_file", required=True, help="Path to save the output .txt file.")
    parser.add_argument("--peptide_pad", type=int, default=15, help="Padding length for peptides.")
    parser.add_argument("--batch_size", type=int, default=32, help="Batch size for prediction.")
    args = parser.parse_args()

    model_config = {
    "padding": {
        "peptide_pad": 0,  # No additional padding since peptide_len is fixed at 15
        "peptide_len": 15,  # Fixed peptide length
        "mhc_len": 34,      # Length of MHC sequences
    },
    "model": {
        "peptide_pad": 0,  # No additional padding for peptides
        "emb_size": 16,
        "conv_size": [9, 11, 13, 15],
        "conv_num": [256, 128, 64, 64],
        "conv_off": [3, 2, 1, 0],
        "dropout": 0.25,
        "linear_size": [256, 128],
    },
}

    predict_binding_affinity_single(
        model_path=args.model_path,
        peptides_file=args.peptides_file,
        alleles_file=args.alleles_file,
        output_file=args.output_file,
        model_config=model_config,
        batch_size=args.batch_size
    )