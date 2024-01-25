# Recyclarr yaml configuration

For now I only use Radarr, Sonarr is commented out.
To access the yml file enable the Codeserver addon in true nas scale app. The port then should be 36107.

You can then just upload the files to the /config folder:
- recyclarr.yml
- secrets.yml

Run `recyclarr sync` to update settings.