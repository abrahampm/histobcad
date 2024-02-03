import os
from io import BytesIO

from PIL import Image

from library.base.tile_server import TileServer
from library.deepzoom.openslide_utils import _SlideCache

OPENSLIDE_WINDOWS_PATH = r'static\openslide-win64\bin'
if hasattr(os, 'add_dll_directory'):
    # Windows
    OPENSLIDE_WINDOWS_PATH = os.path.realpath(os.path.join(os.getcwd(), OPENSLIDE_WINDOWS_PATH))
    with os.add_dll_directory(OPENSLIDE_WINDOWS_PATH):
        import openslide
else:
    import openslide


class OpenSlideServer(TileServer):
    def __init__(self, base_path: str = '.', tile_size: int = 256, tile_quality: int = 100, tile_overlap: int = 0,
                 tile_bg_color: str = '#ffffff', tile_cache_size: int = 10, cache_size_mb: int = 128):
        self._basedir = os.path.abspath(base_path)
        self._tile_size = tile_size
        self._tile_quality = tile_quality
        self._tile_overlap = tile_overlap
        self._tile_cache_size = tile_cache_size
        self._cache_size_mb = cache_size_mb
        self._bg_color = tile_bg_color
        self._supported_file_extensions = ['tif', 'tiff', 'dcm', 'ndpi', 'vms', 'vmu', 'scn', 'mrxs', 'svslide', 'bif']

        self._cache = _SlideCache(
            self._tile_cache_size,
            self._cache_size_mb,
            self._tile_size,
            self._tile_overlap,
            True,
            'default'
        )

    def __get_slide__(self, file_name: str):
        path = os.path.abspath(os.path.join(self._basedir, file_name))
        if not path.startswith(self._basedir + os.path.sep):
            # Directory traversal
            raise ValueError('Invalid slide path: {}'.format(path))
        if not os.path.exists(path):
            raise ValueError('Slide does not exist {}'.format(path))
        try:
            slide = self._cache.get(path)
            slide.filename = os.path.basename(path)
            return slide
        except openslide.OpenSlideError as err:
            raise ValueError("Error opening slide {}".format(err))

    def __get_tile__(self, file_name: str, level: int, col: int, row: int, img_format: str) -> BytesIO:
        slide = self.__get_slide__(file_name)
        format = img_format.lower()
        if format != 'jpg' and format != 'png':
            # Not supported by Deep Zoom
            raise ValueError('Not supported image format')

        try:
            tile = slide.get_tile(level, (col, row))
        except ValueError:
            # Return blank background image
            tile = self.__create_bg_tile__()

        if level < len(slide.level_tiles) and (
                col == slide.level_tiles[level][0] - 1 or row == slide.level_tiles[level][1] - 1):
            # Create tile from blank background + tile image
            bg_tile = self.__create_bg_tile__()
            bg_tile.paste(tile, (0, 0))
            tile = bg_tile

        slide.transform(tile)
        buf = BytesIO()
        tile.save(
            buf,
            format,
            quality=self._tile_quality,
            icc_profile=tile.info.get('icc_profile'),
        )
        return buf

    def __create_bg_tile__(self):
        return Image.new('RGB', (self._tile_size, self._tile_size), self._bg_color)

    def get_levels(self, file_name):
        slide = self.__get_slide__(file_name)
        return slide.level_tiles

    def get_dimensions(self, file_name: str):
        slide = self.__get_slide__(file_name)
        return slide.level_dimensions

    def get_supported_file_types(self):
        return self._supported_file_extensions

    def get_thumbnail(self, file_name: str, img_format: str):
        return self.__get_tile__(file_name, 9, 0, 0, img_format)

    def get_tile(self, file_name: str, level: int, col: int, row: int, img_format: str):
        return self.__get_tile__(file_name, level, col, row, img_format)

    def set_base_path(self, path: str):
        self._basedir = path

    def set_tile_background(self, hex_color: str):
        self._bg_color = hex_color
