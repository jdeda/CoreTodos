import Foundation

extension Collection {
  /// Returns a new collection with the corresponding value set to a new value.
  ///
  /// - Parameters:
  ///   - keyPath: The value to set
  ///   - newValue: The new value
  ///
  func set<T>(_ keyPath: WritableKeyPath<Element, T>, to newValue: T) -> [Self.Element] {
    return map { element in
      var copy = element
      copy[keyPath: keyPath] = newValue
      return copy
    }
  }
}
