// test_example.cpp
#define CATCH_CONFIG_MAIN  // This defines the main() function
#include "catch.hpp"

int add(int a, int b) {
    return a + b;
}

TEST_CASE("Addition works", "[math]") {
    REQUIRE(add(2, 2) == 4);
    REQUIRE(add(2, -1) == 1);
}