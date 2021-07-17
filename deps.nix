fetchNuGet:
[
  (fetchNuGet {
    name = "Mono.Cecil";
    version = "0.11.2";
    sha256 = "114idyjaa6npi580d61gvr7i5xfcy5xi2yc1pfr9y82pj5kj7x5a";
  })
  (fetchNuGet {
    name = "Newtonsoft.Json";
    version = "12.0.3";
    sha256 = "17dzl305d835mzign8r15vkmav2hq8l6g7942dfjpnzr17wwl89x";
  })

  (fetchNuGet {
    name = "Microsoft.NETCore.App.Ref";
    version = "3.1.0";
    sha256 = "08svsiilx9spvjamcnjswv0dlpdrgryhr3asdz7cvnl914gjzq4y";
  })

  (fetchNuGet {
    name = "Microsoft.AspNetCore.App.Ref";
    version = "3.1.10";
    sha256 = "0xn4zh7shvijqlr03fqsmps6gz856isd9bg9rk4z2c4599ggal77";
  })
  (fetchNuGet {
    name = "Microsoft.NETCore.App.Host.linux-x64";
    version = "3.1.14";
    sha256 = "11rqnascx9asfyxgxzwgxgr9gxxndm552k4dn4p1s57ciz7vkg9h";
  })
]
