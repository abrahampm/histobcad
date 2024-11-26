import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.responses import Response
from PySide6.QtCore import QObject, Slot
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
        self._app = FastAPI()
        self._app_config = uvicorn.Config(app=self._app, host=self._host, port=self._port)
        self._http_server = uvicorn.Server(self._app_config)
        self.__register_routes__()

    def __register_routes__(self):
        @self._app.get('/{path}/thumbnail')
        def get_thumbnail(path: str):
            return self.__get_thumbnail__(path)

        @self._app.get('/{path}/tiles/{level}/{col}/{row}.{img_format}')
        def get_tile(path: str, level: int, col: int, row: int, img_format: str):
            return self.__get_tile__(path, level, col, row, img_format)

    def __get_thumbnail__(self, path):
        img_format = 'png'
        try:
            buf = self._tile_server.get_thumbnail(path, 512, 512, img_format)
        except ValueError as err:
            raise HTTPException(status_code=500, detail=str(err))
        return Response(content=buf.getvalue(), media_type="image/" + img_format)

    def __get_tile__(self, path, level, col, row, img_format):
        # Translate deepzoom tile to QML Map origin
        origin = (1 << level) / 2
        try:
            buf = self._tile_server.get_tile(path, level, col - origin, row - origin, img_format)
        except ValueError as err:
            raise HTTPException(status_code=500, detail=str(err))
        return Response(content=buf.getvalue(), media_type="image/" + img_format)


    @Slot()
    def run(self):
        print('Starting deepzoom server')
        self._http_server.run()

    @Slot()
    def stop(self):
        print('Stopping deepzoom server')
        self._http_server.should_exit = True

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

    def get_meters_per_pixel(self, file_name: str) -> float:
        return self._tile_server.get_meters_per_pixel(file_name)

    def get_tile_dimensions(self) -> tuple:
        return self._tile_server.get_tile_dimensions()