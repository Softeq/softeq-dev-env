#include <gtest/gtest.h>

TEST(Trivial, Negative)
{
    new int[1];
    EXPECT_FALSE(false);
}

TEST(Trivial, Positive)
{
    EXPECT_TRUE(true);
}

int main(int argc, char *argv[])
{
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}