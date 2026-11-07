# Source provenance

Read when updating the vendored source or root payloads.

| Material | Upstream / version |
| --- | --- |
| Root host source in `root-source/src/` | [chris-ritsen/samsung-tv-root](https://github.com/chris-ritsen/samsung-tv-root), commit `3b97edf3762db7670585d73e29623dc56195bf98` |
| Compiled archive/root-agent payloads | Upstream release `v0.0.12`, extracted from `samsung-tv-root-0.0.12-macos-arm64.tar.gz` |
| Python SDB transport in `transport/install.py` | [simbasjungles/free-my-tv](https://github.com/simbasjungles/free-my-tv), commit `ed6be1ecaa98804c383fa021cdb648fd80f061f3` |
| Archive-root method and Tizen 9 service findings | [DemonKingSwarn's reproduction](https://github.com/DemonKingSwarn/samsung-tv-tizen-root/blob/main/ROOTING-RESEARCH.md) |
| AT-HUB startup-hook approach | [levkropp's AT-HUB implementation](https://github.com/levkropp/samsung-tv-root-untethered/tree/master/modules/at-hub-persistence) |

The downloaded root release archive matched its published SHA-256:

```text
8ee4587462963f8ad0374f921e41050bd9198a7cb0b15899a5f35a7ad8f50f2c
```

The original Free My TV v1.3.0 WGT download matched GitHub's digest:

```text
89a644830bbff9a2972529f88e70384d4f296db79e355f3c46115a860bdfc794
```

That WGT was then re-signed for the TV. Neither the signed package nor its certificate is included here. The original Samsung vendor boot script is also excluded; it is backed up on the TV and checked by hash before replacement.

Root host source and payloads are under the Unlicense; Free My TV's transport is MIT-licensed. The corresponding texts are in `licenses/`. The local hook follows the published AT-HUB approach, with a smaller worker limited to this setup's service policy and launcher behavior.
