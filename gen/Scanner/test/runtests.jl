using Scanner, Test

@testset "Scanner.jl" begin
  node = findfirst(".//interface[@name = \"wl_display\"]", xroot[])
  itf = Interface(node)
  @test length(itf.enums) == 1
  @test length(itf.requests) == 2
  @test length(itf.events) == 2
  @test !isnothing(itf.description)
  @test itf.version == v"1"

  itfs = Interface.(findall(".//interface", xroot[]))
  @test length(itfs) ≥ 22
  @test sum(itf -> length(itf.requests), itfs) ≥ 64
  @test sum(itf -> length(itf.events), itfs) ≥ 55
  @test sum(itf -> length(itf.enums), itfs) ≥ 25
end;
