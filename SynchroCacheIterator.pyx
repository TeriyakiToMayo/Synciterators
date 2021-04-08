from LinkedList import LinkedList

__author__ = ['Wong Limsoon', 'Foo Yong Qi', 'Tian Zhen']

class SynchroCacheIterator:
    '''
    A SynchroCacheIterator is an iterator with a cache. It also
    supports iteration in synchrony via a syncedWith method.
    See https://www.comp.nus.edu.sg/~wongls/projects/intensional/synchrony
    for more information.
    '''
    def __init__(self, it):
        # Cached Iterator has the iterator and
        # a cache.
        self._it = iter(it)
        self._cache = LinkedList()

    def __iter__(self):
        return self

    def __next__(self):
        # Pop from cache, if cache is
        # empty then pop from iterator.
        if self._cache:
            return self._cache.pop()
        # Potentially raise stop iteration.
        return next(self._it)

    def __bool__(self):
        # Return True if not empty, False otherwise.
        if self._cache:
            return True

        # Try obtaining an element from the iterator.
        # If no exception happens, then cache that element
        # and return True. If a StopIteration was raised,
        # then the iterator is empty as well.
        try:
            x = next(self)
            self.cache(x)
            return True
        except:
            # StopIteration was raised by next(self).
            return False

    def cache(self, item):
        # Add item to cache.
        self._cache.add(item)

    def peek(self):
        # Peek the first element in the cache.
        if self._cache:
            return self._cache.head.value

        # Potentially raise StopIteration
        x = next(self._it)
        self.cache(x)
        return x

    def syncedWith(self, x, bf, cs):
        res = []

        # Traverse through the cache obtaining each element y,
        # doing the following:
        #   1) Removing some y from the cache and throwing it away upon
        #      antimonotonicity condition 1: i.e. bf(y, x) and !cs(y, x).
        #   2) Upon antimonotonicity condition 2: i.e. !bf(y, x) and !cs(y, x),
        #      no more traversal needs to be done, so res can be returned immediately.
        #   3) Adding y to res upon cs(y, x) without removal from the cache.

        # Begin traversal.
        prev = curr = self._cache.head
        while curr != None:
            y = curr.value
            if bf(y, x) and not cs(y, x):
                # remove curr from cache because
                # antimonotonicity condition 1 was met.
                if self._cache.head == curr:
                    # curr is at head of list.
                    self._cache.head = curr.next
                    prev = self._cache.head
                    curr = self._cache.head
                else:
                    curr = curr.next
                    prev.next = curr
            elif not bf(y, x) and not cs(y, x):
                # Stopping condition reached, i.e. antimonotonicity
                # condition 2 is met.
                return res
            else:
                # Here, cs(y,x) is true.
                res.append(y)
                prev = curr
                curr = curr.next
                
        # At this point, everything from cache where cs(y,x) is true
        # has been added to res. But there is more to add from self._it. 
        # Iterate through self._it via the same methodology as above. 
        # The only difference is, as long antimonotonicity condition 1 is
        # NOT met, then y MUST be cached.
        while True:
            try:
                y = next(self._it)
            except StopIteration:
                # self._it is empty. Nothing left to do.
                return res

            if bf(y,x) and not cs(y, x):
                # throw y away.
                continue

            # Because y cannot be thrown away, cache y.
            self.cache(y)
            if not bf(y, x) and not cs(y, x):
                # Stopping condition reached.
                return res
            # as per usual, here cs(y,x) is true.
            res.append(y)

