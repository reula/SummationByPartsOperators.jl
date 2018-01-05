using Base.Test
using SummationByPartsOperators

D_test_list = (MattssonSvärdShoeybi2008(), Mattsson2014(), MattssonAlmquistCarpenter2014Extended())
Di_test_list = (MattssonSvärdNordström2004(),)


# Test symmetry and eigenvalues
for source_D in D_test_list, source_Di in Di_test_list, acc_order in 2:2:8, T in (Float32,Float64)
    xmin = -one(T)
    xmax = 2*one(T)
    N = 101
    der_order = 1

    D = try
        derivative_operator(source_D, der_order, acc_order, xmin, xmax, N)
    catch
        nothing
    end

    if D != nothing
        @inferred mass_matrix(D)
        H = mass_matrix(D)

        for order in 2:2:8
            Di = try
                dissipation_operator(source_Di, D, order)
            catch
                nothing
            end
            if Di != nothing
                println(DevNull, Di)
                println(DevNull, Di.coefficients)
                HDi = H*full(Di)
                @test norm(HDi - HDi') < 10*eps(T)
                @test minimum(real, eigvals(HDi)) > -10*eps(T)
            end
        end
    end
end


# Compare mul! with β=0 and mul! without β.
for T in (Float32, Float64), order in (2,4,6,8)
    xmin = zero(T)
    xmax = 5*one(T)
    N = 51
    source = MattssonSvärdShoeybi2008()
    D = derivative_operator(source, 1, order, xmin, xmax, N)
    x = grid(D)
    u = x.^5
    dest1 = zeros(u)
    dest2 = zeros(u)

    Di_serial = dissipation_operator(MattssonSvärdNordström2004(), D, order, Val{:serial}())
    Di_threads= dissipation_operator(MattssonSvärdNordström2004(), D, order, Val{:threads}())
    Di_full   = full(Di_serial)

    mul!(dest1, Di_serial, u, one(T), zero(T))
    mul!(dest2, Di_serial, u, one(T))
    @test all(i->dest1[i] ≈ dest2[i], eachindex(u))
    mul!(dest1, Di_threads, u, one(T), zero(T))
    mul!(dest2, Di_threads, u, one(T))
    @test all(i->dest1[i] ≈ dest2[i], eachindex(u))
    dest3 = Di_serial*u
    @test all(i->dest1[i] ≈ dest3[i], eachindex(u))
    dest3 = Di_full*u
    @test all(i->isapprox(dest1[i], dest3[i], atol=500000*eps(T)), eachindex(u))
end
