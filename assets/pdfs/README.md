# Bundled study-guide PDFs

This folder holds PDF study guides ("الملازم") that ship with the app as
static assets. Anything listed in `manifest.json` here appears in the student
"الملازم" tab automatically — no code changes required.

## How to add a new PDF

1. Copy your PDF into this folder, e.g. `assets/pdfs/math-rev-2025.pdf`.
2. Open `manifest.json` and add an entry to the `guides` array:

   ```json
   {
     "id": "math-rev-2025",
     "name": "ملزمة الرياضيات للسادس الإعدادي 2025",
     "path": "assets/pdfs/math-rev-2025.pdf",
     "trackId": "preparatory",
     "subject": "الرياضيات",
     "author": "أ. محمد العبيدي",
     "pageCount": 80,
     "sizeBytes": 5200000,
     "priceIqd": 0,
     "locked": false,
     "description": "مراجعة شاملة لمنهج الرياضيات للسادس الإعدادي."
   }
   ```

3. Commit and push to `main`. The GitHub Action redeploys automatically;
   the new ملزمة shows up in the app within ~3 minutes.

## Field reference

| Field         | Type    | Required | Notes                                                                       |
| ------------- | ------- | -------- | --------------------------------------------------------------------------- |
| `id`          | string  | yes      | Unique slug (kebab-case). Must not collide with existing guide ids.        |
| `name`        | string  | yes      | Title shown in the catalog and detail screen.                              |
| `path`        | string  | yes      | Asset path relative to repo root, OR a full URL (https://…).               |
| `trackId`     | string  | yes      | One of `preparatory`, `engineering`, `medical`.                            |
| `subject`     | string  | yes      | Subject chip (e.g. `الرياضيات`, `الفيزياء`).                                |
| `author`      | string  | yes      | Author / teacher name.                                                     |
| `pageCount`   | int     | no       | Defaults to 0 if omitted.                                                  |
| `sizeBytes`   | int     | no       | Defaults to 0 if omitted. Used only for the file-size badge in the UI.    |
| `priceIqd`    | int     | no       | Defaults to 0. Set this for paid guides.                                   |
| `locked`      | bool    | no       | Defaults to `false`. `true` requires a coupon to unlock.                   |
| `description` | string  | no       | Long-form description for the detail screen.                               |
| `coverUrl`    | string  | no       | Optional cover image URL.                                                  |

## Using external URLs

If you'd rather host the PDF on Google Drive / Dropbox / anywhere, set
`path` to the public URL instead:

```json
{
  "id": "med-anatomy-2025",
  "name": "ملزمة التشريح",
  "path": "https://drive.google.com/uc?export=download&id=…",
  "trackId": "medical",
  ...
}
```

The app detects `http(s)://` and opens the URL directly. Otherwise it treats
`path` as a relative asset path and resolves it under the deployed site.
