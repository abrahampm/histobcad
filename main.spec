# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

external_files = [('models/svmclassifier.C30_coef01.0_degree3_kernelpoly_selected_features100_histomics_rgb_color_histogram_rgb.joblib.pkl', 'models'),
                  ('utils/scaler_gui_100_features.joblib.pkl', 'utils'),
                  ('main.qml', '.'),
                  ('resources/qt.qrc', 'resources'),
                  ('resources/qtquickcontrols2.conf', 'resources')]

a = Analysis(['main.py'],
             pathex=['/home/abraham/Breast Cancer/IDC Tissue Classification using ML/App'],
             binaries=[],
             datas=external_files,
             hiddenimports=['sklearn'],
             hookspath=[],
             runtime_hooks=[],
             excludes=['matplotlib','tkinter'],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          [],
          exclude_binaries=True,
          name='BreastHistopathApp',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          console=False )
coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas,
               strip=False,
               upx=True,
               upx_exclude=[],
               name='BreastHistopathApp')
