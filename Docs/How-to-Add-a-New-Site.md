# How to Add a New Manga Website (Site Adapter)

This program supports **unlimited manga websites**. Each site is described by an **adapter (JSON rules)** — no Python coding needed.

## What Is an Adapter

A JSON file that describes three things about a site:

| Thing | In the adapter | Purpose |
|---|---|---|
| How to search | `search` | Search a comic → get the detail page URL |
| Where the chapter list is | `detail.chapters_js` | Extract all chapter links from the detail page |
| Where the images are | `chapter.images_js` | Extract comic image URLs from the chapter page |

Save it into the `自定义站点` folder and the program loads it automatically on startup/refresh — the site appears in the dropdown.

---

## Method 1: Create Inside the Program (recommended)

1. Launch the program; click **New Adapter** next to the Site dropdown
2. Fill the form:
   - **Site name**: anything, e.g. "Some Manga"
   - **Site URL**: e.g. `https://xxx.com/`
   - **Search mode**: most sites use "GET URL search"; a few need a POST API (e.g. yumanhua) — choose "POST API search"
   - **Search URL template**: for GET mode, use `{kw}` for the manga title, e.g. `https://xxx.com/search?keyword={kw}`
   - **POST path / form key**: for POST mode (e.g. path `/s`, key `k`)
   - **Search result JS / chapter list JS / chapter image JS**: three JS snippets (see "How to Write JS" below)
3. Click **Save** → the site list refreshes automatically
4. Type a comic title and click **Test Adapter** → the program really opens the site and logs "found comics, chapter count, first-chapter image count". **All green** means the adapter is correct and ready to download.

## Method 2: Place a JSON File Manually

Save the adapter JSON as `自定义站点/SiteName_适配器.json`, then restart the program or click **Refresh**. You can copy an existing file and edit it.

---

## Adapter JSON Fields — Full Reference

```json
{
  "site_name": "Site display name",
  "site_url": "https://site-domain/",
  "image_attr": "src",
  "search": {
    "mode": "get or post_fetch",
    "url_template": "GET mode: https://.../search?keyword={kw}",
    "post_path": "POST mode: API path, e.g. /s",
    "post_key": "POST mode: form key, e.g. k",
    "result_js": "return [...];   // search result JS"
  },
  "detail": {
    "chapters_js": "return [...];  // chapter list JS",
    "chapters_reverse": false,
    "cover_js": "return '...';    // cover JS (optional)"
  },
  "chapter": {
    "images_js": "return [...];   // chapter image JS",
    "scroll_to_load": false
  }
}
```

- `chapters_reverse`: set `true` if the chapter list is ordered **new → old** (the program reverses it to old → new so downloads start from chapter 1)
- `scroll_to_load`: set `true` if the chapter page only loads images **after scrolling to the bottom** (lazy loading)
- `cover_js`: optional; leave empty to skip the cover

---

## How to Write the JS (copy & tweak)

All three JS snippets run inside the browser and return values to the program.

### 1. Search result JS (`search.result_js`)

Runs on the **search page**, returns the comic list; the program takes the first one:

```js
// Typical: all "search result links" on the page, take the first 5
return Array.from(document.querySelectorAll('.result-list a'))
  .slice(0, 5)
  .map(a => ({ url: a.href, title: (a.textContent || '').trim() }));
```

POST API mode (results stored in `window.__rs`):

```js
return (window.__rs || []).slice(0, 10)
  .map(x => ({ url: 'https://site-domain/' + x.id + '/', title: x.name }));
```

### 2. Chapter list JS (`detail.chapters_js`)

Runs on the **detail page**, returns all chapters:

```js
return Array.from(document.querySelectorAll('.chapter-list a'))
  .map(a => ({ url: a.href, title: (a.getAttribute('title') || a.textContent || '').trim() }));
```

### 3. Chapter image JS (`chapter.images_js`)

Runs on the **chapter page**, returns the image URL array. **Key: only pick images inside the real comic container** — don't bring in recommendation/ads:

```js
// Example 1: images inside .reader img, real URL in data-src
return Array.from(document.querySelectorAll('.reader img'))
  .map(i => i.getAttribute('data-src') || i.getAttribute('src') || '')
  .filter(u => u && u.indexOf('http') === 0);

// Example 2: lazy loading, real URL in data-original
return Array.from(document.querySelectorAll('.comicimg img'))
  .map(i => i.getAttribute('data-original') || i.getAttribute('src') || '')
  .filter(u => u && u.indexOf('http') === 0);
```

**How to find the right selector**: open the chapter page in a browser → F12 → click a comic image → see which div it's in (e.g. `.reader`) and which attribute holds the real URL (`src` / `data-src` / `data-original`) — copy that.

---

## FAQ

| Symptom | Cause / Fix |
|---|---|
| "No comic found" in test | Check the search URL template and `result_js` (open the search page and look at the result links) |
| Empty chapter list | The chapter link selector is wrong; or the list is lazy-loaded/collapsed — use a more specific container |
| Ads/recommendations mixed into images | `images_js` scope too wide; restrict to the real container (e.g. `.reader img` / `.chapter-img-box img`) |
| Chapter order reversed | The list is new → old; set `chapters_reverse: true` |
| Site needs login | Adapters fit public sites; for login + encrypted-image complex sites, ask the author for a dedicated crawler |

---

## Example

`自定义站点/漫蛙漫画_适配器.json` is a complete example (translated from the built-in Manwa crawler's selectors). Click **Test Adapter** first to verify.

**Note**: adapters suit simple public manga sites. Complex sites like yumanhua (chapter list needs DOM+API merging and notice filtering) or Tencent/Bilibili (encrypted images) still use the built-in dedicated crawlers for best results.

---

## ⭐ Auto-Analyze a New Site (No JS Needed)

The **Auto Analyze Site** wizard lets you simply:

1. Click **Auto Analyze Site** in the main UI
2. Step 1: paste the site URL (home or search page) → **Open & analyze** → it detects the search box → **Trial search** → double-click your comic in the list
3. Step 2: **Analyze chapter list** → detects chapter links and order automatically
4. Step 3: **Open chapter 1 & analyze images** → detects image container / lazy loading
5. Step 4: enter a site name → **Generate & save adapter** → it appears in the site list immediately, usable forever

Analysis results are generated automatically by heuristics; if a site isn't recognized well, fine-tune with **New Adapter** or verify repeatedly with **Test Adapter**.
