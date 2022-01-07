### A Pluto.jl notebook ###
# v0.17.5

using Markdown
using InteractiveUtils

# ╔═╡ 91d393ae-6e1c-11ec-0b79-29498ea4283d
begin
    import Pkg
    # activate a clean environment
    Pkg.activate(mktempdir())

    Pkg.add([
        Pkg.PackageSpec(name="Plots"),
        Pkg.PackageSpec(name="StatsBase"),
		Pkg.PackageSpec(name="StatsPlots"),
		Pkg.PackageSpec(name="Turing"),
    ])

    using Plots
	using StatsBase
	using StatsPlots
	using Turing
end


# ╔═╡ 4178b5c3-0eab-461c-827f-a3fac25eae10
md"""
# Lectures 1-2
"""

# ╔═╡ 137bc5ea-ae97-491e-8c1a-66be074752cc
begin
	p_grid = collect(0:0.001:1)
	x = 6 # Number of success we are chosing
	n = 9 # Number of trials
	local p # Probability of success
	prob_data = [pdf(Binomial(n, p), x) for p in p_grid]
	prob_uninfprior = ones(1001)
	posterior_uninfprior = prob_data .* prob_uninfprior
	posterior_uninfprior = posterior_uninfprior ./ sum(posterior_uninfprior)
	scatter(p_grid, posterior_uninfprior)
end

# ╔═╡ 0fba150d-9d96-45ae-8f37-bdfd989ebd41
begin
	# Different non-uniform prior Beta
	prob_betaprior = [pdf(Beta(3,1), p) for p in p_grid]
	posterior_betaprior = prob_data .* prob_betaprior
	posterior_betaprior = posterior_betaprior ./ sum(posterior_betaprior)
	
	scatter!(p_grid, posterior_betaprior, color=:blue)
end

# ╔═╡ b46dd645-b71f-4617-a55a-46ad0a5808f4
begin
	# Sample from posterior
	samples_uninfprior = [sample(p_grid, Weights(posterior_uninfprior)) for i in 1:1000]
	samples_betaprior = [sample(p_grid, Weights(posterior_betaprior)) for i in 1:1000]
end

# ╔═╡ ec5ac06d-4a16-4233-891c-492be23745ba
scatter(p_grid, samples_uninfprior, title="Sampled probabilities from posterior distribution")

# ╔═╡ 4e4fca93-2bd5-4aa0-9acf-a5a930b431c8


# ╔═╡ 6067730e-f2cd-4092-aebd-1befa909f68e
begin
	density(samples_uninfprior, title="Density of sampled posterior")
	density!(samples_betaprior,color=:blue)
end

# ╔═╡ 1278c7d4-f5db-401c-923a-fdef994d8e36
begin
	p = rand(samples_uninfprior)
	scatter(1:n,pdf.(Binomial(n,p)),color=:green,title="Single predictive distribution for p=$p")
end

# ╔═╡ b85c0a56-fab5-40d6-a740-601b500e9fd7
begin
	dlist = []
	anim = @animate for i ∈ 1:1000
		# Sample from posterior
		p = sample(p_grid, Weights(posterior_uninfprior))
		# Now given the sample from posterior get a distribution
		d = pdf.(Binomial(n,p), 1:n)
		push!(dlist, d)
		# Accumulate results
		current = sum(dlist) ./ sum(sum(dlist))
		scatter(current,color=:red,title="Posterior predictive")
	end
	gif(anim, "anim_fps15.gif", fps = 30)
end

# ╔═╡ 239d1f5a-6916-408c-a053-b7aa8b093e05
md"""
# Homework
1. Suppose the globe tossing data (Chapter 2) had turned out to be 4 water
and 11 land. Construct the posterior distribution, using grid approximation.
Use the same flat prior as in the book.
2. Now suppose the data are 4 water and 2 land. Compute the posterior
again, but this time use a prior that is zero below p = 0.5 and a constant
above p = 0.5. This corresponds to prior information that a majority of the
Earth’s surface is water.
3. For the posterior distribution from 2, compute 89% percentile and HPDI
intervals. Compare the widths of these intervals. Which is wider? Why? If
you had only the information in the interval, what might you misunderstand
about the shape of the posterior distribution?
4. OPTIONAL CHALLENGE. Suppose there is bias in sampling so that Land
is more likely than Water to be recorded. Specifically, assume that 1-in-5
(20%) of Water samples are accidentally recorded instead as ”Land”. First,
write a generative simulation of this sampling process. Assuming the true
proportion of Water is 0.70, what proportion does your simulation tend to
produce instead? Second, using a simulated sample of 20 tosses, compute
the unbiased posterior distribution of the true proportion of water.
"""

# ╔═╡ 77bbf84d-9a11-4249-b61f-8f10c7d3f50b
# 1
let
	p_grid = collect(0:0.001:1)
	x = 4    # Number of successes we are interested in
	n = 4+11 # Number of trials
	local p  # Probability of success
	prob_data = [pdf(Binomial(n, p), x) for p in p_grid]
	prob_uninfprior = ones(1001)
	posterior_uninfprior = prob_data .* prob_uninfprior
	posterior_uninfprior = posterior_uninfprior ./ sum(posterior_uninfprior)
	scatter(p_grid,posterior_uninfprior, title="Posterior probability")
end

# ╔═╡ 25d5b189-364d-46d0-8b9d-24acbaf82157
#2
let
	p_grid = collect(0:0.001:1)
	x = 4    # Number of successes we are interested in
	n = 4+11 # Number of trials
	local p  # Probability of success
	prob_data = [pdf(Binomial(n, p), x) for p in p_grid]
	prob_uninfprior = [p < 0.5 ? 0 : 1 for p in p_grid]
	posterior_uninfprior = prob_data .* prob_uninfprior
	posterior_uninfprior = posterior_uninfprior ./ sum(posterior_uninfprior)
	scatter(p_grid,posterior_uninfprior, title="Posterior probability")
end

# ╔═╡ e130de89-9486-45c2-aca5-c39eb4d3d7a0
#3
# 89th percentile
sort(posterior_uninfprior)[Int(round((length(posterior_uninfprior)+1) * (89/100), digits=0))]

# ╔═╡ a73fa697-3a45-40a1-b917-96d778739161


# ╔═╡ Cell order:
# ╠═4178b5c3-0eab-461c-827f-a3fac25eae10
# ╠═91d393ae-6e1c-11ec-0b79-29498ea4283d
# ╠═137bc5ea-ae97-491e-8c1a-66be074752cc
# ╠═0fba150d-9d96-45ae-8f37-bdfd989ebd41
# ╠═b46dd645-b71f-4617-a55a-46ad0a5808f4
# ╠═ec5ac06d-4a16-4233-891c-492be23745ba
# ╠═4e4fca93-2bd5-4aa0-9acf-a5a930b431c8
# ╠═6067730e-f2cd-4092-aebd-1befa909f68e
# ╠═1278c7d4-f5db-401c-923a-fdef994d8e36
# ╠═b85c0a56-fab5-40d6-a740-601b500e9fd7
# ╠═239d1f5a-6916-408c-a053-b7aa8b093e05
# ╠═77bbf84d-9a11-4249-b61f-8f10c7d3f50b
# ╠═25d5b189-364d-46d0-8b9d-24acbaf82157
# ╠═e130de89-9486-45c2-aca5-c39eb4d3d7a0
# ╠═a73fa697-3a45-40a1-b917-96d778739161
