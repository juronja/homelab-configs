# OpenID Connect Authentication

Example: Audiobookshelf <> Google Cloud Oauth

Docs:
- [Google Cloud setup article](https://www.itix.fr/blog/use-google-account-openid-connect-provider/) i sourced from
- [Audiobookshelf docs](https://www.audiobookshelf.org/guides/oidc_authentication/)


## Google Cloud Console configs

1. Create project (if you don't have one)
2. Go to **APIs & Services** and first prepare a 0Auth consent screen:
    - App info details
    - leave app logo blank to avoid approval
    - App domain (Application home page). e.g. `https://audiobook.repina.eu`
    - Authorized domains. e.g. `repina.eu`
    - developer contact
    - add default non-sensitive scopes
3. Go to **Credentials** and add a **0Auth client ID** credential
    - select web application type
    - add name
    - add redirect URIs (taken form [Audiobookshelf docs](https://www.audiobookshelf.org/guides/oidc_authentication/#configuring-your-oidc-provider)) and save to generate `ClientID` and `Secret`.

```markdown
https://abs.yoursite.com/auth/openid/callback
https://abs.yoursite.com/auth/openid/mobile-redirect
```

## Audiobookshelf app configs

1. Go to **Settings > Authentication** and enable **OpenID Connect Authentication**
2. Fill the **Issuer URL** and click **Auto-populate**. e.g. `https://accounts.google.com`
3. Fill out the `Client ID` and `Secret`
4. Change Button Text (Optional)
5. In **Match existing users by** select `Match by email`
6. Enable **Auto Register** to auto create new users.


