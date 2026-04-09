string name = "Alice";
int items = 5;

// Using C# 11 Raw String Literals with interpolation
string message = $"""
    Hello {name},
    You have {items / 1} new messages in your "Inbox".
    Thanks!
    """;

Console.WriteLine(message);