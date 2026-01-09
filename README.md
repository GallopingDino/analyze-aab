# analyze-aab

Extract and analyze Android App Bundle (AAB) sizes. Track app size changes, compare builds, identify bloat.

## Overview

This toolkit consists of two scripts:

- **analyze-aab** — Extracts APK files from AAB files using bundletool, unpacks key APKs, and generates size reports. When multiple AABs are provided, automatically calls compare-reports to generate a comparison.
- **compare-reports** — Generates markdown tables comparing size reports with deltas between columns. Runs automatically when analyze-aab processes multiple AABs, but can also be used standalone on existing report files.

### Example Output

```
# AAB Size Comparison Report

| Device APKs                  | v1.0.0       | v1.1.0               |
|------------------------------|--------------|----------------------|
| Reference Device             | 132.88 Mb    | 141.17 Mb (+8.29 Mb) |
...

| Resources (from base-master) | v1.0.0       | v1.1.0               |
|------------------------------|--------------|----------------------|
| **Total**                    | **7.94 Mb**  | **10.20 Mb** (+2.26) |
|                              |              |                      |
| data.unity3d                 | 4.19 Mb      | 6.45 Mb (+2.26 Mb)   |
| unity default resources      | 3.75 Mb      | 3.75 Mb              |
...

| Bundles (from base-master)   | v1.0.0       | v1.1.0               |
|------------------------------|--------------|----------------------|
| **Total**                    | **60.76 Mb** | **66.81 Mb** (+6.05) |
|                              |              |                      |
| ui_assets_all.bundle         | 4.92 Mb      | 10.44 Mb (+5.52 Mb)  |
| level_1.bundle               | 9.66 Mb      | 9.76 Mb (+0.10 Mb)   |
| level_2.bundle               | 1.42 Mb      | 1.45 Mb (+0.03 Mb)   |
...
```

## Installation

### Requirements

This toolkit requires macOS and Java 8.

Analyze-aab uses bundletool to extract APKs from an AAB. It looks for bundletool in the PATH and, if not found, automatically downloads it on the first run. You may also specify bundletool path using the --bundletool option.

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/GallopingDino/analyze-aab/main/install.sh | bash
```

This installs to `~/.local/bin`. If that's not in your PATH, the script will show you how to add it.

### Manual Install

Clone the repository and add `bin/` to your PATH:

```bash
git clone https://github.com/GallopingDino/analyze-aab.git
```

### Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/GallopingDino/analyze-aab/main/install.sh | bash -s uninstall
```

## Usage

### analyze-aab

```bash
analyze-aab [options] [path]
```

#### Modes

- **No path**: processes all AAB files in current directory
- **Path to directory**: processes all AAB files in that directory
- **Path to AAB**: processes that file; output in its parent directory

#### Signing options

The script requires signing credentials to build APKs from AABs. All four flags are required:

- `--ks PATH`: Path to keystore file
- `--ks-key-alias ALIAS`: Key alias within keystore
- `--ks-pass PASSWORD`: Keystore password (or `file:/path` to read from file)
- `--key-pass PASSWORD`: Key password (or `file:/path` to read from file)

#### Analysis options

- `-s, --size-report FILE`: output file for size report (default: `aab-size-report.txt` in the unpacked AAB directory)
- `-c, --comparison-report FILE`: output file for comparison report (default: `size-comparison.txt` in the current directory)
- `-S, --sort size|diff`: sort method for comparison report (default: `diff`)
- `-b, --bundletool PATH`: path to bundletool JAR file
- `-h, --help`: show help

#### Examples

```bash
# Basic usage with signing credentials
analyze-aab --ks app.keystore --ks-key-alias mykey --ks-pass secret --key-pass secret ./my-app.aab

# Using password file for secure credential storage
analyze-aab --ks app.keystore --ks-key-alias mykey --ks-pass file:/path/ks.txt --key-pass file:/path/key.txt ./my-app.aab

# Process all AABs in a directory
analyze-aab --ks app.keystore --ks-key-alias mykey --ks-pass secret --key-pass secret ./aab-directory

# Custom size report path
analyze-aab --ks app.keystore --ks-key-alias mykey --ks-pass secret --key-pass secret --size-report size.txt ./my-app.aab

# Custom comparison report and sort method
analyze-aab --ks app.keystore --ks-key-alias mykey --ks-pass secret --key-pass secret --comparison-report cmp.txt --sort diff ./aabs
```

### compare-reports

```bash
compare-reports [options] [paths]
```

#### Modes

- **No path**: scans current directory for size reports
- **Directory path**: scans that directory for size reports
- **Report files**: compares specified report files directly

#### Options

- `-o, --output FILE`: output file (default: `size-comparison.txt` in current directory)
- `-S, --sort size|diff`: sort method (default: `diff`)
- `-h, --help`: show help

#### Examples

```bash
compare-reports                                       # scan current directory
compare-reports ./reports-directory                   # scan specific directory
compare-reports size1.txt size2.txt                   # compare specific reports
compare-reports --sort diff size1.txt size2.txt       # sort by diff
compare-reports --output cmp.txt size1.txt size2.txt  # custom output path
```

## Reference Devices

JSON device specifications in `devices/` are used to calculate device-specific APK sizes via bundletool's `get-size total` command.

The default device matches the one used in Google Play Console for size estimation. Add more JSON specs to this directory to include additional devices in reports.

## Contributing

This project uses [Conventional Commits](https://www.conventionalcommits.org/).

- `feat:` new features
- `fix:` bug fixes
- `docs:` documentation
- `refactor:` code changes that neither fix bugs nor add features

## License

The MIT License (MIT)
