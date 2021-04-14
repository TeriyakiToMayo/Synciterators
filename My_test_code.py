# -*- coding: utf-8 -*-
"""
Created on Wed Apr  7 15:13:10 2021

@author: tianz
"""

from time import time
import random
from new_synciterators_cython import EIterator as BetterBetter
from new_synciterators import EIterator as Better
from original_synciterators import EIterator as Worse

def timed(f):
    def g(*args, **kwargs):
        t = time()
        f(*args, **kwargs)
        print(f'Execution took {time() - t}s')
    return g

def fixedGapList(low, high, gap=5):
    return list(range(low, high, gap))

def randomGapList(low, high):
    generated_list = []
    last = low
    while(True):
        increment = random.randint(1, 10)
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

