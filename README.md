# TopLevel

Global top level alert and toasts in SwiftUI.

Key features:

- single wrapper over primary view
- global state, call from anywhere as function rather than wrapper and binding

## Usage

```swift
import TopLevel
// Use the view modifier.topLevelAlert() on your main view. 
// A good spot to put this is in your ContentView file.

// Your content goes here
ZStack{
    Color.green
        Button(action: {
            // Show a toast by calling the show function anywhere
            TopLevel.show(
                image: "airpodsmax",
                text: "Playing music"
            )
        }) {
            Text("Toggle")
        }
}
.topLevelAlert()
.onAppear{
    // You can set the defaults any time to affect every Toast
    TopLevel.setDefaults(duration: 2.0, shadow: 0.0, position: .bottom)
}
```
