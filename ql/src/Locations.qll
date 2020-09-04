/**
 * Provides classes for working with locations and program elements that have locations.
 *
 * Stolen liberally from the Javascript QL library:
 * https://github.com/github/codeql/blob/813d14791d6bea399bc96fa9b7143603eef6e6c4/javascript/ql/src/semmle/javascript/Locations.qll
 *
 */

import ruby

/**
 * A location as given by a file, a start line, a start column,
 * an end line, and an end column.
 *
 * For more information about locations see [Locations](https://help.semmle.com/QL/learn-ql/ql/locations.html).
 */
class Location extends @location {
  /** Gets the file for this location. */
  File getFile() { locations_default(this, result, _, _, _, _) }

  /** Gets the 1-based line number (inclusive) where this location starts. */
  int getStartLine() { locations_default(this, _, result, _, _, _) }

  /** Gets the 1-based column number (inclusive) where this location starts. */
  int getStartColumn() { locations_default(this, _, _, result, _, _) }

  /** Gets the 1-based line number (inclusive) where this location ends. */
  int getEndLine() { locations_default(this, _, _, _, result, _) }

  /** Gets the 1-based column number (inclusive) where this location ends. */
  int getEndColumn() { locations_default(this, _, _, _, _, result) }

  /** Gets the number of lines covered by this location. */
  int getNumLines() { result = getEndLine() - getStartLine() + 1 }

  /** Holds if this location starts before location `that`. */
  pragma[inline]
  predicate startsBefore(Location that) {
    exists(File f, int sl1, int sc1, int sl2, int sc2 |
      locations_default(this, f, sl1, sc1, _, _) and
      locations_default(that, f, sl2, sc2, _, _)
    |
      sl1 < sl2
      or
      sl1 = sl2 and sc1 < sc2
    )
  }

  /** Holds if this location ends after location `that`. */
  pragma[inline]
  predicate endsAfter(Location that) {
    exists(File f, int el1, int ec1, int el2, int ec2 |
      locations_default(this, f, _, _, el1, ec1) and
      locations_default(that, f, _, _, el2, ec2)
    |
      el1 > el2
      or
      el1 = el2 and ec1 > ec2
    )
  }

  /**
   * Holds if this location contains location `that`, meaning that it starts
   * before and ends after it.
   */
  predicate contains(Location that) { this.startsBefore(that) and this.endsAfter(that) }

  /** Holds if this location is empty. */
  predicate isEmpty() { exists(int l, int c | locations_default(this, _, l, c, l, c - 1)) }

  /** Gets a textual representation of this element. */
  string toString() { result = this.getFile().getBaseName() + ":" + this.getStartLine().toString() }

  /**
   * Holds if this element is at the specified location.
   * The location spans column `startcolumn` of line `startline` to
   * column `endcolumn` of line `endline` in file `filepath`.
   * For more information, see
   * [Locations](https://help.semmle.com/QL/learn-ql/ql/locations.html).
   */
  predicate hasLocationInfo(
    string filepath, int startline, int startcolumn, int endline, int endcolumn
  ) {
    exists(File f |
      locations_default(this, f, startline, startcolumn, endline, endcolumn) and
      filepath = f.getAbsolutePath()
    )
  }
}

/** A program element with a location. */
class Locatable extends @locatable {
  /** Gets the file this program element comes from. */
  File getFile() { result = getLocation().getFile() }

  /** Gets this element's location. */
  Location getLocation() {
    // overridden by subclasses
    none()
  }

  /** Gets the number of lines covered by this element. */
  int getNumLines() { result = getLocation().getNumLines() }

  /** Gets a textual representation of this element. */
  string toString() {
    // to be overridden by subclasses
    none()
  }
}
