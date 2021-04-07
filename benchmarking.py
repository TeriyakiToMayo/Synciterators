from new_synciterators import EIterator as Better
from original_synciterators import EIterator as Worse
from random import randint
from time import time
class Interval:
    @classmethod
    def generate_intervals(cls, low, high, n, max_width):
        res = []
        existing = {}
        for _ in range(n):
            i = 0
            while True:
                x = randint(low, high - 2)
                y = randint(x + 1, min(high, x + max_width))
                if (x, y) in existing and i < 5:
                    i += 1
                    continue
                res.append(cls(x, y))
                existing[(x, y)] = True
                break
        return sorted(res)
    def __init__(self, start, end):
        if start >= end:
            raise ValueError
        self.start = start
        self.end = end
    def overlaps(self, interval):
        return self.start <= interval.start < self.end or \
            interval.start <= self.start < interval.end
    def __lt__(self, o):
        if self.start < o.start:
            return True
        if self.start > o.start:
            return False
        return self.end < o.end
    def __repr__(self):
        return f'[{self.start}, {self.end}]'

def timed(f):
    def g(*args, **kwargs):
        t = time()
        f(*args, **kwargs)
        print(f'Execution took {time() - t}s')
    return g

@timed
def merged(cls, xs, ys):
    xs = cls(xs)
    ys = cls(ys)
    return [xs.syncedWith(y) for y in ys]


bf = lambda x, y: x < y
cs = lambda x, y: x.overlaps(y)

# Test 1: 1000 intervals.
print('Testing 1000 intervals')
xs = Interval.generate_intervals(0, 5000, 1000, 1000)
ys = Interval.generate_intervals(0, 5000, 1000, 1000)
# Merging using new
print('Testing new implementation...')
new = merged(Better, xs, ys)

# Merging using old
print('Testing old implementation...')
old = merged(Worse, xs, ys)

if new == old:
    print('Output is correct.')
else:
    print('Output is incorrect!.')


print('Testing 5000 intervals')
xs = Interval.generate_intervals(0, 5000, 5000, 1000)
ys = Interval.generate_intervals(0, 5000, 5000, 1000)

# Merging using old
print('Testing old implementation...')
old = merged(Worse, xs, ys)
# Merging using new
print('Testing new implementation...')
new = merged(Better, xs, ys)

if new == old:
    print('Output is correct.')
else:
    print('Output is incorrect!.')

