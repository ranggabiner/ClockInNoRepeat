import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var prayerTime: String = "Loading..."

    var body: some View {
        VStack {
            Text("Next Prayer Time: \(prayerTime)")
                .padding()
            Button("Request Permission") {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
            Button("Schedule Notification") {
                scheduleNotificationForNextPrayer()
            }
            Button("Cancel Notifications") {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                print("All notifications cancelled!")
            }
            NextPrayerTimeView(prayerTime: $prayerTime)
        }
        .padding()
    }

    func scheduleNotificationForNextPrayer() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let notificationTime = formatter.date(from: prayerTime) else {
            print("Failed to parse time string.")
            return
        }

        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: notificationTime)

        guard let scheduledTime = calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime) else {
            print("Could not calculate next prayer time.")
            return
        }

        if scheduledTime <= now {
            print("Scheduled time must be in the future.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Peringatan Sholat"
        content.subtitle = "Anda belum Sholat"
        content.sound = UNNotificationSound.default

        let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.hour, .minute], from: scheduledTime), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(prayerTime)!")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
