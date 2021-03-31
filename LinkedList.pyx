class LinkedList:
    class Node:
        def __init__(self, item):
            self.value = item
            self.next = None
   
    def __init__(self):
        self._head = None
        self._tail = None

    def add(self, item):
        # Add item to the end.
        to_insert = LinkedList.Node(item)
        if self._head == None:
            self._head = self._tail = to_insert
            return
        self._tail.next = to_insert
        self._tail = to_insert

    def pop(self):
        # Pop from front.
        item = self._head
        self._head = item.next
        return item.value

    def concat_ahead(self, ll):
        # Concatenate another linked list to
        # the front of this linked list.
        if ll:
            ll._tail.next = self._head
            self._head = ll._head
    def __bool__(self):
        return self._head != None

    def __list__(self):
        # Convert to Python list.
        res = []
        curr = self._head
        while curr != None:
            res.append(curr.value)
            curr = curr.next
        return res


