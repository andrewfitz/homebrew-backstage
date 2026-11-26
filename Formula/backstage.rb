class Backstage < Formula
  desc "Lets agents drive macOS apps on an invisible display, off the user's screen"
  homepage "https://github.com/andrewfitz/backstage"
  url "https://github.com/andrewfitz/backstage/archive/refs/tags/v1.3.3.tar.gz"
  sha256 "54b92ef6b55f3929264d96d2e87828102bee0fa7c663c770a110c6edf2f37faa"
  head "https://github.com/andrewfitz/backstage.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/andrewfitz/homebrew-backstage/releases/download/backstage-1.3.3"
    sha256 cellar: :any, arm64_tahoe:   "d4e414d7284a4d319fcd1c5db1245cdcff83ebb26314b94bd73df8b71ba9f829"
    sha256 cellar: :any, arm64_sequoia: "be84cc30b043da4995563a2213f1cac791a42fe0bbc2483a86e8d584799e1d1a"
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
