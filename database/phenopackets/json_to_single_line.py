import json
import sys

with open(sys.argv[1]) as handle:
    data = json.load(handle)

text = json.dumps(data, separators=(',', ':'))
print(text)