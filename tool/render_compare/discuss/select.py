"""Picks sample posts from posts.json: for each less common feature in inventory.json, the shortest
post that has it (so one screenshot shows it), plus a few chosen by hand. Writes app_samples.json
(for flarum_ui's screenshot test) and web_samples.json (for webshot.mjs), and samples.txt."""
import json, os, re, sys
from html.parser import HTMLParser

OUT = os.path.dirname(os.path.abspath(__file__))
posts = json.load(open(f'{OUT}/posts.json'))
inventory = json.load(open(f'{OUT}/inventory.json'))
extra = sys.argv[1:]  # "discussion/number" picked by hand

# Plain prose every post has: not worth a sample of their own.
COMMON = {'<p>', '<a>', '<br>', '<strong>', '<em>', '<a>[rel]', '<a>[target]', '<ul>', '<li>', '<ol>'}


class Features(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.features = set()

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        self.features.add(f'<{tag}>')
        for c in (a.get('class') or '').split():
            self.features.add(f'<{tag}>.{c}')
        for k in a:
            if k not in ('class', 'href', 'src', 'alt', 'title'):
                self.features.add(f'<{tag}>[{k}]')
        if tag in ('iframe', 'video', 'audio', 'source', 'img') and a.get('src'):
            from urllib.parse import urlparse
            self.features.add(f'<{tag}> host {urlparse(a["src"]).netloc}')


for p in posts:
    f = Features()
    f.feed(p['html'])
    p['features'] = f.features

chosen = {}
covered = set()
for item in inventory:
    feature = item['feature']
    if feature in COMMON or feature in covered or ' style ' in feature:
        continue
    # One picture host or code language draws like another: keep a few of each.
    if feature.startswith('<img> host ') and feature.split()[-1] not in (
            'img.shields.io', 'discuss.flarum.org', 'i.imgur.com', 'github.com', 'camo.githubusercontent.com'):
        continue
    if feature.startswith('<code>.language-') and feature not in ('<code>.language-bash', '<code>.language-php', '<code>.language-js'):
        continue
    having = [p for p in posts if feature in p['features']]
    if not having:
        continue
    best = min(having, key=lambda p: len(p['html']))
    key = f"{best['discussion']}/{best['number']}"
    chosen.setdefault(key, (best, set()))[1].add(feature)
    covered |= best['features']
for key in extra:
    d, n = key.split('/')
    p = next((p for p in posts if p['discussion'] == d and str(p['number']) == n), None)
    if p:
        chosen.setdefault(key, (p, set()))[1].add('picked')

app, web, lines = {}, {}, []
for i, (key, (p, features)) in enumerate(chosen.items()):
    name = f"s{i:02d}_{p['discussion']}_{p['number']}"
    app[name] = p['html']
    web[name] = {'discussion': p['discussion'], 'number': p['number']}
    lines.append(f"{name}\t{len(p['html'])}\t{', '.join(sorted(features))}\thttps://discuss.flarum.org/d/{key}")
json.dump({'discuss': {'baseUrl': 'https://discuss.flarum.org', 'samples': app}}, open(f'{OUT}/app_samples.json', 'w'), indent=1)
json.dump(web, open(f'{OUT}/web_samples.json', 'w'), indent=1)
open(f'{OUT}/samples.txt', 'w').write('\n'.join(lines) + '\n')
print(len(chosen), 'samples')
