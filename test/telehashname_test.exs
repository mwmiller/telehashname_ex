defmodule TelehashnameTest do
  use PowerAssert
  doctest Telehashname
  alias Telehashname, as: Hashname

  test "from tuples" do
  csk_list = [  {"3a","hp6yglmmqwcbw5hno37uauh6fn6dx5oj7s5vtapaifrur2jv6zha"}, {"1a","vgjz3yjb6cevxjomdleilmzasbj6lcc7"} ]
  assert Hashname.from_tuples(csk_list) == {"jvdoio6kjvf3yqnxfvck43twaibbg4pmb7y3mqnvxafb26rqllwa",
                                                %{"1a" => "ym7p66flpzyncnwkzxv2qk5dtosgnnstgfhw6xj2wvbvm7oz5oaq",
                                                  "3a" => "bmxelsxgecormqjlnati6chxqua7wzipxliw5le35ifwxlge2zva"}
                                               }
  csk_list = [ {"3a","eg3fxjnjkz763cjfnhyabeftyf75m2s4gll3gvmuacegax5h6nia"}, {"1a", "an7lbl5e6vk4ql6nblznjicn5rmf3lmzlm"} ]
  assert Hashname.from_tuples(csk_list) == {"27ywx5e5ylzxfzxrhptowvwntqrd3jhksyxrfkzi6jfn64d3lwxa",
                                                %{"1a" => "eg3fxjnjkz763cjfnhyabeftyf75m2s4gll3gvmuacegax5h6nia",
                                                  "3a" => "s7md2gxysgmhjjcjo2iuln5tznddlgzmcilj5zj6na2hppweoeaq"}
                                               }

  csk_list = [{"1a", "vgjz3yjb6cevxjomdleilmzasbj6lcc7"}]
  assert Hashname.from_tuples(csk_list) == {"echmb6eke2f6z2mqdwifrt6i6hkkfua7hiisgrms6pwttd6jubiq",
                                                %{"1a" => "ym7p66flpzyncnwkzxv2qk5dtosgnnstgfhw6xj2wvbvm7oz5oaq"}
                                               }
  end

  test "is_valid_csid?" do
    assert Hashname.is_valid_csid?("1a")
    assert Hashname.is_valid_csid?("8a")
    refute Hashname.is_valid_csid?("at")
    refute Hashname.is_valid_csid?("bad")
  end

end
