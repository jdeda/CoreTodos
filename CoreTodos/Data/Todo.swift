import Foundation
import Tagged

struct Todo: Identifiable, Codable {
  typealias ID = Tagged<Self, UUID>
  
  let id: ID
  var description: String
  var isComplete: Bool
}
