home = homedir()
artifacts_dir = joinpath(homedir(), ".julia/artifacts")
mkpath(artifacts_dir)
datapath = joinpath(pwd(), "data")
write(
    joinpath(artifacts_dir, "Overrides.toml"),
    "113db057ea8fd9dd2ed6814748e832a38653cb43 = $(repr(datapath))"
)
import Pkg
Pkg.activate(".")
Pkg.develop(url="https://github.com/Wild-Area/VsRecorderBase.jl.git")
Pkg.develop(url="https://github.com/sunoru/SimpleI18n.jl.git")
Pkg.develop(url="https://github.com/sunoru/Tesseract.jl.git")
