defmodule Telehashname do

  @type csid :: <<_::2 * 8>>
  @type csk :: binary
  @type cs_pair :: {csid, csk}
  @type sort_dir :: :asc | :dsc

  @spec from_tuples([cs_pair]) :: {binary, map} | nil
  def from_tuples(csk_list) do
    csk_list |> ids(:asc) |> hash_tuples({"",%{}})
  end

  def ids(ids, dir \\ :dsc)
  def ids(ids, dir) when is_map(ids), do: ids |> Map.to_list |> ids(dir)
  def ids(ids, dir) when is_list(ids) do
    sort_func = case dir do
                  :asc -> &(&1 <= &2)
                  :dsc -> &(&1 >= &2)
                  _    -> raise("Improper sort direction")
                end
     valid_ids(ids, []) |> Enum.sort(sort_func)
  end

  defp valid_ids([], acc), do: acc
  defp valid_ids([{csid, data}|rest],acc) do
    newacc = case valid_csid(csid) do
        nil ->  acc
        id  ->  [{id, data}|acc]
    end
    valid_ids(rest, newacc)
  end
  defp valid_ids([csid|rest],acc) do
    newacc = case valid_csid(csid) do
        nil ->  acc
        id  ->  [id|acc]
    end
    valid_ids(rest, newacc)
  end

  defp valid_csid(csid) do
    csid = if byte_size(csid) == 4 and binary_part(csid, 0,2) == "cs", do: binary_part(csid,2,2), else: csid
    if is_valid_csid?(csid), do: csid, else: nil
  end

  @spec is_valid?(term) :: boolean
  def is_valid?(hn) when is_binary(hn) and byte_size(hn) == 52 do
    case Base.decode32(hn,bp) do
      {:ok, b} -> byte_size(b) == 32 # I think this is superfluous, but why not?
      :error   -> false
    end
  end
  def is_valid?(_), do: false

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
