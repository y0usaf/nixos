###############################################################################
# Marvel Rivals Engine Configuration - Nix-Maid Version
# Optimizes graphics settings for better performance
###############################################################################
{
  config,
  lib,
  ...
}: let
  cfg = config.home.gaming.marvel-rivals.engine;
in {
  ###########################################################################
  # Module Options
  ###########################################################################
  options.home.gaming.marvel-rivals.engine = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Marvel Rivals engine configuration";
    };
  };

  ###########################################################################
  # Module Configuration
  ###########################################################################
  config = lib.mkIf cfg.enable {
    users.users.y0usaf.maid.file.home.".local/share/Steam/steamapps/compatdata/2767030/pfx/drive_c/users/steamuser/AppData/Local/Marvel/Saved/Config/Windows/Engine.ini".text = lib.generators.toINI {} {
      "SystemSettings" = {
        "r.LevelStreamingDistanceScale" = "1";
        "r.ViewDistanceScale" = "1";
        "r.LandscapeLODBias" = "0";
        "r.LandscapeLODDistributionScale" = "1";
        "r.LandscapeLOD0DistributionScale" = "1";
        "r.LODFadeTime" = "2";
        "r.UITextureLODBias" = "-1";
        "r.Streaming.Boost" = "1";
        "r.TextureStreaming" = "1";
        "r.Streaming.ScaleTexturesByGlobalMyBias" = "1";
        "r.Streaming.LimitPoolSizeToVRAM" = "0";
        "r.DefaultFeature.AmbientOcclusion" = "False";
        "r.DefaultFeature.AmbientOcclusionStaticFraction" = "False";
        "r.DefaultFeature.AntiAliasing" = "0";
        "r.DefaultFeature.AutoExposure" = "True";
        "r.DefaultFeature.Bloom" = "False";
        "r.DefaultFeature.LensFlare" = "False";
        "r.DefaultFeature.MotionBlur" = "False";
        "r.DepthOfFieldQuality" = "0";
        "r.DistanceFieldAO" = "0";
        "r.EmitterSpawnRateScale" = "0";
        "r.FastBlurThreshold" = "0";
        "r.LensFlareQuality" = "0";
        "r.MaterialQualityLevel" = "1";
        "r.RefractionQuality" = "0";
        "r.SceneColorFormat" = "3";
        "r.SceneColorFringeQuality" = "0";
        "r.SeparateTranslucency" = "False";
        "r.Shadow.CSM.MaxCascades" = "1";
        "r.Shadow.CSM.TransitionScale" = "0";
        "r.Shadow.DistanceScale" = "0";
        "r.Shadow.MaxResolution" = "64";
        "r.Shadow.RadiusThreshold" = "0";
        "r.ShadowQuality" = "0";
        "r.SSR.Quality" = "0";
        "r.SSS.SampleSet" = "0";
        "r.SSS.Scale" = "0";
        "r.Fog" = "0";
        "r.PostProcessAAQuality" = "0";
        "r.MotionBlurQuality" = "0";
        "r.BlurGBuffer" = "0";
        "r.MaxAnisotropy" = "0";
        "r.BloomQuality" = "0";
        "r.LightFunction" = "0";
        "r.DetailMode" = "1";
        "r.TonemapperQuality" = "0";
        "r.MaterialQuality" = "1";
        "r.DepthOfField.MaxSize" = "0";
        "r.SwitchGridShadow" = "0";
        "r.Tonemapper.Sharpen" = "0.0";
        "r.AmbientOcclusionLevels" = "0";
        "r.VolumetricFog" = "0";
        "r.FogDensity" = "0";
        "r.Atmosphere" = "0";
        "r.ParticleLightQuality" = "0";
        "FX.MaxCPUParticlesPerEmitter" = "20";
        "FX.MaxGPUParticlesSpawnedPerFrame" = "0";
        "r.ParticleLODBias" = "3";
      };

      "/script/engine.renderersettings" = {
        "r.DefaultFeature.LensFlare" = "False";
        "r.DefaultFeature.DepthOfField" = "False";
        "r.DefaultFeature.AmbientOcclusion" = "False";
        "r.DefaultFeature.AmbientOcclusionStaticFraction" = "False";
        "r.BloomQuality" = "0";
        "r.MotionBlurQuality" = "0";
        "r.FastBlurThreshold" = "0";
        "r.TranslucencyVolumeBlur" = "0";
        "r.AmbientOcclusionLevels" = "0";
        "r.AmbientOcclusionRadiusScale" = "0";
        "r.DepthofFieldQuality" = "0";
        "r.DefaultFeature.AntiAliasing" = "0";
        "r.DefaultFeature.Bloom" = "False";
        "r.MobileHDR" = "False";
        "r.Shadow.MaxResolution" = "0";
        "r.Shadow.MaxCSMResolution" = "0";
        "r.Streaming.Boost" = "0.1";
        "r.SSR" = "0";
        "r.PostProcessAAQuality" = "0";
        "r.BlurGBuffer" = "0";
        "r.Fog" = "0";
        "r.TranslucentLightingVolume" = "0";
        "r.TriangleOrderOptimization" = "1";
        "r.Tonemapper.GrainQuantization" = "0";
        "r.TonemapperGamma" = "3";
        "r.Atmosphere" = "0";
        "r.EyeAdaptationQuality" = "1";
        "r.FullScreenMode" = "0";
        "r.IndirectLightingCache" = "0";
        "r.LightFunctionQuality" = "0";
        "r.LightShafts" = "0";
        "r.MaxCSMRadiusToAllowPerObjectShadows" = "0.01";
        "r.MipMapLODBias" = "1";
        "r.ReflectionEnvironment" = "0";
        "r.Shadow.RadiusThresholdRSM" = "0";
        "r.Shadow.TexelsPerPixel" = "0";
        "r.SimpleDynamicLighting" = "0";
        "r.UniformBufferPooling" = "1";
        "r.OptimizeForUAVPerformance" = "0";
        "r.Shadow.PerObject" = "1";
        "r.AllowLandscapeShadows" = "0";
        "r.AllowStaticLighting" = "0";
        "r.DFShadowScatterTileCulling" = "0";
        "r.ParallelShadows" = "0";
        "r.Shadow.FadeExponent" = "1";
        "r.Shadow.PreshadowExpand" = "-1";
        "r.Shadow.Preshadows" = "0";
        "r.TiledDeferredShading.MinimumCount" = "0";
        "r.AOApplyToStaticIndirect" = "0";
        "r.ContactShadows" = "0";
        "r.Shadow.PerObjectCastDistanceRadiusScale" = "0.001";
        "r.Shadow.CachePreshadow" = "1";
        "r.Shadow.CachedShadowsCastFromMovablePrimitives" = "0";
        "r.RayTracing.Translucency.Shadows" = "0";
        "r.LightMaxDrawDistanceScale" = "0.01";
        "r.CapsuleDirectShadows" = "0";
        "r.CapsuleIndirectShadows" = "0";
        "r.CapsuleMaxDirectOcclusionDistance" = "0";
        "r.CapsuleMaxIndirectOcclusionDistance" = "0";
        "r.CapsuleShadows" = "0";
        "r.Mobile.Shadow.CSMShaderCullingMethod" = "0";
        "r.Shadow.LightViewConvexHullCull" = "0";
        "r.Shadow.RectLightDepthBias" = "9";
        "r.Shadow.RectLightReceiverBias" = "0";
        "r.Shadow.TransitionScale" = "9";
      };
    };
  };
}
