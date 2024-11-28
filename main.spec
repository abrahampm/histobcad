# -*- mode: python ; coding: utf-8 -*-
from PyInstaller.utils.hooks import collect_data_files, collect_submodules, collect_dynamic_libs

import os
import openslide_bin

openslide_bin_path = os.path.dirname(openslide_bin.__file__)
binaries = [(os.path.join(openslide_bin_path, file), 'openslide_bin/') for file in os.listdir(openslide_bin_path) if file.endswith('.dll') or file.endswith('.so') or file.endswith('.dylib')]

# Include all data and modules from PySide6
datas = collect_data_files('PySide6')

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
    binaries=binaries,
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
