```julia
# Loading packages as we have to precompile everything in the host
using Distributed, Printf, DataStructures, HCubature, Cuba, ForwardDiff, Roots, Dates, PyPlot, LaTeXStrings, PyCall, StructArrays
import PhysicalConstants.CODATA2018: c_0
import Unitful: ustrip

# detect if using SLURM
const IN_SLURM = "SLURM_JOBID" in keys(ENV)

# load ClusterManagers if needed

IN_SLURM && using ClusterManagers

# Create parallel julia processes
if IN_SLURM
    pids = addprocs_slurm(parse(Int, ENV["SLURM_NTASKS"]))
    print("\n")
else
    pids = addprocs()
end

# See ids of our workers. Should be same length as SLURM_NTASKS
# The output of this `println` command will appear in the
# SLURM output file julia_in_parallel.output
println("Workers: ", workers())

    @everywhere using  Distributed, Printf, DataStructures, HCubature, Cuba, ForwardDiff, Roots, Dates, PyPlot, LaTeXStrings, PyCall, StructArrays
    @everywhere import PhysicalConstants.CODATA2018: c_0
    @everywhere import Unitful: ustrip
    
@everywhere begin
    const c = ustrip(c_0)
    const GHz = 1e9

    # Gaussian waist radius
    ω₀f(λ, Tₑ, θₛ) = √(Tₑ/8.686)*λ/(π*deg2rad(θₛ))
    ω₀f(λ) = ω₀f(λ, 12.0, 7.0);

    # Gaussian beam radius
    ω(z, λ, ω₀, z₀) = ω₀*√(1 + (λ*(z + z₀)/(π*ω₀^2))^2)
    ω(z, λ, z₀) = ω(z, λ, ω₀f(λ), z₀);

    # Intersection between chopper wheel at an angle of 𝛼 and Gaussian beam
    function gauss_x(φ, λ, ω₀, z₀, α, n) 
        return -n*cos(φ)*(n*z₀*λ^2*cos(φ)*tan(α) + π*ω₀*√(z₀^2*λ^2 - (n*λ*ω₀*cos(φ)*tan(α))^2 + (π*ω₀^2)^2))/((n*λ*cos(φ)*tan(α))^2 - (π*ω₀)^2)
    end

    # Radial position of the beam where the 2ω₀ radius
    # coincides with the rim of the chopper.
    function beam_position(λ, z₀, α, Rᶜ, n)
        𝟐ω₀ᶜ = gauss_x(deg2rad(0.0), λ, ω₀f(λ), z₀, α, n)/cos(α);
        return Rᶜ - 𝟐ω₀ᶜ # == x₀ᶜ
    end

    # Helper functions
    r²(rᶜ, φᶜ, α, x₀ᶜ) = ((rᶜ*cos(φᶜ) - x₀ᶜ)*cos(α))^2 + (rᶜ*sin(φᶜ))^2
    r²(rᶜ, φᶜ, x₀ᶜ) = r²(rᶜ, φᶜ, deg2rad(45.0), x₀ᶜ)
    z(rᶜ, φᶜ, α, x₀ᶜ) = (rᶜ*cos(φᶜ) - x₀ᶜ)*sin(α)
    z(rᶜ, φᶜ, x₀ᶜ) = z(rᶜ, φᶜ, deg2rad(45.0), x₀ᶜ);

    # Normalized electric field on chopper blade.
    function Ef(rᶜ, φᶜ, λ, ω₀, x₀ᶜ, z₀)
        return ω₀/ω(z(rᶜ, φᶜ, x₀ᶜ), λ, z₀)*exp(-r²(rᶜ, φᶜ, x₀ᶜ)/ω(z(rᶜ, φᶜ, x₀ᶜ), λ, z₀)^2)
    end
    Ef(rᶜ, φᶜ, λ, x₀ᶜ, z₀) = Ef(rᶜ, φᶜ, λ, ω₀f(λ), x₀ᶜ, z₀);

    # Corresponding relative intensity.
    If(rᶜ, φᶜ, λ, ω₀, x₀ᶜ, z₀) = Ef(rᶜ, φᶜ, λ, ω₀, x₀ᶜ, z₀)^2
    If(rᶜ, φᶜ, λ, x₀ᶜ, z₀) = If(rᶜ, φᶜ, λ, ω₀f(λ), x₀ᶜ, z₀);

    # Cuba.jl helper functions
    function cubascale(x, lower, upper)
        ndim = length(lower)
        scaledx = zeros(Float64, ndim)
        for i in 1:ndim
            scaledx[i] = lower[i] + x[i]*(upper[i] - lower[i])
        end
        return scaledx
    end

    function cubajacobian(lower, upper)
        jacobian = 1.0
        ndim = length(lower)
        for i in 1:ndim
            jacobian *= (upper[i] - lower[i])
        end
        return jacobian
    end   

    function If_integrand_cuba!(x, f, lower, upper, λ, x₀ᶜ, z₀)
        scaledx = cubascale(x, lower, upper)
        f[1] = scaledx[1]*If(scaledx[1], scaledx[2],  λ, x₀ᶜ, z₀)
    end

    function powers(Rᶜ₀, Rᶜ, λ, x₀ᶜ, z₀)

        initdiv = 200 # Initial number of segments
        
        Pφ = Float64[]
        Δφ = deg2rad(90.0) 

        # Integrand for HCubature, HCubature requires that the integrand accepts single vector-type argument
        If_integrand(x) = x[1]*If(x[1], x[2], λ, x₀ᶜ, z₀);

        lower = [0.0, 0.0]; upper = [4*Rᶜ, 2π];

        # Total power of the beam
        Pmax = hcubature(If_integrand, lower, upper, initdiv = initdiv)[1]

        for φ = deg2rad(-135.0):deg2rad(1.0):deg2rad(45.0)
            lower = [Rᶜ₀, φ]; upper = [Rᶜ, φ + Δφ]
            push!(Pφ, hcubature(If_integrand, lower, upper, initdiv = initdiv)[1])
        end
        
        return Pφ/Pmax
    end

    function powers_cuba(Rᶜ₀, Rᶜ, λ, x₀ᶜ, z₀)
        
        Pφ = Float64[]
        Δφ = deg2rad(90.0) 

        lower = [0.0, 0.0]; upper = [4*Rᶜ, 2π];

        #If_integrand_cuba!(x, f) = If_integrand_cuba!(x, f, lower, upper, λ, x₀ᶜ, z₀)
        Pmax = cubajacobian(lower, upper)*cuhre((x, f) -> f = If_integrand_cuba!(x, f, lower, upper, λ, x₀ᶜ, z₀), 2).integral[1];

        for φ = deg2rad(-135.0):deg2rad(1.0):deg2rad(45.0)
            lower = [Rᶜ₀, φ]; upper = [Rᶜ, φ + Δφ]
            j = cubajacobian(lower, upper)
            push!(Pφ, j*cuhre((x, f) -> f = If_integrand_cuba!(x, f, lower, upper, λ, x₀ᶜ, z₀), 2).integral[1])
        end
        
        return Pφ/Pmax
    end

    function beam_subtended_half_angle(λ, z₀, α, x₀ᶜ, n)
        # If chopper axis is inside the beam, abort half angle calculation 
        if x₀ᶜ <= abs(gauss_x(deg2rad(180.0), λ, ω₀f(λ), z₀, α, n)/cos(α))
            return -1.0
        else
            f(φ) = gauss_x(φ, λ, ω₀f(λ), z₀, α, n)/cos(α)
            g(φ) = n*ω(f(φ), λ, z₀)*sin(φ)

            Df(φ) = ForwardDiff.derivative(f, φ)
            Dg(φ) = ForwardDiff.derivative(g, φ)
            a(φ) = Dg(φ)/Df(φ)
            
            tangenteq(φ) = g(φ) - a(φ)*(f(φ) + x₀ᶜ)
            Dtangenteq(tangenteq) = φ -> ForwardDiff.derivative(tangenteq, float(φ));

            φ_tangent = find_zero((tangenteq, Dtangenteq(tangenteq)), deg2rad(170), Roots.Newton())

            return atan(a(φ_tangent))
        end
    end

    function efficiencies(Pφ, beam_half_angle::Integer)
        # r[46] = -45.0 
        # r[136] = 45.0
        
        # If chopper axis is inside the beam, set power to zero (chopper is unusable) 
        if beam_half_angle < 0
            P2ω₀ = 0.0
        else
            P2ω₀ = sum(Pφ[46 + beam_half_angle : 136 - beam_half_angle])
        end
        Pon = sum(Pφ[46:136]); Poff = sum(Pφ[1:45]) + sum(Pφ[137:end])
        return ((Pon - Poff)/90.0, P2ω₀/90.0)
    end

    efficiencies(Pφ, beam_half_angle::AbstractFloat) = efficiencies(Pφ, round(Int, rad2deg(beam_half_angle)))
    
    function plot_beam_switching(P, Rᶜ, band, z₀, α, x₀ᶜ, n, ηgo, η2ω₀, β)
        r = collect(-135.0:1.0:45.0) .+ 45.0
        Pideal = 90.0; # Power is calculated in 1 deg steps, so normalized ideal power is 90.0
        Pon = sum(P[46:136])
        Poff = sum(P[1:45]) + sum(P[137:end])

        if β == -1
            Ω₂ = 45
        else
            Ω₂ = round(Int, rad2deg(beam_subtended_half_angle(0.3/band, z₀, α, x₀ᶜ, n)))
        end
        
        figure()
        plot(r, P, color = "black")
        fill_between(r, 0, P, where = abs.(r) .<= 45.0, facecolor = "green", label = "OK")
        fill_between(r, 0, P, where = (abs.(r) .> 45.0 - Ω₂) .& (abs.(r) .<= 45.0), facecolor = "orange", label = L"2\omega_0")
        fill_between(r, 0, P, where = abs.(r) .>= 45.0, facecolor = "red", label = "Off")
        ax = gca()
        ax.xaxis.set_major_locator(matplotlib.ticker.MultipleLocator(45.0))
        grid(which = "major", axis = "both", linestyle = "--")
        xlabel("Chopper angle")
        title(@sprintf("Rᶜ = %d mm, focus = %d mm, f = %d GHz",Rᶜ*1000, z₀*1000, band))
        textstr = @sprintf("\$\\eta_{\\mathrm{go}}\$ = %.2f\n\$\\eta_{2\\omega_0}\$ = %.2f",ηgo, η2ω₀)

        # place a text box in upper left in axes coords
        ax.text(0.025, 0.925, textstr, transform=ax.transAxes, fontsize=10, verticalalignment="top", bbox=Dict("facecolor"=>"white", "alpha"=>0.7))
        
        legend()
    end

    function plot_blade(bands, Rᶜ, z₀, α, x₀ᶜ, n, η, β)
        φ = 0:deg2rad(1):2π
        figure()
        # Plot beams
        for band in bands # in GHz
            λ = 0.3/band
            x = gauss_x.(φ, λ, ω₀f(λ), z₀, α, n)/cos(α)
            y = n*ω.(x, λ, ω₀f(λ), z₀).*sin.(φ);
            plot(x .+ x₀ᶜ, y, label = @sprintf("%d GHz", band))
            axis("equal")
        end
        plot(x₀ᶜ, 0, marker = "+", color = "k")
        
        # Plot the blade
        plot([0.0, Rᶜ*cos(π/4)], [0.0, Rᶜ*sin(π/4)], color = "k")
        plot([0.0, Rᶜ*cos(π/4)], [0.0, -Rᶜ*sin(π/4)], color = "k")
        ax = gca()
        patch = pyimport("matplotlib.patches")
        c = patch.Arc([0.0, 0.0], 2*Rᶜ, 2*Rᶜ, theta1 = -45, theta2 = 45)
        ax.add_artist(c)
        
        # Plot beam subtended angle
        if β != -1.0
            plot([0.0, Rᶜ*cos(β)], [0.0, Rᶜ*sin(β)], color = "k", linestyle = "--", linewidth = 1)
            plot([0.0, Rᶜ*cos(β)], [0.0, -Rᶜ*sin(β)], color = "k", linestyle = "--", linewidth = 1)
        end
        
        xlabel("[m]")
        ylabel("[m]")
        
        title(@sprintf("%d\$\\omega_0\$ contours, chopper radius %d mm, %d mm from focus", round(Int, n), round(Int, Rᶜ*1000), round(Int, z₀*1000)))
        
        textstr = ""
        for i in η
            textstr *= @sprintf("%d GHz:\n\$\\eta_{\\mathrm{go}}\$ = %.2f, \$\\eta_{2\\omega_0}\$ = %.2f\n", i[1], i[2], i[3])
        end
        textstr = textstr[1:end-1]
        
        # place a text box in upper left in axes coords
        ax.text(0.025, 0.975, textstr, transform=ax.transAxes, fontsize=8.5, verticalalignment="top", bbox=Dict("facecolor"=>"white", "alpha"=>0.7))
        
        grid(true, linestyle="--")
        legend();
    end
end # @everywhere
R_start = 0.2
R_step = 0.02
#R_step = 0.4
R_stop = 0.5

focus_start = 0.0
focus_step = 0.02
#focus_step = 0.2
focus_stop = 0.2

@everywhere begin
    #const bands = (86,)
    const bands = (22, 37, 43, 86)
    const α = deg2rad(45.0)
    const n = 2.0
    const Rᶜ₀ = 0.0
end

Rrange = R_start:R_step:R_stop
z₀range = focus_start:focus_step:focus_stop
@printf("%d jobs\n", length(Rrange)*length(z₀range))
# 756 jobs

out = pmap((R = R, z₀ = z₀) for R in Rrange, z₀ in z₀range) do i
    data = DefaultDict(DefaultDict(Dict))

    # Calculate beam position at lowest frequency
    x₀ᶜ = beam_position(maximum(c./(bands.*1e9)), i.z₀, α, i.R, n)
    η = []
    data = []
    β = 0.0
    for band in bands
        @show λ = c/(band*1e9)

        P = powers(Rᶜ₀, i.R, λ, x₀ᶜ, i.z₀)

        β = beam_subtended_half_angle(λ, i.z₀, α, x₀ᶜ, n)
        
        @show i.R i.z₀ β
        @show η_go, η2ω₀ = efficiencies(P, β)
#        data[i.R][i.z₀][band] = (x₀ᶜ = x₀ᶜ, η_go = η_go, η2ω₀ = η2ω₀, P = P, β = β)
        push!(data, (radius = i.R, focus = i.z₀, band = band, x₀ᶜ = x₀ᶜ, η_go = η_go, η2ω₀ = η2ω₀, P = P, β = β))
        println("After setting data")
        plot_beam_switching(P, i.R, band, i.z₀, α, x₀ᶜ, n, η_go, η2ω₀, β)
        println("After plot_beam_switching")
        push!(η, [band, η_go, η2ω₀])
        savefig(@sprintf("beam_switching_R=%d_z0=%d_f=%d.pdf", round(Int, i.R*1000), round(Int, i.z₀*1000), round(Int, band))) 
    end
    β = beam_subtended_half_angle(maximum(c./(bands.*1e9)), i.z₀, α, x₀ᶜ, n)
    plot_blade(bands, i.R, i.z₀, α, x₀ᶜ, n, η, β)
    savefig(@sprintf("blade_R=%d_z0=%d.pdf", round(Int, i.R*1000), round(Int, i.z₀*1000))) 
    data
end

data = hcat(out...) |> vec |> StructArray
using JLD2
@save "efficiencies-"*Dates.format(now(), "yyyy-mm-ddTHH:MM:SS")*".jld2" data

rmprocs(pids)
println("procs removed")
```
