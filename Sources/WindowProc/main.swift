import WinSDK

// ฟังก์ชัน WindowProc สำหรับจัดการข้อความต่าง ๆ
func WindowProc(hWnd: HWND?, message: UINT, wParam: WPARAM, lParam: LPARAM) -> LRESULT {
    switch message {
    case UINT(WM_DESTROY):
        PostQuitMessage(0)
        return 0
    case UINT(WM_COMMAND):
        let buttonID = Int(LOWORD(wParam))
        if buttonID == 1 {
            MessageBoxW(hWnd, toWideString("ปุ่มถูกคลิก!"), toWideString("ข้อมูล"), UINT(MB_OK))
        }
        return 0
    default:
        return DefWindowProcW(hWnd, message, wParam, lParam)
    }
}

// ฟังก์ชันแปลงสตริงเป็น wchar_t*
func toWideString(_ string: String) -> UnsafePointer<wchar_t> {
    let wideString = string.utf16.map { UInt16($0) } + [0]
    return wideString.withUnsafeBufferPointer { $0.baseAddress! }
}

// ฟังก์ชัน LOWORD
func LOWORD(_ value: WPARAM) -> WORD {
    return WORD(value & 0xFFFF)
}

// ฟังก์ชันแทนที่ MAKEINTRESOURCE
func makeIntResource(_ id: Int) -> UnsafePointer<wchar_t>? {
    return UnsafePointer(bitPattern: UInt(id))
}

// ฟังก์ชัน CREATE_WINDOW
func createWindow() -> HWND? {
    let className = "MyWindowClass"
    let wideClassName = toWideString(className)

    var wc = WNDCLASSW()
    wc.lpfnWndProc = WindowProc
    wc.hInstance = GetModuleHandleW(nil)
    wc.lpszClassName = wideClassName
    wc.hCursor = LoadCursorW(nil, makeIntResource(32512)) // ใช้ฟังก์ชัน makeIntResource

    let stockObject = GetStockObject(COLOR_WINDOW)
    wc.hbrBackground = unsafeBitCast(stockObject, to: HBRUSH.self)

    if RegisterClassW(&wc) == 0 {
        fatalError("Failed to register window class")
    }

    let windowName = "Hello, Windows GUI!"
    let wideWindowName = toWideString(windowName)
    return CreateWindowExW(
        0,
        wideClassName,
        wideWindowName,
        DWORD(WS_OVERLAPPEDWINDOW),
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        800,
        600,
        nil,
        nil,
        wc.hInstance,
        nil
    )
}

// ฟังก์ชัน CREATE_BUTTON
func createButton(parentWindow: HWND) -> HWND? {
    let buttonName = "Click Me!"
    let wideButtonName = toWideString(buttonName)
    return CreateWindowExW(
        0,
        toWideString("BUTTON"),  // คลาสของปุ่ม
        wideButtonName,
        DWORD(WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON),
        50,
        50,
        200,
        50,
        parentWindow,
        UnsafeMutablePointer(bitPattern: 1), // ID ของปุ่ม (ต้องใช้ HMENU)
        GetModuleHandleW(nil),
        nil
    )
}

// ฟังก์ชันหลักในการเริ่มต้นโปรแกรม
func runApp() {
    guard let hWnd = createWindow() else {
        fatalError("Failed to create window")
    }

    guard let _ = createButton(parentWindow: hWnd) else {
        fatalError("Failed to create button")
    }

    ShowWindow(hWnd, SW_SHOW)
    UpdateWindow(hWnd)

    var msg = MSG()
    while Bool(GetMessageW(&msg, nil, 0, 0)) {
        TranslateMessage(&msg)
        DispatchMessageW(&msg)
    }
}

// เริ่มโปรแกรม
runApp()
