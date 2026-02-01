# Cronista Example: Error-Tolerant Python Pipelines

This example demonstrates using [cronista](https://github.com/b-rodrigues/cronista)
(Python chronicler equivalent) with rixpress/ryxpress for error-tolerant pipelines.

## What is Cronista?

Cronista implements the Maybe monad pattern for Python using [talvez](https://github.com/b-rodrigues/talvez).
When you decorate a function with `@record()` or `record(func)`, it captures errors and warnings
as `Nothing` values instead of raising exceptions, allowing pipelines to continue.

## The Problem: Silent Failures

When using cronista in rixpress pipelines:
- **Nix builds always succeed** - even when computations produce `Nothing`
- A `Nothing` value is still a valid Python object that gets serialized
- Without checking, you might think your pipeline worked perfectly

## The Solution: rxp_check_chronicles()

ryxpress provides `rxp_check_chronicles()` to scan pipeline outputs and detect Nothing values:

```python
from ryxpress import rxp_check_chronicles

# After building the pipeline
rxp_check_chronicles()
```

Output:
```
Chronicle status:
✓ sqrt_result (chronicle: OK)
✓ filtered_values (chronicle: OK)
✓ mean_result (chronicle: OK)
✓ stats_result (chronicle: OK)
✗ sqrt_negative (chronicle: NOTHING)
    Failed: sqrt
✗ div_by_zero (chronicle: NOTHING)
    Failed: divide_by_zero
    Message: ZeroDivisionError: division by zero
✗ downstream_of_nothing (chronicle: NOTHING)
    Failed: downstream_calc
    Message: Short-circuited due to Nothing

Summary: 4 success, 0 with warnings, 3 nothing
```

## Files

- `gen-env.R` - Environment definition including cronista, talvez, ryxpress, rixpress
- `functions.py` - Python functions decorated with cronista's `record()`
- `gen-pipeline.R` - Pipeline definition using `rxp_py()` derivations

## Running

```bash
# Generate environment
nix-shell --expr "$(curl -sl https://raw.githubusercontent.com/ropensci/rix/main/inst/extdata/default.nix)" --run "Rscript gen-env.R"

# Build environment
nix-build

# Generate pipeline
nix-shell --run "Rscript gen-pipeline.R"

# Build pipeline
nix-shell --run "Rscript -e 'rixpress::rxp_make()'"

# Check chronicle status with Python
nix-shell --run "python -c 'from ryxpress import rxp_check_chronicles; rxp_check_chronicles()'"
```

## Expected Output

| Derivation | State | Reason |
|------------|-------|--------|
| sqrt_result | ✓ Success | sqrt(16) = 4.0 |
| filtered_values | ✓ Success | [3, 4, 5, 6] |
| mean_result | ✓ Success | 4.5 |
| stats_result | ✓ Success | {mean: 4.5, ...} |
| sqrt_negative | ✗ Nothing | sqrt(-1) produces NaN |
| div_by_zero | ✗ Nothing | ZeroDivisionError |
| downstream_of_nothing | ✗ Nothing | Upstream was Nothing |
