//
//  DrawingViewController.swift
//  Design Stage
//
//  Handles drawing input and stroke rendering.
//

import Cocoa
import QuartzCore

class DrawingViewController: NSViewController {
    private let drawingView: DrawingView
    private let fadeEngine: FadeEngine?
    private var displayLink: CVDisplayLink?
    
    var currentColor: DrawingColor = .yellow {
        didSet {
            drawingView.currentColor = currentColor
        }
    }
    
    init(fadeEngine: FadeEngine?) {
        self.fadeEngine = fadeEngine
        self.drawingView = DrawingView(fadeEngine: fadeEngine)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = drawingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startDisplayLink()
    }
    
    func clearAllStrokes() {
        drawingView.clearAllStrokes()
    }
    
    func cancelCurrentStroke() {
        drawingView.cancelCurrentStroke()
    }
    
    func setCurrentColor(_ color: DrawingColor) {
        currentColor = color
    }
    
    func setBrushWidth(_ width: CGFloat) {
        drawingView.lineWidth = width
    }
    
    private func startDisplayLink() {
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        
        if let displayLink = displayLink {
            CVDisplayLinkSetOutputCallback(displayLink, { (_, _, _, _, _, userData) -> CVReturn in
                guard let userData = userData else { return kCVReturnSuccess }
                let view = Unmanaged<DrawingView>.fromOpaque(userData).takeUnretainedValue()
                
                DispatchQueue.main.async {
                    view.needsDisplay = true
                }
                
                return kCVReturnSuccess
            }, Unmanaged.passUnretained(drawingView).toOpaque())
            
            CVDisplayLinkStart(displayLink)
        }
    }
    
    deinit {
        if let displayLink = displayLink {
            CVDisplayLinkStop(displayLink)
        }
    }
}

