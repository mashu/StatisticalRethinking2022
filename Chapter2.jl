### A Pluto.jl notebook ###
# v0.17.5

using Markdown
using InteractiveUtils

# ╔═╡ 54e4c02a-75e8-11ec-15a2-750ac5013cc1
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
    ])

    using Plots
	using StatsBase
	using StatsPlots
	using Turing
	using PlutoUI
end

# ╔═╡ df941df5-5ab5-4b4d-8b1c-aedf675ec84c
md"""
Code 2.1
"""

# ╔═╡ 3448b3a5-6dce-4cb5-a2e8-755240c58b5c
begin
	ways = [0,3,8,9,0]
	ways./sum(ways)
end

# ╔═╡ 53299309-2692-45f3-9f5c-3b9e463d1db3
md"""
Since multiplication and division are comutative, when we standardize does not matter, so prior can be numbers or counts. This is important for computing posterior by updating.

$\text{Plausability of p after Dnew} = \frac{(\text{ways p can produce Dnew}) (\text{prior plausability p})}{\text{sum of products in nominator}}$
"""

# ╔═╡ b609632c-cb99-413d-bb50-f5a0697b95ea

md"""
1. First we need to enlist all possible parameter values (proportions blue marbles to white marbles)
2. Each possible proportion can be more or less plausible
3. **Bayesian updating** starts with prior and assigns new plausability to each enlisted proportion (parameter value)
"""

# ╔═╡ fd58080a-292f-4cf5-b5c4-9de2a4e6b231
# In Julia Binomial(trials, probability)
pdf(Binomial(9,0.5), 6) # for datum 6
# Same as in R dbinom(6, size=9, prob=0,5)

# ╔═╡ 33744373-ec72-4098-aba9-9a8c089c12cf
# Prior from the Uniform(a,b) where a,b is interal and we take probability for datum 1:9
uniform_prior = pdf.(Uniform(0,1),0:0.01:1)

# ╔═╡ 971dfd7b-5615-4e1a-8b7c-1112f441a337
# Problem 2M1
begin
	a = [1,1,1] # 3xW
	b = [1,1,1,0] # 3xW 1xL
	c = [0,1,1,0,1,1,1] # 5xW 2xL
	p_grid = collect(0:0.01:1)
	prior = pdf.(Uniform(0,1),p_grid)
	liklihood_a = [pdf(Binomial(3,p),3) for p in p_grid]
	liklihood_b = [pdf(Binomial(4,p),3) for p in p_grid]
	liklihood_c = [pdf(Binomial(7,p),5) for p in p_grid]
	posterior_a = liklihood_a .* prior / sum(liklihood_a .* prior)
	posterior_b = liklihood_b .* prior / sum(liklihood_b .* prior)
	posterior_c = liklihood_c .* prior / sum(liklihood_c .* prior)
	plot(p_grid,posterior_a)
	plot!(p_grid, posterior_b, color=:blue)
	plot!(p_grid, posterior_c, color=:red)
end

# ╔═╡ 00903bdf-5588-4e9a-ba99-19f64677d98c
# Problem 2M1
let
	a = [1,1,1] # 3xW
	b = [1,1,1,0] # 3xW 1xL
	c = [0,1,1,0,1,1,1] # 5xW 2xL
	p_grid = collect(0:0.01:1)
	prior = [p < 0.5 ? 0 : pdf(Uniform(0,1),p) for p in p_grid]  # Tenary operator p<0.5
	liklihood_a = [pdf(Binomial(3,p),3) for p in p_grid]
	liklihood_b = [pdf(Binomial(4,p),3) for p in p_grid]
	liklihood_c = [pdf(Binomial(7,p),5) for p in p_grid]
	posterior_a = liklihood_a .* prior / sum(liklihood_a .* prior)
	posterior_b = liklihood_b .* prior / sum(liklihood_b .* prior)
	posterior_c = liklihood_c .* prior / sum(liklihood_c .* prior)
	plot(p_grid,posterior_a)
	plot!(p_grid, posterior_b, color=:blue)
	plot!(p_grid, posterior_c, color=:red)
end

# ╔═╡ 520e32c3-9073-4d55-b3da-bffa965ccf76
# 2M3
md"""
What we know

$Pr(land|Earth) = 1-0.7$

$Pr(land|Mars) = 1.0$

$Pr(Earth) = 0.5$

$Pr(Mars) = 0.5$

What we want to know is 

$Pr(Earth|land)$

Bayes rule would be

$Pr(Earth|land) = \frac{Pr(land|Earth)Pr(Earth)}{Pr(land)}$

We only need to know the probability of land, though land is just a normalization term across two globes, so it would include same thing as in nominator but for two globes.

$Pr(Earth|land) = \frac{Pr(land|Earth)Pr(Earth)}{Pr(land|Earth)Pr(Earth)+Pr(land|Mars)Pr(Mars)}$
"""

# ╔═╡ a1659173-8b30-442d-800c-ec9fbb87db52
(0.3*0.5)/((0.3*0.5)+(1.0*0.5))

# ╔═╡ 8acdad45-3e4e-415c-9c06-d2b38d902c0c
#2M4
md"""
What we know is three cards with sides Black (B) and white (W)

B/B
B/W
W/W

Show that the probablity of other side also being B is $\frac{2}{3}$

B/B 2 ways to produce B
B/W 1 way to produce B
W/W 0 ways to produce B

Total is 3 ways, so 2/3
"""

# ╔═╡ a8bef533-8cca-4cff-acdb-10770872f547
# 2M5
md"""
Four cards B/B B/W W/W and B/B

B/B 2 ways
B/B 2 ways
B/W 1 ways
W/W 0 ways

4/5 ways to produce second black
"""

# ╔═╡ 0d42bb17-1ce3-4410-af8b-cc87937dd7b5
# 2M6
md"""
We get a prior for this excercise

W/W 3 ways

B/W 2 ways

B/B 1 ways

Data are

B/B 2 ways to produce second black

B/W 1 ways

W/W 0 ways

After incorporating prior it is

B/B 2 ways * 1 ways = 2

B/W 1 ways * 2 ways = 2

W/W 0 ways * 3 ways = 0

There are 2 ways out of 4 to produce second black given that prior
"""

# ╔═╡ d7729a6e-000e-4ba0-acc7-218e11287472
#2M7
md"""
Two draws

B/B = 2 ways black and left cards are B/W or W/W which is 3 ways to produce white

B/W = 1 ways black left cards are B/B and W/W which is 2 ways to produce white

W/W = 0 ways black left cards are B/B and B/W which is 1 ways to produce white

2*3 = 6
1*2 = 2
0*1 = 0

So 6/8 ways to produce first black and second white
"""

# ╔═╡ 0d8e3e8e-dd5b-47ed-bf9a-b96d725844c3


# ╔═╡ d45b92ac-8d25-41ef-a12e-07fdf1258e03


# ╔═╡ Cell order:
# ╠═54e4c02a-75e8-11ec-15a2-750ac5013cc1
# ╠═df941df5-5ab5-4b4d-8b1c-aedf675ec84c
# ╠═3448b3a5-6dce-4cb5-a2e8-755240c58b5c
# ╠═53299309-2692-45f3-9f5c-3b9e463d1db3
# ╠═b609632c-cb99-413d-bb50-f5a0697b95ea
# ╠═fd58080a-292f-4cf5-b5c4-9de2a4e6b231
# ╠═33744373-ec72-4098-aba9-9a8c089c12cf
# ╠═971dfd7b-5615-4e1a-8b7c-1112f441a337
# ╠═00903bdf-5588-4e9a-ba99-19f64677d98c
# ╠═520e32c3-9073-4d55-b3da-bffa965ccf76
# ╠═a1659173-8b30-442d-800c-ec9fbb87db52
# ╠═8acdad45-3e4e-415c-9c06-d2b38d902c0c
# ╠═a8bef533-8cca-4cff-acdb-10770872f547
# ╠═0d42bb17-1ce3-4410-af8b-cc87937dd7b5
# ╠═d7729a6e-000e-4ba0-acc7-218e11287472
# ╠═0d8e3e8e-dd5b-47ed-bf9a-b96d725844c3
# ╠═d45b92ac-8d25-41ef-a12e-07fdf1258e03
