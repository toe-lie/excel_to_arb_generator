# 📝 **Excel to ARB Generator**

Tired of manually converting translation spreadsheets into `.arb` files for your Flutter or Dart projects? This command-line tool automates the process, letting you manage your localization in a simple Excel file—and generates all the necessary Application Resource Bundle (`.arb`) files instantly.

---

## 🚀 How It Works

You provide a link to a specially formatted Excel file, and the tool generates the corresponding `.arb` files for each language, ready to be used in your application.

```
Excel File → excel2arb Tool → Generated .arb Files
```

---

## 🔧 Prerequisites

Make sure you have the [Dart SDK](https://dart.dev/get-dart) installed.

---

## 📦 Installation

Activate the package globally:

```bash
dart pub global activate excel2arb
```

This makes the `excel2arb` command available globally in your terminal.

---

## 📁 Step 1: Format Your Excel Sheet

Create an Excel sheet following these key formatting rules. You can see a full example [here](https://shorturl.at/aP146).

### ✅ Key Formatting Rules

| Column | Description |
|--------|-------------|
| `Name [name]` | **Required.** Used as the JSON key in `.arb` files. |
| `Language {locale}` | **Required.** Columns with language names and 2-letter locale in `{}`. E.g., `English {en}` |
| `Remark` | Optional. Notes or instructions for translators. |
| `Placeholders [placeholders]` | Optional. JSON object defining placeholders and their types. |

### 🧾 Example Excel Layout

| Name `[name]` | Description `[description]` | Remark | English `{en}` | Myanmar `{my}` | Placeholders `[placeholders]` |
|---------------|-----------------------------|--------|------------------|------------------|-------------------------------|
| `greeting` | A welcome message |  | Hello, World! | မင်္ဂလာပါ လောကကြီး | |
| `welcomeUser` | Welcomes a specific user | Keep `{}` as-is | Hello `{userName}` | မင်္ဂလာပါ `{userName}` | `{"userName": {"type": "String"}}` |

---

## ⚙️ Step 2: Run the Generator

Once your Excel file is published and accessible via URL, run:

### ▶️ Basic Usage

```bash
excel2arb --excel-url <your-excel-file-url> --output-directory <path-to-output-folder>
```

If the script isn't found, try:

```bash
dart pub global run excel2arb --excel-url <your-excel-file-url> --output-directory <path-to-output-folder>
```

---

### 🧰 Command-Line Options

| Flag | Alias | Description | Default |
|------|-------|-------------|---------|
| `--excel-url` | `-u` | **(Required)** Public URL of the Excel file | |
| `--sheet-name` | `-s` | Sheet name to parse | `Localization` |
| `--output-directory` | `-o` | Directory to save `.arb` files | Current directory |
| `--gen-l10n` | `-g` | Also generate `l10n.yaml` config | `false` |

---

### 💡 Full Example

```bash
excel2arb -u https://example.com/sample.xlsx -s Localization -o output_dir -g true
```

---

## 💡 Bonus Tip #1: Using Google Sheets

You can use Google Sheets instead of Excel:

1. Create your spreadsheet in **Google Sheets** (follow the same format).
2. Go to **File → Share → Publish to web**.
3. Under the **Link** tab, select the specific sheet.
4. Change format to **Microsoft Excel (.xlsx)**.
5. Click **Publish**.
6. Copy the generated link and use it with `--excel-url`.

✅ This gives you a **live Excel download link**, so your team can collaborate in real-time—just run the generator when you're ready.

---

## 💡 Bonus Tip #2: Streamline with an IDE Plugin

If you're using Android Studio or any JetBrains IDE, streamline the sync using the [Dart Scripts Runner](https://plugins.jetbrains.com/plugin/18726-dart-scripts-runner) plugin.

### 🛠 Setup

1. Install **Dart Scripts Runner** from JetBrains Marketplace.
2. In `pubspec.yaml`, add:

```yaml
scripts:
  sync_localization:
    script: excel2arb -u https://shorturl.at/abcd -o lib/l10n/locales -g true
    description: Sync localization from google sheet
```

3. Replace the URL with your actual spreadsheet link.
4. Now, you can run `sync_localization` directly from the **Dart Scripts** tool window in your IDE—just one click!

![Dart Scripts Configuration](https://toelie.sgp1.digitaloceanspaces.com/public/pubspec-script-example.png)

---

## ✨ Features

- ✅ Downloads Excel files directly from a URL  
- ✅ Generates `.arb` files for all languages  
- ✅ Supports custom sheet names  
- ✅ Optionally generates `l10n.yaml`  
- ✅ Handles placeholders and their types

---

## 🤝 Contributing

Contributions are welcome! Feel free to open an issue or submit a PR on the [GitHub repo](https://github.com/toe-lie/excel_to_arb_generator).
