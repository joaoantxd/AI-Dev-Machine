---
name: windows-desktop
description: Windows desktop development guidelines for WinUI 3, WPF, Electron, UI threading, and WinApp CLI.
trigger: model_decision
---

# Windows Desktop & Native UI Rules

## 1. Threading & Apartment State
- UI interactions (WPF, WinUI 3, WinForms) must execute on the dedicated STA (Single-Threaded Apartment) thread.
- Long-running operations, I/O, and hardware captures must run on background threadpools or dedicated worker threads.
- Safely marshal results back to the UI thread via `Dispatcher.InvokeAsync` or `CoreDispatcher`.

## 2. Resource Management & Native Handles
- Always wrap unmanaged handles (HWND, GDI HBITMAP, DXGI surfaces, COM pointers) in `SafeHandle` or deterministic `IDisposable` patterns.
- Ensure proper cleanup in `try/finally` or `using` blocks to prevent handle leaks.

## 3. Physical QA & WinApp CLI
- Use `winapp ui` and UI Automation (UIA) tree inspection for desktop UI element verification.
- When hardware or windowing behavior changes, provide exact manual verification steps for display monitors and input events.
