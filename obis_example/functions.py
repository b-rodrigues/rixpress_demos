def read_shp(path_folder):
    # Look for files ending with .shp in the given folder
    candidates = glob.glob(os.path.join(path_folder, "*.shp"))
    if not candidates:
        raise FileNotFoundError(f"No .shp file found in {path_folder}")

    shapefile = candidates[0]
    return gpd.read_file(shapefile, driver="ESRI Shapefile")
