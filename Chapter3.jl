### A Pluto.jl notebook ###
# v0.17.7

using Markdown
using InteractiveUtils

# ╔═╡ b5995a3e-784d-11ec-2b4b-358722f2b5b8
begin
    import Pkg
    # activate a clean environment
    Pkg.activate(mktempdir())

    Pkg.add([
        Pkg.PackageSpec(name="Plots"),
        Pkg.PackageSpec(name="StatsBase"),
		Pkg.PackageSpec(name="StatsPlots"),
		Pkg.PackageSpec(name="Turing"),
		Pkg.PackageSpec(name="PlutoUI"),
		Pkg.PackageSpec(name="CSV"),
		Pkg.PackageSpec(name="DataFrames"),
		
    ])
	
    using Plots
	using StatsBase
	using StatsPlots
	using Turing
	using PlutoUI
	using CSV
	using DataFrames
end

# ╔═╡ d74b4314-1fa0-47d0-a5bc-09377dc41e5d
begin
	samples = []
	for i in 1:10000
		push!(samples,rand(Binomial(1000,0.5)))
	end
	samples
end

# ╔═╡ 7636881c-2af3-4b5a-9a90-16dca35a6747
histogram(samples) # As many as 1000 people flip a coin 10000 with probability 0.5 of success

# ╔═╡ 1bd4f35f-d529-4a34-a729-944120f62a57
md"""
Language for modeling

W ~ Binomial(N,p)

p ~ Uniform(0,1)  # Rate of success probability

Binomial -> data distribution (likelyhood)

p -> is the think we try to estimate parameter distributed as Uniform prior
"""

# ╔═╡ 413fd7c3-04fb-4894-b547-1eeede5d8b87
md"""
So

W ~ Binomial(N,p)

p ~ Uniform(0,1)

these implies Bayesian updating, so turns into

... = Binomial(W | N,p)

... = Uniform(p | 0,1)


Pr(W|N,p) = Binomial(W | N,p)

Pr(p) = Uniform(p | 0,1)

we learned last week that it is ∝ (proportional)

Pr(p|W,N) ∝ Binomial(W | N,p)Uniform(p | 0,1)

posterior is proportional to likelyhood times prior
"""

# ╔═╡ f84e9d72-3896-41c9-b62f-e35240cfbb4d
# This is equivalent to code from last lecture
let
	p = collect(0:0.001:1)
	W = 6
	N = 9
	PrW = [pdf(Binomial(N,i),W) for i in p]
	Prp = [pdf(Uniform(0,1), i) for i in p]
	posterior = PrW .* Prp
end

# ╔═╡ 2e7b4337-fcc6-48ed-b10f-767804673253
md"""
## Howell data

Showing relation between height and weight of children
"""

# ╔═╡ b4252618-c74e-4ffb-ba87-a49a98e6eea4
howell = CSV.read("Howell1.csv", DataFrame)

# ╔═╡ 0e9e8888-5a48-41dd-b88c-a75f5ecd8a78
begin
	scatter(howell.height,howell.weight)
	xlabel!("height (cm)")
	ylabel!("weight (kg)")
end

# ╔═╡ e8089a90-045d-4740-b875-113d387c9ab3
# Since this is not linear for now we will look only at adults
adults = howell[howell.age .>= 18,:]

# ╔═╡ 250c92db-ce49-4f39-a12a-2e53283b8753
begin
	scatter(adults.height,adults.weight)
	xlabel!("height (cm)")
	ylabel!("weight (kg)")
end

# ╔═╡ 2e1436c3-7a69-4e97-966e-5277d34a280c
md"""
## Scientific model
How does height influences weight?

H → W

We need to find

W = f(H)

We gonna use linear function
"""

# ╔═╡ 22f728a3-afdb-4545-88b2-1908e1bd0f8a
md"""
Generative models
1. Dynamic: Incremental growth simulated both height and mass
2. Static is what we will do: Changes in height results in changes in weight but no mechanism why it works that way
"""

# ╔═╡ 466d3270-12d5-4bab-8a49-6a9159eb1020
md"""

$y_i = \alpha+\beta _i$

"""

# ╔═╡ e004dad6-612c-41f2-9b6e-e3130265e89a
let
	i = collect(-2:0.01:2)
	α = [1.5, 0.7, 0.6]
	β = [-0.2, 1, 0.6]
	lines = []
	for j in 1:3
		y = (i.*β[j]) .+ α[j]
		push!(lines,(i,y))
	end
	scatter(lines[1][1],lines[1][2])
	scatter!(lines[2][1],lines[2][2])
	scatter!(lines[3][1],lines[3][2])
end

# ╔═╡ b4a4528c-4e5c-403a-9229-1c59eb4df1b9
md"""
Different choices of α and β give different lines.
What's **different about linear regression** is that the line does **not** tell you where observed values on the x axis are, instead it tells you where the **mean** value is (expectation of observed value will be).

$y_i \sim \text{Normal}(\mu_i,\sigma)$
$\mu_i = \alpha + \beta x_i$

Meaning each value $x$

has a different expectation
$E(y|x) = μ$
"""

# ╔═╡ 580356ae-29ad-4ee1-be42-dd517f316e95
md"""
Generative mode example
"""

# ╔═╡ 0ca662fb-bfad-4a32-aec9-01d681f0a55a
begin
	# Parameters
	alpha = 70
	beta = 0.5
	sigma = 5
	n_individuals = 100
	H = rand(Uniform(130,170),n_individuals)

	# Linear model
	mu = alpha .+ (beta.*(H.-mean(H)))
	
	# Model implies distribution of weights
	W = [rand(Normal(u,sigma)) for u in mu]

	# Plot our simulated synthetic people
	scatter(H,W)
	xlabel!("simulated height (cm)")
	ylabel!("simulated weight (cm)")
end

# ╔═╡ 4a5233eb-58bb-41f8-beaf-d23cde3b8288
md"""
Next step we are going to take this scientific model and turn it into statistical model

## Statstical model
To make a linear model a statistical model we need a little bit more now:
- Priors
- Posterior distributions of parameters we need to learn now all three of them
α, β and σ

$y_j \sim \text{Normal}(\mu_i,\sigma)$
$\mu_i = \alpha + \beta x_i$
$\alpha \sim \text{Normal}(0,1)$
$\beta \sim \text{Normal}(0,1)$
$\sigma \sim \text{Uniform}(0,1)$

Scale parameter $\sigma$ is always positive so prior is Uniform
"""

# ╔═╡ a0dc0a49-a47f-4751-a8e6-b900b2f69131
let
	# Parameters
	n_individuals = 100
	alpha = rand(Normal(0,1), n_individuals)
	beta = rand(Normal(0,1), n_individuals)
	points = collect(0:n_individuals)./n_individuals
	f(x,α,β) = α.+β.*x 
	plt = scatter()
	for i in 2:n_individuals
		Plots.abline!(alpha[i],beta[i])
	end
	plt
end

# ╔═╡ c12bd5e1-7646-4703-961d-b842b156351b
md"""
Scaling
1. We do that so the β parameter becomes zero and it's α equals our  μ for $H_i$ equal average $\bar{H}$

$\mu_i = \alpha + \beta(H_i-\bar{H})$
2. We can more easily use prior now, by plugging averages

$\alpha \sim \text{Normal}(60,10)$
$\beta \sim \text{Normal}(0,10)$
$\sigma \sim \text{Uniform}(0,10)$
"""

# ╔═╡ 03d9846f-8d65-47f2-8b1e-b8673f7aa51d
# Sampled regression lines
let
	# Parameters
	n_individuals = 10
	alpha = rand(Normal(60,10), n_individuals)
	beta = rand(Normal(0,10), n_individuals)
	Hseq = collect(range(130,170,length=30))
	Hbar = mean(Hseq)
	plt = scatter()
	ylims!(10,100)
	xlims!(130,170)
	for i in 1:n_individuals
		plot!(Hseq,alpha[i].+beta[i].*(Hseq.-Hbar))
	end
	plt
end

# ╔═╡ 8b7a662f-d9fa-43d8-bf0b-79643d1f97a2
md"""
These lines sometimes even go in wrong direction, this is because of the prior we use for beta that is centered around zero. That is not a good prior. Instead we will use LogNormal.
"""

# ╔═╡ f4551cc9-a107-4aad-9a0d-8cee87d86d3d
# Sampled regression lines
let
	# Parameters
	n_individuals = 10
	alpha = rand(Normal(60,10), n_individuals)
	beta = rand(LogNormal(0,1), n_individuals)
	Hseq = collect(range(130,170,length=30))
	Hbar = mean(Hseq) 
	plt = scatter()
	ylims!(10,100)
	xlims!(130,170)
	for i in 1:n_individuals
		plot!(Hseq,alpha[i].+beta[i].*(Hseq.-Hbar))
	end
	plt
end

# ╔═╡ 5351a562-e0e1-4527-8312-d0be46536400
histogram(rand(LogNormal(0,1), 100)) # it is always positive

# ╔═╡ c3e5c772-5337-4a05-9952-c38c5eb1825e
md"""
There is no right prior, but it's good to have one that is realistic, and not one that would determine our outcome. So we put some constrain here that want beta to be positive as we don't expect people going smaller while they grow.
For linear regression usually prior has no such a big effect on posterior, does not matter that much, but it's not always the case, especially for more complex models it may matter, so we practice now using better prior.

So the model is

$W \sim \text{Normal}(\mu_i,\sigma) \rightarrow Pr(W_i|\mu_i,sigma)$
$\mu_i = \alpha+\beta(H_i-\bar{H})$
$\alpha \sim \text{Normal}(60,10) \rightarrow Pr(\alpha)$
$\beta \sim \text{LogNormal}(0,1) \rightarrow Pr(\beta)$
$\sigma \sim \text{Uniform}(0,10) \rightarrow Pr(\sigma)$

Posterior is $Pr(\alpha,\beta,\sigma|W,H)$

*Probabilities in this buisness are relative number of ways each outcome can happen.*
"""

# ╔═╡ 3ddb17de-7fa7-424d-9f9a-4cd01a682311
begin
	# Linear regression model for Howell dataset
	@model function linear_regression(x, y)
		α ~ Normal(60, 10)
		β ~ LogNormal(0, 1)
		σ ~ Uniform(0, 10)
		# Calculate the terms
		for i in 1:length(x)
			μ = α + (β * (x[i]-mean(x)))
			y[i] ~ Normal(μ, σ)
		end
	end
end

# ╔═╡ a9f05e82-7f2e-4397-93b9-e73e5dde71a5
begin
	model = linear_regression(H, W)  # Simulated W and H with known params
end

# ╔═╡ 62822af0-7a8f-45ab-a71b-234aa9321e29
chain = sample(model, NUTS(0.65), 5_000);

# ╔═╡ 52952023-a1f3-4322-82a0-a8b3b27575d1
plot(chain)

# ╔═╡ 6ed1f638-ce27-4683-8c5c-9e285dcc0afc
describe(chain)

# ╔═╡ 7333c14b-d2fb-4188-bc4b-b0a721423203
begin
	# Skip warm-up and predict multiple targets for each set of sampled parameters
	# Returned predictions are set of fitted lines, so must be averaged
	function predict(chain, x; warmup=1000)
		 p = get_params(chain[warmup:end])
		 yhat = p.α' .+ (p.β' .* (H.-mean(H)))
	end
	yhats = predict(chain,H)
	yhat = mean(yhats, dims=2) # We could use this for plotting for the average line
end

# ╔═╡ 171979d3-30fc-4d7a-8f5b-bc72659bd182
begin
	scatter(H,W)
	scatter!(H,yhats, color=:red,legend = false)
end

# ╔═╡ bbbdeb65-486a-4799-869d-fa925a3dfec2


# ╔═╡ Cell order:
# ╠═b5995a3e-784d-11ec-2b4b-358722f2b5b8
# ╠═d74b4314-1fa0-47d0-a5bc-09377dc41e5d
# ╠═7636881c-2af3-4b5a-9a90-16dca35a6747
# ╠═1bd4f35f-d529-4a34-a729-944120f62a57
# ╠═413fd7c3-04fb-4894-b547-1eeede5d8b87
# ╠═f84e9d72-3896-41c9-b62f-e35240cfbb4d
# ╠═2e7b4337-fcc6-48ed-b10f-767804673253
# ╠═b4252618-c74e-4ffb-ba87-a49a98e6eea4
# ╠═0e9e8888-5a48-41dd-b88c-a75f5ecd8a78
# ╠═e8089a90-045d-4740-b875-113d387c9ab3
# ╠═250c92db-ce49-4f39-a12a-2e53283b8753
# ╠═2e1436c3-7a69-4e97-966e-5277d34a280c
# ╠═22f728a3-afdb-4545-88b2-1908e1bd0f8a
# ╠═466d3270-12d5-4bab-8a49-6a9159eb1020
# ╠═e004dad6-612c-41f2-9b6e-e3130265e89a
# ╠═b4a4528c-4e5c-403a-9229-1c59eb4df1b9
# ╠═580356ae-29ad-4ee1-be42-dd517f316e95
# ╠═0ca662fb-bfad-4a32-aec9-01d681f0a55a
# ╠═4a5233eb-58bb-41f8-beaf-d23cde3b8288
# ╠═a0dc0a49-a47f-4751-a8e6-b900b2f69131
# ╠═c12bd5e1-7646-4703-961d-b842b156351b
# ╠═03d9846f-8d65-47f2-8b1e-b8673f7aa51d
# ╠═8b7a662f-d9fa-43d8-bf0b-79643d1f97a2
# ╠═f4551cc9-a107-4aad-9a0d-8cee87d86d3d
# ╠═5351a562-e0e1-4527-8312-d0be46536400
# ╠═c3e5c772-5337-4a05-9952-c38c5eb1825e
# ╠═3ddb17de-7fa7-424d-9f9a-4cd01a682311
# ╠═a9f05e82-7f2e-4397-93b9-e73e5dde71a5
# ╠═62822af0-7a8f-45ab-a71b-234aa9321e29
# ╠═52952023-a1f3-4322-82a0-a8b3b27575d1
# ╠═6ed1f638-ce27-4683-8c5c-9e285dcc0afc
# ╠═7333c14b-d2fb-4188-bc4b-b0a721423203
# ╠═171979d3-30fc-4d7a-8f5b-bc72659bd182
# ╠═bbbdeb65-486a-4799-869d-fa925a3dfec2
