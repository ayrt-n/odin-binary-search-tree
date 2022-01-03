# Ruby Binary Search Tree

## Overview

Project for The Odin Project (https://www.theodinproject.com/) as part of the Fundamental Computer Science section. 

Among files, binary_search_.rb contains implementation of a binary search tree (BST) in ruby.

Implementation contains two separate classes, one class respresenting the individual nodes within the BST, and the other representing the binary search tree itself.

Tree class has a number of instance methods for creating, reading, updating, and deleting data within the BST, including:
- #build_tree
- #insert
- #delete
- #find
- #level_order, #preorder, #inorder, #postorder which accepts optional block parameter
- #height
- #depth
- #balanced?
- #rebalance

Node class has several instance methods which help to improve readability of code and abstract small requests about node properties, including:
- Custom comparable mixin (#<=>)
- #leaf_node?
- #two_child?
- #one_child?
- #has_left_child?
- #has_right_child?


