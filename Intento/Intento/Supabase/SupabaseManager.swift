import Foundation
import Supabase

enum SupabaseManager {
    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://dojwxukwugamihoidvar.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRvand4dWt3dWdhbWlob2lkdmFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzODE4NDgsImV4cCI6MjA5OTk1Nzg0OH0.sB1a37zbpKfXQZ1otYji5ypry7hStn5h8qDf-sFVMmI",
        options: SupabaseClientOptions(
            auth: SupabaseClientOptions.AuthOptions(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
}
