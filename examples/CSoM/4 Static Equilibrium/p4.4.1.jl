using CSoM

ProjDir = dirname(@__FILE__)

data = Dict(
  # Frame(nels, nn, ndim, nst, nip, finite_element(nod, nodof))
  :struc_el => Frame(6, 6, 2, 1, 1, Line(2, 3)),
  :properties => [
    5.0e9 6.0e4;
    1.0e9  2.0e4],
  :etype => [1, 1, 1, 2, 2, 2],
  :x_coords => [0.0, 6.0, 6.0, 12.0, 12.0, 14.0],
  :y_coords => [0.0, 0.0, -4.0, 0.0, -5.0, 0.0],
  :g_num => [
    1 2 4 3 3 5;
    2 4 6 2 4 4],
  :support => [
    (1, [0 0 1]),
    (3, [0 0 0]),
    (5, [0 0 0])
    ],
  :loaded_nodes => [
    (1, [0.0 -60.0 -60.0]),
    (2, [0.0 -180.0 -80.0]),
    (4, [0.0 -140.0 133.33]),
    (6, [0.0 -20.0 6.67])
    ],
  :penalty => 1e19,
  :eq_nodal_forces_and_moments => [
    (1, [0.0 -60.0 -60.0 0.0 -60.0 60.0]),
    (2, [0.0 -120.0 -140.0 0.0 -120.0 140.0]),
    (3, [0.0 -20.0 -6.67 0.0 -20.0 6.67])
  ]
)

data |> display
println()

@time m = FE4_4(data)
println()

if VERSION.minor > 5
  println("Displacements:")
  m.displacements' |> display
  println()

  println("Actions:")
  m.actions' |> display
  println()
else
  using DataFrames
  dis_df = DataFrame(
    x_translations = m.displacements'[:, 1],
    y_translations = m.displacements'[:, 2],
    rotations = m.displacements'[:, 3]
  )
  fm_df = DataFrame(
    x1_Force = m.actions[1, :],
    y1_Force = m.actions[2, :],
    z1_Moment = m.actions[3, :],
    x2_Force = m.actions[4, :],
    y2_Force = m.actions[5, :],
    z2_Moment = m.actions[6, :]
  )
  # Correct element forces and moments for equivalent nodal
  # forces and moments introduced for loading between nodes
  if :eq_nodal_forces_and_moments in keys(data)
    eqfm = data[:eq_nodal_forces_and_moments]
    k = data[:struc_el].fin_el.nod * data[:struc_el].fin_el.nodof

    for t in eqfm
      for i in 1:k
        fm_df[t[1], i] -= t[2][i]
      end
    end
  end
    
  display(dis_df)
  println()
  display(fm_df)
  
  using Plots
  gr(size=(400,600))

  p = Vector{Plots.Plot{Plots.GRBackend}}(3)
  titles = ["p4.4.1 rotations", "p4.4.1 y shear force", "p4.4.1 z moment"]
  moms = vcat(fm_df[:, :z1_Moment], fm_df[end, :z2_Moment])
  fors = vcat(fm_df[:, :y1_Force], fm_df[end, :y2_Force])
  x_coords = data[:x_coords]
  
  p[1] = plot(m.displacements[3,:], ylim=(-0.002, 0.002),
    xlabel="node", ylabel="rotation [radians]", color=:red,
    line=(:dash,1), marker=(:circle,4,0.8,stroke(1,:black)),
    title=titles[1], leg=false)
  p[2] = plot(fors, lab="y Shear force", ylim=(-150.0, 250.0),
    xlabel="node", ylabel="shear force [N]", color=:blue,
    line=(:dash,1), marker=(:circle,4,0.8,stroke(1,:black)),
    title=titles[2], leg=false)
  p[3] = plot(moms, lab="z Moment", ylim=(-10.0, 150.0),
    xlabel="node", ylabel="z moment [Nm]", color=:green,
    line=(:dash,1), marker=(:circle,4,0.8,stroke(1,:black)),
    title=titles[3], leg=false)

  plot(p..., layout=(3, 1))
  savefig(ProjDir*"/p4.4.1.png")
  
end