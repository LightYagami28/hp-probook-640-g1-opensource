"""gdb script: harvest the assembled fingerprint image from the HP driver."""

# gdb python: harvest the motion-compensated assembled fingerprint image from HP's
# validity-sensor (4.5-136) at IRqualityDetermination (0x4689b0). Writes:
#   <u32 dim1><u32 dim2><dim1*dim2 bytes>  to $VFS_ASM_OUT
import importlib
import os
import struct

gdb = importlib.import_module("gdb")

OUT = os.environ["VFS_ASM_OUT"]
hit = {"n": 0, "errors": 0}


class BP(gdb.Breakpoint):
    """Breakpoint that dumps the assembled fingerprint image."""

    def stop(self):
        """Continue execution, storing one assembled image when its size is plausible."""
        ctx = int(gdb.selected_frame().read_register("rdi")) & 0xFFFFFFFFFFFFFFFF
        try:
            self.harvest(gdb.selected_inferior(), ctx)
        except gdb.MemoryError:
            hit["errors"] += 1
        return False

    def harvest(self, inf, ctx):
        """Write the image referenced by the context when its size is plausible."""
        img = int.from_bytes(inf.read_memory(ctx + 0xA8, 8), "little")
        if not img:
            return
        dim_a = int.from_bytes(inf.read_memory(img - 0x44, 4), "little")
        dim_b = int.from_bytes(inf.read_memory(img - 0x48, 4), "little")
        if 0 < dim_a <= 5000 and 0 < dim_b <= 20000 and dim_a * dim_b <= 4_000_000:
            pixels = bytes(inf.read_memory(img, dim_a * dim_b))
            with open(OUT, "wb") as handle:
                handle.write(struct.pack("<II", dim_a, dim_b) + pixels)
            hit["n"] += 1


BP("*0x4689b0")
gdb.execute("run getprintwait -doinit")
gdb.execute("quit")
