//
//  HotkeyManager.swift
//  Design Stage
//
//  Manages global keyboard shortcuts using Carbon API.
//

import Cocoa
import Carbon

class HotkeyManager {
    private var hotkeys: [UInt32: EventHotKeyRef] = [:]
    private var handlers: [UInt32: () -> Void] = [:]
    private var nextID: UInt32 = 1
    private let hotKeySignature: OSType = "htk1".fourCharCode
    
    private var eventHandler: EventHandlerRef?
    
    init() {
        installEventHandler()
    }
    
    deinit {
        unregisterAll()
        if let handler = eventHandler {
            RemoveEventHandler(handler)
        }
    }
    
    func register(keyCode: UInt32, modifiers: NSEvent.ModifierFlags, handler: @escaping () -> Void) {
        let hotkeyID = nextID
        nextID += 1
        
        var hotKeyRef: EventHotKeyRef?
        let carbonModifiers = convertToCarbonModifiers(modifiers)
        
        let status = RegisterEventHotKey(
            keyCode,
            carbonModifiers,
            EventHotKeyID(signature: hotKeySignature, id: hotkeyID),
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status == noErr, let ref = hotKeyRef {
            hotkeys[hotkeyID] = ref
            handlers[hotkeyID] = handler
        }
    }
    
    func unregisterAll() {
        for (_, hotKeyRef) in hotkeys {
            UnregisterEventHotKey(hotKeyRef)
        }
        hotkeys.removeAll()
        handlers.removeAll()
    }
    
    private func installEventHandler() {
        var eventTypes = [EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))]
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, inEvent, userData) -> OSStatus in
                guard let userData = userData else { return OSStatus(eventNotHandledErr) }
                
                let manager = Unmanaged<HotkeyManager>.fromOpaque(userData).takeUnretainedValue()
                
                var hotkeyID = EventHotKeyID()
                let status = GetEventParameter(
                    inEvent,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotkeyID
                )
                
                if status == noErr {
                    manager.handleHotkey(id: hotkeyID.id)
                }
                
                return noErr
            },
            1,
            &eventTypes,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
    }
    
    private func handleHotkey(id: UInt32) {
        DispatchQueue.main.async { [weak self] in
            self?.handlers[id]?()
        }
    }
    
    private func convertToCarbonModifiers(_ modifiers: NSEvent.ModifierFlags) -> UInt32 {
        var carbonModifiers: UInt32 = 0
        
        if modifiers.contains(.command) {
            carbonModifiers |= UInt32(cmdKey)
        }
        if modifiers.contains(.shift) {
            carbonModifiers |= UInt32(shiftKey)
        }
        if modifiers.contains(.option) {
            carbonModifiers |= UInt32(optionKey)
        }
        if modifiers.contains(.control) {
            carbonModifiers |= UInt32(controlKey)
        }
        
        return carbonModifiers
    }
}

