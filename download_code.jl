using Base.Filesystem
using JLD2
using RegistryInstances
using PackageAnalyzer
using Pkg
using ProgressMeter

const auth = PackageAnalyzer.github_auth(ENV["GITHUB_PAT"])
const directory_path = "./tmp_code"

function get_packages()
    registries = [i for i in reachable_registries() if i.name == "General"] # Ignore private registries
    all_packages = find_packages(; registries)
    all_packages = Any[i for i in all_packages if i.name ∉ ["SeisProcessing", "vOptGeneric", "ExactDiagonalization", "CachedFunctions", "Mads", "FractionalDelayFilter"]]
    push!(all_packages, "https://github.com/JuliaLang/julia")
    push!(all_packages, "https://github.com/JuliaLang/Distributed.jl")
    return all_packages
end

function analyze_packages(all_packages)
    example_package = analyze(all_packages[1]; root=directory_path, auth=auth)
    all_results = [example_package for i in 1:length(all_packages)]
    p = Progress(length(all_packages))
    Threads.@threads for ix in 1:length(all_packages)
        package = all_packages[ix]
        res = analyze(package; root=directory_path, auth=auth)
        all_results[ix] = res
        next!(p)
    end
    return all_results
end

function download_skipped_packages(all_packages, all_results)
    all_results = unique(all_results)
    current_packages = [i.name for i in all_results]
    @showprogress for package in all_packages[1:end-2]
        if package.name in current_packages
            continue
        end
        res = analyze(package; root=directory_path, auth=auth)
        display(res)
        push!(all_results, res)
    end
    return all_results
end

function main()
    all_packages = get_packages()
    all_results = analyze_packages(all_packages)
    all_results = download_skipped_packages(all_packages, all_results)
    all_results = [i for i in all_results if i.reachable]
    all_results = [i for i in all_results if i.name != "Invalid Project.toml"]
    save("all_results.jld2", Dict("all_results" => all_results))
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
