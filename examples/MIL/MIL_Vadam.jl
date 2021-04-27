using Vadam


MI_dir = "C:/Users/Zdenda/Documents/GitHub/MIProblems"
λ = 0.01
k_all = 1:25
for (root, dirs, files) in walkdir(MI_dir)
    for dir in dirs
        path = joinpath(root, dir)
        if(!occursin(".git",path))
            println(path)
            problem = splitpath(path)[end]
            (xt,yt,xte,yte, dta) = ReadMillAndSplit(path,N_iter)
            N_data = length(yt)
            results = sensitivity_nn_width(k_all, λ)
            filename = string(problem,"_NNwidth_sensitivity_lambda_",λ,".csv")
            filepath = joinpath("C:\\Users\\Zdenda\\Documents\\GitHub\\Vadam\\data\\sims\\MIL",filename)
            CSV.write(filepath, results)
            #jeste plot dodelat
        end
    end
end


dirs = ["C:/Users/Zdenda/Documents/GitHub/MIProblems/Musk1","C:/Users/Zdenda/Documents/GitHub/MIProblems/Musk2"]

for dir in dirs
    path = dir
    println(path)
    problem = splitpath(path)[end]
    N_iter = 15000; opt = ADAM(0.01)
    (xt,yt,xte,yte, dta) = ReadMillAndSplit(path,N_iter)
    N_data = size(yt)[2]
    results = sensitivity_nn_width(k_all, λ)
    filename = string(problem,"_NNwidth_sensitivity_lambda_",λ,".csv")
    filepath = joinpath("C:\\Users\\Zdenda\\Documents\\GitHub\\Vadam\\data\\sims\\MIL",filename)
    CSV.write(filepath, results)
    #jeste plot dodelat
    end
end
