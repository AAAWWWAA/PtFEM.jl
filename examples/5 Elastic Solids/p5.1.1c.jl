using Compat, Base.Test, CSoM

include(Pkg.dir("CSoM", "examples", "5 Elastic Solids", "FE5_1.jl"))

data = @compat Dict(
  # Plane(ndim, nst, nxe, nye, nip, direction, finite_element(nod, nodof), axisymmetric)
  :element_type => Plane(2, 3, 2, 2, 1, :x, Triangle(3, 2), false),
  :properties => [1.0e6 0.3;],
  :x_coords => [0.0,  0.5,  1.0],
  :y_coords => [0.0,  -0.5,  -1.0],
  :support => [
    (1, [0 1]),
    (4, [0 1]),
    (7, [0 0]),
    (8, [1 0]),
    (9, [1 0])
    ],
  :loaded_nodes => [
    (1, [0.0 -1//4]),
    (2, [0.0 -1//2]),
    (3, [0.0 -1//4])
    ]
)

@time m = FE5_1(data)

@test_approx_eq_eps m.loads [0.0, -9.100000000000005e-7, 1.950000000000001e-7,
-9.100000000000006e-7, 3.900000000000002e-7, -9.1e-7, -4.5500000000000025e-7,
1.950000000000002e-7, -4.550000000000004e-7, 3.900000000000004e-7,
-4.5499999999999993e-7, 1.9500000000000038e-7, 3.9000000000000045e-7] eps()