{
  config,
  lib,
  pkgs,
  profile,
  ...
}: let
  # Function to read directory contents
  readDir = path: builtins.readDir path;

  # Function to get profile directories
  getProfiles = profilesPath: let
    contents = readDir profilesPath;
    # Filter directories that end with .default or .default-release
    isProfile = name: value:
      value
      == "directory"
      && (lib.hasSuffix ".default" name || lib.hasSuffix ".default-release" name);
    profiles = lib.filterAttrs isProfile contents;
  in
    builtins.attrNames profiles;

  # Common settings and CSS for all profiles
  commonSettings = {
    # Enable userChrome customizations (needed for the CSS)
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    # Disable hardware acceleration if using Nvidia
    "gfx.webrender.all" =
      if (builtins.elem "nvidia" profile.features)
      then false
      else true;
    "media.hardware-video-decoding.enabled" =
      if (builtins.elem "nvidia" profile.features)
      then false
      else true;
    "media.ffmpeg.vaapi.enabled" =
      if (builtins.elem "nvidia" profile.features)
      then false
      else true;
    "layers.acceleration.disabled" =
      if (builtins.elem "nvidia" profile.features)
      then true
      else false;

    # Performance settings
    "browser.sessionstore.interval" = 15000; # Reduce writes to disk (default 15000)
    "network.http.max-persistent-connections-per-server" = 10; # Increase connections per server
    "browser.cache.disk.enable" = false; # Disable disk cache in favor of memory cache
    "browser.cache.memory.enable" = true;
    "browser.cache.memory.capacity" = 1048576; # 1GB memory cache
    "browser.sessionhistory.max_entries" = 50; # Reduce memory usage from session history
    "network.prefetch-next" = true; # Enable link prefetching
    "network.dns.disablePrefetch" = false;
    "network.predictor.enabled" = true;

    # Basic UI settings
    "browser.tabs.drawInTitlebar" = true;
    "browser.theme.toolbar-theme" = 0;

    # Enable Browser Toolbox and development features
    "devtools.chrome.enabled" = true;
    "devtools.debugger.remote-enabled" = true;
    "devtools.debugger.prompt-connection" = false;
    "browser.enabledE10S" = false;

    # Theme and UI settings
    "browser.theme.dark-private-windows" = false;

    # Development settings
    "dom.webcomponents.enabled" = true;
    "layout.css.shadow-parts.enabled" = true;
  };

  userChromeCss = ''

    :root {
        --tab-font-size: 0.8em;
        --max-tab-width: none;
        --show-titlebar-buttons: none;
        --tab-height: 20px;
        --toolbar-icon-size: calc(var(--tab-height) / 1.5)
    }

    .titlebar-buttonbox-container {
        display: var(--show-titlebar-buttons)
    }

    :root:not([customizing]) #TabsToolbar {
        margin-left: 1px!important;
        margin-right: 1px!important;
        border-radius: 0!important;
        padding: 0!important;
        min-height: 0!important
    }

    .tabbrowser-tab * {
        margin: 0!important;
        border-radius: 0!important
    }

    .tabbrowser-tab {
        height: var(--tab-height);
        font-size: var(--tab-font-size)!important;
        min-height: 0!important;
        align-items: center!important;
        margin-bottom: 5px!important
    }

    .tab-icon-image {
        height: auto!important;
        width: var(--toolbar-icon-size)!important;
        margin-right: 4px!important
    }

    #titlebar {
        -moz-appearance: none!important;
        margin-bottom: 0!important;
        padding-bottom: 0!important;
    }

    #tabbrowser-arrowscrollbox,#tabbrowser-tabs,#tabbrowser-tabs>.tabbrowser-arrowscrollbox {
        min-height: 0!important
    }

    :root:not([customizing]) #TabsToolbar .titlebar-button,
    :root:not([customizing]) #TabsToolbar-customization-target>.toolbarbutton-1,
    :root:not([customizing]) #tabbrowser-tabs .tabs-newtab-button,
    :root:not([customizing]) #tabs-newtab-button {
        -moz-appearance: none!important;
        padding-top: 0!important;
        padding-bottom: 0!important;
        -moz-box-align: stretch;
        margin: 0!important
    }

    #tabbrowser-tabs .tabs-newtab-button:hover,#tabs-newtab-button:hover {
        background-color: var(--toolbarbutton-hover-background)
    }

    #tabbrowser-tabs .tabs-newtab-button>.toolbarbutton-icon,#tabs-newtab-button>.toolbarbutton-icon {
        padding: 0!important;
        transform: scale(.6);
        background-color: transparent!important
    }

    @media (-moz-os-version:windows-win10) {
        :root[sizemode=maximized] #navigator-toolbox {
            padding-top: 7px!important
        }
    }

    :root[tabsintitlebar] #toolbar-menubar[autohide=true][inactive] {
        transition: height 0ms steps(1) 80ms
    }

    #nav-bar {
        margin-left: 0;
        margin-right: 0;
        min-width: 40rem;
        height: var(--tab-height);
        min-height: 0!important;
        border-inline: var(--uc-window-drag-space-width) solid var(--toolbar-bgcolor);
        margin-top: -1px!important;
        border-top: none!important;
    }

    /* Add margins only when window is wide enough */
    @media (min-width: 60rem) {
        #nav-bar {
            margin-left: 25vw;
            margin-right: 25vw;
        }
    }

    #navigator-toolbox {
        appearance: toolbar!important;
        margin: 0!important;
        padding: 0!important;
    }

    #tabbrowser-arrowscrollbox:not([overflowing]) {
        --uc-flex-justify: center
    }

    scrollbox[orient=horizontal]>slot {
        justify-content: var(--uc-flex-justify, initial)
    }

    #urlbar,#urlbar-input-container {
        height: var(--tab-height)!important
    }

    #urlbar,#urlbar[open] {
        min-height: var(--tab-height)!important
    }

    #urlbar-input-container {
        min-height: 0!important
    }

    #urlbar[open],#urlbar[open] #urlbar-input-container {
        height: auto!important
    }

    #identity-icon,#page-action-buttons img,#permissions-granted-icon,#star-button-box,#tracking-protection-icon,.searchbar-search-icon,.toolbarbutton-icon,.urlbar-icon,.urlbar-page-action {
        height: auto!important;
        width: var(--toolbar-icon-size)!important;
        padding: 0!important
    }

    .toolbarbutton-1 {
        padding: 0 4px!important
    }

    /* Apply compact styling to all toolbar buttons and UI elements */
    .toolbarbutton-1,
    .toolbarbutton-icon,
    .toolbaritem-combined-buttons,
    #nav-bar toolbarbutton,
    #TabsToolbar toolbarbutton,
    #PersonalToolbar toolbarbutton,
    .titlebar-button,
    .tab-close-button,
    .urlbar-icon,
    .urlbar-page-action {
        -moz-appearance: none!important;
        padding-top: 0!important;
        padding-bottom: 0!important;
        padding-inline: 2px!important;
        -moz-box-align: stretch;
        margin: 0!important;
    }

    /* Ensure consistent icon sizing */
    .toolbarbutton-icon,
    .urlbar-icon,
    .urlbar-page-action > image,
    .tab-close-button,
    .titlebar-button > image {
        padding: 0!important;
        width: var(--toolbar-icon-size)!important;
        height: auto!important;
    }

    /* Remove gaps between nav elements */
    #navigator-toolbox {
        appearance: toolbar!important;
        margin: 0!important;
        padding: 0!important;
    }

    #nav-bar {
        margin-top: -1px!important;  /* Remove gap between nav-bar and tabs */
        border-top: none!important;
    }

    /* Ensure no gaps in tabs area */
    #titlebar {
        -moz-appearance: none!important;
        margin-bottom: 0!important;
        padding-bottom: 0!important;
    }

    #TabsToolbar {
        margin-bottom: 0!important;
        padding-bottom: 0!important;
    }

    /* Remove any spacing between toolbars */
    toolbar {
        margin-top: 0!important;
        margin-bottom: 0!important;
        padding: 0!important;
    }

    /* Compact urlbar results styling */
    .urlbarView {
        font-size: var(--tab-font-size) !important;
        margin: 0 !important;
        padding: 0 !important;
        max-height: calc(60vh - 40px) !important;  /* Subtract input height from max-height */
        overflow-y: auto !important;
    }

    .urlbarView-row {
        padding-block: 2px !important;
    }

    .urlbarView-row-inner {
        padding-inline: 4px !important;
    }

    .urlbarView-title,
    .urlbarView-secondary,
    .urlbarView-url {
        padding: 0 !important;
        margin: 0 !important;
    }

    /* URL bar styling when expanded */
    #urlbar[breakout][breakout-extend] {
        box-shadow: 0 15px 30px rgba(0, 0, 0, 0.2);
        width: 50vw !important;  /* 100% - (25vw * 2) */
        left: 50% !important;
        right: auto !important;
        top: 20vh !important;
        margin: 0 !important;
        position: fixed !important;
        z-index: 999 !important;
        transform: translateX(-50%) !important;
        max-height: 60vh !important;
        min-height: 40px !important;
    }

    /* Center URL bar text when not focused/expanded */
    #urlbar:not([breakout][breakout-extend]) #urlbar-input,
    #urlbar:not([focused]) #urlbar-input {
        text-align: center !important;
    }

    /* Remove rounded corners from URL bar */
    #urlbar-background,
    #urlbar-input-container {
        --toolbarbutton-border-radius: 0px !important;
        --urlbar-icon-border-radius: 0px !important;
    }

  '';

  # Get the profiles from the Firefox directory
  profilesPath = "${config.home.homeDirectory}/.mozilla/firefox";
  profiles =
    if builtins.pathExists profilesPath
    then getProfiles profilesPath
    else [];

  # Create profile configurations
  mkProfileConfig = name: {
    inherit name;
    settings = commonSettings;
    userChrome = userChromeCss;
  };

  # Generate profile configurations for all detected profiles
  profileConfigs = builtins.listToAttrs (map
    (name: {
      inherit name;
      value = mkProfileConfig name;
    })
    profiles);
in {
  programs.firefox = {
    enable = true;
    profiles = {
      "y0usaf" = {
        settings = commonSettings;
        userChrome = userChromeCss;
      };
    };
  };
}
