# RWLegacySupport
This project aims to provide support when transitioning RapidWeaver plugins from v8 to v9

This is a work in progress and there will be things missing. If you find something please raise a GitHub issue.


# A note on subclassing
Subclassing anything in the API makes it very hard for us to make any changes so the majority of classes in RW9's API have been restricted. If there's missing functionality in these restricted classes, please raise a GitHub issue with some sample code or reasoning showing what's required and we'll either add it to the SDK or open the class again.


# Steps to upgrade plugin from RW8 SDK to RW9 SDK

1. Check project settings
    - Enable Modules (C and Objective-C) = yes
    - Allow Non-modular Includes In Framework Modules = yes

1. Update frameworks
    - Remove RMKit & any references to it
    - Replace RW8's RWKit with RW9's RWKit

1. Add legacy support code
    This repository contains legacy code you may be using from the RW8 SDK. You only need to include the files your plugin requires.
    If you need `RWLegacyEntityConversion`, you must also add the `-fcxx-modules` flag to Compiler Flags in Compile Sources under Build Phases
    
    <img width="515" alt="Screenshot 2022-03-04 at 15 08 54" src="https://user-images.githubusercontent.com/143310/156795793-abcd6b1d-2de7-468c-92bd-0013dcc2a602.png">


1. Fix up the code
    - Change occurrences of `RWPlugin` to `RWPluginProtocol`
    - Change uses of `+[RWAbstractPlugin pathToAppTempDirectory]` to `-[RWAbstractPlugin tempFilesDirectory:]`
    - Change occurrences of `RWLinkStyleAbsolute` to `RWKitLinkStyleAbsolute`
    - Change occurrences of `RWHTMLView` to `RWCodeView` and set the language to HTML `myCodeView.language = RWCodeHighlightingLanguageHTML;`
    - Remove calls to broadcastMediaChanged, these shouldn’t be needed
    - Remove calls to broadcastPluginSettingsRequest, these shouldn’t be needed
    - `RWStyledTextView` only supports attributed strings in RW9, remove any references to plain text mode


# Archive and export

1. Check project settings
    - Enable Hardened Runtime = yes
    - Code Signing Team = Your team
    - Code Signing Identity = Your developer ID
    - Skip Install = No (otherwise the built product won't be included in the archive)
    - Installation Directory = / (make sure the plugin is inside the Products directory when archived)
1. Choose Archive from the Product menu in Xcode
1. Export the archive


# Check code signing
Run the following command on your plugin
```
codesign -dvvv [path to plugin]
```

If your plugin is universal (Intel / Apple Silicon) you should see this line
```
Format=bundle with Mach-O universal (x86_64 arm64)
```

For hardened runtime, look for "(runtime)"

```
CodeDirectory v=20500 size=7432 flags=0x10000(runtime) hashes=225+3 location=embedded
```

And for code signing, you should see something similar to this but using your developer ID
```
Authority=Developer ID Application: Realmac Software Limited (P97H7FTHWN)
Authority=Developer ID Certification Authority
Authority=Apple Root CA
TeamIdentifier=P97H7FTHWN
```

# Notarize the plugin

Create an archive of your plugin, right click and choose "Compress ..."

Use altool to upload the zip to the notary service
```
xcrun altool --notarize-app -f [myPlugin.rapidweaverplugin.zip] --primary-bundle-id [Plugin Bundle ID] -u [App Store Connect Username]
```

Remove the temporary zip file

See the following article to customise the notary process.
https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution/customizing_the_notarization_workflow

Once the notary service has completed, staple your plugin
```
xcrun stapler staple [myPlugin.rapidweaverplugin]
```

Finally, create a compressed archive of your stapled plugin for distribution.
