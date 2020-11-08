from skimage import io
from numpy import zeros


def split_wsi(filename, tile_width = 50, tile_height = 50):
    wsi = io.imread(filename)
    wsi_height, wsi_width = wsi.shape[0], wsi.shape[1]

    # Create tiles[x,y] array discarding tiles with width < TILE_WIDTH / 2 or height < TILE_HEIGHT / 2_
    tiles = zeros([round(wsi_width / tile_width), round(wsi_height / tile_width), tile_width, tile_height, 3], dtype='uint8')

    i = 0
    for x in range(0, wsi_width - int(tile_width / 2), tile_width):
        j = 0
        if x + tile_width > wsi_width:
            x = wsi_width
        for y in range(0, wsi_height - int(tile_height / 2), tile_height):
            if y + tile_height > wsi_height:
                y = wsi_height
            tiles[i, j, :, :, :] = wsi[y:y + tile_height, x:x + tile_width, 0:3]
            j += 1
        i += 1

    return wsi, tiles
