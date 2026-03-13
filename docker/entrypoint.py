import os
import sys
import torch
import torch.nn.functional as F
from iopaint import entry_point

# ---------------------------------------------------------------------------
# MONKEY PATCH: FORCE MATH ATTENTION ON ROCm
# Fixes "RuntimeError: No available kernel" in scaled_dot_product_attention
# ---------------------------------------------------------------------------
print("Wrapper: Monkey-patching torch.nn.functional.scaled_dot_product_attention for ROCm compatibility...")

original_sdpa = F.scaled_dot_product_attention

def patched_sdpa(*args, **kwargs):
    # Force the use of the "math" implementation (slow but compatible)
    # and disable flash/mem_efficient backends which are missing kernels on some AMD cards.
    with torch.backends.cuda.sdp_kernel(enable_flash=False, enable_math=True, enable_mem_efficient=False):
        return original_sdpa(*args, **kwargs)

# Apply the patch
torch.nn.functional.scaled_dot_product_attention = patched_sdpa
F.scaled_dot_product_attention = patched_sdpa

print("Wrapper: Patch applied successfully.")
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    # Pass control to the original IOPaint entry point
    # We rely on sys.argv being passed correctly
    sys.exit(entry_point())
