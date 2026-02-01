"""
Cronista-decorated functions for the example pipeline.

These functions use cronista's record() decorator to wrap computations,
capturing errors and warnings as Maybe values instead of failing.
"""
import math
from cronista import record

# Record-decorated versions of common operations
r_sqrt = record(math.sqrt)
r_mean = record(lambda xs: sum(xs) / len(xs) if xs else 0)

@record()
def filter_positive(values):
    """Filter to only positive values."""
    return [v for v in values if v > 0]

@record()  
def compute_stats(values):
    """Compute basic statistics."""
    if not values:
        raise ValueError("Empty list")
    return {
        "mean": sum(values) / len(values),
        "min": min(values),
        "max": max(values),
        "count": len(values)
    }

@record()
def divide_by_zero():
    """Intentionally fail - demonstrates Nothing propagation."""
    return 1 / 0

@record()
def downstream_calc(x):
    """This will receive Nothing from upstream and also become Nothing."""
    return x * 2
