#!/usr/bin/env python3
"""Build and launch the native SwiftUI app in Debug without a Dart VM connection."""

import argparse
from collections import deque
from dataclasses import dataclass
import json
from pathlib import Path
import plistlib
import shlex
import subprocess
import sys
from typing import List, Optional, Set


ROOT = Path(__file__).resolve().parents[1]
DERIVED_DATA = ROOT / "build/native_ios"
BUILD_LOG = DERIVED_DATA / "build.log"


class RunnerError(Exception):
    """An actionable command or device-selection failure."""


@dataclass(frozen=True)
class Device:
    identifier: str
    name: str
    simulator: bool
    available: bool
    os_version: str


def command_json(arguments: List[str]):
    result = subprocess.run(
        arguments, cwd=ROOT, capture_output=True, text=True, check=False
    )
    if result.returncode:
        details = result.stderr.strip() or result.stdout.strip()
        raise RunnerError(f"{shlex.join(arguments)} failed:\n{details}")
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise RunnerError(f"Invalid JSON from {shlex.join(arguments)}") from error


def discover_devices() -> List[Device]:
    inventory = command_json(["xcrun", "xcdevice", "list", "--timeout", "2"])
    devices = {}
    for item in inventory:
        if item.get("platform") not in {
            "com.apple.platform.iphoneos",
            "com.apple.platform.iphonesimulator",
        }:
            continue
        device = Device(
            identifier=item["identifier"],
            name=item["name"],
            simulator=item.get("simulator", False),
            available=item.get("available", False) and not item.get("ignored", False),
            os_version=item.get("operatingSystemVersion", ""),
        )
        previous = devices.get(device.identifier)
        if previous is None or device.available:
            devices[device.identifier] = device
    return sorted(devices.values(), key=lambda device: (device.simulator, device.name))


def booted_simulators() -> Set[str]:
    inventory = command_json(["xcrun", "simctl", "list", "devices", "--json"])
    return {
        device["udid"]
        for runtime in inventory.get("devices", {}).values()
        for device in runtime
        if device.get("state") == "Booted"
    }


def device_listing(devices: List[Device], booted: Optional[Set[str]] = None) -> str:
    lines = []
    for device in devices:
        kind = "simulator" if device.simulator else "device"
        state = "available" if device.available else "unavailable"
        if booted is not None and device.identifier in booted:
            state = "booted"
        lines.append(
            f"  {device.name} | {device.identifier} | {kind}, {state} | iOS {device.os_version}"
        )
    return "\n".join(lines) or "  No iOS devices found."


def select_device(devices: List[Device], requested: Optional[str]) -> Device:
    if requested:
        # Match identifiers first; names must match exactly and identify one device.
        matches = [device for device in devices if device.identifier == requested]
        if not matches:
            matches = [device for device in devices if device.name == requested]
        if len(matches) != 1:
            reason = "Device name is ambiguous" if matches else "Device was not found"
            raise RunnerError(f"{reason}: {requested}\n{device_listing(matches or devices)}")
        if not matches[0].available:
            raise RunnerError(f"Device is unavailable:\n{device_listing(matches)}")
        return matches[0]

    physical = [device for device in devices if device.available and not device.simulator]
    if len(physical) == 1:
        return physical[0]
    if len(physical) > 1:
        raise RunnerError(
            "Multiple physical devices are available. Choose one with --device ID:\n"
            + device_listing(physical)
        )
    booted = booted_simulators()
    simulators = [
        device
        for device in devices
        if device.available and device.simulator and device.identifier in booted
    ]
    if len(simulators) == 1:
        return simulators[0]
    reason = "Multiple simulators are booted" if simulators else "No default device is available"
    raise RunnerError(
        f"{reason}. Choose an exact ID or name with --device:\n"
        + device_listing(simulators or devices, booted)
    )


def run_command(arguments: List[str]) -> None:
    print(f"$ {shlex.join(arguments)}", flush=True)
    result = subprocess.run(arguments, cwd=ROOT, check=False)
    if result.returncode:
        raise RunnerError(f"Command failed with exit code {result.returncode}.")


def build_app(device: Device) -> Path:
    if not (ROOT / "ios/Flutter/Generated.xcconfig").is_file():
        raise RunnerError(
            "Missing ios/Flutter/Generated.xcconfig. Run `flutter pub get` first.\n"
            "If it is still missing, prepare it with "
            "`flutter build ios --config-only --debug --no-codesign`."
        )
    DERIVED_DATA.mkdir(parents=True, exist_ok=True)
    arguments = [
        "xcodebuild",
        "-workspace", str(ROOT / "ios/Runner.xcworkspace"),
        "-scheme", "Runner",
        "-configuration", "Debug",
        "-destination", f"id={device.identifier}",
        "-derivedDataPath", str(DERIVED_DATA),
        "build",
    ]
    if device.simulator:
        arguments.append("CODE_SIGNING_ALLOWED=NO")
    print(f"Building native Debug for {device.name}. Log: {BUILD_LOG}", flush=True)
    with BUILD_LOG.open("w") as log:
        result = subprocess.run(arguments, cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
    if result.returncode:
        with BUILD_LOG.open(errors="replace") as log:
            tail = "".join(deque(log, maxlen=50))
        raise RunnerError(f"Build failed. Last log lines:\n{tail}\nFull log: {BUILD_LOG}")
    platform = "iphonesimulator" if device.simulator else "iphoneos"
    app = DERIVED_DATA / "Build/Products" / f"Debug-{platform}" / "Runner.app"
    if not app.is_dir():
        raise RunnerError(f"Build completed but the app bundle was not found: {app}")
    return app


def launch_app(device: Device, app: Path, console: bool) -> None:
    with (app / "Info.plist").open("rb") as file:
        bundle_id = plistlib.load(file).get("CFBundleIdentifier")
    if not bundle_id:
        raise RunnerError(f"Missing CFBundleIdentifier in {app / 'Info.plist'}")

    if device.simulator:
        # bootstatus -b also boots a stopped simulator and waits until it is ready.
        run_command(["xcrun", "simctl", "bootstatus", device.identifier, "-b"])
        run_command(["xcrun", "simctl", "install", device.identifier, str(app)])
        arguments = ["xcrun", "simctl", "launch", "--terminate-running-process"]
        if console:
            arguments.append("--console-pty")
        arguments.extend([device.identifier, bundle_id])
    else:
        run_command([
            "xcrun", "devicectl", "device", "install", "app",
            "--device", device.identifier, str(app),
        ])
        arguments = [
            "xcrun", "devicectl", "device", "process", "launch",
            "--device", device.identifier, "--terminate-existing",
        ]
        if console:
            arguments.append("--console")
        arguments.append(bundle_id)

    print("Swift breakpoints: use Xcode Cmd+R or Debug > Attach to Process.", flush=True)
    if console:
        print("Streaming native console; Ctrl+C stops the session. No Dart VM is required.", flush=True)
    run_command(arguments)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument("--device", metavar="ID_OR_NAME", help="exact device ID or name")
    selection.add_argument("--list", action="store_true", help="list iOS devices and simulators")
    parser.add_argument("--no-console", action="store_true", help="launch and return without streaming logs")
    arguments = parser.parse_args()
    try:
        devices = discover_devices()
        if arguments.list:
            print(device_listing(devices, booted_simulators()))
            return 0
        device = select_device(devices, arguments.device)
        print(f"Native SwiftUI Debug: {device.name} ({device.identifier})", flush=True)
        launch_app(device, build_app(device), console=not arguments.no_console)
        return 0
    except KeyboardInterrupt:
        return 130
    except (RunnerError, OSError, plistlib.InvalidFileException) as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
