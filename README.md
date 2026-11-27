# Moved: andrewfitz/tap

backstage now lives in [andrewfitz/tap](https://github.com/andrewfitz/homebrew-tap), with my other
apps:

```bash
brew tap andrewfitz/tap
brew install backstage
```

If you installed from this tap, `brew update` moves backstage there (`tap_migrations.json`);
afterwards `brew untap andrewfitz/backstage` removes this one. This repository stays for that
migration and for the bottles of older releases.
