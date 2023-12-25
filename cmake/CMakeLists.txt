cmake_minimum_required( VERSION 3.10 FATAL_ERROR )

set( PNAME casetrack )

project( ${PNAME}
         VERSION 1.0
         DESCRIPTION "Tracking Cases"
         LANGUAGES CXX )

set( CMAKE_CXX_STANDARD 20 )
set( CMAKE_CXX_STANDARD_REQUIRED ON )
# -> Alternative for a certain target: target_compile_features(myApp PRIVATE cxx_std_20)

file( GLOB_RECURSE SOURCE_FILES "src/*.cpp" )

add_executable( ${PNAME} ${SOURCE_FILES} )

# sets compiler option -D:
# target_compile_definitions(myApp PRIVATE VAR=<val>)

# set compiler flags
target_compile_options( ${PNAME} PRIVATE -Wall -Wextra -Wpedantic )

option( DBG "Compile in debug mode" OFF )

if(NOT DBG STREQUAL "ON" AND NOT DBG STREQUAL "OFF")
   message(FATAL_ERROR "Invalid value for DBG. Use ON or OFF.")
endif()

if( DBG )
   message("Build in Debug-Mode")
   set( CMAKE_BUILD_TYPE debug )
else()
   message("Build in Release-Mode")
   set( CMAKE_BUILD_TYPE release  )
endif()

# example append to compiler flags
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D DIMENSION=${DIM} -D AXISYMMETRY=${AXISYMM}")