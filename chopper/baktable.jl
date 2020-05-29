R_start = 0.2
R_step = 0.02
#R_step = 0.4
R_stop = 0.5

focus_start = 0.0
focus_step = 0.02
#focus_step = 0.2
focus_stop = 0.2

Rrange = R_start:R_step:R_stop
z₀range = focus_start:focus_step:focus_stop


function cell(io, R, z₀, effs, basepath)
    println(io, "<td><a href=$basepath/
for R in Rrange, z₀ in z₀range
    
