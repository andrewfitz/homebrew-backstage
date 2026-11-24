# Homebrew tap for backstage

[backstage](https://github.com/andrewfitz/backstage) lets coding agents launch, screenshot,
inspect and operate macOS apps on an invisible display, without touching your screen, cursor,
focus, Dock or speakers.

```bash
brew install andrewfitz/backstage/backstage
backstage doctor      # check permissions
backstage install     # skills for Claude Code, Codex and Grok (--hooks: also the hook)
```

Installing by the full name trusts this tap's formula (Homebrew asks you to trust third-party
taps). Prebuilt bottles cover macOS 15 and later on Apple Silicon; other Macs build from
source, which needs Xcode.

After `brew upgrade backstage`, restart the daemon so it runs the new version (this quits the
apps agents have open backstage):

```bash
backstage stop --all && backstage start
```

## Releasing a new version

Open a pull request that bumps `url` and `sha256` in `Formula/backstage.rb` (or run
`brew bump-formula-pr --no-fork andrewfitz/backstage/backstage --version X.Y.Z`). CI builds
the bottles; when it's green, run the **brew pr-pull** workflow with the PR number to publish
them and merge.
