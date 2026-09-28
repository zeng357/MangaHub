# MangaNest · Chapter-List Feature Notes

This document describes the **chapter-list (checkable download)** feature added to the main program source, plus the yumanhua.com site crawler.

## 1. What Was Added

1. **Chapter list (checked download)**
   - A "Chapter list" area was added to the main UI: after typing a comic title, click **Load chapter list** — the program opens the detail page, reads the total chapter count, and shows "Chapter 1 ~ Chapter N" in a scrollable checklist, all selected by default.
   - Provides **Select All / Select None** buttons.
   - When **Start Download** is clicked, **only the checked chapters are downloaded** (non-contiguous selections are supported — the program groups them into consecutive batches automatically).
   - If no chapter list was loaded, the original "chapter range" start/end download logic is unchanged.

2. **New site: yumanhua.com**
   - New `sites_data/yumanhua_crawler.py` (class `YumanhuaCrawler`, site name "漫画客").
   - Implemented from a fresh analysis of that site: search via POST `/s`, chapter list via POST `/morechapter`, chapter pages are pull-down style with lazy loading — real URLs are read from `img` `data-src` after scrolling (real images spread across ecombdimg.com / shimolife.com CDNs with expiring signatures; CONFIG declares `image_referer=http://yumanhua.com/` so downloads carry the Referer automatically). Images are plain http(s), downloaded via HTTP (not browser rendering).
   - Note: that site and its image CDNs block non-browser requests — use headed mode (default) so images go through the browser session.

## 2. Files Changed

| File | Change |
| --- | --- |
| gui.py | New "chapter list" panel with Load / Select All / Select None; download_task prioritizes checked chapters |
| download_flow.py | New `run_download_flow_selected` (checked-chapter batched download); `_run_download_async` gained a `download_cover` parameter to avoid duplicate covers |
| sites_data/yumanhua_crawler.py | New (yumanhua site crawler) |

Existing site crawler download interfaces are unchanged; the original "chapter range" download remains compatible.

## 3. How to Rebuild Into a Runable Program

In the **MangaNest** directory (the one containing `build.bat`), **double-click `build.bat`**:
1. Automatically installs DrissionPage and PyInstaller (requires network);
2. Builds a single-file `dist\MangaNest.exe` (no console window);
3. Automatically copies sites_data, config, cookies into `dist\`.

Then double-click `dist\MangaNest.exe` to run. Keep the whole `dist\` folder (the exe must stay with sites_data).

> Note: this change was syntax/static-checked locally (21 files compiled). Because the session had no network and no browser, packaging/run verification wasn't done here; run `build.bat` on your own machine for the final build and real verification.

## 4. Verification Suggestions (run on your machine)

1. Run build.bat to package.
2. Open the exe → pick site "漫画客" → type a comic title (e.g. 道诡异仙) → click **Load chapter list** → check a few chapters → **Start Download**.
3. Confirm only the checked chapters downloaded, images complete, no failures.
