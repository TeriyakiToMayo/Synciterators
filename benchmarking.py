from new_synciterators_cython import EIterator as BetterBetter
from new_synciterators import EIterator as Better
from original_synciterators import EIterator as Worse
from random import randint
from time import time



#===============================================
# Utilities
#===============================================
def timed(f):
    def g(*args, **kwargs):
        t = time()
        f(*args, **kwargs)
        print(f'Execution took {time() - t}s')
    return g



#===============================================
# Intersections
#===============================================

def fixedGapList(low, high, gap=5):
    return list(range(low, high, gap))

def randomGapList(low, high):
    generated_list = []
    last = low
    while(True):
        increment = randint(1, 10)
        if last + increment > high: break
        last += increment
        generated_list.append(last)
    return generated_list

@timed
def intersection(cls, xs, ys, rounds=1):
    
    _Yprime = cls(ys)
    bf = (lambda y, x : y < x)
    cs = (lambda y, x: y == x)
    
    for i in range(rounds):
        [_Yprime.syncedWith(x, bf, cs) for x in xs]
        
    

print("Testing Intersection 10^6*15 Fixed Gap")
xs = fixedGapList(0, 1000000)
ys = fixedGapList(0, 1000000, 1)
rounds = 15
print('Testing new with Cython implementation...')
intersection(BetterBetter, xs, ys, rounds)
print('Testing new implementation...')
intersection(Better, xs, ys, rounds)
print('Testing old implementation...')
intersection(Worse, xs, ys, rounds)


print("Testing Intersection 10^6*30 Fixed Gap")
xs = fixedGapList(0, 1000000)
ys = fixedGapList(0, 1000000, 1)
rounds = 30
print('Testing new with Cython implementation...')
intersection(BetterBetter, xs, ys, rounds)
print('Testing new implementation...')
intersection(Better, xs, ys, rounds)
print('Testing old implementation...')
intersection(Worse, xs, ys, rounds)


print("Testing Intersection 10^6*15 Random Gap")
xs = randomGapList(0, 1000000)
ys = randomGapList(0, 1000000)
rounds = 15
print('Testing new with Cython implementation...')
intersection(BetterBetter, xs, ys, rounds)
print('Testing new implementation...')
intersection(Better, xs, ys, rounds)
print('Testing old implementation...')
intersection(Worse, xs, ys, rounds)


print("Testing Intersection 10^6*30 Random Gap")
xs = randomGapList(0, 1000000)
ys = randomGapList(0, 1000000)
rounds = 30
print('Testing new with Cython implementation...')
intersection(BetterBetter, xs, ys, rounds)
print('Testing new implementation...')
intersection(Better, xs, ys, rounds)
print('Testing old implementation...')
intersection(Worse, xs, ys, rounds)




#===============================================
# Interval Merge
#===============================================
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
# Merging using new with cython
print('Testing new with Cython implementation...')
new = merged(BetterBetter, xs, ys)
# Merging using new
print('Testing new implementation...')
old = merged(Better, xs, ys)
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
# Merging using new with cython
print('Testing new with Cython implementation...')
new = merged(BetterBetter, xs, ys)
# Merging using new
print('Testing new implementation...')
old = merged(Better, xs, ys)
# Merging using old
print('Testing old implementation...')
# old = merged(Worse, xs, ys)

if new == old:
    print('Output is correct.')
else:
    print('Output is incorrect!.')




