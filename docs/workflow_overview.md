# Workflow Overview

## Immunoinformatics‑Based Multi‑Epitope Vaccine Design Pipeline

This document provides a **high‑level, publication‑safe overview** of the complete computational workflow implemented in this repository. It is intended to explain **how each stage of the pipeline fits together biologically and computationally**, without exposing unpublished results or licensed software.

This file is written for:

* Recruiters and interview panels
* Academic collaborators and reviewers
* Readers who want pipeline‑level understanding rather than code details

---

## Pipeline Summary

The workflow follows a **stepwise filtering and validation strategy**, where each stage reduces candidate space while increasing biological confidence:

1. Protein sequence retrieval
2. Conserved region processing and peptide generation
3. Host‑homology (autoimmunity) screening
4. HLA Class I epitope prediction and cross‑validation
5. HLA Class II epitope prediction and cross‑validation
6. Multi‑epitope vaccine construct design
7. Structural validation and visualization

---

## 1. Protein Sequence Retrieval

**Folder:** `01_sequence_retrieval/`

**Objective:**
Acquire pathogen protein sequences in a standardized and reproducible format suitable for downstream immunoinformatics analysis.

**Key operations:**

* Automated retrieval of protein sequences and metadata from public databases
* Organization of sequences into structured tabular formats

**Rationale:**
Accurate sequence input is foundational. Errors at this stage propagate through the entire pipeline.

---

## 2. Conserved Region Processing and Peptide Generation

**Folder:** `02_conserved_region_processing/`

**Objective:**
Transform protein sequences into peptide libraries appropriate for epitope prediction.

**Key operations:**

* Sliding‑window generation of overlapping peptide‑mers (e.g., 9‑mers, 15‑mers)
* Mapping peptide start–end positions to parent protein sequences

**Rationale:**
Epitope prediction algorithms operate on peptides rather than full‑length proteins. Proper peptide generation ensures biologically meaningful predictions.

---

## 3. Host‑Homology (Autoimmunity) Screening

**Folder:** `03_autoimmunity_filtering/`

**Objective:**
Eliminate peptides with significant similarity to host proteins to reduce the risk of autoimmunity.

**Key operations:**

* Automated BLASTp screening using short‑query optimization
* Batch processing of candidate peptides
* Rule‑based exclusion using alignment identity, coverage, and similarity metrics
* Transparent filtering logic implemented in spreadsheet‑based templates

**Rationale:**
This step acts as a **hard safety gate**. Peptides failing host‑homology screening are excluded from all downstream analyses.

---

## 4. HLA Class I Epitope Prediction and Validation

**Folder:** `04_hla_class_I_prediction/`

**Objective:**
Identify and prioritize CD8⁺ T‑cell epitopes capable of binding HLA Class I molecules.

**Key operations:**

* Automated execution of HLA Class I prediction tools
* Cleaning and normalization of large‑scale prediction outputs
* Aggregation of multi‑run results
* Cross‑validation using allele‑specific binding affinity predictors
* Final prioritization using biologically validated thresholds

**Rationale:**
Using multiple predictors reduces algorithmic bias and increases confidence in selected epitopes.

---

## 5. HLA Class II Epitope Prediction and Validation

**Folder:** `05_hla_class_II_prediction/`

**Objective:**
Identify CD4⁺ T‑cell epitopes capable of binding HLA Class II molecules.

**Key operations:**

* HLA Class II epitope prediction using pan‑allelic tools
* Deep learning‑based validation using independent models
* Interpretation of model‑specific scoring metrics (e.g., log‑transformed affinity)

**Rationale:**
Class II epitopes are essential for helper T‑cell activation and long‑term immune memory formation.

---

## 6. Multi‑Epitope Vaccine Construct Design

**Folder:** `06_multi_epitope_vaccine_design/`

**Objective:**
Assemble prioritized epitopes into candidate multi‑epitope vaccine constructs.

**Key operations:**

* Epitope shuffling and permutation generation
* Integration of linker sequences
* Generation of multiple construct variants for downstream evaluation

**Rationale:**
Construct design influences immunogenicity, stability, and feasibility of structural validation.

---

## 7. Structural Validation and Visualization

**Folders:** `07_structural_validation/`, `08_visualization_and_analysis/`

**Objective:**
Support biological interpretation through structural and visual analyses.

**Key operations:**

* Automated retrieval and preprocessing of protein structure files
* Preparation of inputs for docking and interaction analysis
* Visualization of epitope–HLA interaction patterns (e.g., heatmaps)
* Automated documentation of computational results

**Rationale:**
Structural and visualization‑based analyses provide supporting evidence for epitope selection and aid result communication.

---

## Design Principles

* **Modularity:** Each stage is logically independent but biologically connected
* **Model diversity:** Multiple prediction models used to reduce bias
* **Transparency:** Decision thresholds are explicit and reviewable
* **Reproducibility:** Automation applied wherever feasible
* **Publication safety:** Unpublished results and licensed software are excluded

---

## Intended Use

This repository represents a **research‑grade immunoinformatics workflow** developed during an MSc Biotechnology thesis. It is intended for:

* Methodological demonstration
* Academic and industry portfolio review
* Reproducible pipeline design reference

It is **not intended for direct clinical or diagnostic use**.

---

## Author Note

This workflow reflects the computational design, automation strategy, and biological reasoning used in an immunoinformatics study targeting Severe Fever with Thrombocytopenia Syndrome Virus (SFTSV).
