#!/usr/bin/env cwl-runner

# http://www.commonwl.org/draft-3/Workflow.html#Parameter_references
# http://www.commonwl.org/draft-3/CommandLineTool.html#Runtime_environment
# http://www.commonwl.org/draft-3/CommandLineTool.html

cwlVersion: v1.0
class: Workflow

requirements:
- class: ScatterFeatureRequirement

inputs:
  # Barrnap
  - id: barrnap_genomic_fasta
    type: File
    doc: Input genomic FASTA file
  
  # Aragorn
  - id: aragorn_format
    type: boolean
  
  # Prodigal
  - id: source_fasta
    type: File
    doc: Starting protein multi-FASTA file
  - id: output_format
    type: string
    doc: Prodigal prediction output format
  - id: initial_structural_prediction
    type: string
    doc: Prodigal structural prediction file
  - id: initial_protein_out
    type: string
    doc: Prodigal polypeptide FASTA prediction file
  
  # Convert prodigal
  - id: prodigal2gff3_input_file
    type: File
    doc: ''
  - id: prodigal2gff3_output_file
    type: string
    doc: ''
  
  # Write prodigal FASTA (with GFF-matching IDs)
  - id: prodigal2fasta_input_file
    type: File
    doc: ''
  - id: prodigal2fasta_output_file
    type: string
    doc: ''
  - id: prodigal2fasta_type
    type: string
    doc: ''
  - id: prodigal2fasta_fasta
    type: File
    doc: Genomic FASTA
  - id: prodigal2fasta_feature_type
    type: string
    doc: ''
  
  # split_fasta
  - id: fragmentation_count
    type: int
    doc: How many files the input will be split into
  - id: out_dir
    type: string
    doc: Location where split files will be written
  
  # rapsearch2
  - id: rapsearch2_database_file
    type: File
    doc: ''
  - id: rapsearch2_query_file
    type: File
    doc: ''
  - id: rapsearch2_output_file_base
    type: string
    doc: ''
  - id: rapsearch2_threads
    type: int
    doc: ''
  - id: rapsearch2_one_line_desc_count
    type: int
    doc: Number of matches to return
  
  # HMMer3
  - id: hmmscan_use_accessions
    type: boolean
    doc: ''
  - id: hmmscan_cutoff_gathering
    type: boolean
  - id: hmmscan_database_file
    type: File
    doc: ''
  - id: hmmscan_query_file
    type: File
    doc: ''
  - id: hmmscan_output_file
    type: string
    doc: ''
  - id: hmmscan_threads
    type: int
    doc: ''
  
  # Convert HMMer3 to HTAB
  - id: raw2htab_input_file
    type: File
    doc: ''
  - id: raw2htab_mldbm_file
    type: File
    doc: ''
  - id: raw2htab_output_htab
    type: string
    doc: ''
  
  # TMHMM
  - id: tmhmm_input_file
    type: File
  
  # Attributor
  - id: attributor_config_file
    type: string
  - id: attributor_output_base
    type: string
    doc: ''
  - id: attributor_output_format
    type: string
    doc: ''
  - id: attributor_hmm_attribute_lookup_file
    type: File
  - id: attributor_blast_attribute_lookup_file
    type: File
  - id: attributor_polypeptide_fasta
    type: File
  - id: attributor_source_gff3
    type: File
outputs:
- id: fasta_files
  type:
    type: array
    items: File
  outputSource: split_multifasta/fasta_files
- id: barrnap_gff_output
  type: File
  outputSource: barrnap/barrnap_gff_output
- id: aragorn_raw_output
  type: File
  outputSource: aragorn/aragorn_raw_output
- id: prodigal_annot_file
  type: File
  outputSource: prodigal/prodigal_annot_file
- id: prodigal_protein_file
  type: File
  outputSource: prodigal/prodigal_protein_file
- id: prodigal_gff3
  type: File
  outputSource: prodigal2gff3/output_gff3
- id: prodigal_protein_fasta
  type: File
  outputSource: prodigal2fasta/protein_fasta
- id: rapsearch2_m8_files
  type:
    type: array
    items: File
  outputSource: rapsearch2/output_base
- id: hmmscan_raw_files
  type:
    type: array
    items: File
  outputSource: hmmscan/output_base
- id: hmmscan_htab_files
  type:
    type: array
    items: File
  outputSource: raw2htab/htab_file
- id: tmhmm_raw_files
  type:
    type: array
    items: File
  outputSource: tmhmm/tmhmm_out
- id: attributor_files
  type:
    type: array
    items: File
  outputSource: attributor/output_files
- id: attributor_output_config
  type: File
  outputSource: attributor/the_config
steps:
- id: barrnap
  run: ../tools/barrnap.cwl
  out:
  - {id: barrnap_gff_output}
  in:
  - {id: genomic_fasta, source: barrnap_genomic_fasta}
- id: aragorn
  run: ../tools/aragorn.cwl
  out:
  - {id: aragorn_raw_output}
  in:
  - {id: genomic_fasta, source: source_fasta}
  - {id: aragorn_format, source: aragorn_format}
- id: prodigal
  run: ../tools/prodigal.cwl
  out:
  - {id: prodigal_annot_file}
  - {id: prodigal_protein_file}
  in:
  - {id: genomic_fasta, source: source_fasta}
  - {id: output_format, source: output_format}
  - {id: annotation_out, source: initial_structural_prediction}
  - {id: protein_out, source: initial_protein_out}
- id: prodigal2gff3
  run: ../tools/biocode-ConvertProdigalToGFF3.cwl
  out:
  - {id: output_gff3}
  in:
  - {id: input_file, source: prodigal/prodigal_annot_file}
  - {id: output_file, source: prodigal2gff3_output_file}
- id: prodigal2fasta
  run: ../tools/biocode-WriteFastaFromGFF.cwl
  out:
  - {id: protein_fasta}
  in:
  - {id: input_file, source: prodigal2gff3/output_gff3}
  - {id: output_file, source: prodigal2fasta_output_file}
  - {id: type, source: prodigal2fasta_type}
  - {id: fasta, source: source_fasta}
  - {id: feature_type, source: prodigal2fasta_feature_type}
- id: split_multifasta
  run: ../tools/biocode-SplitFastaIntoEvenFiles.cwl
  out:
  - {id: fasta_files}
  in:
  - {id: file_to_split, source: prodigal2fasta/protein_fasta}
  - {id: file_count, source: fragmentation_count}
  - {id: output_directory, source: out_dir}
- id: rapsearch2
  run: ../tools/rapsearch2.cwl
  scatter: query_file
  out:
  - {id: output_base}
  in:
  - {id: database_file, source: rapsearch2_database_file}
  - {id: query_file, source: split_multifasta/fasta_files}
  - {id: output_file_base, source: rapsearch2_output_file_base}
  - {id: thread_count, source: rapsearch2_threads}
  - {id: one_line_desc_count, source: rapsearch2_one_line_desc_count}
- id: hmmscan
  run: ../tools/hmmer3-hmmscan.cwl
  scatter: query_file
  out:
  - {id: output_base}
  in:
  - {id: cutoff_gathering, source: hmmscan_cutoff_gathering}
  - {id: use_accessions, source: hmmscan_use_accessions}
  - {id: database_file, source: hmmscan_database_file}
  - {id: query_file, source: split_multifasta/fasta_files}
  - {id: output_file, source: hmmscan_output_file}
  - {id: thread_count, source: hmmscan_threads}
- id: raw2htab
  run: ../tools/biocode-ConvertHmmscanToHtab.cwl
  scatter: input_file
  out:
  - {id: htab_file}
  in:
  - {id: input_file, source: hmmscan/output_base}
  - {id: output_htab, source: raw2htab_output_htab}
  - {id: mldbm_file, source: raw2htab_mldbm_file}
- id: tmhmm
  run: ../tools/tmhmm.cwl
  scatter: query_file
  out:
  - {id: tmhmm_out}
  in:
  - {id: query_file, source: split_multifasta/fasta_files}
- id: attributor
  run: ../tools/attributor-prok-cheetah.cwl
  out:
  - {id: output_files}
  - {id: the_config}
  in:
  - {id: config_file, source: attributor_config_file}
  - {id: output_base, source: attributor_output_base}
  - {id: output_format, source: attributor_output_format}
  - {id: hmm_attribute_lookup_file, source: attributor_hmm_attribute_lookup_file}
  - {id: blast_attribute_lookup_file, source: attributor_blast_attribute_lookup_file}
  - {id: hmm_files, source: raw2htab/htab_file}
  - {id: polypeptide_fasta, source: prodigal2fasta/protein_fasta}
  - {id: source_gff3, source: prodigal2gff3/output_gff3}
  - {id: m8_files, source: rapsearch2/output_base}
  - {id: tmhmm_files, source: tmhmm/tmhmm_out}

