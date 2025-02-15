{ lib
, buildGoModule
, fetchFromGitHub
, installShellFiles
, pandoc
, makeWrapper
}:

buildGoModule rec {
  pname = "ov";
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "noborus";
    repo = "ov";
    rev = "refs/tags/v${version}";
    hash = "sha256-tbJ3Es6huu+0HcpoiNpYLbxsm0QCWYZk6bX2MdQxT2I=";
  };

  vendorHash = "sha256-EjLslvc0cgvD7LjuDa49h/qt6K4Z9DEtQjV/LYkKwKo=";

  ldflags = [
    "-X main.Version=v${version}"
    "-X main.Revision=${src.rev}"
  ];

  subPackages = [ "." ];

  nativeBuildInputs = [
    installShellFiles
    pandoc
    makeWrapper
  ];

  outputs = [ "out" "doc" ];

  postInstall = ''
    installShellCompletion --cmd ov \
      --bash <($out/bin/ov completion bash) \
      --fish <($out/bin/ov completion fish) \
      --zsh <($out/bin/ov completion zsh)

    mkdir -p $out/share/$name
    cp $src/ov-less.yaml $out/share/$name/less-config.yaml
    makeWrapper $out/bin/ov $out/bin/ov-less --add-flags "--config $out/share/$name/less-config.yaml"

    mkdir -p $doc/share/doc/$name
    pandoc -s < $src/README.md > $doc/share/doc/$name/README.html
    mkdir -p $doc/share/$name
    cp $src/ov.yaml $doc/share/$name/sample-config.yaml
  '';

  meta = with lib; {
    description = "Feature-rich terminal-based text viewer";
    homepage = "https://noborus.github.io/ov";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ farcaller ];
  };
}
