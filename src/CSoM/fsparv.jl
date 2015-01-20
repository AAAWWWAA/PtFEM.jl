#=
@doc doc"""
  This subroutine assembles element matrices into a symmetric skyline
  global matrix.

  fsparv(kv, km, g, kdiag)

  where:
    kv::Vector{Float64}   : Skyline vector of global stiffness matrix
    km::Matrix{Float64}   : Stiffness matrix
    g::Vector{Int64}      : Global coordinate vector
    kdiag::Vector{Int64}  : Diagonal element vector
  """ ->
=#
function fsparv!(kv::Vector{Float64}, km::Matrix{Float64},
  g::Vector{Int64}, kdiag::Vector{Int64})
  
  ndof = size(g, 1)
  for i in 1:ndof
    k = g[i]
    if k !== 0
      for j in 1:ndof
        if g[j] !== 0
          iw = k - g[j]
          if iw >= 0
            ival = kdiag[k] - iw
            kv[ival] += km[i, j]
          end
        end
      end
    end
  end
end