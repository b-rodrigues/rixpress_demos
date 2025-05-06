def read_first_n_lines_two_files(file1_path, file2_path, n=5):
    lines = []

    for path in [file1_path, file2_path]:
        with open(path) as f:
            for i, line in enumerate(f):
                if i >= n:
                    break
                lines.append(line.rstrip('\n'))

    return lines
