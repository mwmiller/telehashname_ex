defmodule TelehashnameTest do
  use ExUnit.Case
  doctest Telehashname
  alias Telehashname, as: Hashname

  test "from_csks" do
    csk_list = [  {"3a","hp6yglmmqwcbw5hno37uauh6fn6dx5oj7s5vtapaifrur2jv6zha"}, {"1a","vgjz3yjb6cevxjomdleilmzasbj6lcc7"} ]
    assert Hashname.from_csks(csk_list) == {"jvdoio6kjvf3yqnxfvck43twaibbg4pmb7y3mqnvxafb26rqllwa",
                                            %{"1a" => "ym7p66flpzyncnwkzxv2qk5dtosgnnstgfhw6xj2wvbvm7oz5oaq",
                                              "3a" => "bmxelsxgecormqjlnati6chxqua7wzipxliw5le35ifwxlge2zva"}
                                           }
    csk_list = [ {"3a","eg3fxjnjkz763cjfnhyabeftyf75m2s4gll3gvmuacegax5h6nia"}, {"1a", "an7lbl5e6vk4ql6nblznjicn5rmf3lmzlm"} ]
    assert Hashname.from_csks(csk_list) == {"27ywx5e5ylzxfzxrhptowvwntqrd3jhksyxrfkzi6jfn64d3lwxa",
                                            %{"1a" => "eg3fxjnjkz763cjfnhyabeftyf75m2s4gll3gvmuacegax5h6nia",
                                              "3a" => "s7md2gxysgmhjjcjo2iuln5tznddlgzmcilj5zj6na2hppweoeaq"}
                                           }

    csk_list = [{"cs1a", "vgjz3yjb6cevxjomdleilmzasbj6lcc7"}]
    assert Hashname.from_csks(csk_list) == {"echmb6eke2f6z2mqdwifrt6i6hkkfua7hiisgrms6pwttd6jubiq",
                                            %{"1a" => "ym7p66flpzyncnwkzxv2qk5dtosgnnstgfhw6xj2wvbvm7oz5oaq"}
                                           }

    csk_list = [{"bad", "mojo"}]
    assert Hashname.from_csks(csk_list) == nil

    csk_list = [{"cs1a", "vgjz3yjb6cevxjomdleilmzasbj6lcc7"}, {"bad", "mojo"}]
    assert Hashname.from_csks(csk_list) == {"echmb6eke2f6z2mqdwifrt6i6hkkfua7hiisgrms6pwttd6jubiq",
                                             %{"1a" => "ym7p66flpzyncnwkzxv2qk5dtosgnnstgfhw6xj2wvbvm7oz5oaq"}
                                           }
    csk_list = [  {"3a","hp6yglmmqwcbw5hno37uauh6fn6dx5oj7s5vtapaifrur2jv6zha"} ]
    im_map   = %{"1a" => "ym7p66flpzyncnwkzxv2qk5dtosgnnstgfhw6xj2wvbvm7oz5oaq"}
    assert Hashname.from_csks(csk_list, im_map) == {"jvdoio6kjvf3yqnxfvck43twaibbg4pmb7y3mqnvxafb26rqllwa",
                                                    %{"1a" => "ym7p66flpzyncnwkzxv2qk5dtosgnnstgfhw6xj2wvbvm7oz5oaq",
                                                    "3a" => "bmxelsxgecormqjlnati6chxqua7wzipxliw5le35ifwxlge2zva"}
                                                   }
  end

  test "from_intermediates" do
    im_map = %{"1a" => "eg3fxjnjkz763cjfnhyabeftyf75m2s4gll3gvmuacegax5h6nia",
               "3a" => "s7md2gxysgmhjjcjo2iuln5tznddlgzmcilj5zj6na2hppweoeaq"}

    assert Hashname.from_intermediates(im_map) == {"27ywx5e5ylzxfzxrhptowvwntqrd3jhksyxrfkzi6jfn64d3lwxa",
                                                   %{"1a" => "eg3fxjnjkz763cjfnhyabeftyf75m2s4gll3gvmuacegax5h6nia",
                                                     "3a" => "s7md2gxysgmhjjcjo2iuln5tznddlgzmcilj5zj6na2hppweoeaq"}
                                                  }
  end

  test "is_valid_csid?" do
    assert Hashname.is_valid_csid?("1a")
    assert Hashname.is_valid_csid?("8a")
    refute Hashname.is_valid_csid?("at")
    refute Hashname.is_valid_csid?("bad")
  end

  test "is_valid?" do
    assert Hashname.is_valid?("echmb6eke2f6z2mqdwifrt6i6hkkfua7hiisgrms6pwttd6jubiq")
    assert Hashname.is_valid?("27ywx5e5ylzxfzxrhptowvwntqrd3jhksyxrfkzi6jfn64d3lwxa")
    refute Hashname.is_valid?("27ywx5e5ylzxfzxrhptowvwntqrd3jhksyxrfkzi6jfn64d3lwx/")
    refute Hashname.is_valid?("hashname")
  end


  test "ids" do
    in_list = ["8a", "cs1a", "toot", "3a"]
    in_tuple_list = [{"8a", "doot"}, {"cs1a", "root"}, {"toot", "2a"}, {"3a", "loot"}]
    in_map  = %{"8a" => "doot", "cs1a" => "root", "toot" => "2a", "3a" => "loot"}

    assert Hashname.ids(in_tuple_list, :asc) == [{"1a", "root"}, {"3a", "loot"}, {"8a", "doot"}]
    assert Hashname.ids(in_tuple_list, :dsc) == [{"8a", "doot"}, {"3a", "loot"}, {"1a", "root"}]
    assert Hashname.ids(in_tuple_list)       == [{"8a", "doot"}, {"3a", "loot"}, {"1a", "root"}]

    assert Hashname.ids(in_map, :asc)        == [{"1a", "root"}, {"3a", "loot"}, {"8a", "doot"}]
    assert Hashname.ids(in_map, :dsc)        == [{"8a", "doot"}, {"3a", "loot"}, {"1a", "root"}]
    assert Hashname.ids(in_map)              == [{"8a", "doot"}, {"3a", "loot"}, {"1a", "root"}]

    assert Hashname.ids(in_list, :asc)       == ["1a", "3a", "8a"]
    assert Hashname.ids(in_list, :dsc)       == ["8a", "3a", "1a"]
    assert Hashname.ids(in_list)             == ["8a", "3a", "1a"]
  end

  test "best_match" do

    checks = %{"1a" => "lo", "3a" => "hi"}
    outs   = %{"3a" => "lo", "8a" => "hi"}

    assert Hashname.best_match(checks,outs) == {"3a", "lo"}

    checks = ["2a", "8a", "3a"]
    assert Hashname.best_match(checks,outs) == {"8a", "hi"}

    outs = ["1a","2a","3a"]
    assert Hashname.best_match(checks,outs) == "3a"

    checks = [{"bad", "thing"}, {"still", "bad"}, {"1a", "ok"}]
    outs   = ["bad", "still"]
    assert Hashname.best_match(checks,outs) == nil

    outs   = ["bad", "still", "cs1a"]
    assert Hashname.best_match(checks,outs) == "1a"

    checks = %{"1a" => "only"}
    outs   = %{"2a" => "only"}
    assert Hashname.best_match(checks,outs) == nil

    checks = %{"1a" => "lo", "2a" => "med", "3a" => "high"}
    assert Hashname.best_match(checks,outs) == {"2a", "only"}

    checks = %{"1a" => "only"}
    outs   = %{"1a" => "lo", "2a" => "med", "3a" => "high"}
    assert Hashname.best_match(checks,outs) == {"1a", "lo"}

  end

end
