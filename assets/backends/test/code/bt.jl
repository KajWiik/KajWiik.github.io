# This file was generated, do not modify it. # hide
using BenchmarkTools

@btime sin.(rand(100000))