
#
# Synchrony iterators in Python
#
# Wong Limsoon
# 2 November 2010
#

"""
This is a simplified implementation of Synchrony iterators.
Synchrony iterators make it possible to define efficient
synchronized iterators on multiple collections---in particular,
merge join-like algorithms---using only comprehension syntax and
functions in Scala's collection-type function libraries, without
using other higher-order features (recursion, while-loops,
high-order functions, nested collections, etc.)

See https://www.comp.nus.edu.sg/~wongls/projects/intensional/synchrony
for more information.
"""



from collections import deque
from SynchroCacheIterator import SynchroCacheIterator
# from more_itertools import peekable
import heapq
import itertools


class EIterator:

    """EIterator implements Synchrony iterators. It extends iterators
       with a syncedWith() method which provides synchronized iteration.

       A Synchrony iterator on two collections (X, Y) is defined based
       on two predicates, viz. isBefore (bf) and canSee (cs), as follows:
   
       Let (X, Y) be two collections we want to iterate on in synchrony.
       Let (x << x'|X) denote x appears before x' in the collection X.
       Let (y << y'|Y) denote y appears before y' in the collection Y.
    
       Then bf is required to be monotonic wrt (X,Y) in the following sense:
       (1) If (x << x'|X), then for all y in Y: bf(y,x) => bf(y,x')
       (2) If (y' << y|Y), then for all x in X: bf(y,x) => bf(y',x)
    
       And cs is required to be antimonotonic wrt bf in the following sense:
       (1) If (x << x'|X), then for all y in Y: bf(y,x) & !cs(y,x) => !cs(y,x')
       (2) If (y << y'|Y), then for all x in X: !bf(y,x) & !cs(y,x) => !cs(y',x)
    
       Let a = EIterator(Y) and b1, b2, ..., bn = X. Suppose also that
       bf is monotonic wrt (X, Y) and cs is antimonotic wrt bf.
       Then a.syncedWith(bi, bf, cs) = [y for y in X if cs(y, bi)],
       provided a.syncedWith(bi, bf, cs) is invoked on b1, b2, ..., bn
       in the same order as b1, b2, ..., bn in X.

       See https://www.comp.nus.edu.sg/~wongls/projects/intensional/synchrony
       for more information.
    """
 
    def __init__(self, vec, close = lambda: ()): 

       """ Make Synchrony iterator (EIterator) buffered and closeable."""
 
       self.__myIter = SynchroCacheIterator(vec)
       self.__myClose = close

    def __iter__(self): 

        """ Make Synchrony iterator a Python-style iterator."""

        return self

    def __next__(self): 

        """ Make Synchrony iterator a Python-style iterator."""

        return self.next()

    def hasNext(self):

        """ Make Synchrony iterator a Scala-style iterator. """

        return bool(self.__myIter)

    def next(self): 

        """ Make Synchrony iterator a Scala-style iterator, and 
            also close itself at end of iteration.
        """

        if self.hasNext():
            return next(self.__myIter)
        else:
            self.close()
            raise StopIteration

    def close(self):

        """ Close this Synchrony iterator (EIterator); 
            i.e. close the underlying file, if it is iterating on a file.
        """

        self.__myClose()

    '''
    Probably don't need these anymore.
    def lookahead(self, n = 1):

        """ Extract an initial slice from this Synchrony iterator,
            w/o removing any item.
        """

        return self.__myIter[: n]

    def peekahead(self, n = 1):

        """ Extract an item from this Synchrony iterator, w/o removing it. """

        try:
            tmp = [self.__myIter[n - 1]]
        except:
            self.close()
            tmp = []
        return tmp

    def prepend(self, vec):

        """ Insert a list (vec) at the front of this Synchrony iterator. """

        self.__myIter.prepend(*vec)
    '''
    
    def peek(self):
        try:
            tmp = [self.__myIter.peek()]
        except:
            self.close()
            tmp = []
        return tmp

#
# TODO - WLS, 2 Nov 2020: 
# A more efficient version should simply add vec as an 
# element # to __myIter, rather than unpacking it in prepend.
# Then the other methods (next, lookahead, # peekahead, etc.)
# should dynamically extracts from vec.
# 

    def syncedWith(
      self, 
      x, 
      isBefore = lambda y, x: y < x, 
      canSee = lambda y, x: True
    ):

        """ Synchronize iteration. """
        zs = self.__myIter.syncedWith(x, isBefore, canSee)
        if not self.hasNext(): self.close()
        return zs
     
    def filter(self, check):
        
        """ Use the check function to filter this EIterator. """

        return EIterator((x for x in self if check(x)), lambda: self.close())

    def map(self, f):

        """ Apply f to each object in this EIterator.
        #
        # f: A -> B.
        """

        return EIterator((f(x) for x in self), lambda: self.close())

    def flatmap(self, f):

        """ Apply f to each object in this EIterator, and flatten the result
        #
        # f: A -> list(B); 
        #   i.e. f outputs a result which is a list of objects of type B.
        #   The returned eiterator iterates over all these lists, like
        #   one single flattened list.
        """

        return EIterator((y for x in self for y in f(x)), lambda: self.close())

    def distinct(self):

        """ Remove consecutive duplicates """

        eit = ( e for e in self if [e] != self.peek() )
        return EIterator(eit, lambda: eit.close())
                 
        

class SynchroEIterator:
    def __init__(self, isBefore, canSee, lmtrack, extrack,
                 screen    = lambda y, x: True,
                 grpscreen = lambda x, ys: True):
        self.isBefore = isBefore
        self.canSee   = canSee
        self.extrack  = extrack
        self.lmtrack  = lmtrack
        self.screen   = screen
        self.grpscreen= grpscreen

    def map(self, iter):
        lmIt = self.lmtrack.eiterator()
        exIt = self.extrack.eiterator() 
        tr   = ( iter(x, ys)
                   for x in lmIt
                     for es in [ exIt.syncedWith(x, self.isBefore, self.canSee)]
                       for ys in [[ y for y in es if self.screen(y, x)]]
                         if self.grpscreen(x, ys) )
        return EIterator(tr, lambda: (lmIt.close(), exIt.close()))  

    def ext(self, iter):
        lmIt = self.lmtrack.eiterator()
        exIt = self.extrack.eiterator() 
        tr   = ( e
                   for x in lmIt
                     for es in [ exIt.syncedWith(x, self.isBefore, self.canSee)]
                       for ys in [[ y for y in es if self.screen(y, x)]]
                         if self.grpscreen(x, ys)
                           for e in iter(x, ys) )
        return EIterator(tr, lambda: (lmIt.close(), exIt.close()))  




