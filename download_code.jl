using Base.Filesystem
using JLD2
using PackageAnalyzer
using Pkg
using ProgressMeter

all_packages = find_packages()[4:end];
all_packages = Any[i for i in all_packages if i.name ∉ ["SeisProcessing", "vOptGeneric", "ExactDiagonalization", "CachedFunctions", "Mads", "FractionalDelayFilter"]]
push!(all_packages, "https://github.com/JuliaLang/julia")
push!(all_packages, "https://github.com/JuliaLang/Distributed.jl")
directory_path = "./tmp_code"

all_results = PackageV1[]
@showprogress for package in all_packages
    res = analyze(package, root="./tmp_code")
    push!(all_results, res)
end

# Download any packages that were skipped
#TODO: figure out why some packages are skipped
current_packages = [i.name for i in all_results]
@showprogress for package in all_packages
    if package.name in current_packages
        continue
    end
    res = analyze(package, root="./tmp_code")
    push!(all_results, res)
end

all_results = [i for i in all_results if i.reachable]
all_results = [i for i in all_results if i.name != "Invalid Project.toml"]
save("all_results.jld2", Dict("all_results" => all_results))
