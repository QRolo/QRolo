# QRolo

A nullsafe QR code scanner plugin supporting Flutter web. Flutter web qr scanner.

Note script src usage in web/index.html

Note that we are using the (not-quite) bleeding edge versions of Flutter Dart beta

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Git hooks

Created with:

```sh
# Care around ! expansion
echo "#"'!'"/bin/sh
exec flutter format ./lib/ ./test/
" >> .git/hooks/pre-commit

chmod +x .git/hooks/pre-commit
```
