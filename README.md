# Cronix

Cronix is a native frontend for [opa334/Dopamine](https://github.com/opa334/Dopamine), pinned to upstream release 3.0.11, commit `448ff1a83d2bb807346f1f3d36332e4afbf9794a`.

Frontend attribution: Zenyical. Jailbreak engine: Lars Fröder (opa334) and upstream contributors. Original copyright notices and all bundled dependency licences remain in the app.

The build clones pristine upstream source, replaces only frontend files and launcher assets, checks that the engine, exploits, entitlements and bootstrap sources are unchanged, compiles the native UI preview and ARM64 app, and verifies the resulting IPA.

Preview screenshots use the actual shared native UI components in a simulator fixture. Preview activity messages are sample data used only by that fixture, which is not included in the IPA. Production activity is populated by real Dopamine log events and has no estimated percentage.

The resulting app is ad-hoc signed with jailbreak entitlements for installation through TrollStore on a supported device. An Apple development certificate is not provided. A successful build and simulator render do not establish successful physical-device jailbreak execution.

Cronix has no package-manager picker or management pages. It clears its enabled package-manager selection before running the engine, so the upstream bootstrap can initialize without installing Sileo or Zebra. Existing installed package-manager apps are not removed.
