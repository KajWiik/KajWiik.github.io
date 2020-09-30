<!--This file was generated, do not modify it.-->
# **8.** Example

[![](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/KajWiik/KajWiik.github.io/gh-pages?filepath=dev/generated/example.ipynb)
[![](https://img.shields.io/badge/show-nbviewer-579ACA.svg)](https://nbviewer.jupyter.org/github/KajWiik/KajWiik.github.io/blob/gh-pages/dev/generated/example.ipynb)

This is an example generated with Literate based on this
source file: [`example.jl`](https://github.com/KajWiik/KajWiik.github.io/blob/master/examples/example.jl).
You are seeing the
HTML-output which Documenter have generated based on a markdown
file generated with Literate. The corresponding notebook
can be viewed in [nbviewer](http://nbviewer.jupyter.org/) here:
[`example.ipynb`](https://nbviewer.jupyter.org/github/KajWiik/KajWiik.github.io/blob/gh-pages/dev/generated/example.ipynb),
and opened in [binder](https://mybinder.org/) here:
[`example.ipynb`](https://mybinder.org/v2/gh/KajWiik/KajWiik.github.io/gh-pages?filepath=dev/generated/example.ipynb),
and the plain script output can be found here: [`example.jl`](./example.jl).

It is recommended to have the [source file](https://github.com/KajWiik/KajWiik.github.io/blob/master/examples/example.jl)
available when reading this, to better understand how the syntax in the source file
corresponds to the output you are seeing.

### Basic syntax
The basic syntax for Literate is simple, lines starting with `# ` is interpreted
as markdown, and all the other lines are interpreted as code. Here is some code:

```julia:ex1
x = 1//3
y = 2//5
```

In markdown sections we can use markdown syntax. For example, we can
write *text in italic font*, **text in bold font** and use
[links](https://www.youtube.com/watch?v=dQw4w9WgXcQ).

It is possible to filter out lines depending on the output using the
`#md`, `#nb`, `#jl` and `#src` tags (see [Filtering Lines](@ref)):
- This line starts with `#md` and is thus only visible in the markdown output.

The source file is parsed in chunks of markdown and code. Starting a line
with `#-` manually inserts a chunk break. For example, if we want to
display the output of the following operations we may insert `#-` in
between. These two code blocks will now end up in different
`@example`-blocks in the markdown output, and two different notebook cells
in the notebook output.

```julia:ex2
x + y
```

```julia:ex3
x * y
```

### Output Capturing
Code chunks are by default placed in Documenter `@example` blocks in the generated
markdown. This means that the output will be captured in a block when Documenter is
building the docs. In notebooks the output is captured in output cells, if the
`execute` keyword argument is set to true. Output to `stdout`/`stderr` is also
captured.

!!! note
    Note that Documenter currently only displays output to `stdout`/`stderr`
    if there is no other result to show. Since the vector `[1, 2, 3, 4]` is
    returned from `foo`, the printing of `"This string is printed to stdout."`
    is hidden.

```julia:ex4
function foo()
    println("This string is printed to stdout.")
    return [1, 2, 3, 4]
end

foo()
```

Just like in the REPL, outputs ending with a semicolon hides the output:

```julia:ex5
1 + 1;
```

Both Documenter's `@example` block and notebooks can display images. Here is an example
where we generate a simple plot using the
[Plots.jl](https://github.com/JuliaPlots/Plots.jl) package

```julia:ex6
using PyPlot

plot(rand(10))

savefig(joinpath(@OUTPUT, "test.svg")) # hide
```

\figalt{foo1}{test.svg}

### Custom processing

It is possible to give Literate custom pre- and post-processing functions.
For example, here we insert a placeholder value `x = 123` in the source, and use a
preprocessing function that replaces it with `y = 321` in the rendered output.

```julia:ex7
x = 123
```

In this case the preprocessing function is defined by

```julia:ex8
function pre(s::String)
    s = replace(s, "x = 123" => "y = 321")
    return s
end
```

### [Documenter.jl interaction](@id documenter-interaction)

In the source file it is possible to use Documenter.jl style references,
such as `@ref` and `@id`. These will be filtered out in the notebook output.
For example, [here is a link](@ref documenter-interaction), but it is only
visible as a link if you are reading the markdown output. We can also
use equations:

```math
\int_\Omega \nabla v \cdot \nabla u\ \mathrm{d}\Omega = \int_\Omega v f\ \mathrm{d}\Omega
```

using Documenters math syntax. Documenters syntax is automatically changed to
`\begin{equation} ... \end{equation}` in the notebook output to display correctly.

