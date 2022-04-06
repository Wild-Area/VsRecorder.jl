datapath(path...) = joinpath(artifact"data", path...)
load_data(path...) = load(datapath(path...))
