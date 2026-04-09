// lambda and unused args

#include <iostream>
#include <functional>

int main() {
    // Lambda takes 3 parameters (int a, int b, int c)
    // 'a' and 'b' are unused, 'c' is used.
    auto myLambda = [](int /* unused int */, int /* unused */, int c) {

        // (void)a; (void)b; // Optional: alternate approach to silence warnings
        return c * 2;
    };

    std::cout << "Result: " << myLambda(10, 20, 5) << std::endl; // Output: 10
    return 0;
}
