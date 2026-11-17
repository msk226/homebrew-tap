class Workclock < Formula
  desc "Menu bar app showing today's work progress and earnings"
  homepage "https://github.com/msk226/work-clock"
  url "https://github.com/msk226/work-clock/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "REPLACE_WITH_TARBALL_SHA256"
  license "MIT"

  depends_on macos: :ventura

  def install
    system "./build.sh", "--output", prefix

    # 심볼릭 링크로 실행하면 앱 번들을 찾지 못해 로그인 시 실행 등록이 실패한다.
    # .app 안의 실행 파일을 직접 부르는 스크립트를 둔다.
    (bin/"workclock").write <<~SH
      #!/bin/bash
      exec "#{opt_prefix}/WorkClock.app/Contents/MacOS/WorkClock" "$@"
    SH
  end

  def caveats
    <<~EOS
      Link the app into ~/Applications so Launchpad and Spotlight can find it:
        mkdir -p ~/Applications
        ln -sf "#{opt_prefix}/WorkClock.app" ~/Applications/WorkClock.app
        open ~/Applications/WorkClock.app

      Use a symlink, not a copy. `brew upgrade` does not update a copied app.

      To start WorkClock at login, turn on "로그인 시 실행" in its menu, or run:
        workclock --enable-login

      Each build gets a new ad-hoc signature, so after `brew upgrade`
      you may need to turn the login item on again.

      Settings live in ~/.config/workclock/config.json.
    EOS
  end

  test do
    output = shell_output("#{bin}/workclock --print")
    assert_match "WorkClock #{version}", output
    assert_path_exists testpath/".config/workclock/config.json"
  end
end
