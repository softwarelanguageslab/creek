defmodule Encrypted do
  use Creek.MetaBehaviour

  def decrypt({:encrypted, value}), do: value
  def encrypt(value), do: {:encrypted, value}

  fragment not_next(
             as filter(&(not match?({_, :next, _}, &1)))
                ~> base
                ~> effects
           )

  fragment next as filter(&match?({_, :next, _}, &1))
                   ~> map(fn {state, :next, encrypted} ->
                     IO.inspect(encrypted)
                     {state, :next, decrypt(encrypted)}
                   end)
                   ~> base()
                   ~> map(fn result ->
                     case result do
                       {p, {state, :next, decrypted}} ->
                         {p, {state, :next, encrypt(decrypted)}}

                       {p, {state, :skip}} ->
                         {p, {state, :skip}}

                       {p, {state, :ok}} ->
                         {p, {state, :ok}}
                     end
                   end)
                   ~> effects()

  fragment mymeta as dup
                     ~> (next ||| not_next)
                     ~> merge()

  defdag operator(src, snk) do
    src
    ~> mymeta
    ~> snk
  end

  defdag source(src, snk) do
    src
    ~> mymeta
    ~> snk
  end

  defdag sink(src, snk) do
    src
    ~> mymeta
    ~> snk
  end
end
