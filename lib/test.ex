defmodule TestMacro do
  defmacro call_it(f) do
    {f_atom, _, _} = f

    quote do
      apply(__MODULE__, unquote(f_atom), ["The argument", "Other argument"])
    end
  end

  defmacro call_it_module_func(f) do
    quote do
      apply(unquote(f), ["The argument", "Other argument"])
    end
  end
end

defmodule Other do
  def f(x, y) do
    IO.puts("Calling otherfunc with #{x} and #{y}")
    :result
  end
end

defmodule Test do
  import TestMacro

  def otherfunc(x, y) do
    IO.puts("Calling otherfunc with #{x} and #{y}")
    :result
  end

  def macrotest() do
    myfunc = fn x, y ->
      IO.puts("Calling myfunc with #{x} and #{y}")
      :result
    end

    call_it_module_func(myfunc)
    call_it_module_func(&otherfunc/2)
    call_it(otherfunc)
  end
end
