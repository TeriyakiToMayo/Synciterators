from LinkedList import LinkedList

class SynchroCacheIterator:
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
            # cache is not empty.
            return True
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
        if self._cache:
            return self._cache.head.value
        # Potentially raise StopIteration
        x = next(self._it)
        self.cache(x)
        return x

    def syncedWith(self, x, bf, cs):
        res = LinkedList()
        # traverse through nodes in cache and add to res the elements where
        # cs is true. Potentially pop out nodes where bf(y, x) and !cs(y, x)

        # begin traversal.
        prev = curr = self._cache.head
        while curr != None:
            y = curr.value
            if bf(y, x) and not cs(y, x):
                # remove curr from cache.
                if self._cache.head == curr:
                    # curr is at head of list.
                    self._cache.head = curr.next
                    prev = self._cache.head
                    curr = self._cache.head
                    continue
                curr = curr.next
                prev.next = curr
            elif not bf(y, x) and not cs(y, x):
                # Stopping condition reached.
                return res.__list__()
            else:
                # Here, cs(y,x) is true.
                res.add(y)
                prev = curr
                curr = curr.next
        # At this point, everything from cache where cs(y,x) is true
        # has been added to res. But there is more to add from self._it. 
        # Iterate through self._it until all zs have been found.
        while True:
            try:
                y = next(self._it)
            except StopIteration:
                # self._it is empty. Nothing left to do.
                return res.__list__()

            if bf(y,x) and not cs(y, x):
                # throw y away.
                continue

            # Because y cannot be thrown away, cache y.
            self.cache(y)
            if not bf(y, x) and not cs(y, x):
                # Stopping condition reached.
                return res.__list__()
            # as per usual, here cs(y,x) is true.
            res.add(y)
