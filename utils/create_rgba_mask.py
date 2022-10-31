from numpy import zeros
from matplotlib.pyplot import cm
from skimage.filters import gaussian


def create_rgba_mask(data, msk_width, msk_height, tile_width, tile_height, sigma=15):
    mask = zeros([msk_height, msk_width])
    # mask[:, :, 0] = np.ones([msk_height, msk_width])
    # mask[:, :, 3] = np.full([img_height, img_width], 0.4)
    for d in data:
        mask[d['y']:d['y'] + tile_height, d['x']:d['x'] + tile_width] = d['lbl']

    mask = gaussian(mask, sigma=sigma)
    cmap = cm.get_cmap('jet')
    rgba_mask = cmap(mask)
    rgba_mask[..., -1] = mask
    rgba_mask *= 255
    return rgba_mask.astype('uint8')


# import joblib
# import matplotlib.pyplot as plt
# from skimage.io import imread
# d = joblib.load('data.pkl')
# wsi = imread('../../Code/wsi/images/10260__original_2201px_3051px.png')
# msk_width = wsi.shape[1] - 1
# msk_height = wsi.shape[0] - 1
# msk = create_rgba_mask(d, msk_width, msk_height, 50, 50)
# fig = plt.figure(figsize=(msk_width / 100, msk_height / 100), dpi=100)
# plt.gca().set_axis_off()
# plt.subplots_adjust(top=1, bottom=0, right=1, left=0, hspace=0, wspace=0)
# plt.margins(0, 0)
# plt.gca().xaxis.set_major_locator(plt.NullLocator())
# plt.gca().yaxis.set_major_locator(plt.NullLocator())
# # plt.imshow(wsi, extent=(0, msk_width, 0, msk_height))
# plt.imshow(msk,  extent=(0, msk_width, 0, msk_height))
# fig.savefig('output.png', format='png', dpi=100, bbox_inches='tight', pad_inches=0, transparent=True)

# plt.imshow(wsi,  extent=(0, wsi.shape[1], 0, wsi.shape[0]))
# plt.imshow(msk,  extent=(0, 2650, 0, 2100))

# plt.show()

