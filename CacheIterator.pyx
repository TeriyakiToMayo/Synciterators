from LinkedList import LinkedList

class CacheIterator:
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
        return next(self._it)
    def __bool__(self):
        if self._cache:
            return True
        try:
            x = next(self)
            self.cache(x)
            return True
        except:
            return False
    def cache(self, item):
        # Add item to cache.
        self._cache.add(item)
    def prepend(self, ll):
        # Push ll to front of cache
        self._cache.concat_ahead(ll)


