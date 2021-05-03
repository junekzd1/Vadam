module Vadam

using Flux
import Flux.Optimise:  batchmemaybe, update!

include("mill_load/mill_load.jl")
export ReadMillData, train_val_test_split, train_val_test_inds, ReadMillAndSplit

include("mill_load/mill_models.jl")
export sensitivity_nn_width, get_results_mle, get_results_vadam


function vadam!(loss,ps,dta,N_data,λ,N_sim=10,σ_init=1.0,α=0.001) #jeste pak jak dodat spravne data
    γ_1 = 0.9; γ_2 = 0.99 #mozna dat jako mozny input?
    μ_vad = deepcopy(ps); s = deepcopy(ps); m = deepcopy(ps)
    map((x)->(x.=σ_init), s)
    # N_data = size(batchmemaybe(dt)[1])[2] #asi jinak radsi

    for dt in dta
        m_temp = deepcopy(m); s_temp = deepcopy(s)
        map((x)->(x.=0) , m_temp); map((x)->(x.=0) , s_temp)
        for j ∈ 1:N_sim
            for i in 1:length(ps)
                ps[i] .= μ_vad[i] .+ (1 ./ sqrt.(abs.(N_data .* s[i] .+ λ))) .* randn(size(ps[i]))
            end
            gs = gradient(()->loss(batchmemaybe(dt)...),ps)
            for i ∈ 1:length(ps)
                gs[ps[i]] == nothing && continue
                @. m_temp[i] += γ_1 * m[i] .+ (1-γ_1) * (gs[ps[i]] .+ (λ/N_data .* μ_vad[i]))
                @. s_temp[i] += γ_2 * s[i] .+ (1-γ_2) * (gs[ps[i]] .* gs[ps[i]])
            end
        end
        m = m_temp ./ N_sim; s = s_temp ./ N_sim
        for i in 1:length(ps)
            m_hat = 1/(1-γ_1^i) * m[i]; s_hat = 1/(1-γ_2^i) * s[i]
            @. μ_vad[i] = μ_vad[i] .- (α * m_hat) ./ (sqrt.(abs.(s_hat)) .+ λ/N_data) #DAT PRYC ABS!!
        end
    end
    σ_vad = deepcopy(ps)
    for i ∈ 1:length(ps)
        @. σ_vad[i] = 1 ./ sqrt.(abs.(N_data .* s[i] .+ λ)) #DAT PRYC ABS!!
    end
    return (μ_vad,σ_vad)
end


end
