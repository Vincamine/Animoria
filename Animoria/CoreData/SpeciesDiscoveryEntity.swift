//
//  SpeciesDiscoveryEntity.swift
//  Animoria
//
//  Phase 2.1 - Core Data Entity for Species Discoveries
//

import Foundation
import CoreData

@objc(SpeciesDiscoveryEntity)
public class SpeciesDiscoveryEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var speciesId: String?
    @NSManaged public var discoveredAt: Date?
    @NSManaged public var photoData: Data?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SpeciesDiscoveryEntity> {
        return NSFetchRequest<SpeciesDiscoveryEntity>(entityName: "SpeciesDiscoveryEntity")
    }
}

extension SpeciesDiscoveryEntity : Identifiable {

}
