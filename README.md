# MangaNest · Multi-Site Manga Downloader

📖 Full usage guide: `Docs/Usage.md` (main UI walkthrough + download flow + adding sites + FAQ)

A manga downloader that runs on Windows and supports multiple manga websites: built-in crawlers + custom site adapters (JSON rules) + an Auto Site Analyzer wizard — paste any new website, the program automatically analyzes its search/chapter/image structure and generates a reusable adapter.

**v1.1 new features**: 🔄 **Format Converter page** (turn downloaded manga images into PDF / CBZ / EPUB / MOBI e-books — one-click whole-book merge, multi-folder merge, automatic original cover), **startup self-check** (writes diagnostic logs), **one-click network-stack repair** script.

**v1.1.1 new features**: 🔐 **Secure Login Vault** — login sessions are now stored in an **AES-256-GCM encrypted container**:
- **Device-bound**: opens automatically on THIS PC (hardware fingerprint) — no password needed
- **Password unlock** for other computers (PBKDF2 200k iterations)
- **Auto-destroy**: 4 wrong passwords → all saved login data is permanently destroyed
- **Password rule**: at least 6 characters, must contain **letters + digits + symbols** (e.g. `Abc@123`)
- **Auto-login**: after logging in once, the program automatically uses the saved container — no more QR scans
- New **🔐 Password Manager** page (fold menu in the sidebar): view container status / set & change password / test password / clear container

**v1.1.2 new features**: ❓ **Security Question verification** - set a **custom security question** when creating the container password (e.g. "What is my hobby?" / "Name of my favorite person", free text, no length limit):
- Changing the password **requires answering the security question correctly** (retry allowed, no auto-destroy)
- Answer stored as a salted hash (only THIS PC can verify; other computers cannot read it)
- Forgot your password on this PC? Answer the security question -> reset a new password

---

## 1. UI Guide

After launch (double-click `start.bat`), the main window has three pages in the left sidebar (plus a collapsible **🔐 Password Manager** menu below Format Converter):

| Page | Purpose |
|---|---|
| 🏠 **Home** | Download comics: site selector, search, load chapter list, start download |
| 🔄 **Format Converter** | Merge downloaded manga images into e-books (PDF/CBZ/EPUB/MOBI) |
| 🔐 **Password Manager** | Click `🔐 密码管理 ▸` to expand → open the vault manager page (encrypted login containers) |
| ⚙ **Settings** | Image naming, window, download and browser options |

### 🏠 Home (download)

| Area | Description |
|---|---|
| **Site selector** | Dropdown to choose a manga website (built-in sites + your custom adapters) |
| **Comic name input** | Type the manga title |
| **Search button** | Searches the selected site; candidates are listed below; click one to auto-fill and open its detail page |
| **Need login** | When checked, a login flow runs before opening chapters: Open Login (browser login page) → scan QR / sign in → Login Done. **Login is saved as an encrypted container** (v1.1.1): next time the site needs login, the program auto-logs-in with the saved container — no QR scan needed. On this PC it unlocks automatically; on another PC you enter the container password; 4 wrong passwords destroy the container |
| **Load chapter list** | Reads all chapters of the comic (number + name), builds a checkable list |
| **Chapter list** | Select chapters to download (all / partial / range) |
| **Start download** | Downloads all images of the selected chapters (auto-creates `comic/chapter/1.jpg` structure) |
| **Retry failed images** | Retry images that failed before |
| **Retry failed chapters** | Batch-retry failed chapters |
| **Log window** | Live log of every step (search → chapters → images → download → cover) |

Folder structure after download:

```
ComicName/
├── 0/cover.jpg                 # cover (0-prefixed folder = cover directory)
├── 128 Final-Chap/
│   ├── 1.jpg
│   └── ...
└── 127 Side-Story/
    ├── 1.jpg
    └── ...
```

> Keep the console window open while downloading; close it or the main window to quit.

### 🔐 Secure Login Vault (v1.1.1)

Login sessions are stored in **encrypted containers** (`cookies/<site>_cookies.json`, AES-256-GCM + PBKDF2):

| Behavior | Description |
|---|---|
| **This PC** | Opens automatically via hardware fingerprint — you are never asked |
| **Another PC** | Requires the **container password** (set when login completes, or in Password Manager) |
| **4 wrong passwords** | The container **destroys itself** — all saved login data is wiped permanently |
| Password rule | ≥ 6 chars, must contain **letters + digits + symbols** |

**Password Manager page** (sidebar → `🔐 密码管理 ▸` → open):
- View each site's container status (encrypted / needs password / destroyed / none)
- Set or change the container password (no old password needed on this PC)
- Test a password (careful: wrong attempts count, 4 = destroy)
- Clear a container (delete that site's saved login, requires re-login)

### 🔄 Format Converter page (merge manga into a book)

| Control | Description |
|---|---|
| **Add folder** | Add a manga folder to convert |
| **Scan sub-folders (batch)** | Pick a comic root folder; every sub-folder containing images is added to the list at once |
| **Remove selected / Clear list** | Manage the list |
| **⚡ One-click whole-book merge** | **Merge all folders in the list (1 or many) into ONE file** (auto cover) |
| **Start convert** | Convert per current settings (whole book / per chapter, cover on/off) |
| Target format | PDF (universal) / CBZ (comic readers) / EPUB (e-book) / MOBI (needs Calibre) |
| Output folder | Where the result files are saved |
| **Per-chapter files** | Checked = one file per chapter (cover only on the first); unchecked = merge into one file |
| **Add cover to first book** | Default on: use the original manga cover automatically |
| **Choose cover image** | Pick any image manually as the cover (overrides auto detection) |
| Convert log | Live progress of every file |

**Cover rules**:
- Auto-detects a **0-prefixed folder** (e.g. `0/cover.jpg`) as the original cover; prefers `cover.*`, else the first image in that folder
- No 0-folder → no extra cover added; the first image naturally becomes the cover page
- Only the first book gets a cover; other chapters do not

**Supported image inputs**: JPG / JPEG / PNG / WebP / GIF / BMP (mixed formats OK)

**After conversion**: the source list is cleared automatically, ready for the next batch.

---

## 2. Supported Sites

**Built-in crawlers** (code-level adapters, most stable):

| Site | Notes |
|---|---|
| Tencent Anime ac.qq.com | Chapter list with names; direct image collection; chapters needing login/VIP are detected and reported |
| ManWa, Copymanga & other built-in sites | Built-in adapters |

**Custom adapter sites** (`custom-sites/*_adapter.json`, preinstalled):

| Adapter | Site | Notes |
|---|---|---|
| `kanman_adapter.json` | kanman.com | Image URLs in page JS variables; full and reliable |
| `zymk_adapter.json` | zymk.cn | Chapter pages redirect to kanman; compatible |
| `cosz_adapter.json` | cosz.com | WordPress gallery; supports lazy-load `data-src` |
| `manwa_adapter.json` | ManWa | Adapter example |

> Note: **paid/VIP chapters** are restricted by the site's account permissions (guests see preview pages only). After login, free chapters download fully; VIP paid chapters need a corresponding membership. The program never bypasses paywalls.

---

## 3. Adding Any New Site (Auto Analyzer wizard)

Open **Auto Site Analyzer** from the main window, 4 steps:

1. **Open & analyze**: paste the new site's homepage; the program analyzes search box / search entry structure
2. **Trial search**: type a keyword; the program lists candidate comic links (filter & fix rules)
3. **Analyze chapters**: open the selected comic detail page; the program scrolls / paginates to find all chapters (with names)
4. **Analyze images → save adapter**: opens a chapter page, analyzes image structure, generates rules and **saves to `custom-sites/newsite_adapter.json`** — reusable forever

After saving, refresh the site list: the new site works like built-in ones (search, chapter list, download).

### Adapter JSON fields

```json
{
  "site_name": "Display name",
  "site_url": "https://site.com/",
  "search": {
    "mode": "get",
    "url_template": "https://site.com/search?keyword={kw}",
    "result_js": "return []; // extract comic links [{url,title},...]"
  },
  "detail": {
    "chapters_js": "return []; // extract chapter links [{url,title},...]",
    "chapters_scroll": false,
    "chapters_reverse": false,
    "cover_js": "return '';  // cover image URL"
  },
  "chapter": {
    "images_js": "return [];  // chapter image URL array",
    "scroll_to_load": false
  }
}
```

- `chapters_scroll: true`: lazy-loaded chapter lists auto-scroll + click "load more" until complete
- `scroll_to_load: true`: lazy-loaded chapter images are scrolled into view before extraction

---

## 4. Environment & Installation

**Requires Python 3.10** (tested on `Python 3.10.10`), dependencies:

```
DrissionPage
aiohttp
aiofiles
execjs        # requires Node.js installed
pycryptodome
requests
requests_file
lxml
```

Install (admin shell):

```bat
pip install DrissionPage aiohttp aiofiles execjs pycryptodome requests requests_file lxml
```

Node.js: https://nodejs.org/ (runtime for execjs).

## 5. One-Click Start

Double-click **`start.bat`** (auto-checks Python, network and dependencies, then opens the GUI).

> Missing module? `pip install <module>` then start again.

### Self-check & logs

- Every launch runs a **self-check** (Python version / required modules / network socket / core files / writable dirs); results go to **`startup_diag.log`**
- Unexpected errors are written to **`crash.log`** (so even a "black window flashed by" can be diagnosed)
- If a blocking error is found, a dialog shows the log file location

### Network repair (WinError 10038)

If the program reports a network-stack failure (socket error WinError 10038) or cannot reach the internet:

1. Right-click **`fix-network-stack.bat`** → **Run as administrator** (resets Winsock / TCP-IP / DNS)
2. **Restart your PC**
3. The program can connect normally afterwards

> Format conversion is fully local and works without internet.

## 6. Adding Your Own Site Crawler (two ways)

- **No coding**: Auto Site Analyzer wizard / "New Adapter" — generate a JSON adapter (see `Docs/How-to-Add-a-New-Site.md`)
- **Python**: "Crawler Source Manager" window → "New from template" → edit → save; sources in `sites_data/` are auto-loaded (see `Docs/How-to-Add-a-Custom-Crawler.md`)

### Standalone EXE (recommended for non-Python users)

`MangaNest.exe` (PyInstaller one-file build, DrissionPage bundled) is provided in **GitHub Releases**:

1. Download the release package and extract (the EXE must stay in the same folder as `sites_data`, `custom-sites`, `config.json`)
2. Double-click `MangaNest.exe` — no Python needed

> Site folders (`sites_data`, `custom-sites`) are read from the EXE's own directory; don't move the EXE alone.

---

## 7. FAQ

| Problem | Cause & fix |
|---|---|
| Black window flashes and closes | BAT line-ending/encoding issue; use the original BAT from the package, or run `python gui.py` manually |
| No module named 'xxx' | Missing dependency; install per section 4 |
| Chapter list shows numbers only | Old bug, fixed; new version shows "Chap N + name" |
| A chapter downloads only 1–2 images | Paid / login-required chapter; guests see preview only; check "Need login" and retry |
| Search shows unrelated results | Some sites' search APIs don't filter by keyword (e.g. kanman shows hot list); adapters apply keyword filtering + fallback |
| Missing chapters / can't reach next page | Lazy-loaded sites need scrolling; new version auto-scrolls + paginates |
| Downloaded images include UI pictures | Restricted to real images inside the chapter container |
| Converted PDF won't open | Old object-number bug; fixed in v1.1 — re-convert |
| Conversion still produces separate files | Use "⚡ One-click whole-book merge" to merge all folders into ONE file |
| "Self-check found problems" dialog | Open `startup_diag.log`; for network issues use `fix-network-stack.bat` (section 5) |

---

## 8. Disclaimer (see `Docs/DISCLAIMER.txt` for English & Chinese)

1. This software is **for personal learning, research and technical exchange only; commercial use is strictly prohibited**.
2. Downloaded content is owned by the original authors/platforms; **delete within 24 hours** and support the official releases.
3. Users must obey each site's terms of service; all consequences of using this software are the user's own responsibility.
4. This software **provides no paywall bypass, membership cracking or piracy distribution**; VIP content requires proper permission on the platform.
5. Provided "as is"; the author makes no warranty of fitness, stability or completeness, and accepts no direct or indirect liability.

By using this software you agree to the terms above.
