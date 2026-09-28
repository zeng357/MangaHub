# MangaHub · Usage Guide

A multi-site manga downloader (chapter-list edition). Supports Tencent Anime, kanman, zymk, cosz, Manwa and other built-in sites, plus **any manga website** (JSON adapter / Python crawler source).

---

## 1. How to Launch

| Version | How to start |
|---|---|
| **Source version** | Extract → double-click `start.bat` (requires Python 3.10 + dependencies, see README) |
| **Standalone EXE** | Extract → double-click `MangaHub.exe` (no Python needed) |

> Note: the exe must stay in the **same folder** as `sites_data`, `自定义站点`, `config.json`. Don't move the exe alone.

---

## 2. Main UI Areas (top to bottom)

### 2.1 Site selection row

```
Site: [dropdown▼] Add File  Add Folder  Remove Site  Refresh  Open Folder       N sites loaded
```

- **Dropdown**: choose the manga website (built-in sites + your custom adapters)
- **Add File / Add Folder**: add `.py` crawler files or whole folders to the site library
- **Remove Site**: remove the currently selected site
- **Refresh**: rescan site folders (use after adding/removing)
- **Open Folder**: open the `sites_data/` folder (crawler sources live here)

### 2.2 Adapter row (custom site entry)

```
Adapter: Auto Analyze Site  New Adapter  Edit Adapter  Test Adapter  Open Custom Sites  Crawler Source Manager
```

| Button | Purpose |
|---|---|
| **Auto Analyze Site** | 4-step wizard: enter URL → auto-analyze search/chapter/image rules → generate adapter (no coding) |
| **New Adapter** | Manually create an adapter form (JSON rules) |
| **Edit Adapter** | Modify an existing adapter |
| **Test Adapter** | Real verification: search → chapter count → first-chapter image count; all green = ready to download |
| **Open Custom Sites** | Open the `自定义站点/` folder (adapter JSONs live here) |
| **Crawler Source Manager** | Dedicated window to add/edit your own Python crawler sources (.py), see Section 4 |

> Adapter = describe a site's search/chapter/image rules in JSON, no coding;
> Crawler source = full Python control over the scraping logic.

### 2.3 Comic info & actions

- **Site URL**: shows the current site URL (copyable)
- **Comic name**: type the manga title to download
- **Search comic**: search → opens the detail page when found
- **Load chapter list**: shows all chapters (**each with its name**), checkable for download
- **Download settings**: chapter range, save path, thread count, login requirement, etc.
- **Start download**: downloads checked/range chapters; each chapter saved as its own folder with live progress

---

## 3. First-Time Download Flow

1. Pick a site in the dropdown (e.g. Tencent Anime)
2. Type the manga title → click **Search**
3. Click **Load chapter list** → confirm chapter count & names are complete
4. Check the chapters / set the range → click **Start Download**
5. Check the save directory when done (structure: `ComicName/ChapterName/images`)

> Note: while downloading chapter pages the program opens browser tabs to collect images and **closes them automatically** after loading/downloading — no manual closing needed.

---

## 4. Add Your Own Site

### Method A: No coding → Auto Analyze wizard (recommended)

1. Click **Auto Analyze Site** → paste the site URL → Next
2. The wizard opens the site and analyzes: search method → chapter list → image URLs
3. Generates an adapter → auto-saved to `自定义站点/`
4. Back in the main UI, select the new site, test → download

### Method B: Python coder → Crawler Source Manager

1. Click **Crawler Source Manager** → **New from template** generates a commented skeleton
2. Follow the comments: site name/URL → three locators (inspect with F12) → search URL → image collection
3. **Save to sites_data** → auto-validated, site list refreshed
4. Use it in the main UI

> Detailed tutorials: `Docs/How-to-Add-a-Custom-Crawler.md` (source way), `Docs/How-to-Add-a-New-Site.md` (adapter way)

---

## 5. FAQ

| Issue | Fix |
|---|---|
| exe errors/crashes on launch | Check exe is in the same folder as sites_data & 自定义站点; download the latest build |
| Can't find a comic | Is the right site selected? Try another title; run **Test Adapter** to read the log |
| Chapter list incomplete | Detail page may lazy-load; wait after clicking **Load chapter list** |
| Few images / unrelated images downloaded | Optimize the site adapter's image filter via **Edit Adapter** or the crawler manager |
| Images return 403 | Set `image_referer` to the site URL in the adapter/crawler |
| Only 1 preview image | The chapter needs login/payment: check **Need login** → **Open Login** → scan QR, then retry |

---

## 6. Disclaimer

For personal learning & research only — no commercial use. Downloaded content belongs to the original authors/platforms; support the official releases. Users must comply with target sites' terms of service and bear all consequences themselves. See `Docs/DISCLAIMER.txt`.
