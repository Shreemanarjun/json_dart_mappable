# JSON DART Mappable Converter

A state-of-the-art web application to transform JSON into type-safe Dart classes using the powerful `dart_mappable` package. Built with **Jaspr**, the modern web framework for Dart.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Jaspr](https://img.shields.io/badge/built%20with-Jaspr-blue.svg)

## 🚀 Key Features

- **Modern Bento UI**: A beautiful, premium interface designed with glassmorphism and reactive layouts.
- **Smart Nullability**: Intelligent analysis of JSON structures across multiple records to determine optional fields.
- **Production-Ready**: Generates idiomatic Dart code compatible with `dart_mappable` v4+.
- **Real-Time Generation**: See your Dart classes updated instantly as you type your JSON.
- **Customizable**: Control class names, nullability policies, and advanced constructor options.
- **Developer Utilities**: One-click format, minify, copy, and download functionality.

## 🛠️ Technology Stack

- **Frontend**: [Jaspr](https://jaspr.site) (Dart Web Framework)
- **Styling**: [Tailwind CSS](https://tailwindcss.com) via `jaspr_tailwind`
- **Core Logic**: Custom JSON analyzer and Dart code generator
- **Highlighting**: [Highlight.js](https://highlightjs.org) for beautiful code previews

## 🏗️ Development

### Running Locally

1. Install the Jaspr CLI:
   ```bash
   dart pub global activate jaspr_cli
   ```

2. Serve the project:
   ```bash
   jaspr serve
   ```
   The development server will be available on `http://localhost:8080`.

### Building for Production

Build the highly optimized web assets:
```bash
jaspr build
```
The output will be located inside the `build/jaspr/` directory.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---
Created with ❤️ by **Shreeman Arjun Sahu** (2025)
