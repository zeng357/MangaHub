# How to Add Your Own Site Crawler (Source Code)

The program supports **unlimited manga websites** via two paths:

| Way | Best for | Result |
|---|---|---|
| **Adapter (JSON rules)** | No coding | `自定义站点/SiteName_适配器.json`, see `How-to-Add-a-New-Site.md` |
| **Crawler source (.py file)** | Python coders who want full control | `sites_data/SiteName_crawler.py`, this document |

> Both are auto-detected: sources go in `sites_data/`, adapters in `自定义站点/`.
> After saving and refreshing, the site appears in the dropdown — usage is identical.

---

## 1. The Crawler Source Manager Window (how to use)

Click **Crawler Source Manager** in the main UI to open the dedicated window:

```
┌─────────────────────────────────────────────┐
│  Left: existing crawlers │  Right: source editor │
│  (site names)            │  filename / site name / login │
│                          │  ┌──────────────────┐  │
│  Refresh / Delete /      │  │ your crawler code │  │
│  Open Folder             │  │ (dark editor)     │  │
│                          │  └──────────────────┘  │
│  New from template │ Load reference template │ Save to sites_data │
└─────────────────────────────────────────────┘
```

**Add a new site in 5 steps:**

1. Click **New from template** → a commented crawler skeleton appears in the editor
2. Follow the comments and change 4 places (see "2. What to change" below):
   - `SITE_NAME` / `SITE_URL` (site name, URL)
   - `CONFIG.locators` (three XPath locators)
   - `search_comic` (the real search URL)
   - `get_chapter_image_urls` (image container/attribute — the most important)
3. Click **Save to sites_data** → the program validates (must have `class XxxCrawler:` and `SITE_NAME`), writes the file and refreshes the site list
4. Back in the main UI, pick your new site in the dropdown
5. Search → load chapter list → download

Other buttons:
- **Load reference template**: reads the fully-polished `yumanhua_crawler.py` into the editor for reference (it demonstrates AJAX search, lazy-load scrolling, real-image filtering — the whole toolkit). After referencing, **save under a new file name** — don't overwrite it
- **Delete selected**: removes a crawler (with confirmation)
- **Open folder**: opens `sites_data/` (you can also drop `.py` files written by others in here and click **Refresh list**)

---

## 2. Crawler Code Structure (what each method does)

A crawler = one class; the program calls your methods through a fixed "interface" — **method names must not change**:

| Method | Called when | Your job |
|---|---|---|
| `search_comic(title)` | Search clicked | Open the site → find the comic → return the **detail-page tab** |
| `get_chapter_count(detail_tab)` | Loading chapter list | Return the chapter count |
| `get_chapter_list(detail_tab)` | Showing chapter names | Return `[{num, url, title}, ...]` (**names required in the new version**) |
| `get_cover_image(detail_tab)` | Downloading cover | Return the cover image URL |
| `get_chapter_image_urls(chapter_tab)` | Downloading a chapter | Return **all image URLs** of this chapter (most important) |
| `collect_chapter_images(chapter_info)` | Batch download | Open chapter → get images → close tab (template done, usually unchanged) |
| `collect_chapters_images(...)` | Batch download | Concurrent loop over the above (template done, usually unchanged) |

Class-level variables (metadata the program reads):

| Variable | Meaning |
|---|---|
| `SITE_NAME` | Display name in the dropdown |
| `SITE_URL` | Site URL |
| `REQUIRES_LOGIN` | True if login is required (shows the "login" checkbox in the UI) |
| `CONFIG.locators` | Locators: `search_result` (first search result) / `cover_image` (cover) / `chapter_item` (chapter list items) |
| `CONFIG.image_attr` | Which attribute holds image URLs: `src` / `data-src` / `data-original` |
| `CONFIG.image_referer` | Anti-hotlink Referer for images; fill the site URL |

---

## 3. How to Change the Code (step by step, template-based)

### ① Site info

```python
SITE_NAME = 'Some Manga'             # dropdown display name
SITE_URL = 'https://xxx.com/'        # must end with /
REQUIRES_LOGIN = False
```

### ② Locators (use browser F12)

Open the site → F12 → click the arrow icon → click the element → copy the XPath:

```python
CONFIG = {
    'site_url': 'https://xxx.com/',
    'locators': {
        'search_result': 'xpath:/html/body/div[1]/div[3]/a',   # first search result
        'cover_image': 'xpath://div[contains(@class,"cover")]//img',  # cover
        'chapter_item': 'xpath://ul[contains(@class,"chapter")]/li',  # chapter list item
    },
    'image_attr': 'data-src',   # image attr: src / data-src / data-original — try until correct
    'chapter_group_size': None,
    'image_referer': 'https://xxx.com/',   # Referer used when downloading images
}
```

> To find the image attribute: open a chapter page, F12, inspect an `<img>` — if the real URL is in `src`, use `src`; if it's in `data-src`/`data-original` (lazy-load sites), use that.

### ③ Search URL

Look at what URL the browser jumps to when you search; put the keyword in the template:

```python
search_url = self.SITE_URL + 'search?keyword=' + comic_name   # change to the real format
```

- GET search: `https://xxx.com/search?keyword=title`
- API search (AJAX POST): see `_js_fetch_to_window` + `_wait_window` in `yumanhua_crawler.py`
- Some sites render search results with JS: `self.crawler.tab.get(search_url)` then `time.sleep(3)` for results

### ④ Chapter images (the most important)

Most common case (images directly in `<img>`, no lazy loading):

```python
def get_chapter_image_urls(self, chapter_tab):
    urls = chapter_tab.run_js(
        "return Array.from(document.querySelectorAll('img'))"
        ".map(function(i){var d=i.getAttribute('data-src')||'';var s=i.getAttribute('src')||'';return d||s;})"
        ".filter(function(u){return u && u.indexOf('http')===0;})"
    ) or []
    return [u for u in urls if is_normal_url(u)]
```

**Lazy-load sites** (placeholder images until you scroll) — add the scrolling logic first:

```python
def get_chapter_image_urls(self, chapter_tab):
    # 1) scroll to bottom to trigger lazy loading (see yumanhua for the pattern)
    last_h = -1
    for _ in range(60):
        h = chapter_tab.run_js('return document.body.scrollHeight') or 0
        chapter_tab.run_js('window.scrollTo(0, document.body.scrollHeight)')
        time.sleep(0.4)
        if h == last_h:
            time.sleep(1.2)
            if (chapter_tab.run_js('return document.body.scrollHeight') or 0) == h:
                break
        last_h = h
    # 2) collect real images; add filters if recommendations/UI images sneak in:
    urls = chapter_tab.run_js(
        "return Array.from(document.querySelectorAll('img'))"
        ".map(function(i){var d=i.getAttribute('data-src')||'';var s=i.getAttribute('src')||'';return d||s;})"
        ".filter(function(u){return u && u.indexOf('http')===0"
        " && u.indexOf('logo')<0 && u.indexOf('load.gif')<0 && u.indexOf('/static/')<0;})"
    ) or []
    return [u for u in urls if is_normal_url(u)]
```

**Only pick images inside the real container** (when the page mixes in recommendations — like yumanhua):

```python
# Real images live in .chapter-img-box: only collect images inside that container
js = "return Array.from(document.querySelectorAll('.chapter-img-box img')).map(...)"
```

**Images stored in a JS variable** (e.g. kanman): use the page variable directly, no need to wait for rendering:

```python
def get_chapter_image_urls(self, chapter_tab):
    urls = chapter_tab.run_js(
        "try{return window.comicInfo.current_chapter.chapter_img_list.map(function(i){return i.url||i;})}"
        "catch(e){return []}"
    ) or []
    return [u for u in urls if is_normal_url(u)]
```

### ⑤ Save & use

Click **Save to sites_data** → validated → site list refreshed → back in the main UI to select, test and download.
To fix something later: **Crawler Source Manager** → pick the file on the left → edit → save.

---

## 4. FAQ

| Symptom | Cause & fix |
|---|---|
| Save says "class XxxCrawler not found" | The class name must end with `Crawler`: `class NameCrawler:` |
| Search fails "no results" | ① `search_result` locator wrong (re-inspect with F12) ② search URL format wrong ③ search is API-based (use POST pattern) |
| Chapter count is 0 | `chapter_item` locator wrong; chapters hide behind a "load more" button → click it first |
| All chapter names show "Chapter N" | `get_chapter_list` extracts the wrong title element; use `a.get('title')` or the right element |
| Logo/recommendation images mixed in | Add filters (see ④ above); best to restrict to the real container |
| Only 1 image | The chapter needs login/payment → check **Need login** in the main UI → **Open Login** → scan QR |
| Images return 403 | Set `CONFIG.image_referer` to the site URL; or add a custom User-Agent in the main UI |
| Site fails to load | Open `sites_data/`, double-click your `.py` to see any red error (syntax/indentation) |

---

## 5. Advanced: Copy a Full Working Example

`sites_data/yumanhua_crawler.py` is a polished full crawler that demonstrates solutions for three "hard" site patterns:

1. **AJAX API search** (`_js_fetch_to_window`): issue a POST fetch inside the page to get JSON
2. **Chapter list split in two** (detail page shows only the latest chapters + API returns older ones): `_fetch_all_chapters` merges and dedupes
3. **Lazy loading + unrelated images mixed in** (scroll to trigger + collect only inside `.chapter-img-box`): `get_chapter_image_urls`

In the window, click **Load reference template** to read it in, swap the site name/URL/locators for yours, and **save under a new file name**.

> Can't code? Use the **Auto Analyze Site** wizard to generate an adapter JSON — no code at all.
