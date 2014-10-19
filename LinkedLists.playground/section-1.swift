// GOAL: Create a linked list with generics and implement methods to add and remove nodes.
import UIKit

class Node <T> {
    var value: T?
    var next: Node?
}

class LinkedList <T> {
    var head: Node<T>?
    
    func insert(value: T) {
            // If Linked List is empty, will create a node for the linked list.
        if head == nil {
            var node = Node<T>()
            node.value = value
            node.next = nil
            head = node
            return
        }
            //  Start at the beginning of the Linked List
        var currentNode = head
            //  If the current node is not the last Node in the linked List, move to the next node. The loop will end when the last node is selected.
        while currentNode?.next != nil {
            currentNode = currentNode?.next
        }
            //  Create a new node at the end of the Linked List
        var node = Node<T>()
        node.value = value
        node.next = nil
        currentNode?.next = node
    }
    
    func remove() {
            //  If linked list is empty, inform user that there is nothing to remove.
        if head == nil {
            println("Nothing to remove")
            return
        }
            //  If linked list only has the head, remove the head.
        if head?.next == nil {
            head = nil
            return
        }
            //  If current node is not the last node in the linked list, move to the next node. The loop will end when the last node is selected.
        var currentNode = head
        while currentNode?.next != nil {
            currentNode = currentNode?.next
        }
            //  Set the last node to nil.
        currentNode = nil
    }
}





