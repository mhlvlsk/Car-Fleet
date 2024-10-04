import Foundation

class Vehicle {
    var make: String
    var model: String
    var year: Int
    var capacity: Int
    var cargoTypes: [CargoType]?
    var currentLoad: Int = 0
    let fuelCapacity: Int
    var fuelConsumption: Double
    
    init(make: String, model: String, year: Int, capacity: Int, fuelCapacity: Int, fuelConsumption: Double, cargoTypes: [CargoType]? = nil) {
        self.make = make
        self.model = model
        self.year = year
        self.capacity = capacity
        self.fuelCapacity = fuelCapacity
        self.cargoTypes = cargoTypes
        self.fuelConsumption = fuelConsumption
    }
    
    func loadCargo(cargo: Cargo) {
        if let allowedTypes = cargoTypes {
            let isSupported = allowedTypes.contains(cargo.type)
            if !isSupported {
                print("Error: This vehicle does not support \(cargo.type.details) cargo.")
                return
            }
        }
        
        if currentLoad + cargo.weight > capacity {
            print("Error: Exceeds vehicle capacity!")
        } else {
            currentLoad += cargo.weight
            print("\(cargo.description) loaded into \(make) \(model).")
        }
    }
    
    func unloadCargo() {
        currentLoad = 0
        print("Unload \(make) \(model).")
    }
    
    func info() -> String {
        return "\(year) \(make) \(model) | Capacity: \(capacity)kg | Current Load: \(currentLoad)kg \nFuel Capacity: \(fuelCapacity) | Fuel Consumption: \(fuelConsumption) L/km \n"
    }
    
    func fuelCalc(path: Int) -> Bool {
            let maxDistance = (Double(fuelCapacity) / fuelConsumption) / 2
            return Double(path) <= maxDistance
        }
}

class Truck: Vehicle {
    var trailerAttached: Bool
    var trailerCapacity: Int?
    var trailerCargoTypes: [CargoType]?
    var trailerCurrentLoad: Int = 0
    
    init(make: String, model: String, year: Int, capacity: Int, trailerAttached: Bool, trailerCapacity: Int? = nil, trailerCargoTypes: [CargoType]? = nil, fuelCapacity: Int, fuelConsumption: Double, cargoTypes: [CargoType]? = nil) {
        self.trailerAttached = trailerAttached
        self.trailerCapacity = trailerCapacity
        self.trailerCargoTypes = trailerCargoTypes
        super.init(make: make, model: model, year: year, capacity: capacity, fuelCapacity: fuelCapacity, fuelConsumption: fuelConsumption, cargoTypes: cargoTypes)
    }
    
    override func loadCargo(cargo: Cargo) {
        if currentLoad + cargo.weight <= capacity {
            super.loadCargo(cargo: cargo)
            return
        }

        if trailerAttached, let trailerCapacity = trailerCapacity {
            if let allowedTrailerTypes = trailerCargoTypes {
                let isTrailerSupported = allowedTrailerTypes.contains(cargo.type)
                if !isTrailerSupported {
                    print("Error: Trailer does not support \(cargo.type.details) cargo type.")
                    return
                }
            }

            if trailerCurrentLoad + cargo.weight <= trailerCapacity {
                trailerCurrentLoad += cargo.weight
                print("\(cargo.description) loaded into trailer of \(make) \(model).")
            } else {
                print("Error: Cargo exceeds trailer capacity!")
            }
        } else {
            print("Error: No trailer attached or incompatible cargo for trailer.")
        }
    }
    
    func unloadTrailer() {
        trailerCurrentLoad = 0
        print("Trailer unloaded for \(make) \(model).")
    }
}


struct Cargo {
    var description: String
    var weight: Int
    var type: CargoType
    
    init?(description: String, weight: Int, type: CargoType) {
        if weight < 0 {
            return nil
        }
        self.description = description
        self.weight = weight
        self.type = type
    }
}

enum CargoType: Equatable {
    case fragile(cargoFixation: Bool = false)
    case perishable(temp: Int)
    case bulk(inContainer: Bool = false)
    
    var details: String {
        switch self {
        case .fragile(let description):
            if (description) {
                return "Fragile cargo is fixed"
            }
            else {
                return "Fragiel cargo is not fixed"
            }
        case .perishable(let temp):
            return "Perishable, requires temperature: \(temp)°C"
        case .bulk(let description):
            if (description) {
                return "Bulk cargo in container"
            }
            else {
                return "Bulk cargo is not in container"
            }
        }
    }
}

class Fleet {
    private var vehicles: [Vehicle] = []
    
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
    }
    
    func totalCapacity() -> Int {
        return vehicles.reduce(0) { $0 + $1.capacity }
    }
    
    func totalCurrentLoad() -> Int {
        return vehicles.reduce(0) { $0 + $1.currentLoad }
    }
    
    func info() {
        print("Fleet Summary:")
        vehicles.forEach { print($0.info()) }
        print("Total Fleet Capacity: \(totalCapacity()) kg")
        print("Total Current Load: \(totalCurrentLoad()) kg")
    }
    
    func canGo(cargo: [Cargo], path: Int) -> Bool {
            var totalWeight = 0
            
            for elem in cargo {
                totalWeight += elem.weight
            }
            
            if totalWeight > totalCapacity() {
                print("Error: The total weight is more than fleet load capacity.")
                return false
            }

            for vehicle in vehicles {
                if !vehicle.fuelCalc(path: path) {
                    print("\(vehicle.make) \(vehicle.model) can not go, fuel capacity less than needed.")
                    return false
                }
            }

            print("The fleet can deliver the cargo, distance is \(path) km.")
            return true
        }
}
let fleet = Fleet()

guard let cargo1 = Cargo(description: "Vases", weight: 400, type: .fragile(cargoFixation: true)) else { fatalError("Cargo1 creation failed") }
guard let cargo2 = Cargo(description: "Medicines", weight: 430, type: .perishable(temp: -5)) else { fatalError("Cargo2 creation failed") }
guard let cargo3 = Cargo(description: "Rice", weight: 1000, type: .bulk(inContainer: true)) else { fatalError("Cargo3 creation failed") }

let vehicle1 = Vehicle(make: "Lada", model: "Largus", year: 2015, capacity: 490, fuelCapacity: 80, fuelConsumption: 0.1, cargoTypes: [.fragile(cargoFixation: true), .perishable(temp: 25)])
let vehicle2 = Vehicle(make: "Toyota", model: "Probox", year: 2023, capacity: 450, fuelCapacity: 70, fuelConsumption: 0.1, cargoTypes: [.perishable(temp: -5)])
let truck1 = Truck(make: "KAMAZ", model: "6520", year: 2020, capacity: 8000, trailerAttached: true, trailerCapacity: 11000, fuelCapacity: 350, fuelConsumption: 0.2, cargoTypes: [.perishable(temp: 25), .bulk(inContainer: true)])

fleet.addVehicle(vehicle1)
fleet.addVehicle(truck1)
fleet.addVehicle(vehicle2)

vehicle1.loadCargo(cargo: cargo1)
truck1.loadCargo(cargo: cargo3)
vehicle2.loadCargo(cargo: cargo2)

fleet.info()

let distance = 330

let canTransport = fleet.canGo(cargo: [cargo1, cargo2, cargo3], path: distance)
if !canTransport {
 print("The fleet can not transport the cargo.")
}
