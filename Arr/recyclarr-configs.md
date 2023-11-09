# Recyclarr yaml configuration

For now I only use Radarr, Sonarr is commented out.
To access the yml file enable the Codeserver addon in true nas scale app. The port then should be 36107.

```yml
# yaml-language-server: $schema=https://raw.githubusercontent.com/recyclarr/recyclarr/master/schemas/config-schema.json

# A starter config to use with Recyclarr. Most values are set to "reasonable defaults". Update the
# values below as needed for your instance. You will be required to update the API Key and URL for
# each instance you want to use.
#
# Many optional settings have been omitted to keep this template simple. Note that there's no "one
# size fits all" configuration. Please refer to the guide to understand how to build the appropriate
# configuration based on your hardware setup and capabilities.
#
# For any lines that mention uncommenting YAML, you simply need to remove the leading hash (`#`).
# The YAML comments will already be at the appropriate indentation.
#
# For more details on the configuration, see the Configuration Reference on the wiki here:
# https://recyclarr.dev/wiki/yaml/config-reference/

# Configuration specific to Sonarr
#sonarr:
#  series:
    # Set the URL/API Key to your actual instance
#    base_url: {IP & Port}
#    api_key: YOUR_KEY_HERE

    # Quality definitions from the guide to sync to Sonarr. Choices: series, anime
#    quality_definition:
#      type: series

    # Release profiles from the guide to sync to Sonarr v3 (Sonarr v4 does not use this!)
    # Use `recyclarr list release-profiles` for values you can put here.
    # https://trash-guides.info/Sonarr/Sonarr-Release-Profile-RegEx/
#    release_profiles:
      # Series
#      - trash_ids:
#          - EBC725268D687D588A20CBC5F97E538B # Low Quality Groups
#          - 1B018E0C53EC825085DD911102E2CA36 # Release Sources (Streaming Service)
#          - 71899E6C303A07AF0E4746EFF9873532 # P2P Groups + Repack/Proper
      # Anime (Uncomment below if you want it)
      #- trash_ids:
      #    - d428eda85af1df8904b4bbe4fc2f537c # Anime - First release profile
      #    - 6cd9e10bb5bb4c63d2d7cd3279924c7b # Anime - Second release profile

# Configuration specific to Radarr.
radarr:
  movies:
    # Set the URL/API Key to your actual instance
    base_url: {IP & Port}
    api_key: YOUR_KEY_HERE

    # Which quality definition in the guide to sync to Radarr. Only choice right now is 'movie'
    quality_definition:
      type: movie

    # Set to 'true' to automatically remove custom formats from Radarr when they are removed from
    # the guide or your configuration. This will NEVER delete custom formats you manually created!
    delete_old_custom_formats: true

    custom_formats:
      # A list of custom formats to sync to Radarr.
      # Use `recyclarr list custom-formats radarr` for values you can put here.
      # https://trash-guides.info/Radarr/Radarr-collection-of-custom-formats/
      - trash_ids:
          # HQ Release Groups
          - ed27ebfef2f323e964fb1f61391bcb35 # HD Bluray Tier 01
          - c20c8647f2746a1f4c4262b0fbbeeeae # HD Bluray Tier 02
          - 5608c71bcebba0a5e666223bae8c9227 # HD Bluray Tier 03
          - c20f169ef63c5f40c2def54abaf4438e # WEB Tier 01
          - 403816d65392c79236dcb6dd591aeda4 # WEB Tier 02
          - af94e0fe497124d1f9ce732069ec8c3b # WEB Tier 03

          # Misc
          - e7718d7a3ce595f289bfee26adc178f5 # Repack/Proper
          - ae43b294509409a6a13919dedd4764c4 # Repack2
          - 0d91270a7255a1e388fa85e959f359d8 # FreeLeech
          - 2899d84dc9372de3408e6d8cc18e9666 # x264
          - 9170d55c319f4fe40da8711ba9d8050d # x265
          - cae4ca30163749b891686f95532519bd # AV1

          # Movie Versions
          - 570bc9ebecd92723d2d21500f4be314c  # Remaster
          - eca37840c13c6ef2dd0262b141a5482f  # 4K Remaster
          - e0c07d59beb37348e975a930d5e50319  # Criterion Collection
          - 9d27d9d2181838f76dee150882bdc58c  # Masters of Cinema
          - db9b4c4b53d312a3ca5f1378f6440fc9  # Vinegar Syndrome
          - 957d0f44b592285f26449575e8b1167e  # Special Edition
          - eecf3a857724171f968a66cb5719e152  # IMAX
          - 9f6cbff8cfe4ebbc1bde14c7b7bec0de  # IMAX Enhanced

          # Optional
          - 820b09bb9acbfde9c35c71e0e565dad8 # 1080p

          # Streaming Services
          - b3b3a6ac74ecbd56bcdbefa4799fb9df # AMZN
          - 40e9380490e748672c2522eaaeb692f7 # ATVP
          - 84272245b2988854bfb76a16e60baea5 # DSNP
          - 509e5f41146e278f9eab1ddaceb34515 # HBO
          - 5763d1b0ce84aff3b21038eea8e9b8ad # HMAX
          - 526d445d4c16214309f0fd2b3be18a89 # Hulu
          - 170b1d363bd8516fbf3a3eb05d4faff6 # NF

          # Unwanted
          - b8cd450cbfa689c0259a01d9e29ba3d6 # 3D
          - ed38b889b31be83fda192888e2286d83 # BR-DISK
          - bfd8eb01832d646a0a89c4deb46f8564 # Upscaled
          - dc98083864ea246d05a42df0d05f81cc # x265 (HD)
          - 7357cf5161efbf8c4d5d0c30b4815ee2 # Obfuscated
          - f537cf427b64c38c8e36298f657e4828 # Scene
          - 923b6abef9b17f937fab56cfcf89e1f1 # DV (WEBDL)
          - 90cedc1fea7ea5d11298bebd3d1d3223 # EVO (no WEBDL)
          - b6832f586342ef70d9c128d40c07b872 # Bad Dual Groups

        # Uncomment the below properties to specify one or more quality profiles that should be
        # updated with scores from the guide for each custom format. Without this, custom formats
        # are synced to Radarr but no scores are set in any quality profiles.
        quality_profiles:
          - name: HD Bluray + WEB
            #score: -9999 # Optional score to assign to all CFs. Overrides scores in the guide.
            #reset_unmatched_scores: true # Optionally set other scores to 0 if they are not listed in 'names' above.

      - trash_ids:
          # Custom Score Jure
          - 90a6f9a284dff5103f6346090e6280c8 # LQ

        quality_profiles:
          - name: HD Bluray + WEB
            score: 0
```