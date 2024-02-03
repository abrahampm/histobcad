import os
from PySide2.QtCore import QObject, Slot
from flask import Flask, abort, make_response
from library.base.tile_server import TileServer


class DeepZoomServer(QObject):
    def __init__(self, host, port, tile_server: TileServer):
        super(DeepZoomServer, self).__init__()
        self._host = host
        self._port = port
        self._protocol = 'http'
        self._base_url = f'{self._protocol}://{self._host}:{self._port}'
        self._tile_server = tile_server
        # Create and configure app
        self._app = Flask(__name__)
        self.__register_routes__()

    @Slot()
    def run(self):
        print('Starting deepzoom server')
        self._app.run(host=self._host, port=self._port, threaded=False)

    @Slot()
    def stop(self):
        print('Stopping deepzoom server')

    def get_base_url(self) -> str:
        return self._base_url

    def get_thumbnail_url(self, file_name: str) -> str:
        return f'{self._base_url}/{file_name}/thumbnail'

    def get_slide_url(self, file_name: str) -> str:
        return f'{self._base_url}/{file_name}/tiles/'

    def get_supported_file_types(self) -> list:
        return self._tile_server.get_supported_file_types()

    def set_base_dir(self, base_dir: str):
        self._tile_server.set_base_path(base_dir)

    def get_level_tiles(self, file_name: str) -> tuple:
        return self._tile_server.get_levels(file_name)

    def get_level_dimensions(self, file_name: str) -> tuple:
        return self._tile_server.get_dimensions(file_name)

    def __register_routes__(self):
        @self._app.route('/<path:path>/thumbnail')
        def get_thumbnail(path):
            return self.__get_thumbnail__(path, 'png')

        @self._app.route('/<path:path>/tiles/<int:level>/<int:col>/<int:row>.<img_format>')
        def get_tile(path, level, col, row, img_format):
            return self.__get_tile__(path, level, col, row, img_format)

    def __get_thumbnail__(self, path, img_format):
        try:
            buf = self._tile_server.get_thumbnail(path, img_format)
        except ValueError:
            abort(500)
        resp = make_response(buf.getvalue())
        resp.mimetype = 'image/%s' % format
        return resp

    def __get_tile__(self, path, level, col, row, img_format):
        # Translate deepzoom tile to QML Map origin
        origin = (1 << level) / 2
        try:
            buf = self._tile_server.get_tile(path, level, col - origin, row - origin, img_format)
        except ValueError:
            abort(500)
        resp = make_response(buf.getvalue())
        resp.mimetype = 'image/%s' % format
        return resp


