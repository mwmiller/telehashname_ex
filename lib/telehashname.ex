defmodule Telehashname do

  @type csid :: <<_::2 * 8>>
  @type csk :: binary
  @type cs_pair :: {csid, csk}

  @spec from_tuples([cs_pair]) :: {binary, map}
  def from_tuples(csk_list) do
    csk_list |> Enum.sort(&(elem(&1,0) <= elem(&2,0))) |> hash_tuples({"",%{}})
  end

  defp bp, do: [case: :lower, padding: false]

  defp hash_tuples([], {h,m}), do: {h |> Base.encode32(bp), m}
  defp hash_tuples([{csid, csk}|rest], {h,m}) do
    hash = :crypto.hash(:sha256, h<>Base.decode16!(csid, bp))
    intr = :crypto.hash(:sha256, Base.decode32!(csk, bp))
    hash_tuples(rest, {:crypto.hash(:sha256, hash<>intr), Map.put(m,csid,(intr |> Base.encode32(bp)))})
  end

end
