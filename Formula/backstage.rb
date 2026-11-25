class Backstage < Formula
  desc "Lets agents drive macOS apps on an invisible display, off the user's screen"
  homepage "https://github.com/andrewfitz/backstage"
  url "https://github.com/andrewfitz/backstage/archive/refs/tags/v1.3.2.tar.gz"
  sha256 "010384c5dec5bb8565adefd95463b56580517f1a2fe2fb836f36e8dffb72a513"
  head "https://github.com/andrewfitz/backstage.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/andrewfitz/homebrew-backstage/releases/download/backstage-1.3.2"
    sha256 cellar: :any, arm64_tahoe:   "ae5eb0f82c61c2c71e73e0b88e72647aa7a088516b8930a1d32136f2b1580219"
    sha256 cellar: :any, arm64_sequoia: "ad6ad3e2577ab7ca94c7c53f5d2ba531437317902c2d45cf3ea002cce21c05ea"
  end

  depends_on xcode: :build
  depends_on macos: :sonoma

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release", "--product", "backstage"
    bin_path = Utils.safe_popen_read("swift", "build", "-c", "release", "--show-bin-path").strip
    bin.install "#{bin_path}/backstage"

    # Injected into the dev builds and test runners `launch` starts, to make them inaudible.
    # Universal: an injected app's x86_64 (Rosetta) child would otherwise fail to start.
    # backstage finds it in ../lib/backstage relative to its resolved path.
    (lib/"backstage").mkpath
    system "xcrun", "clang", "-dynamiclib", "-O2", "-arch", "arm64", "-arch", "x86_64",
           "-mmacosx-version-min=14.0", "-framework", "CoreAudio",
           "-install_name", "@rpath/libbackstage-inaudible.dylib", "-Wl,-headerpad_max_install_names",
           "-o", lib/"backstage/libbackstage-inaudible.dylib",
           "Sources/BackstageInaudible/inaudible.c"
  end

  def caveats
    <<~EOS
      Grant whatever runs backstage (your terminal or agent host) these, in
      System Settings > Privacy & Security:
        - Accessibility
        - Screen & System Audio Recording
        - System Audio Recording Only (to measure app audio with --audio; muting works without it)

      Then check and install the agent skills:
        backstage doctor
        backstage install            # add --hooks for the hook too

      After `brew upgrade backstage`, restart the daemon so it runs the new version
      (this quits the apps agents have open backstage):
        backstage stop --all && backstage start
    EOS
  end

  test do
    assert_equal "backstage #{version}", shell_output("#{bin}/backstage version").strip
  end
end
