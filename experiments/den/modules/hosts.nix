{...}: {
  den.hosts.x86_64-linux.y0usaf-desktop = {
    hostName = "y0usaf-desktop";
    profile = "desktop";
    roles = ["graphical" "gaming"];
    users.y0usaf = {
      classes = ["hjem"];
      profile = "desktop";
      homeDirectory = "/home/y0usaf";
    };
  };

  den.hosts.x86_64-linux.y0usaf-laptop = {
    hostName = "y0usaf-laptop";
    profile = "portable";
    roles = ["graphical" "portable"];
    users.y0usaf = {
      classes = ["hjem"];
      profile = "desktop";
      homeDirectory = "/home/y0usaf";
    };
  };

  den.hosts.x86_64-linux.y0usaf-framework = {
    hostName = "y0usaf-framework";
    profile = "portable";
    roles = ["graphical" "portable" "impermanent"];
    users.y0usaf = {
      classes = ["hjem"];
      profile = "mobile";
      homeDirectory = "/home/y0usaf";
    };
  };

  den.hosts.x86_64-linux.y0usaf-server = {
    hostName = "y0usaf-server";
    profile = "server";
    roles = ["headless" "impermanent"];
    users.y0usaf = {
      classes = ["hjem"];
      profile = "server";
      homeDirectory = "/home/y0usaf";
    };
  };

  den.hosts.aarch64-darwin.y0usaf-macbook = {
    hostName = "y0usaf-macbook";
    profile = "darwin-laptop";
    roles = ["graphical" "portable"];
    users.y0usaf = {
      classes = ["homeManager"];
      profile = "darwin";
      homeDirectory = "/Users/y0usaf";
    };
  };
}
