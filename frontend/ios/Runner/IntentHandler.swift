import Intents

@available(iOS 14.0, *)
class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // Handle Siri Shortcuts for expense entry
        if intent is INAddExpenseIntent {
            return AddExpenseIntentHandler()
        }
        return self
    }
}

@available(iOS 14.0, *)
class AddExpenseIntentHandler: NSObject, INAddExpenseIntentHandling {
    
    func handle(intent: INAddExpenseIntent, completion: @escaping (INAddExpenseIntentResponse) -> Void) {
        // Process expense intent
        // This would communicate with Flutter via platform channels
        let response = INAddExpenseIntentResponse(code: .success, userActivity: nil)
        completion(response)
    }
}
