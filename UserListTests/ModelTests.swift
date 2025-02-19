//
//  ModelTests.swift
//  UserListTests
//
//  Created by Julien Choromanski on 19/02/25.
//

import XCTest

@testable import UserList

final class ModelTests: XCTestCase {
    
    var modelTest: Model!

    override func setUpWithError() throws {
        super.setUp()
        modelTest = Model()
    }

    override func tearDownWithError() throws {
        modelTest = nil
        super.tearDown()
    }

    // Test du chargement initial des utilisateurs
    func testInitialFetchUsers() async throws {
        // Given
        let initialUsersCount = modelTest.users.count
        
        // When
        await modelTest.fetchUsers()
        
        // Then
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 secondes
        XCTAssertGreaterThan(modelTest.users.count, initialUsersCount)
        XCTAssertFalse(modelTest.isLoading)
    }
    
    // Test du rechargement des utilisateurs
    func testReloadUsers() async throws {
        // Given
        await modelTest.fetchUsers()
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 secondes
        let initialUsers = modelTest.users
        XCTAssertFalse(initialUsers.isEmpty, "Les utilisateurs initiaux ne devraient pas être vides")
        
        // When
        await modelTest.reloadUsers()
        
        // Then
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 secondes
        XCTAssertNotEqual(modelTest.users, initialUsers)
    }
    
    // Test de la vérification du chargement de données supplémentaires
    func testShouldLoadMoreData() async throws {
        // Given
        await modelTest.fetchUsers()
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 secondes
        
        guard let lastUser = modelTest.users.last else {
            XCTFail("La liste d'utilisateurs ne devrait pas être vide")
            return
        }
        
        // When
        let shouldLoadMore = modelTest.shouldLoadMoreData(currentItem: lastUser)
        
        // Then
        XCTAssertTrue(shouldLoadMore)
    }

}
