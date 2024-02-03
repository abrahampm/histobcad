from io import BytesIO


class TileServer:
    def get_tile(self, file_id: str, level: int, col: int, row: int, img_format: str) -> BytesIO:
        raise NotImplementedError

    def get_thumbnail(self, file_id: str, width: int, height: int, img_format: str) -> BytesIO:
        raise NotImplementedError

    def get_dimensions(self, file_id: str) -> tuple:
        raise NotImplementedError

    def get_supported_file_types(self) -> list:
        raise NotImplementedError

    def get_levels(self, file_id: str) -> tuple:
        raise NotImplementedError

    def set_base_path(self, file_id: str):
        raise NotImplementedError

    def set_tile_background(self, hex_color: str):
        raise NotImplementedError
