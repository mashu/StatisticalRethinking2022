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
p_grid[argmax(posterior_skewed)],p_grid[argmax(posterior)]

# ╔═╡ ff6b5ce3-109d-4e8a-b32f-bc327ff1b422
# Approximate this point by computing mode(..) if you sampled
begin
	samples_skewed = sample(p_grid, Weights(posterior_skewed), 10000)
	mode(samples_skewed)
end
# But why not median, mean?
# Use loss function to decide, different losses suggest different point estimate median or mean

# ╔═╡ c6ffc1b0-afac-4a6d-b419-4406f2441175
# Code 3.20
pdf.(Binomial(2,0.7),0:2)
# There is 9% chance of observing water 1x, 42% chance of observing water 2x, and 49% chance of observing water 3x, this is likelihood the probability of data given parameters

# ╔═╡ 4bf1c4d9-7a22-4808-b2c2-63e7fd2f88a2
# Code 3.21-3.22
# We can sample 10 random draws using these probabilities
sample(0:2,Weights(pdf(Binomial(2,0.7))), 10)

# ╔═╡ 86dffa2e-08ea-440c-a8f5-4beafeae2d5f
# Helper function for calculating frequencies for code 3.23
function frequency(x)
	d = Dict{Int,Float64}()
	for v in x
		if !haskey(d,v)
			d[v] = (1 /length(x))
		else
			d[v] += (1 /length(x))
		end
	end
	return d
end

# ╔═╡ d86336c1-847d-432a-8851-ad4b83d68c27
begin
	# Code 3.23
	# Sample 100 000 to verify that each draw appears in proportion to its liklihood
	x = sample(0:2,Weights(pdf(Binomial(2,0.7))), 100000);
	println(frequency(x))
	x = sample(0:9,Weights(pdf(Binomial(9,0.7))), 100000); # Sample posterior
	hist(x)
end

# ╔═╡ 31c8da03-4979-4f5e-9a4d-b72df4cbcf52
# Secondly to propagate perameter uncertainty into these predictions (samples) replace value 0.6 with samples from posterior (but these need to be frequencies since)
begin 
	freq = frequency(x)
	values = Vector{Float64}()
	for i in 0:length(freq)-1
		push!(values,freq[i])
	end
	v = sample(0:9,Weights(values),10000)
	hist(v) # posterior predictive
end

# ╔═╡ eef6719f-e312-4e74-ae5e-1c1b040eabe5
md"""
# Practice
"""

# ╔═╡ e80d6253-2eba-4f82-97bb-271425c8d52c
begin
	ex_p_grid = collect(0.001:0.001:1)
	ex_prior = ones(1000)
	ex_likelihood = [pdf(Binomial(9,p),6) for p in ex_p_grid]
	ex_posterior = ex_likelihood .* ex_prior
	ex_posterior = ex_posterior ./ sum(ex_posterior)
	ex_samples = sample(ex_p_grid, Weights(ex_posterior), 10000)
end

# ╔═╡ 639e0476-0341-4626-82cb-8157fa3d2055
#3E1-3

# ╔═╡ ad752a33-e193-4691-80ac-48474a80b2e1
sum(ex_posterior[p_grid .< 0.2])

# ╔═╡ dd0c00bf-3495-4b7a-908c-ec7293e0b740
sum(ex_samples .< 0.2) / length(ex_samples)

# ╔═╡ a032da55-8d23-4cbd-820f-8a07b6dabe4a
sum(ex_posterior[p_grid .> 0.8])

# ╔═╡ 5b038ac1-307d-4d82-95d5-c3d958b05114
sum(ex_samples .> 0.8) / length(ex_samples)

# ╔═╡ feaa72da-c04c-4899-b80e-255531bb0a63
sum(ex_posterior[(p_grid .< 0.8) .& (p_grid .> 0.2)])

# ╔═╡ 51f28530-702b-448c-8b10-1dc06a9a72a3
sum((ex_samples .< 0.8) .& (ex_samples .> 0.2))/length(ex_samples)

# ╔═╡ 6cce67d0-2882-43d5-9f6b-993166830c27
#3E4-5

# ╔═╡ 0f41342f-60d3-40d4-8237-9df41375b186
sum(ex_samples .< quantile(ex_samples, 0.2)) / length(ex_samples)

# ╔═╡ 442d5ebd-b693-4e4b-963e-59a8f6c47091
sum(ex_samples .> quantile(ex_samples, 0.2)) / length(ex_samples)

# ╔═╡ c239f5d3-0a54-43ac-ba25-1ce9a2018d94
#3E6-7

# ╔═╡ ad8ac0cd-0710-477b-bf42-f30129410fb5
hpdi(ex_samples, alpha=0.66)

# ╔═╡ 64aca326-eb1a-4644-b68a-9dcea9951353
begin
	side = (1-0.66)/2
	quantile(ex_samples, [side,1-side])
end

# ╔═╡ f2bd6a45-090e-4e52-9ff6-c32767832cc6


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
# ╠═ff6b5ce3-109d-4e8a-b32f-bc327ff1b422
# ╠═c6ffc1b0-afac-4a6d-b419-4406f2441175
# ╠═4bf1c4d9-7a22-4808-b2c2-63e7fd2f88a2
# ╠═86dffa2e-08ea-440c-a8f5-4beafeae2d5f
# ╠═d86336c1-847d-432a-8851-ad4b83d68c27
# ╠═31c8da03-4979-4f5e-9a4d-b72df4cbcf52
# ╠═eef6719f-e312-4e74-ae5e-1c1b040eabe5
# ╠═e80d6253-2eba-4f82-97bb-271425c8d52c
# ╠═639e0476-0341-4626-82cb-8157fa3d2055
# ╠═ad752a33-e193-4691-80ac-48474a80b2e1
# ╠═dd0c00bf-3495-4b7a-908c-ec7293e0b740
# ╠═a032da55-8d23-4cbd-820f-8a07b6dabe4a
# ╠═5b038ac1-307d-4d82-95d5-c3d958b05114
# ╠═feaa72da-c04c-4899-b80e-255531bb0a63
# ╠═51f28530-702b-448c-8b10-1dc06a9a72a3
# ╠═6cce67d0-2882-43d5-9f6b-993166830c27
# ╠═0f41342f-60d3-40d4-8237-9df41375b186
# ╠═442d5ebd-b693-4e4b-963e-59a8f6c47091
# ╠═c239f5d3-0a54-43ac-ba25-1ce9a2018d94
# ╠═ad8ac0cd-0710-477b-bf42-f30129410fb5
# ╠═64aca326-eb1a-4644-b68a-9dcea9951353
# ╠═f2bd6a45-090e-4e52-9ff6-c32767832cc6
