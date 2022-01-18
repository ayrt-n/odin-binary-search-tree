# Class representation of node within balanced binary search tree
class Node
  include Comparable

  attr_reader :value
  attr_accessor :left_node, :right_node

  def initialize(value, left_node = nil, right_node = nil)
    @value = value
    @left_node = left_node
    @right_node = right_node
  end

  # Comparison operator allows for comparison of Node to integers/strings/etc.
  # BUT cannot compare the opposite way (i.e., integer to Node)

  def <=>(other)
    value <=> (other.instance_of?(Node) ? other.value : other)
  end

  # Returns true if node is a leaf node (i.e., has no children)

  def leaf_node?
    left_node.nil? && right_node.nil?
  end

  # Returns true if node has two children

  def two_child?
    !left_node.nil? && !right_node.nil?
  end

  # Returns true if node has only one child

  def one_child?
    return false if leaf_node? || two_child?
    
    true
  end

  # Returns true if node has a left child

  def has_left_child?
    !@left_node.nil?
  end

  # Returns true if node has a right child

  def has_right_child?
    !@right_node.nil?
  end
end

# Class representation of balanced binary search tree
class Tree
  def initialize(array)
    @root = build_tree(array.uniq.sort)
  end

  # Builds balanced binary search tree given sorted array of unique values

  def build_tree(sorted_array)
    return nil if sorted_array.size <= 0

    midpoint = sorted_array.size / 2
    root_node = Node.new(sorted_array[midpoint])

    root_node.left_node = build_tree(sorted_array[0, midpoint])
    root_node.right_node = build_tree(sorted_array[midpoint + 1..])
    
    root_node
  end

  # Inserts value at leaf node, if value already in tree then no changes

  def insert(new_value)
    if @root.nil?
      @root = Node.new(new_value)
    else
      prev_node = nil
      current_node = @root

      until current_node.nil?
        return if current_node == new_value

        prev_node = current_node
        current_node = current_node > new_value ? current_node.left_node : current_node.right_node
      end

      replace_child_node(prev_node, Node.new(new_value))
    end
  end

  # Implementation of #insert but using recursion

  def insert_recursively(new_value, node = @root)
    return node if node == new_value
    return Node.new(new_value) if node.nil?

    if node > new_value
      node.left_node = insert_recursively(new_value, node.left_node)
    else
      node.right_node = insert_recursively(new_value, node.right_node)
    end

    node
  end

  # Deletes value if present in tree. Implementation could be much cleaner if Node values
  # were made to be mutable. 

  def delete(value)
    prev_node = nil
    current_node = @root

    until current_node.nil? || current_node == value
      prev_node = current_node
      current_node = current_node > value ? current_node.left_node : current_node.right_node
    end

    return if current_node.nil? # Guard clause if value not found

    if current_node == @root
      delete_root
    else
      if current_node.leaf_node?
        current_node < prev_node ? (prev_node.left_node = nil) : (prev_node.right_node = nil)
      elsif current_node.one_child?
        child_node = current_node.has_left_child? ? current_node.left_node : current_node.right_node
        replace_child_node(prev_node, child_node)
      else
        inorder_successor_value = inorder_successor(current_node).value
        delete(inorder_successor_value)
        replacement_node = Node.new(inorder_successor_value, current_node.left_node, current_node.right_node)
        replace_child_node(prev_node, replacement_node)
      end
    end
  end

  # Special case for deleting root node, given there is no prev_node pointing to the root

  def delete_root
    if @root.leaf_node?
      @root = nil
    elsif @root.one_child?
      @root = @root.has_left_child? ? @root.left_node : @root.right_node
    else
      inorder_successor_value = inorder_successor(@root).value
      delete(inorder_successor_value)
      @root = Node.new(inorder_successor_value, @root.left_node, @root.right_node)
    end
  end

  # Returns node with given value, if not found will return nil

  def find(value)
    current_node = @root
    until current_node.nil? || current_node == value
      current_node = current_node > value ? current_node.left_node : current_node.right_node 
    end

    current_node
  end

  # Recursive implementation of #find

  def find_recursively(value, node = @root)
    return node if node.nil? || node == value

    if node > value
      find_recursively(value, node.left_node)
    else
      find_recursively(value, node.right_node)
    end
  end

  # Returns array of tree elements in level-order (BFS). Method can take a block in which
  # each element will be yielded to block and returned in array.

  def level_order
    queue = [@root]
    result = []

    until queue.empty?
      current_node = queue.shift # Dequeue
      queue.push(current_node.left_node) unless current_node.left_node.nil? # Enqueue children
      queue.push(current_node.right_node) unless current_node.right_node.nil? # Enqueue children

      if block_given?
        result << yield(current_node)
      else
        result << current_node.value
      end
    end

    result
  end

  # Recursive imeplementation of #level_order

  def level_order_recursively(queue = [@root], result= [], &block)
    return result if queue.empty?

    current_node = queue.shift # Dequeue
    queue.push(current_node.left_node) unless current_node.left_node.nil? # Enqueue children
    queue.push(current_node.right_node) unless current_node.right_node.nil? # Enqueue children

    if block_given?
      result << block.call(current_node)
    else
      result << current_node.value
    end

    level_order_recursively(queue, result, &block)

    result
  end

  # Returns array of tree elements in pre-order. Method can take a block in which
  # each element will be yielded to block and returned in array.

  def preorder(root_node = @root, result = [], &block)
    return if root_node.nil?

    if block_given?
      result << block.call(root_node)
    else
      result << root_node.value
    end

    preorder(root_node.left_node, result, &block)
    preorder(root_node.right_node, result, &block)

    result
  end

  # Returns array of tree elements inorder. Method can take a block in which
  # each element will be yielded to block and returned in array.

  def inorder(root_node = @root, result = [], &block)
    return if root_node.nil?

    inorder(root_node.left_node, result, &block)
    if block_given?
      result << block.call(root_node)
    else
      result << root_node.value
    end
    inorder(root_node.right_node, result, &block)

    result
  end

  # Returns array of tree elements in post-order. Method can take a block in which
  # each element will be yielded to block and returned in array.

  def postorder(root_node = @root, result = [], &block)
    return if root_node.nil?

    postorder(root_node.left_node, result, &block)
    postorder(root_node.right_node, result, &block)

    if block_given?
      result << block.call(root_node)
    else
      result << root_node.value
    end

    result
  end

  # Takes node and returns height (maximum distance (i.e., number of edges) from node to leaf node)
  # If tree does not exist, will return -1

  def height(node = @root)
    return -1 if node.nil?

    height_left = height_alt(node.left_node) + 1
    height_right = height_alt(node.right_node) + 1

    height_left > height_right ? height_left : height_right
  end

  # Takes node and returns the depth of node (distance (i.e., number of edges) from node to root node).
  # Returns -1 if node does not exist

  def depth(node)
    current_node = @root
    count = 0
    until current_node.nil? || current_node == node
      count += 1
      current_node = current_node > node ? current_node.left_node : current_node.right_node 
    end

    if current_node.nil? # Node could not be found
      return -1
    else # Node found, return the count (depth)
      count
    end
  end

  # Checks whether the binary search tree is balanced

  def balanced?
    return true if @root.nil?

    # Call height_of_all_paths on left and right subtree. Comparison of left and right subtree
    # catches edge case where either tree is completely empty
    left_sub_height = height_of_all_paths(@root.left_node).uniq
    right_sub_height = height_of_all_paths(@root.right_node).uniq
    height_array = left_sub_height + right_sub_height
    if height_array.max - height_array.min >  1
      false
    else
      true
    end
  end

  # If tree is not balanced, will rebalance the tree

  def rebalance
    return if balanced?

    @root = build_tree(inorder)
  end

  # Method provided by The Odin Project, prints BST to console
  # Added guard clause in case that the tree is empty

  def pretty_print(node = @root, prefix = '', is_left = true)
    return if node.nil? # Guard clause if tree is empty

    pretty_print(node.right_node, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right_node
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.value}"
    pretty_print(node.left_node, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left_node
  end

  private

  # Takes node and returns the height of all paths from the node
  # Used when trying to check whether tree is balanced

  def height_of_all_paths(node = @root, count = 0, result = [])
    return [0] if node.nil?
  
    count += 1
  
    if node.leaf_node?
      result << count
    else
      height_of_all_paths(node.left_node, count, result)
      height_of_all_paths(node.right_node, count, result)
    end
      
    result
  end

  # Abstraction to replace child node of parent. Checks whether right/left child and assigns Node

  def replace_child_node(parent_node, child_node)
    return if child_node == parent_node
    
    if child_node < parent_node
      parent_node.left_node = child_node
    else
      parent_node.right_node = child_node
    end
  end

  # Takes Node and returns the inorder successor (i.e., the lowest next highest value)

  def inorder_successor(starting_node)
    current_node = starting_node.right_node
    current_node = current_node.left_node until current_node.left_node.nil?

    current_node
  end
end


# Driver code

binary_search_tree = Tree.new(Array.new(15) { rand(1..100) })
binary_search_tree.pretty_print
puts ''
puts "Tree is balanced?: #{binary_search_tree.balanced?}"
puts ''
puts "Level-order: #{binary_search_tree.level_order}"
puts "Preorder: #{binary_search_tree.preorder}"
puts "Post-order: #{binary_search_tree.postorder}"
puts "Inorder: #{binary_search_tree.inorder}"
puts ''
puts 'Unbalancing tree by adding several elements >100...'
binary_search_tree.insert(rand(101..1000))
binary_search_tree.insert(rand(101..1000))
binary_search_tree.insert(rand(101..1000))
binary_search_tree.insert(rand(101..1000))
binary_search_tree.insert(rand(101..1000))
binary_search_tree.insert(rand(101..1000))
puts ''
binary_search_tree.pretty_print
puts ''
puts "Tree is balanced?: #{binary_search_tree.balanced?}"
puts ''
puts 'Rebalancing tree...'
puts ''
binary_search_tree.rebalance
binary_search_tree.pretty_print
puts ''
puts "Level-order: #{binary_search_tree.level_order}"
puts "Preorder: #{binary_search_tree.preorder}"
puts "Post-order: #{binary_search_tree.postorder}"
puts "Inorder: #{binary_search_tree.inorder}"
puts ''
puts 'Done!'
