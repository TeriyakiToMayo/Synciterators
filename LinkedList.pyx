class LinkedList:
    class Node:
        def __init__(self, item):
            self.value = item
            self.next = None
   
    def __init__(self):
        self.head = None
        self.tail = None

    def add(self, item):
        # Add item to the end.
        to_insert = LinkedList.Node(item)
        if self.head == None:
            self.head = self.tail = to_insert
            return
        self.tail.next = to_insert
        self.tail = to_insert

    def pop(self):
        # Pop from front.
        item = self.head
        self.head = item.next
        if self.head == None:
            self.tail = None
        return item.value

    def __bool__(self):
        return self.head != None

    def __list__(self):
        # Convert to Python list.
        res = []
        curr = self.head
        while curr != None:
            res.append(curr.value)
            curr = curr.next
        return res



