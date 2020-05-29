using JLD, Printf, StructArrays
basepath = "localhost:8000/assets/chopper"
R_start = 0.2
R_step = 0.02
#R_step = 0.4
R_stop = 0.5

focus_start = 0.0
focus_step = 0.02
#focus_step = 0.2
focus_stop = 0.2


data = load("efficiencies.jld")["data\n"]
function print_bladecell(io, R, z, effs, basepath)
    #blade_R=440_z0=100.pdf
    print(io, "<td><a href=$basepath/", @sprintf("blade_R=%d_z0=%d.pdf ", round(Int, R*1000), round(Int, z*1000)))
    print(io, "title=\"η2ω₀:")
    for band in (22, 37, 43, 86)     
        print(io, @sprintf("&#10;%d GHz: %.2f", band, effs.η2ω₀[band]))
    end
    print(io, "&#10;ηgo:")
    for band in (22, 37, 43, 86)     
        print(io, @sprintf("&#10;%d GHz: %.2f", band, effs.η_go[band]))
    end
    println(io,"\">PDF</a></td>")
end

function print_switchcell(io, R, z, effs, basepath)
    # beam_switching_R=360_z0=140_f=22.pdf
    print(io, "<td>")
    for band in (22, 37, 43, 86)     
        print(io, "<a href=$basepath/", @sprintf("beam_switching_R=%d_z0=%d_f=%d.pdf ", round(Int, R*1000), round(Int, z*1000), band))
        print(io, @sprintf("title=\"%d GHz&#10;η2ω₀=%.2f&#10;ηgo=%.2f\">%d GHz </a>", band, effs.η2ω₀[band], effs.η_go[band], band))
    end
    println(io,"</td>")

end

open("blade.html", "w") do blade
    open("switch.html", "w") do switch
        
        Rrange = R_start:R_step:R_stop
        z₀range = focus_start:focus_step:focus_stop

        println(blade, "<table>")
        println(switch, "<table>")

        println(blade, "<tr>\n<td></td>")
        println(switch, "<tr>\n<td></td>")
        for z₀ in z₀range
            println(blade, @sprintf("<th scope=\"col\">z₀=%d</th>", round(Int, z₀*1000)))
            println(switch, @sprintf("<th scope=\"col\">z₀=%d</th>", round(Int, z₀*1000)))
        end
        println(blade, "</tr>")
        println(switch, "</tr>")
        
        for R in Rrange
            println(blade, "<tr>")
            println(switch, "<tr>")

            println(blade, @sprintf("<th scope=\"row\">R=%d</th>", round(Int, R*1000)))
            println(switch, @sprintf("<th scope=\"row\">R=%d</th>", round(Int, R*1000)))

            for z₀ in z₀range
                η2ω₀ = Dict()
                η_go = Dict()
                for band in (22, 37, 43, 86)
                    η2ω₀[band] = data[(data.radius .== R) .& (data.focus .== z₀) .& (data.band .== band)].η2ω₀[1]
                    η_go[band] = data[(data.radius .== R) .& (data.focus .== z₀) .& (data.band .== band)].η_go[1]
                end
                print_bladecell(blade, R, z₀, (η2ω₀ = η2ω₀, η_go = η_go), basepath)
                print_switchcell(switch, R, z₀, (η2ω₀ = η2ω₀, η_go = η_go), basepath)
            end
            println(blade, "</tr>")
            println(switch, "</tr>")
        end
        println(blade, "</table>")
        println(switch, "</table>")
    end
end

