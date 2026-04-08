# azel TODO

## Hardware portability

- Test boot behavior across multiple UEFI systems, not just one installer machine.
- Review kernel module coverage after generating the final `hardware-configuration.nix` on the target hardware.
- Add a conservative fallback path that remains usable when the preferred Wayland desktop stack fails.
- Evaluate whether extra firmware packages are needed for broader Wi-Fi, Bluetooth, and GPU compatibility.
- Audit graphics-related defaults for portability across Intel, AMD, and hybrid GPU systems.
- Decide whether Secure Boot support should be added for machines that ship with stricter UEFI defaults.
- Verify suspend, resume, external display hotplug, and USB boot behavior on real hardware.
