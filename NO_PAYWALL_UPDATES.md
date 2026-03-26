# No-Paywall Fork Modifications

This fork of Fleet DM has been modified to remove all premium license restrictions, making all features available without requiring a paid license.

## Changes Made

### 1. Core License Check (`server/fleet/app.go`)
**Modified:** `LicenseInfo.IsPremium()` method
- **Original:** Checked if tier was premium, trial, or basic
- **Modified:** Always returns `true` to enable all premium features

```go
func (l *LicenseInfo) IsPremium() bool {
    // No-paywall fork: Always return true to enable all premium features
    return true
}
```

### 2. License Loading (`ee/server/licensing/licensing.go`)
**Modified:** `LoadLicense()` function
- **Original:** Validated JWT license keys and returned appropriate tier
- **Modified:** Always returns a premium license with maximum privileges

```go
func LoadLicense(licenseKey string) (*fleet.LicenseInfo, error) {
    // No-paywall fork: Always return a premium license regardless of input
    return &fleet.LicenseInfo{
        Tier:                  fleet.TierPremium,
        Organization:          "No-Paywall Fork",
        DeviceCount:           999999,
        Expiration:            time.Now().AddDate(100, 0, 0), // 100 years from now
        Note:                  "All premium features enabled",
        AllowDisableTelemetry: true,
    }, nil
}
```

### 3. Context Helper (`server/contexts/license/license.go`)
**Modified:** `IsPremium()` context helper
- **Original:** Checked license from context
- **Modified:** Always returns `true`

```go
func IsPremium(ctx context.Context) bool {
    // No-paywall fork: Always return true to enable all premium features
    return true
}
```

## Features Now Available Without License

All premium features are now available, including:

### MDM Features
- ✅ Custom SCEP integrations (DigiCert, NDES, Smallstep, Custom SCEP Proxy)
- ✅ Fleet variables in MDM profiles
- ✅ Advanced Windows MDM commands
- ✅ Manual agent installation during setup

### Team Management
- ✅ Team-specific configurations
- ✅ Team-based software management
- ✅ Team filtering across all endpoints

### Software Management
- ✅ Software installers
- ✅ Software title management
- ✅ VPP (Volume Purchase Program) apps
- ✅ Fleet-maintained apps
- ✅ Software uninstallation

### Advanced Filtering
- ✅ CVE score filtering (CVSS ranges)
- ✅ Known exploit filtering
- ✅ Advanced vulnerability filters

### Scripts
- ✅ Team-specific scripts
- ✅ Script execution on teams

### User Management
- ✅ GitOps role (API-only users)
- ✅ MFA enforcement

### Configuration
- ✅ Custom transparency URL for Fleet Desktop
- ✅ Agent options with update_channels
- ✅ Extension labels configuration

### Device Features
- ✅ Fleet Desktop premium features
- ✅ Linux disk encryption escrow
- ✅ MDM migration workflows
- ✅ Device custom transparency messages

## Building the Modified Fork

Build as normal:

```bash
# Build the server
make fleet

# Or build with Docker
docker build -t fleet-no-paywall .
```

## Running

No license key is required. Simply start Fleet:

```bash
./build/fleet serve
```

The server will automatically operate with all premium features enabled.

## Important Notes

1. **No License Key Needed:** You don't need to provide any license key. The system will automatically enable all features.

2. **License Info Display:** The UI will show:
   - Organization: "No-Paywall Fork"
   - Tier: "premium"
   - Device Count: 999,999
   - Expiration: 100 years from server start

3. **Telemetry:** Telemetry can be disabled without restrictions.

4. **Updates:** When pulling updates from upstream Fleet DM, you'll need to reapply these modifications if they conflict.

## Maintenance

If you pull updates from the upstream Fleet repository, check these files for conflicts:
- `server/fleet/app.go`
- `ee/server/licensing/licensing.go`
- `server/contexts/license/license.go`

Simply ensure the modifications above are preserved after merging.

## Legal Notice

This is a fork for personal/internal use. Please respect Fleet's original licensing terms and consider supporting the project if you use it commercially.

## Original Fleet DM

This fork is based on Fleet DM: https://github.com/fleetdm/fleet

For the original project with proper licensing, please visit the official repository.
