#if APPLE
    Console.WriteLine("This code runs on Apple/macOS.");
#elif LINUX
    Console.WriteLine("This code runs on Linux.");
#else
    Console.WriteLine("This code runs on another platform (like Windows).");
#endif

#define DEBUG_MODE // Define locally

#if DEBUG_MODE
    #warning "Debug mode is active!"
#endif

#region Database Logic
public void Save() { 
    #pragma warning disable CS0162 // Suppress unreachable code warning
    return;
    Console.WriteLine("Done"); 
}
#endregion