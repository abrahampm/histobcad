# -*- mode: python ; coding: utf-8 -*-
from PyInstaller.utils.hooks import collect_data_files, collect_submodules

# Include all data and modules from PySide6
datas = collect_data_files('PySide6')

# Include libopenslide
import os
import openslide_bin
openslide_bin_dir = os.path.dirname(openslide_bin.__file__)
libopenslide_path = os.path.join(openslide_bin_dir, "libopenslide.so.1")

# Add libopenslide to datas
if os.path.exists(libopenslide_path):
    datas += [(libopenslide_path, "openslide_bin/")]

# Include additional data files if needed
datas += [
    ('main.qml', '.'),
    ('resources', 'resources'),
    ('qml', 'qml'),
]

hiddenimports = collect_submodules('PySide6')

block_cipher = None

a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)
pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)
exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='SlideSimple',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
)
