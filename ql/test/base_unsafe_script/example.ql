/**
 * @name Script contains anything
 * @kind problem
 * @problem.severity warning
 * @id ruby/spec/base-unsafe-script
 */

import ruby

from LeafNode n
select n.getText(), "This is a leaf node."
