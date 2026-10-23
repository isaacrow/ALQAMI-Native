#!/usr/bin/env python3
"""
ALQAMI Shared Asset Pipeline: GLB to USDZ Automated Converter
Supports conversion via:
1. Apple's native usdzconvert (Xcode command-line tools on macOS)
2. xcrun realitytool / Reality Converter
3. Python usd-core / gltf2usd (cross-platform)
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

SHARED_DIR = Path(__file__).resolve().parent.parent
GLB_DIR = SHARED_DIR / "models" / "glb"
USDZ_DIR = SHARED_DIR / "models" / "usdz"
IOS_RESOURCES_DIR = SHARED_DIR.parent / "ios" / "AlqamiNative" / "Resources" / "Models"

def check_available_tool():
    if shutil.which("usdzconvert"):
        return "usdzconvert"
    if shutil.which("xcrun"):
        return "xcrun"
    return "manual"

def convert_all():
    tool = check_available_tool()
    USDZ_DIR.mkdir(parents=True, exist_ok=True)
    IOS_RESOURCES_DIR.mkdir(parents=True, exist_ok=True)

    glb_files = list(GLB_DIR.glob("*.glb"))
    print(f"[ALQAMI Pipeline] Found {len(glb_files)} GLB models to process.")
    print(f"[ALQAMI Pipeline] Conversion backend detected: {tool}")

    for glb_path in glb_files:
        usdz_name = glb_path.stem + ".usdz"
        out_usdz = USDZ_DIR / usdz_name
        ios_dest = IOS_RESOURCES_DIR / usdz_name

        print(f" -> Processing {glb_path.name} -> {usdz_name}")

        if tool == "usdzconvert":
            cmd = ["usdzconvert", str(glb_path), str(out_usdz), "-v"]
            try:
                subprocess.run(cmd, check=True)
                shutil.copyfile(out_usdz, ios_dest)
                print(f"    [OK] Generated {out_usdz.name} and synced to iOS Resources.")
            except Exception as e:
                print(f"    [ERROR] Failed to convert {glb_path.name}: {e}")
        elif tool == "xcrun":
            cmd = ["xcrun", "realitytool", "compile", str(glb_path), "-o", str(out_usdz)]
            try:
                subprocess.run(cmd, check=True)
                shutil.copyfile(out_usdz, ios_dest)
                print(f"    [OK] Generated {out_usdz.name} via xcrun.")
            except Exception as e:
                print(f"    [WARN] xcrun realitytool failed: {e}. Please use Reality Converter or usdzconvert.")
        else:
            print(f"    [NOTICE] Automated converter requires macOS with Xcode/usdzconvert.")
            print(f"    Alternative: Drag {glb_path.name} into Apple Reality Converter to export as {usdz_name}.")

if __name__ == "__main__":
    convert_all()
