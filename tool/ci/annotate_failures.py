#!/usr/bin/env python3
"""Turns a failed `flutter test` run into one annotation per failing test.

The job's log is only for the repository's admins, but annotations show on the public run page:
with these, anyone can see which test failed, where, and why. Reads the JSON that
`flutter test --file-reporter json:<file>` writes.

    python3 tool/ci/annotate_failures.py build/test-results.json
"""

import json
import os
import re
import sys


def escape(text, property=False):
    text = text.replace('%', '%25').replace('\r', '%0D').replace('\n', '%0A')
    return text.replace(':', '%3A').replace(',', '%2C') if property else text


def main(path):
    if not os.path.exists(path):
        return  # The run failed before the tests.
    suites, tests, errors, prints, failed = {}, {}, {}, {}, []
    with open(path) as results:
        for line in results:
            try:
                event = json.loads(line)
            except ValueError:
                continue
            kind = event.get('type')
            if kind == 'suite':
                suites[event['suite']['id']] = event['suite'].get('path')
            elif kind == 'testStart':
                tests[event['test']['id']] = event['test']
            elif kind == 'error':
                errors.setdefault(event['testID'], []).append(event)
            elif kind == 'print' and 'EXCEPTION CAUGHT' in event.get('message', ''):
                # A widget test's failure: the error says only "see exception logs above".
                prints.setdefault(event['testID'], []).append(event['message'])
            elif kind == 'testDone' and event.get('result') != 'success' and not event.get('hidden'):
                failed.append(event['testID'])

    root = os.environ.get('GITHUB_WORKSPACE', os.getcwd())
    for test_id in failed:
        test = tests.get(test_id, {})
        file = test.get('root_url') or test.get('url') or suites.get(test.get('suiteID')) or ''
        line = test.get('root_line') or test.get('line') or 1
        reports = prints.get(test_id, []) + [
            e.get('error', '') + '\n' + e.get('stackTrace', '')
            for e in errors.get(test_id, [])
            if not e.get('error', '').startswith('Test failed. See exception logs above.')
        ]
        # Where it failed, rather than where the test starts: the check, or the deepest test frame.
        for report in reports:
            found = re.search(r'(file://\S+_test\.dart) line (\d+)', report) or re.search(r'(file://\S+_test\.dart):(\d+)', report)
            if found:
                file, line = found.group(1), int(found.group(2))
                break
        file = os.path.relpath(file.removeprefix('file://'), root) if file else ''
        message = '\n\n'.join(
            '\n'.join(l for l in report.splitlines()[:40] if not l.startswith('\u2550')) for report in reports
        )
        print(f"::error file={escape(file, True)},line={line},title={escape(test.get('name', 'a test'), True)}::"
              f"{escape(message.strip()[:4000] or 'failed')}")

if __name__ == '__main__':
    main(sys.argv[1])
