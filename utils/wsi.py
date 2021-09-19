from numpy import zeros, ndarray
from matplotlib.pyplot import cm
from skimage.filters import gaussian


def split_image(image: ndarray, tile_width=50, tile_height=50) -> ndarray:
    wsi_height, wsi_width = image.shape[0], image.shape[1]

    # Create tiles[x,y] array discarding tiles with width < TILE_WIDTH / 2 or height < TILE_HEIGHT / 2_
    tiles = zeros([round(wsi_width / tile_width), round(wsi_height / tile_height), tile_width, tile_height, 3], dtype='uint8')

    i = 0
    for x in range(0, wsi_width - int(tile_width / 2), tile_width):
        j = 0
        i1 = tile_width
        x1 = x + tile_width
        if x1 > wsi_width:
            x1 = wsi_width
            i1 = x1 - x
        for y in range(0, wsi_height - int(tile_height / 2), tile_height):
            j1 = tile_height
            y1 = y + tile_height
            if y1 > wsi_height:
                y1 = wsi_height
                j1 = y1 - y
            tiles[i, j, 0:j1, 0:i1, 0:3] = image[y:y1, x:x1, 0:3]
            j += 1
        i += 1

    return tiles


def create_heatmap(mask: ndarray, sigma=15):
    mask = gaussian(mask, sigma=sigma)
    # TODO Use another colormap to exclude matplotlib from dependencies
    cmap = cm.get_cmap('jet')
    rgba_mask = cmap(mask)
    rgba_mask[..., -1] = mask
    rgba_mask *= 255
    return rgba_mask.astype('uint8')