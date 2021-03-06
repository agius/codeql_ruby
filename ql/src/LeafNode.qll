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
class LeafNode extends @leaf_node, Locatable {
  string getText() { leaf_nodes(this, result, _, _) }

  override Location getLocation() { has_location(this, result) }

  override string toString() { result = "LeafNode" }
}
