//
//  FirestorePortfolioService.swift
//  InvestMind
//
// ВАЖНО: добавьте в таргет два фреймворка из уже подключённого пакета firebase-ios-sdk:
//   Project → App Target → Frameworks, Libraries... → + → FirebaseFirestore + FirebaseFirestoreSwift
//
// Также включите Cloud Firestore в Firebase Console для вашего проекта.
//
// Правила безопасности (Firestore → Rules):
//   rules_version = '2';
//   service cloud.firestore {
//     match /databases/{database}/documents {
//       match /users/{userId}/{document=**} {
//         allow read, write: if request.auth != null && request.auth.uid == userId;
//       }
//     }
//   }
//

import Foundation
import FirebaseFirestore

final class FirestorePortfolioService {

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private func ref(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("portfolios")
    }

    // Realtime-подписка на коллекцию портфелей пользователя.
    func startListening(uid: String, onChange: @escaping ([PersistedPortfolio]) -> Void) {
        listener?.remove()
        listener = ref(uid: uid).addSnapshotListener { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            let portfolios = docs.compactMap { try? $0.data(as: PersistedPortfolio.self) }
            onChange(portfolios)
        }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // Полностью перезаписывает документ портфеля.
    func save(_ portfolio: PersistedPortfolio, uid: String) async throws {
        let docRef = ref(uid: uid).document(portfolio.id.uuidString)
        try docRef.setData(from: portfolio)
    }

    func delete(portfolioId: UUID, uid: String) async throws {
        try await ref(uid: uid).document(portfolioId.uuidString).delete()
    }
}
