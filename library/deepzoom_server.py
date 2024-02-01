import os
from io import BytesIO

from PySide2.QtCore import QObject, Slot
from flask import Flask, abort, make_response
from openslide import OpenSlideError

from library.deepzoom_utils import _SlideCache


class DeepZoomServer(QObject):
    def __init__(self, host='localhost', port=5984):
        super(DeepZoomServer, self).__init__()
        self._host = host
        self._port = port
        self._protocol = 'http'
        self._base_url = f'{self._protocol}://{self._host}:{self._port}'

        # Create and configure app
        self._app = Flask(__name__)
        self._app.config.from_mapping(
            SLIDE_DIR='.',
            SLIDE_CACHE_SIZE=10,
            SLIDE_TILE_CACHE_MB=128,
            DEEPZOOM_FORMAT='png',
            DEEPZOOM_TILE_SIZE=256,
            DEEPZOOM_OVERLAP=0,
            DEEPZOOM_LIMIT_BOUNDS=True,
            DEEPZOOM_TILE_QUALITY=95,
            DEEPZOOM_COLOR_MODE='default',
        )

        # Set up cache
        self._app.basedir = os.path.abspath(self._app.config['SLIDE_DIR'])
        config_map = {
            'DEEPZOOM_TILE_SIZE': 'tile_size',
            'DEEPZOOM_OVERLAP': 'overlap',
            'DEEPZOOM_LIMIT_BOUNDS': 'limit_bounds',
        }
        opts = {v: self._app.config[k] for k, v in config_map.items()}
        self._app.cache = _SlideCache(
            self._app.config['SLIDE_CACHE_SIZE'],
            self._app.config['SLIDE_TILE_CACHE_MB'],
            opts,
            self._app.config['DEEPZOOM_COLOR_MODE'],
        )
        self.__register_routes__()

    @Slot()
    def run(self):

        print('Starting deepzoom server')
        self._app.run(host=self._host, port=self._port, threaded=False)

    def get_base_url(self) -> str:
        return self._base_url

    def get_thumbnail_url(self, file_name: str) -> str:
        return f'{self._base_url}/{file_name}/thumbnail'

    def get_slide_url(self, file_name: str) -> str:
        return f'{self._base_url}/{file_name}/tiles/'

    def set_base_dir(self, base_dir: str):
        self._app.basedir = base_dir

    def __register_routes__(self):
        @self._app.route('/<path:path>/thumbnail')
        def get_thumbnail(path):
            return self.__get_tile__(path, 9, 0, 0, 'png')

        @self._app.route('/<path:path>/tiles/<int:level>/<int:col>/<int:row>.<img_format>')
        def get_tile(path, level, col, row, img_format):
            return self.__get_tile__(path, level + 9, col, row, img_format)

    def __get_slide__(self, path):
        path = os.path.abspath(os.path.join(self._app.basedir, path))
        if not path.startswith(self._app.basedir + os.path.sep):
            # Directory traversal
            abort(404)
        if not os.path.exists(path):
            abort(404)
        try:
            slide = self._app.cache.get(path)
            slide.filename = os.path.basename(path)
            return slide
        except OpenSlideError:
            abort(404)

    def __get_tile__(self, path, level, col, row, img_format):
        slide = self.__get_slide__(path)
        format = img_format.lower()
        if format != 'jpg' and format != 'png':
            # Not supported by Deep Zoom
            abort(404)
        try:
            tile = slide.get_tile(level, (col, row))
        except ValueError:
            # Invalid level or coordinates
            print("Invalid level or coordinates", level, col, row)
            abort(404)
        slide.transform(tile)
        buf = BytesIO()
        tile.save(
            buf,
            format,
            quality=self._app.config['DEEPZOOM_TILE_QUALITY'],
            icc_profile=tile.info.get('icc_profile'),
        )
        resp = make_response(buf.getvalue())
        resp.mimetype = 'image/%s' % format
        return resp


