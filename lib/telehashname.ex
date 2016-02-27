defmodule Telehashname do

  @type csid :: <<_::2 * 8>>
  @type csk :: binary
  @type cs_pair :: {csid, csk}

  @spec from_tuples([cs_pair]) :: {binary, map} | nil
  def from_tuples(csk_list) do
    csk_list |> order_valid_cs_pairs |> hash_tuples({"",%{}})
  end

  def order_valid_cs_pairs(list), do: ovcp(list, [])
  defp ovcp([], acc), do: acc |> Enum.sort(&(elem(&1,0) <= elem(&2,0)))
  defp ovcp([{csid, csk}|rest],acc) do
    csid = if byte_size(csid) == 4 and binary_part(csid, 0,2) == "cs", do: binary_part(csid,2,2), else: csid
    newacc = if is_valid_csid? csid do
        [{csid,csk}|acc]
    else
        acc
    end
    ovcp(rest, newacc)
  end

  @spec is_valid_csid?(term) :: boolean
  def is_valid_csid?(id) when is_binary(id) and byte_size(id) == 2 do
    case Base.decode16(id, bp) do
      {:ok, h} -> Base.encode16(h,bp) == id
      :error   -> false
    end
  end
  def is_valid_csid?(_), do: false

  defp bp, do: [case: :lower, padding: false]

  defp hash_tuples([], {h,m}) when byte_size(h) > 0, do: {h |> Base.encode32(bp), m}
  defp hash_tuples([], _empty_tuple),  do: nil
  defp hash_tuples([{csid, csk}|rest], {h,m}) do
    hash = :crypto.hash(:sha256, h<>Base.decode16!(csid, bp))
    intr = :crypto.hash(:sha256, Base.decode32!(csk, bp))
    hash_tuples(rest, {:crypto.hash(:sha256, hash<>intr), Map.put(m,csid,(intr |> Base.encode32(bp)))})
  end

end
