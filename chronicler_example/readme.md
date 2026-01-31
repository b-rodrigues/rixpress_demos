# Chronicler + Rixpress Example

This example demonstrates how to use the `{chronicler}` package with `{rixpress}` pipelines.

## What is chronicler?

`{chronicler}` provides monadic error handling for R. Functions decorated with `record()` capture errors and warnings, returning `chronicle` objects that contain:
- A **value**: either `Just(result)` for success or `Nothing` for failure
- A **log**: detailed record of operations, timings, and messages

## The Problem

When using chronicler in rixpress pipelines, Nix builds **never fail** because chronicler catches all errors/warnings. This can be misleading - your pipeline appears successful but may contain `Nothing` values (failed computations).

## The Solution

Use `rxp_check_chronicles()` after building to detect Nothing values:

```r
# Build the pipeline
rxp_make()

# Check for Nothing values
rxp_check_chronicles()
```

## Pipeline Structure

This example pipeline demonstrates:

1. **`mtcars`** - Read CSV file (not a chronicle)
2. **`filtered_mtcars`** - Filter using `r_filter()` → **Success (Just)**
3. **`mtcars_mpg`** - Select column using `bind_record()` → **Success (Just)**
4. **`mean_mpg`** - Compute mean → **Success (Just)**
5. **`sqrt_of_negative`** - `sqrt(-1)` produces warning → **Nothing**
6. **`downstream_of_nothing`** - Depends on Nothing → **Nothing** (propagated)

## Status Symbols

| Symbol | State | Meaning |
|--------|-------|---------|
| ✓ | Success | `Just` value, no warnings |
| ⚠ | Warning | `Just` value with captured warnings |
| ✗ | Nothing | Failed computation |

## Running the Example

```bash
# Enter Nix shell
nix develop

# Generate the pipeline
Rscript gen-pipeline.R

# Build the pipeline
Rscript -e "rixpress::rxp_make()"

# Check for Nothing values
Rscript -e "rixpress::rxp_check_chronicles()"
```

## Key Takeaway

Always run `rxp_check_chronicles()` after building pipelines that use chronicler to catch silent failures!
