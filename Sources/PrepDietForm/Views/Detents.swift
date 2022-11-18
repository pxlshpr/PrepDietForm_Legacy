import SwiftUI
import SwiftHaptics

enum TDEEFormDetentHeight {
    case empty
    case expanded
    case expanded2
    case collapsed
}

func resetTDEEFormDetents() {
    detentHeightPrimary = .collapsed
    detentHeightSecondary = .collapsed
}

var detentHeightPrimary: TDEEFormDetentHeight = .empty
var detentHeightSecondary: TDEEFormDetentHeight = .empty

struct PrimaryDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        switch detentHeightPrimary {
        case .empty:
            return 270
        case .collapsed:
            return context.maxDetentValue * 0.5
        case .expanded:
            return context.maxDetentValue
        case .expanded2:
            return context.maxDetentValue * 0.99999
        }
    }
}

struct SecondaryDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        switch detentHeightSecondary {
        case .empty:
            return 270
        case .collapsed:
            return context.maxDetentValue * 0.5
        case .expanded:
            return context.maxDetentValue
        case .expanded2:
            return context.maxDetentValue * 0.99999
        }
    }
}

extension TDEEForm {
    func toggleEditState() {
        if viewModel.isEditing {
            transitionToCollapsedState()
        } else {
            transitionToEditState()
        }
    }
    
    func transitionToCollapsedState() {
        Haptics.successFeedback()
        
        viewModel.detents = [.custom(PrimaryDetent.self), .custom(SecondaryDetent.self)]
        
        let onPrimaryDetent = viewModel.presentationDetent == .custom(PrimaryDetent.self)
        /// We could be on either detent here (expanded or expanded2—which the differences between aren't noticeable)
        if onPrimaryDetent {
            detentHeightSecondary = viewModel.shouldShowSummary ? .collapsed : .empty
        } else {
            detentHeightPrimary = viewModel.shouldShowSummary ? .collapsed : .empty
        }
        withAnimation {
            viewModel.isEditing = false
            
            /// Always go to the opposite one
            if onPrimaryDetent {
                viewModel.presentationDetent = .custom(SecondaryDetent.self)
            } else {
                viewModel.presentationDetent = .custom(PrimaryDetent.self)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if onPrimaryDetent {
                detentHeightSecondary = viewModel.shouldShowSummary ? .collapsed : .empty
                viewModel.detents = [.custom(SecondaryDetent.self)]
            } else {
                detentHeightPrimary = viewModel.shouldShowSummary ? .collapsed : .empty
                viewModel.detents = [.custom(PrimaryDetent.self)]
            }
        }
    }
    
    func transitionToEditState() {
        Haptics.feedback(style: .rigid)

        viewModel.detents = [.custom(PrimaryDetent.self), .custom(SecondaryDetent.self)]
        
        let onSecondaryDetent = viewModel.presentationDetent == .custom(SecondaryDetent.self)
        if onSecondaryDetent {
            detentHeightPrimary = .expanded
        } else {
            detentHeightSecondary = .expanded
        }
        withAnimation {
            viewModel.isEditing = true
            if onSecondaryDetent {
                viewModel.presentationDetent = .custom(PrimaryDetent.self)
            } else {
                viewModel.presentationDetent = .custom(SecondaryDetent.self)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if onSecondaryDetent {
                detentHeightSecondary = .expanded2
                viewModel.detents = [.custom(PrimaryDetent.self)]
            } else {
                detentHeightPrimary = .expanded2
                viewModel.detents = [.custom(SecondaryDetent.self)]
            }
        }
    }
}
