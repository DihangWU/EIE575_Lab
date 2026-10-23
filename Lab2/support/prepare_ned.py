"""Link the course network and Veins into one NED package tree."""

from pathlib import Path
import sys


core, veins, output = (Path(arg).resolve() for arg in sys.argv[1:])
sources = {
    path.relative_to(veins): path
    for path in veins.rglob("*.ned")
    if path != veins / "package.ned"
}
sources.update({path.name: path for path in core.glob("*.ned")})
targets = {output / relative: source for relative, source in sources.items()}
output.mkdir(parents=True, exist_ok=True)
for path in output.rglob("*.ned"):
    if path.is_symlink() and path not in targets:
        path.unlink()
for target, source in targets.items():
    target.parent.mkdir(parents=True, exist_ok=True)
    if target.is_symlink() and target.resolve() == source:
        continue
    if target.is_symlink():
        target.unlink()
    target.symlink_to(source)
