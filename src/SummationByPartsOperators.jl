__precompile__()

module SummationByPartsOperators

using ArgCheck
using Parameters
using StaticArrays

import Base: *
import PolynomialBases: integrate


# types
abstract type AbstractDerivativeOperator{T} end
abstract type AbstractDerivativeCoefficients{T} end
abstract type AbstractMassMatrix{T} end


# source files
include("periodic_operators.jl")


# exports
export PeriodicDerivativeOperator
export derivative_order, accuracy_order
export mul!
export periodic_central_derivative_operator

end # module
