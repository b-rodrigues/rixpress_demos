def serialize_to_json(obj, path):
    with open(path, 'w') as f:
        f.write(obj.to_json())
