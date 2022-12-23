using Scanner, Test

@testset "Scanner.jl" begin
  node = findfirst(".//interface[@name = \"wl_display\"]", xroot[])
  itf = Interface(node)
  @test length(itf.enums) == 1
  @test length(itf.requests) == 2
  @test length(itf.events) == 2
  @test !isnothing(itf.description)
  @test itf.version == v"1"
end;
