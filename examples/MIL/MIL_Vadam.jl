using Vadam
using CSV
using Plots

MI_dir = "C:/Users/Zdenda/Documents/GitHub/MIProblems/"

# for (root, dirs, files) in walkdir(MI_dir)
#     for dir in dirs
#         path = joinpath(root, dir)
#         if(!occursin(".git",path))
#             # println(path)
#             problem = splitpath(path)[end]
#             println(problem)
#             (xt,yt,xte,yte, dta) = ReadMillAndSplit(path,N_iter)
#             # N_data = length(yt)
#             # results = sensitivity_nn_width(k_all, λ)
#             # filename = string(problem,"_NNwidth_sensitivity_lambda_",λ,".csv")
#             # filepath = joinpath("C:\\Users\\Zdenda\\Documents\\GitHub\\Vadam\\data\\sims\\MIL",filename)
#             # CSV.write(filepath, results)
#             #jeste plot dodelat
#         end
#     end
# end


# dirs = ["C:/Users/Zdenda/Documents/GitHub/MIProblems/Musk1","C:/Users/Zdenda/Documents/GitHub/MIProblems/Musk2"]
# dirs = ["C:/Users/Zdenda/Documents/GitHub/MIProblems/Fox"]
#Good: Fox, Musk1, Elephant, Mutagenesis1, Newsgroups1, Newsgroups2, Tiger

#Setting up parameters:

problems = ["Fox", "Musk1", "Elephant", "Mutagenesis1", "Newsgroups1", "Newsgroups2", "Tiger"]
problems = ["Fox", "Musk1"]
root_dir = "C:\\Users\\junek\\Documents\\GitHub\\MIProblems\\"

dirs = [string(root_dir,a) for a in problems];
k_all = [i for i in 1:25];
λ_all = [0.001,0.01,0.1,1,10];
seed_all = [i for i in 1:10];
methods = ["MLE","Vadam"];

params_all = Dict(
    # "path" => dirs,
    "k" => k_all,
    "λ" => λ_all,
    "seed" => seed_all,
    # "method" => methods
)
dicts = dict_list(params_all)


N_iter = 15000; opt = ADAM(0.01)
results = DataFrame(Algo = String[], k = Int[], l=Float64[], seed=Float[], NLL_train = Float64[], NLL_test = Float64[])

for dir in dirs
    path = dir
    println(path)
    problem = splitpath(path)[end]
    for seed in seed_all
        (xt,yt,xte,yte, dta) = ReadMillAndSplit(path,N_iter,seed)
        N_data = size(yt)[2]; nb_features = size(xt.data.data)[1]
        for k ∈ k_all
            push!(results, get_results_mle(k,nb_features))
            for λ ∈ λ_all 
                push!(results, get_results_vadam(k,λ,nb_features))
            end
            wsave(datadir("sims\\MIL","sim1.jld2"), results)
        end
    end
    #save results
    filename = string(problem,"_NNwidth_sensitivity.csv")
    filepath = joinpath("C:\\Users\\Zdenda\\Documents\\GitHub\\Vadam\\data\\sims\\MIL",filename)
    CSV.write(filepath, results)
end

# N_iter = 15000; opt = ADAM(0.01)
for (i,d) in enumerate(dicts)
    @unpack k, λ, seed = d
    println(k)
end


for dir in dirs
    path = dir
    println(path)
    problem = splitpath(path)[end]
    (xt,yt,xte,yte, dta) = ReadMillAndSplit(path,N_iter)
    N_data = size(yt)[2]; nb_features = size(xt.data.data)[1]
    results = sensitivity_nn_width(k_all, λ,nb_features)
    #save results
    filename = string(problem,"_NNwidth_sensitivity_lambda_",λ,".csv")
    filepath = joinpath("C:\\Users\\Zdenda\\Documents\\GitHub\\Vadam\\data\\sims\\MIL",filename)
    CSV.write(filepath, results)
    #save fig
    MLEtemp = results[results.Algo.=="MLE",:]
    VADtemp = results[results.Algo.=="Vadam",:]
    plot(MLEtemp.k,MLEtemp.NLL_train,label=:"MLE train error",color=:blue,line=:dashdot,xlabel=:"layer width")
    plot!(MLEtemp.k,MLEtemp.NLL_test,label=:"MLE test error",color=:blue,line=:dash)
    plot!(VADtemp.k,VADtemp.NLL_train,label=:"Vadam train error",color=:red,line=:dashdot)
    plot!(VADtemp.k,VADtemp.NLL_test,label=:"Vadam test error",color=:red,line=:dash)
    title!("$problem data set")
    filename_png = string(problem,"_NNwidth_sensitivity_lambda_",λ,".png")
    filepath_png = joinpath("C:\\Users\\Zdenda\\Documents\\GitHub\\Vadam\\plots\\MIL",filename_png)
    png(filepath_png)
end
#
# for dir in dirs
#     path = dir
#     println(path)
#     problem = splitpath(path)[end]
#     filename = string(problem,"_NNwidth_sensitivity_lambda_",λ,".csv")
#     filepath = joinpath("C:\\Users\\Zdenda\\Documents\\GitHub\\Vadam\\data\\sims\\MIL",filename)
#     CSV.write(filepath, results)
#     MLEtemp = results[results.Algo.=="MLE",:]
#     VADtemp = results[results.Algo.=="Vadam",:]
#     plot(MLEtemp.k,MLEtemp.NLL_train,label=:"MLE train error",color=:blue,line=:dashdot,xlabel=:"layer width")
#     plot!(MLEtemp.k,MLEtemp.NLL_test,label=:"MLE test error",color=:blue,line=:dash)
#     plot!(VADtemp.k,VADtemp.NLL_train,label=:"Vadam train error",color=:red,line=:dashdot)
#     plot!(VADtemp.k,VADtemp.NLL_test,label=:"Vadam test error",color=:red,line=:dash)
#     title!("$problem data set")
#     filename_png = string(problem,"_NNwidth_sensitivity_lambda_",λ,".png")
#     filepath_png = joinpath("C:\\Users\\Zdenda\\Documents\\GitHub\\Vadam\\plots\\MIL",filename_png)
#     png(filepath_png)
#     #jeste plot dodelat
# end
