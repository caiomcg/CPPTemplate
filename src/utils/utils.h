#ifndef UTILS_UTILS_H
#define UTILS_UTILS_H

#include <ostream>
#include <type_traits>
#include <string>

namespace Utils {
    template <typename T>
    void presentArray(std::ostream& stream, const T& arr, const size_t size) {
        static_assert(std::is_array<T>::value, "Cannot display elements that are not arrays");

        stream << "[";
        for (size_t i = 0; i < size; ++i) stream << arr[i] << (i != size - 1 ? ", " : "");
        stream << "]\n";
    }
}

#endif // define UTILS_UTILS_H
