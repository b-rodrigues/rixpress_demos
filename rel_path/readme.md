# Relative Path Demo

This demo illustrates using relative paths for the `nix_env` argument in rixpress
derivation functions.

## Project Structure

```
rel_path/
├── default.nix              # Nix environment defined at project root
├── gen-env.R                # Script to generate the Nix environment
├── readme.md                # This file
└── subdir/
    └── analysis/
        └── gen-pipeline.R   # Pipeline defined in a subdirectory
```

## Use Case

This pattern is useful when:
- You want to share a single Nix environment across multiple subprojects
- Your pipeline script is located in a subdirectory (e.g., for organisational reasons)
- You're working in a monorepo structure where the Nix environment is at the root

## Running the Demo

1. First, generate the Nix environment:
   ```bash
   nix-shell -p R --run "Rscript gen-env.R"
   ```

2. Enter the Nix shell:
   ```bash
   nix-shell default.nix
   ```

3. Navigate to the analysis folder and run the pipeline generator:
   ```bash
   cd subdir/analysis
   Rscript gen-pipeline.R
   ```

4. Build the pipeline (from the analysis folder):
   ```r
   rixpress::rxp_make()
   ```

## Key Point

When using `nix_env = "../../default.nix"`, rixpress correctly extracts the
basename (`default.nix`) before generating Nix variable names. This means:

- **Before the fix**: `"../../default.nix"` would become `______default_nix`
  (with underscores from `../..`), causing invalid Nix identifiers.

- **After the fix**: `"../../default.nix"` correctly becomes `default`, which
  is a valid Nix identifier.

This allows you to organise your project with the Nix environment at any level
of the directory hierarchy while still referencing it from subdirectories.
