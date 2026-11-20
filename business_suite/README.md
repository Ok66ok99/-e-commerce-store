# منصة المنشآت — Flutter source (early implementation)

**This is NOT a completed production app.** No GitHub Actions run has been performed or verified. No APK is included.

## Build via GitHub
1. Create an empty GitHub repository and upload the entire contents of this directory, including `.github/workflows/android.yml`.
2. Push to the default branch. Open **Actions → Flutter Android CI**.
3. Select the latest run; verify `Static analysis`, `Unit tests`, and `Build release APK` all have green check marks.
4. Download `business-suite-release-apk` from the run's Artifacts section. The APK is unsigned with a production release key (Flutter default debug signing may apply depending on setup), so configure release signing before publishing.
5. If the workflow fails, treat the run as failed and inspect logs. Do not claim success from source code alone.

## Implemented in source
- Six activity-specific service and card-label catalogs
- Local customer creation and Saudi phone normalization / duplicate prevention
- Local sales and simple example points (1 point per whole SAR)
- Local bookings and countdown within app
- Basic discount image sharing through device share sheet
- JSON export/share and paste-to-restore
- Automated domain unit tests and CI build workflow

## Not implemented / production blockers
- Backend, developer console, licensing, multi-device sync, interactive hosted booking links, official WhatsApp API, OCR, five membership tiers, rewards redemption, staff roles, full 10 luxury templates per activity, robust image asset system, audit trails, cancellation/refunds, secure database, comprehensive integration/device tests, localization/accessibility review, production signing.
- Current local persistence uses SharedPreferences and is unsuitable for large/critical business records.
- Activity selection is not locked after setup.
- WhatsApp sharing uses the OS share sheet; it does not automatically send.
- Unit tests are supplied but **have not run in this environment**.

## Local commands
```
flutter create --platforms=android --project-name business_suite .
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release
```
