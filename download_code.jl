using Base.Filesystem
using JLD2
using RegistryInstances
using PackageAnalyzer
using Pkg
using ProgressMeter

const auth = PackageAnalyzer.github_auth(ENV["GITHUB_PAT"])

registries = [i for i in reachable_registries() if i.name == "General"] # Ignore private registries
all_packages = find_packages(; registries);
all_packages = Any[i for i in all_packages if i.name ∉ ["SeisProcessing", "vOptGeneric", "ExactDiagonalization", "CachedFunctions", "Mads", "FractionalDelayFilter"]]
push!(all_packages, "https://github.com/JuliaLang/julia")
push!(all_packages, "https://github.com/JuliaLang/Distributed.jl")
directory_path = "./tmp_code"

example_package = analyze(all_packages[1]; root="./tmp_code", auth=auth)
all_results = [example_package for i in 1:length(all_packages)]
p = Progress(length(all_packages))
Threads.@threads for ix in 1:length(all_packages)
    package = all_packages[ix]
    res = analyze(package; root="./tmp_code", auth=auth)
    all_results[ix] = res
    next!(p)
end

# Download any packages that were skipped
#TODO: figure out why some packages are skipped
all_results = unique(all_results)
current_packages = [i.name for i in all_results]
@showprogress for package in all_packages
    if package.name in current_packages
        continue
    end
    res = analyze(package; root="./tmp_code", auth)
    push!(all_results, res)
end

all_results = [i for i in all_results if i.reachable]
all_results = [i for i in all_results if i.name != "Invalid Project.toml"]
save("all_results.jld2", Dict("all_results" => all_results))
