import SwiftUI

public struct TopLevel {
    
    public enum ToastPosition{
        case top, middle, bottom
    }
    
    @ObservedObject public static var state : ToastState = ToastState()
    @ObservedObject public static var alertState : AlertState = AlertState()
    
    static var duration: Double = 1.5
    static var opacity: Double = 1.0
    static var shadow: CGFloat = 5.0
    static var position: ToastPosition = .top
    
    static var workItem: DispatchWorkItem? = nil
          
    public static func setDefaults(
        duration: Double = 1.5,
        opacity: Double = 0.8,
        shadow: CGFloat = 5.0,
        position: ToastPosition = .top
        
    ){
        TopLevel.duration = duration
        TopLevel.opacity = opacity
        TopLevel.shadow = shadow
        TopLevel.position = position
    }
       
    public static func show(image: String, text: String, duration: Double? = nil){
        
        let delay = duration ?? TopLevel.duration
        
        state.text = text
        state.image = image
        
        state.display = true
        
        workItem?.cancel()
        
        workItem = DispatchWorkItem {
            state.display = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem!)
    }
    
    public static func showAlert(
        title: String,
        message: String,
        dismissButtonText: String
    ){
        alertState.title = title
        alertState.message = message
        alertState.dismissButtonText = dismissButtonText
        
        alertState.display = true
    }
    
    public struct ToastContainerModifier: ViewModifier {
        
        @ObservedObject var state: ToastState = TopLevel.state
        @ObservedObject var alertState: AlertState = TopLevel.alertState
        @State var geo: GeometryProxy? = nil
        
        public init() {}
        
        private var screenSize: CGSize {
            return UIScreen.main.bounds.size
        }

        private var screenHeight: CGFloat {
            screenSize.height
        }
        
        public
        var yOffset: CGFloat {
            switch TopLevel.position {
            case .top:
                return -(screenHeight / 2) + (geo?.safeAreaInsets.top ?? 0.0) + 20
            case .middle:
                return 0.0
            case .bottom:
                return (screenHeight / 2) - (geo?.safeAreaInsets.bottom ?? 0.0) - 20
            }
        }
        
        public func body(content: Content) ->  some View {
            GeometryReader { localGeo in
                ZStack{
                    
                    content
                        .alert(isPresented: $alertState.display) {
                                Alert(title: Text("\(alertState.title)"),
                                      message: Text("\(alertState.message)"),
                                      dismissButton: .default(
                                        Text("\(alertState.dismissButtonText)")
                                      ))
                            }
                    
                    if state.display {
                        HStack{
                            Group {
                                
                                    Image(systemName: "\(state.image)")
                                        .padding(.leading)
                                    Text("\(state.text)")
                                        .padding()
                                
                            }
                        }
                        .background(
                            Color(
                                UIColor.tertiarySystemBackground
                            ).opacity(TopLevel.opacity)
                        )
                        .cornerRadius(100)
                        .shadow(radius: TopLevel.shadow)
                        .allowsHitTesting(false)
                        .animation(.easeInOut, value: state.display)
                        .offset(x: 0, y: yOffset)
                    }
                }
                .onAppear{
                    geo = localGeo
                }
            }
        }
    }
}

public class ToastState: ObservableObject {
    @Published var display: Bool = false
    @Published var image: String = "text.append"
    @Published var text: String = "Added to queue"
}

public class AlertState: ObservableObject {
    @Published var display: Bool = false
    @Published var title: String = ""
    @Published var message: String = ""
    @Published var dismissButtonText: String = ""
}


extension View {
    public func topLevelAlert() -> some View {
        modifier(TopLevel.ToastContainerModifier())
    }
}
