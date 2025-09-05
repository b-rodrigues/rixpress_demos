function write_arrow(df::DataFrame, filename::String)
    Arrow.write(filename, df)
end

function read_csv(path::String)
    df = CSV.read(path, DataFrame; delim="|")
    return df
end

