### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# ╔═╡ edf9276c-8267-11ec-2233-c562522cd77b
begin
    import Pkg
    # activate a clean environment
    Pkg.activate(mktempdir())

    Pkg.add([
        Pkg.PackageSpec(name="StatsBase"),
		Pkg.PackageSpec(name="Turing"),
		Pkg.PackageSpec(name="PlutoUI"),
		Pkg.PackageSpec(name="CSV"),
		Pkg.PackageSpec(name="DataFrames"),
		Pkg.PackageSpec(name="CairoMakie"),
		Pkg.PackageSpec(name="KernelDensity")
		
    ])
	using StatsBase
	using Turing
	using PlutoUI
	using CSV
	using DataFrames
	using CairoMakie
	using KernelDensity
	function hpdi(x::Vector{T}; alpha=0.11) where {T<:Real}
	    n = length(x)
	    m = max(1, ceil(Int, alpha * n))
	
	    y = sort(x)
	    a = y[1:m]
	    b = y[(n - m + 1):n]
	    _, i = findmin(b - a)
	
	    return [a[i], b[i]]
	end
	CairoMakie.activate!(type = "svg")
end

# ╔═╡ 569158f5-452d-45d7-acd9-17bdb6d19803
# Posterior for the globe tossing problem
# Probability of 6 successes out of 9 trials
begin
	p_grid = collect(0.001:0.001:1)
	prob_p = ones(1000)
	prob_data = [pdf(Binomial(9,p),6) for p in p_grid]
	posterior = prob_data .* prob_p
	posterior = posterior ./ sum(posterior)
end

# ╔═╡ 177042bc-2e0a-4b9a-b470-1a8512dc9a07
# Within posterior each value is the plausability of given parameter
scatter(p_grid,posterior)

# ╔═╡ 13a769f6-dd46-486d-90ae-3742af0c4054
# Now we wish to sample 10 000 from this posterior, which will produce individual parameters (p) proportional to their plausability in posterior
samples = sample(p_grid, Weights(posterior), 1000)

# ╔═╡ 57576043-df60-4446-b069-4712d4987cda
density(samples)

# ╔═╡ 11ace4db-6b9d-4c1a-bf31-a1a63104af1e
md"""
We are going to use these sampels to summarize and interpret posterior "great value in it".
1. How much posterior probability lies below some parameter value?
2. How much posterior probability lies between two parameter values?
3. Which parameter value marks the lower 5% of the posterior probability?
4. Which range of parameters values contains 90% of the posterior probability?
5. Which parameter value has the highest posterior probability?

We can split this up into
- Intervals of defined boundaries
- Defined probability mass
- Point estimates
"""

# ╔═╡ 8aa030a6-655d-46a7-800d-bff7c32a3a71
# Add up posterior probability for everything below p<0.5
sum(posterior[p_grid .< 0.5])

# ╔═╡ 03ae747b-e100-437c-866f-3e1af2f2a926
# More general method is using samples from the posterior (because in more complex cases it's not easy to just sum across all parameter values like above)
sum(samples .< 0.5)/length(samples)

# ╔═╡ 0193cf72-ba0d-4822-bac3-f8817a63de37
# Using the same approach we can approximate how many samples lie between 0.5 and 0.75 parameter values
#NOTE it won't be the same, because it involves random sampling, but it will be close
sum((samples .> 0.5 ) .& (samples .< 0.75)) / length(samples)

# ╔═╡ b305ff9e-59de-418f-afd4-9d64ed5c1059
# Compatibility interval (interval of values compatible with the model)
# For < 80% we know it starts at 0 and ends at:
ends = quantile(samples, 0.8)

# ╔═╡ 2e018e01-7e97-4c22-bd0f-bc6ebabfff06
let
	f, ax = scatter(p_grid, posterior)
	ax.xticks = 0:0.1:1
	ax.xlabel = "Proportion of water (p)"
	ax.ylabel = "Density"
	select = p_grid .< 0.5
	band!(p_grid[select],zeros(length(p_grid))[select],posterior[select])
	f
end

# ╔═╡ c7f21245-832d-4852-93b5-8e9b9eb17bfd
let
	f, ax = scatter(p_grid, posterior)
	ax.xticks = 0:0.1:1
	ax.xlabel = "Proportion of water (p)"
	ax.ylabel = "Density"
	select = p_grid .< 0.75
	band!(p_grid[select],zeros(length(p_grid))[select],posterior[select])
	f
end

# ╔═╡ 3811e510-afd8-41d3-acf8-2844b21370ed
let
	f, ax = scatter(p_grid, posterior)
	ax.xticks = 0:0.1:1
	ax.xlabel = "Proportion of water (p)"
	ax.ylabel = "Density"
	select = (p_grid .< 0.75) .& (p_grid .> 0.5)
	band!(p_grid[select],zeros(length(p_grid))[select],posterior[select])
	f
end

# ╔═╡ 28344450-9f46-4b43-b71e-eba48c36248e
let
	f, ax = scatter(p_grid, posterior)
	ax.xticks = 0:0.1:1
	ax.xlabel = "Proportion of water (p)"
	ax.ylabel = "Density"
	lower, upper = quantile(samples, [0.1,0.9]) # middle 80% interval lies between 10% and 90%
	select = (p_grid .< upper) .& (p_grid .> lower)
	band!(p_grid[select],zeros(length(p_grid))[select],posterior[select])
	f
end
#NOTE: Intervals of this sort assign equal mass probability to each tail, and work as long as distribution is not assymetrical.
# In terms of supporting inferences about which parameters are consistent with data, they're not ideal

# ╔═╡ 10ab561d-4e67-4bab-a84b-6b1ce181b7d1
begin
	prob_data_skewed = [pdf(Binomial(3,p),3) for p in p_grid]
	posterior_skewed = prob_data_skewed .* prob_p
	posterior_skewed = posterior_skewed ./ sum(posterior_skewed)
end

# ╔═╡ 402b57bf-9be8-4a60-94ef-525649944c85
let
	f, ax = scatter(p_grid, posterior_skewed)
	ax.xticks = 0:0.1:1
	ax.xlabel = "Proportion of water (p)"
	ax.ylabel = "Density"
	samples = sample(p_grid, Weights(posterior_skewed), 1000)
	lower, upper = quantile(samples, [0.25,0.75]) # 50% middle interval is between 25% and 75% based on samples
	select = (p_grid .< upper) .& (p_grid .> lower)
	band!(p_grid[select],zeros(length(p_grid))[select],posterior_skewed[select])
	f
end
# Problem here is that percentile interval does not include highly probable region around 1.0, since distribution is not symmetrical

# ╔═╡ 045fb832-c8f0-4e9d-9a6f-3f98960bc6c1
let
	f, ax = scatter(p_grid, posterior_skewed)
	ax.xticks = 0:0.1:1
	ax.xlabel = "Proportion of water (p)"
	ax.ylabel = "Density"
	samples = sample(p_grid, Weights(posterior_skewed), 1000)
	lower, upper = hpdi(samples, alpha=0.5) # Narrows interval containing specificed probability mass
	select = (p_grid .< upper) .& (p_grid .> lower)
	band!(p_grid[select],zeros(length(p_grid))[select],posterior_skewed[select])
	f
end
# Using widest interval that exclude a value. Also if distributions are not skewed, percentile interval would be very similar to compatibility interval shown by a HPDI

# ╔═╡ 8ed3b901-32f2-4fc3-a64f-e02a67161601


# ╔═╡ Cell order:
# ╠═edf9276c-8267-11ec-2233-c562522cd77b
# ╠═569158f5-452d-45d7-acd9-17bdb6d19803
# ╠═177042bc-2e0a-4b9a-b470-1a8512dc9a07
# ╠═13a769f6-dd46-486d-90ae-3742af0c4054
# ╠═57576043-df60-4446-b069-4712d4987cda
# ╠═11ace4db-6b9d-4c1a-bf31-a1a63104af1e
# ╠═8aa030a6-655d-46a7-800d-bff7c32a3a71
# ╠═03ae747b-e100-437c-866f-3e1af2f2a926
# ╠═0193cf72-ba0d-4822-bac3-f8817a63de37
# ╠═b305ff9e-59de-418f-afd4-9d64ed5c1059
# ╠═2e018e01-7e97-4c22-bd0f-bc6ebabfff06
# ╠═c7f21245-832d-4852-93b5-8e9b9eb17bfd
# ╠═3811e510-afd8-41d3-acf8-2844b21370ed
# ╠═28344450-9f46-4b43-b71e-eba48c36248e
# ╠═10ab561d-4e67-4bab-a84b-6b1ce181b7d1
# ╠═402b57bf-9be8-4a60-94ef-525649944c85
# ╠═045fb832-c8f0-4e9d-9a6f-3f98960bc6c1
# ╠═8ed3b901-32f2-4fc3-a64f-e02a67161601
