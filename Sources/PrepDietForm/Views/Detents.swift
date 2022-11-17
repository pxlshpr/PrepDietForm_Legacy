import SwiftUI

enum TDEEFormDetentHeight {
    case empty
    case expanded
    case expanded2
    case collapsed
}

func resetTDEEFormDetents() {
    globalPrimaryDetent = .collapsed
    globalSecondaryDetent = .collapsed
}

var globalPrimaryDetent: TDEEFormDetentHeight = .empty
var globalSecondaryDetent: TDEEFormDetentHeight = .empty

struct TDEEFormPrimaryDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        switch globalPrimaryDetent {
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

struct TDEEFormSecondaryDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        switch globalSecondaryDetent {
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
