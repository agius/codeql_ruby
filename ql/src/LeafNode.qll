/**
 * Provides classes for working with expressions.
 */

import ruby

/**
 * An leaf node
 *
 * Examples:
 *
 * ```go
 * eval
 * 1
 * ```
 */
class LeafNode extends @leaf_node {
  string getText() { leaf_nodes(this, result, _, _) }

  string toString() { result = "LeafNode" }
}
