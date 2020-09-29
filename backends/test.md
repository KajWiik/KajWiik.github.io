# Testing

```julia
using BenchmarkTools

@btime sin(rand(100000))
```

$$ \alpha = \beta $$

```julia
using PyPlot
x = range(0, stop=6π, length=1000)
y = sin.(x)
plot(x, y)
gcf()
```
