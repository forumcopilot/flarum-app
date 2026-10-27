# Comparing the app with discuss.flarum.org

The scripts behind `docs/thread-rendering-review.md`. They read the official community as a guest,
pick a sample post for each feature its posts use, and set the app's rendering of each beside the
web's. Their outputs stay here and are git-ignored.

```bash
cd tool/render_compare/discuss
python3 crawl.py          # posts.json and inventory.json: about 375 discussions, 2 requests a second
python3 select.py 40038/4 # app_samples.json and web_samples.json; arguments add posts by hand
(cd ../../../packages/flarum_ui && RENDER_SAMPLES=$PWD/../../tool/render_compare/discuss/app_samples.json \
  flutter test --run-skipped -t render test/render/screenshots_test.dart --plain-name "screenshots discuss")
node webshot.mjs web_samples.json out body   # the web, through the installed Chrome (body or post)
python3 sheets.py         # sheets/pair_<sample>.png and sheet_NN.png
```

`select.py` needs only the standard library. `webshot.mjs` needs Node 22 or later and Google
Chrome; it drives Chrome over its DevTools protocol and downloads nothing. On the site's cookie
banner it chooses Decline. `sheets.py` needs Pillow.

The app's renders use the test environment, so emoji, CJK and a few symbols show as boxes there,
and pictures it fetches through a disk cache (SVG) may not appear. Check those on a phone.
