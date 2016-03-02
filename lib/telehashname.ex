defmodule Telehashname do
  @moduledoc """
  Telehash hashname handling

  https://github.com/telehash/telehash.org/blob/master/v3/hashname.md
  """
  @typedoc """
  Cipher Set ID

  As an affordance, many functions will take a 4-byte CSID (the CSID with a pre-pended `cs`.)
  These will be normalized in most return values.  It is not recommended to depend upon this
  behavior.
  """
  @type csid :: <<_::2 * 8>>
  @typedoc """
  Cipher Set Key
  """
  @type csk_tuple :: {csid, binary}
  @typedoc """
  Sort direction control

  - :asc == ascending
  - :dsc == descending
  """
  @type sort_dir :: :asc | :dsc
  @typedoc """
  A list of CSKs

  Maps will generally be transformed to a list of CSK tuples in the
  return values.
  """
  @type csk_list :: [csk_tuple] | map
  @typedoc """
  A list of CSIDs
  """
  @type csid_list :: csk_list | [csid]

  @doc """
  Generate a hashname from a list of CSKs

  As an affordance, a map may also be provided.  It will be transformed
  into a sorted CSK list.

  The return value is a tuple with the hashname and a map of the intermediate
  values used for generation.

  `nil` is returned when no valid CSKs are found in the list.
  """
  @spec from_csks(csk_list, map) :: {binary, map} | nil
  def from_csks(csks, im \\ %{}), do: csks |> ids(:asc) |> hash_tuples({"",im})

  defp hash_tuples([], {h,m}) when byte_size(h) > 0, do: {h |> Base.encode32(bp), m}
  defp hash_tuples([], _empty_tuple),  do: nil
  defp hash_tuples([{csid, csk}|rest], {h,m}) do
    IO.inspect(m)
    hash = :crypto.hash(:sha256, h<>Base.decode16!(csid, bp))
    intr = case Map.fetch(m, csid) do
            :error -> v = :crypto.hash(:sha256, Base.decode32!(csk, bp))
                      m = Map.put(m,csid, (v |> Base.encode32(bp)))
                      IO.inspect(v |> Base.encode32(bp))
            val    -> Base.decode32!(val)
           end
    hash_tuples(rest, {:crypto.hash(:sha256, hash<>intr), m})
  end

  @doc """
  Validate and sort a CSID list

  This can handle multiple forms of provided CSIDs.  The return value
  will be appropriate to the input parameter.

  Invalid CSIDs are removed, remaining IDs are normalized and sorted
  in the requested order.
  """
  @spec ids(csid_list, sort_dir) :: [csid|csk_tuple]
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

  @spec valid_ids(csid_list, csid_list) ::  [csk_tuple|csid]
  defp valid_ids([], acc), do: acc
  defp valid_ids([{csid, data}|rest],acc) do
    newacc = case csid |> String.downcase |> valid_csid do
        nil ->  acc
        id  ->  [{id, data}|acc]
    end
    valid_ids(rest, newacc)
  end
  defp valid_ids([csid|rest],acc) do
    newacc = case csid |> String.downcase |> valid_csid do
        nil ->  acc
        id  ->  [id|acc]
    end
    valid_ids(rest, newacc)
  end

  @spec valid_csid(term) :: csid | nil
  defp valid_csid(csid) do
    csid = if byte_size(csid) == 4 and binary_part(csid, 0,2) == "cs", do: binary_part(csid,2,2), else: csid
    if is_valid_csid?(csid), do: csid, else: nil
  end

  @doc """
  Find the highest rated match among two CSK lists

  The values returned from the `outs` list.  Selecting
  which list to use for `check` and `outs` may provide
  some useful information "for free."
  """
  @spec best_match(csid_list, csid_list) :: csid | csk_tuple | nil
  def best_match(check, outs) do
        cids = ids(check)
        oids = ids(outs)
        find_fun_fun = case {is_tuple_list(cids),is_tuple_list(oids)} do
                        {true,true}   -> fn(check) ->
                                           c = elem(check,0)
                                           fn(x) -> elem(x,0) == c end
                                         end
                        {true,false}  -> fn(check) ->
                                           c = elem(check,0)
                                           fn(x) -> x == c end
                                         end
                        {false,true}  -> fn(c) ->
                                           fn(x) -> elem(x,0) == c end
                                         end
                        {false,false} -> fn(c) ->
                                           fn(x) -> x == c end
                                         end
                       end
        match(cids,oids, find_fun_fun)
  end

  @spec is_tuple_list(list) :: boolean
  defp is_tuple_list(list), do: list |> List.first |> is_tuple

  @spec match(csid_list, csid_list, function) :: csk_tuple | csid | nil
  defp match([],_outs,_fff), do: nil
  defp match([c|check],outs,fff) do
      case Enum.find(outs, fff.(c)) do
          nil -> match(check,outs,fff)
          hit -> hit
      end
  end

  @doc """
  Determine if something looks like a valid hashname

  Confirms form only, not validity
  """
  @spec is_valid?(term) :: boolean
  def is_valid?(hn) when is_binary(hn) and byte_size(hn) == 52 do
    case Base.decode32(hn,bp) do
      {:ok, b} -> byte_size(b) == 32 # I think this is superfluous, but why not?
      :error   -> false
    end
  end
  def is_valid?(_), do: false

  @doc """
  Determine if something looks like a valid CSID

  Confirms form only, not validity.  Some functions be more liberal in
  what they accept, but confirming validity is always better.
  """
  @spec is_valid_csid?(term) :: boolean
  def is_valid_csid?(id) when is_binary(id) and byte_size(id) == 2 do
    case Base.decode16(id, bp) do
      {:ok, h} -> Base.encode16(h,bp) == id
      :error   -> false
    end
  end
  def is_valid_csid?(_), do: false

  # Base parameters, just to thet are all used in the same way.
  defp bp, do: [case: :lower, padding: false]

end
