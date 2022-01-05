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


# ╔═╡ 137bc5ea-ae97-491e-8c1a-66be074752cc
begin
	p_grid = collect(0:0.001:1)
	x = 6 # Which trial
	n = 9 # Number of trials
	local p # Probability of success
	prob_data = [pdf(Binomial(n, p), x) for p in p_grid]
	prob_uninfprior = ones(1001)
	posterior_uninfprior = prob_data .* prob_uninfprior
	posterior_uninfprior = posterior_uninfprior ./ sum(posterior_uninfprior)
	scatter(posterior_uninfprior)
end

# ╔═╡ 0fba150d-9d96-45ae-8f37-bdfd989ebd41
begin
	# Different non-uniform prior Beta
	prob_betaprior = [pdf(Beta(3,1), p) for p in p_grid]
	posterior_betaprior = prob_data .* prob_betaprior
	posterior_betaprior = posterior_betaprior ./ sum(posterior_betaprior)
	
	scatter!(posterior_betaprior, color=:blue)
end

# ╔═╡ b46dd645-b71f-4617-a55a-46ad0a5808f4
begin
	# Sample from posterior
	samples_uninfprior = [sample(p_grid, Weights(posterior_uninfprior)) for i in 1:1000]
	samples_betaprior = [sample(p_grid, Weights(posterior_betaprior)) for i in 1:1000]
end

# ╔═╡ ec5ac06d-4a16-4233-891c-492be23745ba
scatter(samples_uninfprior, title="Sampled probabilities from posterior distribution")

# ╔═╡ 6067730e-f2cd-4092-aebd-1befa909f68e
begin
	density(samples_uninfprior, title="Density of sampled posterior")
	density!(samples_betaprior,color=:blue)
end

# ╔═╡ 1278c7d4-f5db-401c-923a-fdef994d8e36
begin
	p = rand(samples_uninfprior)
	scatter(pdf.(Binomial(n,p)),color=:green,title="Single predictive distribution for p=$p")
end

# ╔═╡ b85c0a56-fab5-40d6-a740-601b500e9fd7
begin
	dlist = []
	anim = @animate for i ∈ 1:1000
		# Now given the sample from posterior get a distribution
		d = pdf.(Binomial(n,rand(samples_uninfprior)), 1:n)
		push!(dlist, d)
		# Accumulate results
		current = sum(dlist) ./ sum(sum(dlist))
		scatter(current,color=:red,title="Posterior predictive")
	end
	gif(anim, "anim_fps15.gif", fps = 30)
end

# ╔═╡ 239d1f5a-6916-408c-a053-b7aa8b093e05


# ╔═╡ 9617d56f-ebf5-4ccf-9a44-1b68921d007e


# ╔═╡ Cell order:
# ╠═91d393ae-6e1c-11ec-0b79-29498ea4283d
# ╠═137bc5ea-ae97-491e-8c1a-66be074752cc
# ╠═0fba150d-9d96-45ae-8f37-bdfd989ebd41
# ╠═b46dd645-b71f-4617-a55a-46ad0a5808f4
# ╠═ec5ac06d-4a16-4233-891c-492be23745ba
# ╠═6067730e-f2cd-4092-aebd-1befa909f68e
# ╠═1278c7d4-f5db-401c-923a-fdef994d8e36
# ╠═b85c0a56-fab5-40d6-a740-601b500e9fd7
# ╠═239d1f5a-6916-408c-a053-b7aa8b093e05
# ╠═9617d56f-ebf5-4ccf-9a44-1b68921d007e
