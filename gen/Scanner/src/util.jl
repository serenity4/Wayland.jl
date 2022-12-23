function remove_linenums!(ex::Expr)
  Base.remove_linenums!(ex)
  Meta.isexpr(ex, :macrocall) && (ex.args[2] = nothing)
  ex
end
