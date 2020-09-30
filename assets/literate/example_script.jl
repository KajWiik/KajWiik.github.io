# This file was generated, do not modify it.

x = 1//3
y = 2//5

x + y

x * y

function foo()
    println("This string is printed to stdout.")
    return [1, 2, 3, 4]
end

foo()

1 + 1;

using PyPlot

plot(rand(10))

savefig(joinpath(@OUTPUT, "test.svg")) # hide

x = 123

function pre(s::String)
    s = replace(s, "x = 123" => "y = 321")
    return s
end

