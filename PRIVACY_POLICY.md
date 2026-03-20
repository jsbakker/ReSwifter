# Privacy Policy for ReSwifter

**Last updated: March 13, 2026**

Jeffrey Bakker built ReSwifter as a macOS application. This page is used to inform users regarding the policies surrounding the collection, use, and disclosure of personal information for anyone using the app.

## Summary

ReSwifter does not collect, transmit, or share any personal data. All data remains on your device.

## Data Collection and Use

ReSwifter does **not** collect, store, or transmit any personal information to external servers. The app has no network access and performs no analytics, telemetry, or crash reporting.

The following data is created and stored **locally on your device** within the app's sandbox:

- **Code snippets** you save, including their full text, summaries, language tags, and organizational metadata.
- **Folders** you create to organize your snippets.
- **Preferences** such as your selected syntax highlighting theme and last-used folder.

This data is stored using Apple's SwiftData framework and UserDefaults, both confined to the app's sandboxed container. No data is accessible to other applications.

## Xcode Source Editor Extension

ReSwifter includes an Xcode Source Editor Extension that allows you to send selected code from Xcode to the ReSwifter app for processing. Communication between the extension and the main app uses Apple's distributed notifications and a shared App Group container. This is a local inter-process communication mechanism — no data leaves your device during this process.

## On-Device AI Processing (Apple Intelligence)

ReSwifter uses Apple's FoundationModels framework to offer AI-powered features such as code summarization, cleanup, refactoring, conversion, documentation, and code review. This processing is performed **entirely on your device** using Apple Intelligence's local language models. No code or data is sent to any server — Apple's or otherwise — as part of these features.

Apple Intelligence must be enabled on your Mac for these features to be available. For more information about Apple Intelligence and on-device processing, refer to [Apple's documentation](https://support.apple.com/en-us/111907).

## Third-Party Services

ReSwifter does **not** use any third-party services, SDKs, analytics platforms, or advertising frameworks. The app includes open-source libraries (Textual and Web C Plus Plus) for syntax highlighting, which operate entirely locally with no network activity.

## App Sandbox

ReSwifter runs within Apple's App Sandbox. It does not request access to your file system, camera, microphone, location, contacts, or any other sensitive system resources beyond what is required for its core functionality.

## Data Sharing

ReSwifter does not share any data with third parties. There is no data to share, as nothing is collected or transmitted.

## Children's Privacy

ReSwifter does not collect personal information from anyone, including children under the age of 13.

## Changes to This Privacy Policy

This privacy policy may be updated from time to time. Any changes will be reflected on this page with an updated revision date.

## Contact

If you have any questions or concerns about this privacy policy, please contact:

Jeffrey Bakker
