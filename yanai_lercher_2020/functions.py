def read_image(x):
    im = Image.open(x)
    pixels = numpy.asarray(im)
    return pixels
