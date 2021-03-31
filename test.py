# -*- coding: utf-8 -*-
"""
Created on Thu Apr  1 04:26:31 2021

@author: Yong Qi Foo, tianz
"""
#Cython
#https://cython.readthedocs.io/en/latest/src/tutorial/cython_tutorial.html

from LinkedList import LinkedList
from CacheIterator import CacheIterator

class EIterator:
    def __init__(self, it):
        self.it = CacheIterator(it)

    def merge(self, ys, bf, cs):
        # Merge this iterator with another iterator
        for y in ys:
            # See if self is empty.
            if not self.it:
                break
            zs = self.syncedWith(y, bf, cs)
            for i in zs:
                yield (i, y)
   
    def syncedWith(self, y, bf, cs):
        # Each z in zs contain all x in self.it
        # such that cs(x, y) == True
        zs = LinkedList()
        while True:
            try:
                x = next(self.it)
            except:
                break
            if bf(x, y) and not cs(x, y):
                # Throw x away
                continue
            if not bf(x, y) and not cs(x, y):
                # Throw y away but keep x.
                self.it.cache(x)
                break
            else:
                # Here, cs(x, y) is true.
                zs.add(x)
        r = zs.__list__()
        # Cache zs in case there are future ys where
        # cs(z, y) in zs and ys is True
        self.it.prepend(zs)
        return r


mytuple = ("apple", "banana", "cherry")
myit = iter(mytuple)

myEIt = EIterator(myit)


