# MangaNest · Multi-Site Manga Downloader

> 📖 Full usage guide: **Docs/Usage.md** (main UI walkthrough + download flow + adding sites + FAQ)

A manga downloader that runs on Windows and supports **multiple manga websites**: built-in crawlers + custom site adapters (JSON rules) + an **Auto Site Analyzer** wizard — paste any new website, the program automatically analyzes its search/chapter/image structure and generates a reusable adapter.

---

## 1. UI Guide

After launch (double-click `start.bat`), the main window contains:

| Area | Description |
|---|---|
| **Site selector** | Dropdown to choose a manga website (built-in sites + your custom adapters) |
| **Comic name input** | Type the manga title (e.g. Sample Manga A, Sample Manga B) |
| **Search button** | Searches the selected site; candidates are listed below; click one to auto-fill and open its detail page |
| **Need login** | When checked, a login flow runs before opening chapters: `Open Login` (pops a browser login page) → scan QR / sign in → `Login Done` (cookies saved). **Required for chapters that need login.** |
| **Load chapter list** | Reads all chapters of the comic (chapter number + name), builds a checkable list |
| **Chapter list** | Select/deselect chapters to download; supports partial selection and range selection |
| **Start download** | Downloads all images of the selected chapters in order (auto-creates `ComicName/ChapterName/image.jpg`) |
| **Retry failed images** | Retries previously failed image downloads |
| **Retry failed chapters** | Batch-retries failed chapters |
| **Progress / log window** | Real-time logs of every step (search → chapters → images → download → cover) |

Folder structure after download:

```
Sample Manga/
├── 0/cover.jpg                 # cover
├── 128 Final Chapter·A New Start/
│   ├── 1.jpg
│   ├── 2.jpg
│   └── ...
└── 127 Bonus Story/
    ├── 1.jpg
    └── ...
```

> Do not close the black console window — the program prints progress there. To fully exit, close the console or the main window.

---

## 2. Supported Sites

**Built-in crawlers** (code-level adapters, most stable):

| Site | Notes |
|---|---|
| Tencent Anime ac.qq.com | Chapter list includes names; images fetched directly; chapters requiring login/VIP are auto-detected and prompted |
| Manwa, Copymanga and other built-in sites | Built-in adapters |

**Custom adapter sites** (preloaded in `自定义站点/*_适配器.json`):

| Adapter | Site | Highlights |
|---|---|---|
| `kanman_适配器.json` | kanman.com | Chapter image URLs live in page JS variable — full & reliable |
| `zymk_适配器.json` | zymk.cn | Chapter pages redirect to kanman; rules compatible |
| `cosz_适配器.json` | cosz.com | WordPress gallery; lazy-loaded data-src supported |
| `漫蛙漫画_适配器.json` | Manwa | Sample adapter |

> **Paid/VIP chapters** are limited by site account permissions (guests see preview pages only). After login, free chapters download fully; VIP chapters require the corresponding membership — this tool does not bypass paywalls.

---

## 3. Add Any New Website (Auto Analyzer Wizard)

Open **Auto Analyze Site** from the main UI and follow four steps:

1. **Open & analyze**: paste the homepage URL; the program detects the search box and search entry
2. **Trial search**: type a keyword; the program lists candidate comic links (filterable & correctable)
3. **Analyze chapters**: open the selected comic's detail page; the program scrolls/paginates to detect all chapters (with names)
4. **Analyze images → save adapter**: opens a chapter page, analyzes image structure, generates rules and **saves as `自定义站点/NewSite_适配器.json`** — reusable forever

After saving, refresh the site list and the new site works like a built-in one.

### Adapter JSON Fields

```json
{
  "site_name": "Site display name",
  "site_url": "https://site.com/",
  "search": {
    "mode": "get",
    "url_template": "https://site.com/search?keyword={kw}",
    "result_js": "return []; // extract comic links [{url,title},...] from the page"
  },
  "detail": {
    "chapters_js": "return []; // extract chapter links [{url,title},...]",
    "chapters_scroll": false,
    "chapters_reverse": false,
    "cover_js": "return '';  // cover image URL"
  },
  "chapter": {
    "images_js": "return [];  // chapter image URLs",
    "scroll_to_load": false
  }
}
```

- `chapters_scroll: true`: scroll + click "Load more" until the whole lazy-loaded chapter list is loaded
- `scroll_to_load: true`: scroll to bottom first when chapter images are lazy-loaded

---

## 4. Environment & Installation

**Requires Python 3.10** (verified on `Python 3.10.10`), dependencies:

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

**Install dependencies** (admin command line):

```bat
pip install DrissionPage aiohttp aiofiles execjs pycryptodome requests requests_file lxml
```

Node.js: download from https://nodejs.org/ (runtime for execjs).

## 5. One-Click Start

Double-click **`start.bat`** after extraction (the script auto-detects Python, checks network & dependencies, then launches the GUI).

> If a module is missing: `pip install <module>` and start again.

## 8. Add Your Own Site Crawler (Two Ways)

- **No coding**: use the **Auto Analyze Site** wizard or **New Adapter** in the main UI to generate a JSON adapter (see `Docs/How-to-Add-a-New-Site.md`)
- **Python coder**: use the **Crawler Source Manager** window → **New from template** → tweak → save; source goes to `sites_data/` and is loaded automatically (see `Docs/How-to-Add-a-Custom-Crawler.md`)

### Standalone EXE Build (recommended for non-Python users)

`MangaNest.exe` (single-file PyInstaller build with DrissionPage bundled) is available in the release package:

1. Download & extract (the **exe must stay in the same folder as `sites_data`, `自定义站点`, `config.json`**)
2. Double-click `MangaNest.exe` — no Python installation needed

> Site folders (`sites_data`, `自定义站点`) are read from the exe's directory; don't move the exe alone.

---

## 6. FAQ

| Issue | Cause & Fix |
|---|---|
| Black window flashes and closes | The bat file was edited (LF line endings/encoding). Use the original bat; or run `python gui.py` manually |
| `No module named 'xxx'` | Missing dependency — install per Section 4 |
| Chapter list shows numbers only | Old bug, fixed; new version shows "Chapter N · name" |
| A chapter downloads only 1–2 images | It's a paid/login chapter; guests see a preview only. Check "Need login", log in, retry |
| Search returns unrelated results | Some sites' search API ignores keywords (e.g. kanman shows hot list); adapters apply keyword filtering + list fallback |
| Missing chapters / can't reach next page | Lazy-loaded sites need scrolling; new version auto-scrolls & paginates |
| UI images mixed into downloads | Restricted to real images inside the chapter container |

---

## 7. Disclaimer (bilingual in `Docs/DISCLAIMER.txt`)

1. For **personal learning & research only — no commercial use**.
2. Downloaded content belongs to the original authors/platforms; **delete within 24 hours** and support the official releases.
3. Users must comply with target sites' terms of service; all consequences are the user's own responsibility.
4. This tool **does not bypass paywalls, crack memberships, or aid piracy**; VIP content requires the proper entitlement on the platform.
5. Provided "as is" — no warranty on fitness, stability, or completeness; no liability for any direct or indirect loss.

Using this software means you agree to the above terms.
