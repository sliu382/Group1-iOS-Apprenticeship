// CURA

// A modern, privacy‑minded cosmetic planning and beauty routine companion. CURA helps you track products on your shelf, build routines, and plan appointments and reminders — all with a calm, elegant SwiftUI design.

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Welcome to CURA")
            .font(.appSans(.title))
            .foregroundColor(AppColor.primary)
            .padding()
            .background(AppBackground.material)
    }
}

// MARK: - AppColor

enum AppColor {
    static let primary = Color("PrimaryColor")
    static let secondary = Color("SecondaryColor")
    static let accent = Color("AccentColor")
    static let background = Color("BackgroundColor")
}

// MARK: - AppBackground

enum AppBackground {
    static let material = Color(UIColor.systemBackground)
}

// MARK: - Font Helpers

extension Font {
    static func appSans(_ style: TextStyle) -> Font {
        Font.system(style, design: .rounded)
    }

    static func appSerif(_ style: TextStyle) -> Font {
        Font.system(style, design: .serif)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
## Screenshots

Below are empty placeholders you can replace with your own images. Put your PNG/JPG files in `Docs/Images` and keep the same filenames (or update the paths here).

### Login
![Login](Docs/Images/login.png)

### Sign Up
![Sign Up](Docs/Images/signup.png)

### Profile Overview
![Profile Overview](Docs/Images/profile-overview.png)

### Shelf
![Shelf](Docs/Images/shelf.png)

### Add to Calendar
![Add to Calendar](Docs/Images/add-to-calendar.png)

### Change Password
![Change Password](Docs/Images/change-password.png)

## Demo video

Pick one of the following options and replace the placeholders:

- Local file in repo (simple):
  [Watch the demo](Docs/Videos/demo.mp4)

- Hosted (YouTube/Vimeo) with a clickable thumbnail:
  [![Watch the demo](Docs/Images/demo-thumb.png)](https://youtu.be/REPLACE_ME)

- Animated GIF (short loop):
  ![Demo GIF](Docs/Images/demo.gif)

## Where to put images and video

Create a `Docs` folder with `Images` and `Videos` subfolders. Example:


