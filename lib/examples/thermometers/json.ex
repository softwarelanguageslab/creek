# defmodule ThermometerMeta do
#   use Creek
#   use Creek.MetaBehaviour

#   def is_xml?({:xml, _}), do: true
#   def is_xml?(_), do: false

#   def is_json?({:json, _}), do: true
#   def is_json?(_), do: false

#   def xml_to_float({:xml, value}), do: value
#   def json_to_float({:json, value}), do: value

#   fragment not_next as filter(&(not match?({_, :next, _, _}, &1)))
#                        ~> base
#                        ~> effects

#   fragment next as filter(&match?({_, :next, _, _}, &1))
#                    ~> map(fn {state, :next, encoded, from} ->
#                      decoded =
#                        cond do
#                          is_xml?(encoded) -> xml_to_float(encoded)
#                          is_json?(encoded) -> json_to_float(encoded)
#                          true -> encoded
#                        end

#                      {state, :next, decoded, from}
#                    end)
#                    ~> base()
#                    ~> effects()

#   fragment encoding_meta(
#              as dup
#                 ~> (next ||| not_next)
#                 ~> merge
#            )

#   defdag operator(src, snk) do
#     src
#     ~> base
#     ~> effects
#     ~> snk
#   end

#   defdag source(src, snk) do
#     src
#     ~> encoding_meta
#     ~> snk
#   end

#   defdag sink(src, snk) do
#     src
#     ~> base
#     ~> effects
#     ~> snk
#   end
# end

# defmodule Creek.Factorial do
#   use Creek
#   execution(ThermometerMeta)

#   defdag average_temperature(src1, src2, snk) do
#     (src1 ||| src2)
#     ~> merge()
#     ~> average()
#     ~> snk
#   end

#   @spec main :: any
#   def main() do
#     # Sources that produce json data and xml data.
#     json = Creek.Source.function(fn -> {:json, :rand.uniform(30)} end)
#     xml = Creek.Source.function(fn -> {:xml, :rand.uniform(30)} end)
#     snk = Creek.Sink.each(fn x -> IO.inspect(x) end)

#     Creek.Runtime.run(average_temperature(), src1: json, src2: xml, snk: snk)

#     :ok
#   end
# end
