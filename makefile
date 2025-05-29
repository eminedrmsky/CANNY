# Compiler and flags
CXX := g++
NVCC := nvcc
CXXFLAGS :=  -g -pg -Wall -O2 -std=c++17

# OpenCV flags (adjust if not using pkg-config)
OPENCV_CFLAGS := $(shell pkg-config --cflags opencv4)
OPENCV_LIBS   := $(shell pkg-config --libs opencv4)

# Source folders
SRC_DIR := src
SRC_CUDA_DIR := src/cuda
INCLUDE_DIR := inc
THIRD_PARTY_DIR := inc/third_party
LOG_DIR := logs
OUTPUT_DIR := outputs
TEST_DIR := tests

# Sources and objects
SRCS := main.cpp input_image_data.cpp\
        $(wildcard $(SRC_DIR)/*.cpp) \
        $(wildcard $(LIB_DIR)/*.cpp)

SRCS_INPUT_CREATE := create_input_array.cpp \
        $(wildcard $(SRC_DIR)/*.cpp) \
        $(wildcard $(LIB_DIR)/*.cpp)

CU_SRCS := $(wildcard $(SRC_CUDA_DIR)/*.cu)

TEST_SRCS := $(wildcard $(TEST_DIR)/*.cpp)

#SRCS_NO_MAIN := input_image_data.cpp \
#        $(filter-out main.cpp, $(wildcard $(SRC_DIR)/*.cpp)) \
#        $(wildcard $(LIB_DIR)/*.cpp)

SRCS_NO_MAIN := $(filter-out main.cpp, $(wildcard $(SRC_DIR)/*.cpp)) \
        $(wildcard $(LIB_DIR)/*.cpp)

OBJS_NO_MAIN := $(SRCS_NO_MAIN:.cpp=.o)

OBJS := $(SRCS:.cpp=.o)
OBJS_INPUT_CREATE := $(SRCS_INPUT_CREATE:.cpp=.o)
CU_OBJS := $(CU_SRCS:.cu=.o)
OBJS_TEST := $(TEST_SRCS:.cpp=.o)

# Output
TARGET := build/edgeDetector
TARGET_INPUT_CREATE := build/create_array
TARGET_GPU := build/edgeDetectorGPU
TARGET_TEST := build/test_edgeDetector

# Create build dir if not exists
$(shell mkdir -p build)

# Default target
all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@ $(OPENCV_LIBS)

create-array: $(TARGET_INPUT_CREATE)

$(TARGET_INPUT_CREATE): $(OBJS_INPUT_CREATE)
	$(CXX) $(CXXFLAGS) $^ -o $@ $(OPENCV_LIBS)

gpu-detect: $(TARGET_GPU)

$(TARGET_GPU): $(OBJS) $(CU_OBJS)
	$(NVCC) $^ -o $@ $(OPENCV_LIBS) -lcudart -L/usr/local/cuda/lib64

test: $(TARGET_TEST)

$(TARGET_TEST): $(OBJS_TEST) $(OBJS_NO_MAIN) $(CU_OBJS)
	$(NVCC) $^ -o $@ $(OPENCV_LIBS) -lcudart -L/usr/local/cuda/lib64

src_cuda/%.o: src_cuda/%.cu
	$(NVCC) -c $< -o $@ -Xcompiler "-fPIC" -I$(INCLUDE_DIR)

# Compile .cpp to .o
%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(OPENCV_CFLAGS) -I$(INCLUDE_DIR) -I$(THIRD_PARTY_DIR) -c $< -o $@

# Clean build
clean:
	rm -f $(SRC_DIR)/*.o  *.o image_data.o main.o $(TARGET)
	rm -f $(SRC_DIR)/*.o  *.o  $(TARGET_INPUT_CREATE)
	rm -f $(SRC_CUDA_DIR)/*.o *.o  $(TARGET_GPU)
	rm -f $(TEST_DIR)/*.o *.o  $(TARGET_TEST)

clean-logs:
	rm -f $(LOG_DIR)/*.log

clean-outputs:
	rm -f $(OUTPUT_DIR)/*.png

.PHONY: all clean