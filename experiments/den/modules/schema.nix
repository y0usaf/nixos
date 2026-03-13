{lib, ...}: {
  den.schema.conf = {lib, ...}: {
    options = {
      profile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };

      roles = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };
  };

  den.schema.host = {
    options = {
      hostName = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  den.schema.user = {
    options = {
      homeDirectory = lib.mkOption {
        type = lib.types.str;
      };
    };
  };
}
