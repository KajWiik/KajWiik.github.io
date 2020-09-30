# This file was generated, do not modify it. # hide
function pre(s::String)
    s = replace(s, "x = 123" => "y = 321")
    return s
end