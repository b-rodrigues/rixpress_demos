def read_image(x):
    im = PIL.Image.open(x)
    pixels = numpy.asarray(im)
    return pixels
