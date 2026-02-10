from pymol import cmd
import os

def process_structure(input_file, output_folder):
    """
    Process a PDB file to remove water molecules and separate chains into different PDB files.
    """
    cmd.load(input_file, "structure")
    cmd.remove("resn HOH")
    cmd.remove("not polymer.protein")
    
    chains = cmd.get_chains("structure")
    print(f"Chains found: {', '.join(chains)}")
    
    selected_chains = input("Enter chains to separate (comma-separated): ").strip().upper().split(",")
    for chain in selected_chains:
        chain = chain.strip()
        if chain in chains:
            output_file = os.path.join(output_folder, f"{os.path.splitext(os.path.basename(input_file))[0]}_chain_{chain}.pdb")
            cmd.save(output_file, f"structure and chain {chain}")
            print(f"Saved chain {chain} to {output_file}")
        else:
            print(f"Chain {chain} not found in structure.")
    
    cmd.delete("structure")
