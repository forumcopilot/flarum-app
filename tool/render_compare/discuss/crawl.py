"""Reads discuss.flarum.org as a guest and inventories the HTML in its posts.

Writes posts.json (every post's html, with where it is) and inventory.json (each tag, tag.class,
attribute and embed host, with how many posts use it and a few examples).
"""
import collections, json, os, sys, time, urllib.parse, urllib.request
from html.parser import HTMLParser

BASE = 'https://discuss.flarum.org/api'
OUT = os.path.dirname(os.path.abspath(__file__))
UA = 'flarum-app render review (forumcopilot@gmail.com)'


def get(path, query):
    url = f'{BASE}{path}?{urllib.parse.urlencode(query)}'
    for attempt in range(3):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': UA, 'Accept': 'application/vnd.api+json'})
            with urllib.request.urlopen(req, timeout=30) as r:
                return json.load(r)
        except Exception as e:  # noqa: BLE001
            print('retry', url, e, file=sys.stderr)
            time.sleep(3)
    return None


def discussions():
    seen = {}
    for sort, pages in (('-lastPostedAt', 6), ('-commentCount', 2), ('-createdAt', 2)):
        for page in range(pages):
            doc = get('/discussions', {'sort': sort, 'page[offset]': page * 50, 'page[limit]': 50})
            time.sleep(0.5)
            if not doc:
                continue
            for d in doc['data']:
                seen.setdefault(d['id'], d['attributes'].get('title', ''))
    return seen


class Inventory(HTMLParser):
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
            host = urllib.parse.urlparse(a['src']).netloc
            self.features.add(f'<{tag}> host {host}')
        if a.get('style'):
            for prop in a['style'].split(';'):
                if ':' in prop:
                    self.features.add(f'<{tag}> style {prop.split(":")[0].strip()}')


def main():
    ds = discussions()
    print(len(ds), 'discussions', file=sys.stderr)
    posts = []
    for n, (did, title) in enumerate(ds.items()):
        doc = get('/posts', {'filter[discussion]': did, 'sort': 'number', 'page[limit]': 20})
        time.sleep(0.5)
        if not doc:
            continue
        for p in doc['data']:
            a = p['attributes']
            if a.get('contentType') != 'comment' or not a.get('contentHtml'):
                continue
            posts.append({'discussion': did, 'title': title, 'number': a.get('number'), 'id': p['id'],
                          'html': a['contentHtml']})
        if n % 25 == 0:
            print(n, len(posts), file=sys.stderr)
    json.dump(posts, open(f'{OUT}/posts.json', 'w'))
    counts = collections.Counter()
    examples = collections.defaultdict(list)
    for p in posts:
        inv = Inventory()
        inv.feed(p['html'])
        for f in inv.features:
            counts[f] += 1
            if len(examples[f]) < 4:
                examples[f].append(f"https://discuss.flarum.org/d/{p['discussion']}/{p['number']}")
    inventory = [{'feature': f, 'posts': c, 'examples': examples[f]} for f, c in counts.most_common()]
    json.dump(inventory, open(f'{OUT}/inventory.json', 'w'), indent=1)
    print(len(posts), 'posts,', len(inventory), 'features', file=sys.stderr)


main()
