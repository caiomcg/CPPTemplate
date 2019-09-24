#include <iostream>
#include "utils/utils.h"

int main() {
    int arr_of_int[] = {1, 2, 3, 4};
    std::string arr_of_string[] = {"This", "is", "an", "example"};

    Utils::presentArray(std::cout, arr_of_int, 4);
    Utils::presentArray(std::cout, arr_of_string, 4);

    return 0;
}
